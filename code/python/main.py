import time
from datetime import date

import psycopg2

from unit_of_work import UnitOfWork

ADMIN_ID = 1  # користувач admin з 07_data.sql


def print_rows(title, rows):
    print(f"\n--- {title} ---")
    if not rows:
        print("(порожньо)")
    for row in rows:
        print(dict(row))


# успішна транзакція
def scenario_success():
    print("\n===== 1. Успішна транзакція =====")
    email = f"demo{int(time.time())}@univ.ua"

    with UnitOfWork(user_id=ADMIN_ID) as uow:
        student_id = uow.students.add("Демо", "Студент", email, date(2004, 1, 15), 1)
        uow.grades.add(student_id, 1, 1, 88, date.today())
        uow.grades.add(student_id, 2, 1, 92, date.today())
        uow.commit()

    with UnitOfWork(user_id=ADMIN_ID) as uow:
        print_rows("Студент (view v_active_students)", [uow.students.get_by_id(student_id)])
        print_rows("Оцінки (view v_student_grades)", uow.grades.get_by_student(student_id))

    return student_id


# помилка і rollback
def scenario_rollback():
    print("\n===== 2. Помилка і rollback =====")
    try:
        with UnitOfWork(user_id=ADMIN_ID) as uow:
            uow.students.add("Тест", "Відкат", "rollback@univ.ua", date(2004, 3, 3), 1)
            uow.grades.add(1, 1, 1, 150, date.today())
            uow.commit()
    except psycopg2.Error as e:
        print("Помилка:", str(e).strip().splitlines()[0])

    with UnitOfWork(user_id=ADMIN_ID) as uow:
        found = [s for s in uow.students.get_all(limit=2000)
                 if s["email"] == "rollback@univ.ua"]
        print_rows("Чи є студент 'Відкат' у базі (має бути порожньо)", found)


# зміна оцінки і soft delete
def scenario_update_delete(student_id):
    print("\n===== 3. Зміна оцінки та soft delete =====")
    with UnitOfWork(user_id=2) as uow:  # зміни від імені teacher1 (id = 2)
        grades = uow.grades.get_by_student(student_id)
        uow.grades.update(grades[0]["id"], 99)
        uow.commit()

    with UnitOfWork(user_id=ADMIN_ID) as uow:
        print_rows("Оцінки після зміни (updated_by_login = teacher1)",
                   uow.grades.get_by_student(student_id))
        uow.students.delete(student_id)
        uow.commit()

    with UnitOfWork(user_id=ADMIN_ID) as uow:
        print_rows("Студент після soft delete (має бути порожньо)",
                   [uow.students.get_by_id(student_id)] if uow.students.get_by_id(student_id) else [])


# групи і розклад
def scenario_read():
    print("\n===== 4. Групи та розклад =====")
    with UnitOfWork(user_id=ADMIN_ID) as uow:
        print_rows("Групи (view v_active_groups)", uow.groups.get_all())
        print_rows("Розклад групи 1 (view v_group_schedule)", uow.schedule.get_by_group(1))


if __name__ == "__main__":
    new_student_id = scenario_success()
    scenario_rollback()
    scenario_update_delete(new_student_id)
    scenario_read()

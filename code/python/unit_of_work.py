from db import get_connection
from repositories.student_repository import StudentRepository
from repositories.group_repository import GroupRepository
from repositories.grade_repository import GradeRepository
from repositories.schedule_repository import ScheduleRepository


class UnitOfWork:

    def __init__(self, user_id):
        self.user_id = user_id

    def __enter__(self):
        self.connection = get_connection()
        self.cursor = self.connection.cursor()

        # id користувача для updated_by
        self.cursor.execute(
            "SELECT set_config('app.user_id', %s, FALSE)", (str(self.user_id),)
        )

        self.students = StudentRepository(self.cursor)
        self.groups = GroupRepository(self.cursor)
        self.grades = GradeRepository(self.cursor)
        self.schedule = ScheduleRepository(self.cursor)
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        # при помилці скасовуємо транзакцію
        if exc_type is not None:
            self.connection.rollback()
        self.cursor.close()
        self.connection.close()
        return False

    def commit(self):
        self.connection.commit()

    def rollback(self):
        self.connection.rollback()

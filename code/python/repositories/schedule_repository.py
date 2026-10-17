class ScheduleRepository:
    def __init__(self, cursor):
        self.cursor = cursor

    def get_by_group(self, group_id):
        self.cursor.execute(
            "SELECT * FROM v_group_schedule WHERE group_id = %s "
            "ORDER BY day_of_week, lesson_number",
            (group_id,),
        )
        return self.cursor.fetchall()

    def add(self, group_id, subject_id, teacher_id, classroom_id,
            lesson_type_id, semester_id, day_of_week, lesson_number):
        self.cursor.execute(
            "CALL sp_add_schedule_item(%s, %s, %s, %s, %s, %s, %s, %s, NULL)",
            (group_id, subject_id, teacher_id, classroom_id,
             lesson_type_id, semester_id, day_of_week, lesson_number),
        )
        return self.cursor.fetchone()["p_id"]

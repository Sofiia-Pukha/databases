class GradeRepository:
    def __init__(self, cursor):
        self.cursor = cursor

    def get_by_student(self, student_id):
        self.cursor.execute(
            "SELECT * FROM v_student_grades WHERE student_id = %s ORDER BY id",
            (student_id,),
        )
        return self.cursor.fetchall()

    def add(self, student_id, subject_id, semester_id, grade, grade_date):
        self.cursor.execute(
            "CALL sp_add_grade(%s, %s, %s, %s, %s, NULL)",
            (student_id, subject_id, semester_id, grade, grade_date),
        )
        return self.cursor.fetchone()["p_id"]

    def update(self, grade_id, grade):
        self.cursor.execute("CALL sp_update_grade(%s, %s)", (grade_id, grade))

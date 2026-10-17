class StudentRepository:
    def __init__(self, cursor):
        self.cursor = cursor

    def get_all(self, limit=50):
        self.cursor.execute(
            "SELECT * FROM v_active_students ORDER BY id LIMIT %s", (limit,)
        )
        return self.cursor.fetchall()

    def get_by_id(self, student_id):
        self.cursor.execute(
            "SELECT * FROM v_active_students WHERE id = %s", (student_id,)
        )
        return self.cursor.fetchone()

    def get_by_group(self, group_id):
        self.cursor.execute(
            "SELECT * FROM v_active_students WHERE group_id = %s ORDER BY last_name",
            (group_id,),
        )
        return self.cursor.fetchall()

    def add(self, first_name, last_name, email, birth_date, group_id):
        self.cursor.execute(
            "CALL sp_add_student(%s, %s, %s, %s, %s, NULL)",
            (first_name, last_name, email, birth_date, group_id),
        )
        return self.cursor.fetchone()["p_id"]

    def update(self, student_id, first_name, last_name, email, birth_date, group_id):
        self.cursor.execute(
            "CALL sp_update_student(%s, %s, %s, %s, %s, %s)",
            (student_id, first_name, last_name, email, birth_date, group_id),
        )

    def delete(self, student_id):
        self.cursor.execute("CALL sp_delete_student(%s)", (student_id,))

class GroupRepository:
    def __init__(self, cursor):
        self.cursor = cursor

    def get_all(self):
        self.cursor.execute("SELECT * FROM v_active_groups ORDER BY id")
        return self.cursor.fetchall()

    def get_by_id(self, group_id):
        self.cursor.execute(
            "SELECT * FROM v_active_groups WHERE id = %s", (group_id,)
        )
        return self.cursor.fetchone()

    def delete(self, group_id):
        self.cursor.execute("CALL sp_delete_group(%s)", (group_id,))

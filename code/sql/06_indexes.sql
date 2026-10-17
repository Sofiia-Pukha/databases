DROP INDEX IF EXISTS idx_students_last_name;
-- b-tree
CREATE INDEX idx_students_last_name
    ON students USING btree (last_name);

DROP INDEX IF EXISTS idx_grades_student_id;
-- hash
CREATE INDEX idx_grades_student_id
    ON grades USING hash (student_id);

DROP INDEX IF EXISTS idx_students_active_group;
-- частковий індекс
CREATE INDEX idx_students_active_group
    ON students (group_id)
    WHERE is_deleted = FALSE;

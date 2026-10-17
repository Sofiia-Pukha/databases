-- середній бал студента
CREATE OR REPLACE FUNCTION fn_get_student_avg(p_student_id INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE(
        (SELECT ROUND(AVG(grade), 2)
         FROM grades
         WHERE student_id = p_student_id),
        0
    );
END;
$$ LANGUAGE plpgsql;

-- кількість студентів у групі
CREATE OR REPLACE FUNCTION fn_get_group_students_count(p_group_id INT)
RETURNS INT AS $$
BEGIN
    RETURN (SELECT COUNT(*)
            FROM students
            WHERE group_id = p_group_id
              AND is_deleted = FALSE);
END;
$$ LANGUAGE plpgsql;

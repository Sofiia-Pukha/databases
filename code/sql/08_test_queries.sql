-- view
SELECT * FROM v_active_groups;
SELECT * FROM v_active_students LIMIT 10;
SELECT * FROM v_student_grades WHERE student_id = 1;
SELECT * FROM v_group_schedule WHERE group_id = 1 ORDER BY day_of_week, lesson_number;

-- функції
SELECT fn_get_student_avg(1) AS avg_grade,
       fn_get_group_students_count(1) AS students_in_group;

-- тригер аудиту
SELECT set_config('app.user_id', '2', FALSE);
CALL sp_update_grade(1, 95);
SELECT id, grade, updated_at, updated_by FROM grades WHERE id = 1;

-- soft delete студента
CALL sp_delete_student(5);
SELECT id, last_name, is_deleted, deleted_at, updated_at, updated_by
FROM students WHERE id = 5;
SELECT COUNT(*) FROM v_active_students WHERE id = 5;   -- має бути 0

-- soft delete групи
SELECT COUNT(*) AS active_before FROM students WHERE group_id = 6 AND is_deleted = FALSE;
CALL sp_delete_group(6);
SELECT COUNT(*) AS active_after  FROM students WHERE group_id = 6 AND is_deleted = FALSE;

-- конфлікт розкладу (має бути помилка)
CALL sp_add_schedule_item(2, 1, 1, 1, 1, 3, 1, 1, NULL);

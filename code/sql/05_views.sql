-- тільки не видалені записи
CREATE OR REPLACE VIEW v_active_groups AS
SELECT g.id,
       g.name,
       g.course_year,
       sp.name AS specialty_name,
       fn_get_group_students_count(g.id) AS students_count
FROM groups g
JOIN specialties sp ON sp.id = g.specialty_id
WHERE g.is_deleted = FALSE;

CREATE OR REPLACE VIEW v_active_students AS
SELECT s.id,
       s.first_name,
       s.last_name,
       s.email,
       s.birth_date,
       g.id   AS group_id,
       g.name AS group_name,
       sp.name AS specialty_name,
       f.name  AS faculty_name,
       fn_get_student_avg(s.id) AS avg_grade,
       s.updated_at,
       s.updated_by
FROM students s
JOIN groups g       ON g.id  = s.group_id
JOIN specialties sp ON sp.id = g.specialty_id
JOIN faculties f    ON f.id  = sp.faculty_id
WHERE s.is_deleted = FALSE;

CREATE OR REPLACE VIEW v_student_grades AS
SELECT gr.id,
       s.id AS student_id,
       s.first_name || ' ' || s.last_name AS student_name,
       sub.name AS subject_name,
       sem.name AS semester_name,
       gr.grade,
       gr.grade_date,
       gr.updated_at,
       u.login AS updated_by_login
FROM grades gr
JOIN students s   ON s.id   = gr.student_id
JOIN subjects sub ON sub.id = gr.subject_id
JOIN semesters sem ON sem.id = gr.semester_id
LEFT JOIN users u ON u.id   = gr.updated_by
WHERE s.is_deleted = FALSE;

CREATE OR REPLACE VIEW v_group_schedule AS
SELECT sch.id,
       g.id   AS group_id,
       g.name AS group_name,
       sem.name AS semester_name,
       sch.day_of_week,
       sch.lesson_number,
       sub.name AS subject_name,
       t.last_name || ' ' || t.first_name AS teacher_name,
       c.number AS classroom_number,
       lt.name  AS lesson_type
FROM schedule sch
JOIN groups g        ON g.id   = sch.group_id
JOIN semesters sem   ON sem.id = sch.semester_id
JOIN subjects sub    ON sub.id = sch.subject_id
JOIN teachers t      ON t.id   = sch.teacher_id
JOIN classrooms c    ON c.id   = sch.classroom_id
JOIN lesson_types lt ON lt.id  = sch.lesson_type_id
WHERE g.is_deleted = FALSE;

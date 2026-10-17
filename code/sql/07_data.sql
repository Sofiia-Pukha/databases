-- тестові дані
INSERT INTO users (login, full_name, role) VALUES
('admin',    'Адміністратор системи', 'admin'),
('teacher1', 'Мельник Ігор',          'teacher'),
('student1', 'Вишневська Тетяна',     'student');

SELECT set_config('app.user_id', '1', FALSE);

INSERT INTO faculties (name) VALUES
('Факультет інформаційних технологій'),
('Економічний факультет'),
('Юридичний факультет');

INSERT INTO departments (name, faculty_id) VALUES
('Кафедра комп''ютерних наук',  1),
('Кафедра програмної інженерії', 1),
('Кафедра економіки',            2),
('Кафедра права',                3);

INSERT INTO specialties (name, faculty_id) VALUES
('Комп''ютерні науки',    1),
('Інженерія програмного забезпечення', 1),
('Економіка',             2),
('Право',                 3);

INSERT INTO groups (name, specialty_id, course_year) VALUES
('КН-21', 1, 3),
('КН-22', 1, 2),
('ПІ-21', 2, 3),
('ЕК-31', 3, 3),
('ЕК-21', 3, 2),
('ПР-11', 4, 1);

INSERT INTO positions (name) VALUES
('Асистент'),
('Доцент'),
('Професор'),
('Старший викладач');

INSERT INTO teachers (first_name, last_name, email, department_id, position_id) VALUES
('Ігор',    'Мельник',   'melnyk@univ.ua',   1, 2),
('Олена',   'Ковальчук', 'kovalchuk@univ.ua', 1, 3),
('Петро',   'Шевчук',    'shevchuk@univ.ua',  2, 1),
('Наталія', 'Бойко',     'boyko@univ.ua',     3, 2),
('Віктор',  'Лисенко',   'lysenko@univ.ua',   4, 4);

INSERT INTO subjects (name, credits) VALUES
('Програмування',                 6),
('Бази даних',                    5),
('Вища математика',               6),
('Англійська мова',               3),
('Алгоритми та структури даних',  5),
('Мікроекономіка',                4),
('Теорія права',                  4),
('Фізика',                        4);

INSERT INTO teacher_subjects (teacher_id, subject_id) VALUES
(1, 1), (1, 5), (2, 2), (2, 3), (3, 3), (3, 4), (4, 6), (5, 7);

INSERT INTO semesters (name, start_date, end_date) VALUES
('2025/2026 осінь', '2025-09-01', '2026-01-31'),
('2025/2026 весна', '2026-02-01', '2026-06-30'),
('2026/2027 осінь', '2026-09-01', '2027-01-31');

INSERT INTO curriculum (specialty_id, subject_id, semester_number) VALUES
(1, 1, 1), (1, 3, 1), (1, 4, 1), (1, 2, 3), (1, 5, 3),
(2, 1, 1), (2, 3, 1), (2, 2, 3),
(3, 6, 1), (3, 4, 1), (3, 3, 1),
(4, 7, 1), (4, 4, 1);

INSERT INTO classrooms (number, capacity) VALUES
('101', 30), ('102', 30), ('201', 60), ('202', 25), ('305', 40);

INSERT INTO lesson_types (name) VALUES
('Лекція'), ('Практика'), ('Лабораторна');

INSERT INTO schedule
    (group_id, subject_id, teacher_id, classroom_id, lesson_type_id, semester_id, day_of_week, lesson_number)
VALUES
(1, 1, 1, 1, 1, 3, 1, 1),
(1, 2, 2, 2, 2, 3, 1, 2),
(1, 3, 3, 3, 1, 3, 2, 1),
(2, 3, 2, 4, 2, 3, 2, 2),
(3, 4, 3, 5, 3, 3, 3, 2),
(4, 6, 4, 3, 1, 3, 3, 1);

DO $$
DECLARE
    v_id INT;
BEGIN
    CALL sp_add_student('Тетяна', 'Вишневська', 'vyshnevska@univ.ua', '2004-05-12', 1, v_id);
    CALL sp_add_student('Максим', 'Романюк',    'romaniuk@univ.ua',    '2005-02-03', 2, v_id);
    CALL sp_add_student('Юлія',   'Гаврилюк',   'havryliuk@univ.ua',   '2004-11-21', 3, v_id);
END;
$$;

-- генерація студентів
INSERT INTO students (first_name, last_name, email, birth_date, group_id)
SELECT
    (ARRAY['Олександр','Андрій','Марія','Олена','Іван',
           'Наталія','Дмитро','Софія','Богдан','Анна'])[1 + (i % 10)],
    (ARRAY['Шевченко','Коваленко','Бондаренко','Мельник','Ткаченко','Кравченко',
           'Олійник','Мороз','Лисенко','Гриценко','Савченко','Петренко'])[1 + (i % 12)],
    'student' || i || '@univ.ua',
    DATE '2003-01-01' + (i % 1000),
    1 + (i % 6)
FROM generate_series(1, 1000) AS i;

INSERT INTO grades (student_id, subject_id, semester_id, grade, grade_date)
SELECT s.id, n, 1, 50 + ((s.id * n * 7) % 51), DATE '2025-12-20' + n
FROM students s
CROSS JOIN generate_series(1, 4) AS n;

ANALYZE students;
ANALYZE grades;

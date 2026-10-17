-- додати студента
CREATE OR REPLACE PROCEDURE sp_add_student(
    p_first_name VARCHAR,
    p_last_name  VARCHAR,
    p_email      VARCHAR,
    p_birth_date DATE,
    p_group_id   INT,
    INOUT p_id   INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM groups
                   WHERE id = p_group_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'Групу з id % не знайдено', p_group_id;
    END IF;

    INSERT INTO students (first_name, last_name, email, birth_date, group_id)
    VALUES (p_first_name, p_last_name, p_email, p_birth_date, p_group_id)
    RETURNING id INTO p_id;
END;
$$;

-- змінити студента
CREATE OR REPLACE PROCEDURE sp_update_student(
    p_id         INT,
    p_first_name VARCHAR,
    p_last_name  VARCHAR,
    p_email      VARCHAR,
    p_birth_date DATE,
    p_group_id   INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM groups
                   WHERE id = p_group_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'Групу з id % не знайдено', p_group_id;
    END IF;

    UPDATE students
    SET first_name = p_first_name,
        last_name  = p_last_name,
        email      = p_email,
        birth_date = p_birth_date,
        group_id   = p_group_id
    WHERE id = p_id AND is_deleted = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Студента з id % не знайдено', p_id;
    END IF;
END;
$$;

-- видалити студента (soft delete)
CREATE OR REPLACE PROCEDURE sp_delete_student(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE students
    SET is_deleted = TRUE,
        deleted_at = NOW()
    WHERE id = p_id AND is_deleted = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Студента з id % не знайдено', p_id;
    END IF;
END;
$$;

-- видалити групу (soft delete)
CREATE OR REPLACE PROCEDURE sp_delete_group(p_id INT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE groups
    SET is_deleted = TRUE,
        deleted_at = NOW()
    WHERE id = p_id AND is_deleted = FALSE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Групу з id % не знайдено', p_id;
    END IF;
END;
$$;

-- виставити оцінку
CREATE OR REPLACE PROCEDURE sp_add_grade(
    p_student_id  INT,
    p_subject_id  INT,
    p_semester_id INT,
    p_grade       INT,
    p_grade_date  DATE,
    INOUT p_id    INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM students
                   WHERE id = p_student_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'Студента з id % не знайдено', p_student_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM subjects
                   WHERE id = p_subject_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'Дисципліну з id % не знайдено', p_subject_id;
    END IF;

    INSERT INTO grades (student_id, subject_id, semester_id, grade, grade_date)
    VALUES (p_student_id, p_subject_id, p_semester_id, p_grade, p_grade_date)
    RETURNING id INTO p_id;
END;
$$;

-- змінити оцінку
CREATE OR REPLACE PROCEDURE sp_update_grade(
    p_id    INT,
    p_grade INT
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE grades
    SET grade = p_grade
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Оцінку з id % не знайдено', p_id;
    END IF;
END;
$$;

-- додати заняття в розклад
CREATE OR REPLACE PROCEDURE sp_add_schedule_item(
    p_group_id       INT,
    p_subject_id     INT,
    p_teacher_id     INT,
    p_classroom_id   INT,
    p_lesson_type_id INT,
    p_semester_id    INT,
    p_day_of_week    INT,
    p_lesson_number  INT,
    INOUT p_id       INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM groups
                   WHERE id = p_group_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'Групу з id % не знайдено', p_group_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM teachers
                   WHERE id = p_teacher_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'Викладача з id % не знайдено', p_teacher_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM subjects
                   WHERE id = p_subject_id AND is_deleted = FALSE) THEN
        RAISE EXCEPTION 'Дисципліну з id % не знайдено', p_subject_id;
    END IF;

    BEGIN
        INSERT INTO schedule (group_id, subject_id, teacher_id, classroom_id,
                              lesson_type_id, semester_id, day_of_week, lesson_number)
        VALUES (p_group_id, p_subject_id, p_teacher_id, p_classroom_id,
                p_lesson_type_id, p_semester_id, p_day_of_week, p_lesson_number)
        RETURNING id INTO p_id;
    EXCEPTION
        WHEN unique_violation THEN
            RAISE EXCEPTION 'Конфлікт розкладу: група, викладач або аудиторія вже зайняті в цей час';
    END;
END;
$$;

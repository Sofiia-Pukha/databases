-- таблиці бази university
DROP TABLE IF EXISTS grades CASCADE;
DROP TABLE IF EXISTS schedule CASCADE;
DROP TABLE IF EXISTS lesson_types CASCADE;
DROP TABLE IF EXISTS classrooms CASCADE;
DROP TABLE IF EXISTS curriculum CASCADE;
DROP TABLE IF EXISTS semesters CASCADE;
DROP TABLE IF EXISTS teacher_subjects CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS teachers CASCADE;
DROP TABLE IF EXISTS positions CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS specialties CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS faculties CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    id        SERIAL PRIMARY KEY,
    login     VARCHAR(50)  NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    role      VARCHAR(20)  NOT NULL
              CHECK (role IN ('admin', 'teacher', 'student'))
);

CREATE TABLE faculties (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE departments (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    faculty_id INT NOT NULL REFERENCES faculties(id)
);

CREATE TABLE specialties (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    faculty_id INT NOT NULL REFERENCES faculties(id)
);

-- soft delete
CREATE TABLE groups (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(20) NOT NULL UNIQUE,
    specialty_id INT NOT NULL REFERENCES specialties(id),
    course_year  INT NOT NULL CHECK (course_year BETWEEN 1 AND 6),
    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMP
);

-- soft delete, updated_at, updated_by
CREATE TABLE students (
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(100) UNIQUE,
    birth_date DATE,
    group_id   INT NOT NULL REFERENCES groups(id),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP,
    updated_at TIMESTAMP,
    updated_by INT REFERENCES users(id)
);

CREATE TABLE positions (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- soft delete, updated_at, updated_by
CREATE TABLE teachers (
    id            SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    department_id INT NOT NULL REFERENCES departments(id),
    position_id   INT NOT NULL REFERENCES positions(id),
    is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at    TIMESTAMP,
    updated_at    TIMESTAMP,
    updated_by    INT REFERENCES users(id)
);

-- soft delete
CREATE TABLE subjects (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    credits    INT NOT NULL CHECK (credits > 0),
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at TIMESTAMP
);

CREATE TABLE teacher_subjects (
    teacher_id INT NOT NULL REFERENCES teachers(id),
    subject_id INT NOT NULL REFERENCES subjects(id),
    PRIMARY KEY (teacher_id, subject_id)
);

CREATE TABLE semesters (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date   DATE NOT NULL,
    CHECK (end_date > start_date)
);

CREATE TABLE curriculum (
    id              SERIAL PRIMARY KEY,
    specialty_id    INT NOT NULL REFERENCES specialties(id),
    subject_id      INT NOT NULL REFERENCES subjects(id),
    semester_number INT NOT NULL CHECK (semester_number BETWEEN 1 AND 12),
    UNIQUE (specialty_id, subject_id, semester_number)
);

CREATE TABLE classrooms (
    id       SERIAL PRIMARY KEY,
    number   VARCHAR(10) NOT NULL UNIQUE,
    capacity INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE lesson_types (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

-- updated_at, updated_by
CREATE TABLE schedule (
    id             SERIAL PRIMARY KEY,
    group_id       INT NOT NULL REFERENCES groups(id),
    subject_id     INT NOT NULL REFERENCES subjects(id),
    teacher_id     INT NOT NULL REFERENCES teachers(id),
    classroom_id   INT NOT NULL REFERENCES classrooms(id),
    lesson_type_id INT NOT NULL REFERENCES lesson_types(id),
    semester_id    INT NOT NULL REFERENCES semesters(id),
    day_of_week    INT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    lesson_number  INT NOT NULL CHECK (lesson_number BETWEEN 1 AND 8),
    updated_at     TIMESTAMP,
    updated_by     INT REFERENCES users(id),
    UNIQUE (group_id, semester_id, day_of_week, lesson_number),
    UNIQUE (teacher_id, semester_id, day_of_week, lesson_number),
    UNIQUE (classroom_id, semester_id, day_of_week, lesson_number)
);

-- updated_at, updated_by
CREATE TABLE grades (
    id          SERIAL PRIMARY KEY,
    student_id  INT NOT NULL REFERENCES students(id),
    subject_id  INT NOT NULL REFERENCES subjects(id),
    semester_id INT NOT NULL REFERENCES semesters(id),
    grade       INT NOT NULL CHECK (grade BETWEEN 0 AND 100),
    grade_date  DATE NOT NULL,
    updated_at  TIMESTAMP,
    updated_by  INT REFERENCES users(id)
);

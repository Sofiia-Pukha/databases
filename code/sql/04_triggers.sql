-- записує дату зміни і користувача з app.user_id
CREATE OR REPLACE FUNCTION fn_set_audit_fields()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := NOW();
    NEW.updated_by := NULLIF(current_setting('app.user_id', TRUE), '')::INT;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_students_audit ON students;
CREATE TRIGGER trg_students_audit
    BEFORE INSERT OR UPDATE ON students
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_audit_fields();

DROP TRIGGER IF EXISTS trg_grades_audit ON grades;
CREATE TRIGGER trg_grades_audit
    BEFORE INSERT OR UPDATE ON grades
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_audit_fields();

DROP TRIGGER IF EXISTS trg_schedule_audit ON schedule;
CREATE TRIGGER trg_schedule_audit
    BEFORE INSERT OR UPDATE ON schedule
    FOR EACH ROW
    EXECUTE FUNCTION fn_set_audit_fields();

-- при видаленні групи видаляємо її студентів
CREATE OR REPLACE FUNCTION fn_group_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE students
    SET is_deleted = TRUE,
        deleted_at = NOW()
    WHERE group_id = NEW.id
      AND is_deleted = FALSE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_group_soft_delete ON groups;
CREATE TRIGGER trg_group_soft_delete
    AFTER UPDATE OF is_deleted ON groups
    FOR EACH ROW
    WHEN (OLD.is_deleted = FALSE AND NEW.is_deleted = TRUE)
    EXECUTE FUNCTION fn_group_soft_delete();

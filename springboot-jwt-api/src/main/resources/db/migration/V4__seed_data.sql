-- ============================================================
-- School Management System — V4: seed data
-- Default accounts: admin/admin@123, teacher1/teacher@123, student1/student@123
-- ============================================================

-- ---------- Roles ----------
INSERT INTO roles (name, description, created_at, created_by) VALUES
    ('ROLE_ADMIN',   'Full system access',                              NOW(), 'SYSTEM'),
    ('ROLE_TEACHER', 'Read master data, manage enrollments and grades', NOW(), 'SYSTEM'),
    ('ROLE_STUDENT', 'Read-only access to own academic records',        NOW(), 'SYSTEM');

-- ---------- Permissions ----------
INSERT INTO permissions (code, description)
SELECT e.name || '.' || a.name, INITCAP(a.name) || ' ' || e.name || 's'
FROM (VALUES ('user'), ('role'), ('student'), ('teacher'), ('subject'), ('class'), ('enrollment'), ('grade')) AS e(name)
CROSS JOIN (VALUES ('create'), ('read'), ('update'), ('delete')) AS a(name);

INSERT INTO permissions (code, description) VALUES
    ('audit.read',     'Read audit logs'),
    ('dashboard.read', 'View dashboard');

-- ---------- Role → permission mapping ----------
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p WHERE r.name = 'ROLE_ADMIN';

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.name = 'ROLE_TEACHER'
  AND (p.code IN ('student.read', 'teacher.read', 'subject.read', 'class.read', 'dashboard.read')
       OR p.code LIKE 'enrollment.%' OR p.code LIKE 'grade.%');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.name = 'ROLE_STUDENT'
  AND p.code IN ('subject.read', 'class.read', 'enrollment.read', 'grade.read', 'dashboard.read');

-- ---------- Default users (BCrypt-hashed passwords) ----------
INSERT INTO users (username, email, password, first_name, last_name, status, created_at, created_by) VALUES
    ('admin',    'admin@school.edu.kh',    '$2a$10$ZBHfXV.zJJOtQr8iuq8G4efPbU8c/cyGJ7gDsVEPeSOuQdeTnRNPS', 'System', 'Administrator', 'ACT', NOW(), 'SYSTEM'),
    ('teacher1', 'teacher1@school.edu.kh', '$2a$10$WgGgxrPvFJ1fUhAQMGERVeo9zsECf6LrTU0LjTF7A69cgp0bQcHtu', 'Sokha',  'Teacher',       'ACT', NOW(), 'SYSTEM'),
    ('student1', 'student1@school.edu.kh', '$2a$10$wP4n6Inm3fl8WHNpxAe28Oncn7OpgOl6mardneFs/HRYNGQKaNekq', 'Dara',   'Student',       'ACT', NOW(), 'SYSTEM');

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id FROM users u JOIN roles r ON
    (u.username = 'admin'    AND r.name = 'ROLE_ADMIN') OR
    (u.username = 'teacher1' AND r.name = 'ROLE_TEACHER') OR
    (u.username = 'student1' AND r.name = 'ROLE_STUDENT');

-- ---------- Master data: teachers ----------
INSERT INTO teachers (teacher_code, first_name, last_name, gender, email, phone, specialization, status, created_at, created_by) VALUES
    ('T001', 'Sokha',    'Chan',  'M', 'sokha.chan@school.edu.kh',    '012000001', 'Mathematics', 'ACT', NOW(), 'SYSTEM'),
    ('T002', 'Sreymom',  'Keo',   'F', 'sreymom.keo@school.edu.kh',   '012000002', 'Physics',     'ACT', NOW(), 'SYSTEM'),
    ('T003', 'Vibol',    'Sok',   'M', 'vibol.sok@school.edu.kh',     '012000003', 'English',     'ACT', NOW(), 'SYSTEM'),
    ('T004', 'Channary', 'Lim',   'F', 'channary.lim@school.edu.kh',  '012000004', 'Computer Science', 'ACT', NOW(), 'SYSTEM');

-- ---------- Master data: subjects ----------
INSERT INTO subjects (subject_code, name, credit, description, status, created_at, created_by) VALUES
    ('MATH101', 'Mathematics',      3, 'Algebra, geometry and statistics',   'ACT', NOW(), 'SYSTEM'),
    ('PHY101',  'Physics',          3, 'Mechanics and thermodynamics',       'ACT', NOW(), 'SYSTEM'),
    ('ENG101',  'English',          2, 'Reading, writing and communication', 'ACT', NOW(), 'SYSTEM'),
    ('CS101',   'Computer Science', 3, 'Programming fundamentals',           'ACT', NOW(), 'SYSTEM'),
    ('KH101',   'Khmer Literature', 2, 'Khmer language and literature',      'ACT', NOW(), 'SYSTEM'),
    ('HIS101',  'History',          2, 'Cambodian and world history',        'ACT', NOW(), 'SYSTEM');

-- ---------- Master data: classes ----------
INSERT INTO classes (class_code, name, academic_year, teacher_id, capacity, status, created_at, created_by) VALUES
    ('C10A', 'Grade 10A', '2025-2026', (SELECT id FROM teachers WHERE teacher_code = 'T001'), 30, 'ACT', NOW(), 'SYSTEM'),
    ('C10B', 'Grade 10B', '2025-2026', (SELECT id FROM teachers WHERE teacher_code = 'T002'), 30, 'ACT', NOW(), 'SYSTEM'),
    ('C11A', 'Grade 11A', '2025-2026', (SELECT id FROM teachers WHERE teacher_code = 'T004'), 25, 'ACT', NOW(), 'SYSTEM');

-- ---------- Master data: students ----------
INSERT INTO students (student_code, first_name, last_name, gender, date_of_birth, email, phone, address, status, created_at, created_by) VALUES
    ('S001', 'Dara',     'Kim',   'M', '2009-03-12', 'dara.kim@student.school.edu.kh',     '011000001', 'Phnom Penh',   'ACT', NOW(), 'SYSTEM'),
    ('S002', 'Bopha',    'Sorn',  'F', '2009-07-25', 'bopha.sorn@student.school.edu.kh',   '011000002', 'Phnom Penh',   'ACT', NOW(), 'SYSTEM'),
    ('S003', 'Rithy',    'Heng',  'M', '2009-01-08', 'rithy.heng@student.school.edu.kh',   '011000003', 'Kandal',       'ACT', NOW(), 'SYSTEM'),
    ('S004', 'Sreyneang','Phan',  'F', '2009-11-30', 'sreyneang.phan@student.school.edu.kh','011000004', 'Takeo',       'ACT', NOW(), 'SYSTEM'),
    ('S005', 'Visal',    'Chea',  'M', '2008-05-17', 'visal.chea@student.school.edu.kh',   '011000005', 'Phnom Penh',   'ACT', NOW(), 'SYSTEM'),
    ('S006', 'Kanha',    'Mao',   'F', '2008-09-02', 'kanha.mao@student.school.edu.kh',    '011000006', 'Kampong Cham', 'ACT', NOW(), 'SYSTEM'),
    ('S007', 'Piseth',   'Ung',   'M', '2008-12-21', 'piseth.ung@student.school.edu.kh',   '011000007', 'Phnom Penh',   'ACT', NOW(), 'SYSTEM'),
    ('S008', 'Malis',    'Yin',   'F', '2009-04-14', 'malis.yin@student.school.edu.kh',    '011000008', 'Siem Reap',    'ACT', NOW(), 'SYSTEM'),
    ('S009', 'Samnang',  'Ouk',   'M', '2009-06-09', 'samnang.ouk@student.school.edu.kh',  '011000009', 'Phnom Penh',   'ACT', NOW(), 'SYSTEM'),
    ('S010', 'Theary',   'Nop',   'F', '2008-10-28', 'theary.nop@student.school.edu.kh',   '011000010', 'Battambang',   'ACT', NOW(), 'SYSTEM');

-- ---------- Business data: enrollments ----------
INSERT INTO enrollments (student_id, class_id, enrolled_at, status, created_at, created_by)
SELECT s.id, c.id, NOW(), 'ACT', NOW(), 'SYSTEM'
FROM (VALUES
    ('S001', 'C10A'), ('S002', 'C10A'), ('S003', 'C10A'), ('S004', 'C10A'),
    ('S005', 'C10B'), ('S006', 'C10B'), ('S007', 'C10B'),
    ('S008', 'C11A'), ('S009', 'C11A'), ('S010', 'C11A')
) AS x(student_code, class_code)
JOIN students s ON s.student_code = x.student_code
JOIN classes  c ON c.class_code   = x.class_code;

-- ---------- Business data: grades ----------
INSERT INTO grades (enrollment_id, subject_id, score, term, graded_by, status, created_at, created_by)
SELECT e.id, sub.id, x.score, x.term, 'teacher1', 'ACT', NOW(), 'SYSTEM'
FROM (VALUES
    ('S001', 'C10A', 'MATH101', 85.50, 'S1'),
    ('S001', 'C10A', 'ENG101',  78.00, 'S1'),
    ('S002', 'C10A', 'MATH101', 92.25, 'S1'),
    ('S002', 'C10A', 'ENG101',  88.00, 'S1'),
    ('S003', 'C10A', 'MATH101', 64.75, 'S1'),
    ('S005', 'C10B', 'PHY101',  71.00, 'S1'),
    ('S006', 'C10B', 'PHY101',  83.50, 'S1'),
    ('S008', 'C11A', 'CS101',   95.00, 'S1'),
    ('S009', 'C11A', 'CS101',   67.25, 'S1'),
    ('S010', 'C11A', 'CS101',   74.00, 'S1')
) AS x(student_code, class_code, subject_code, score, term)
JOIN students s   ON s.student_code = x.student_code
JOIN classes  c   ON c.class_code   = x.class_code
JOIN enrollments e ON e.student_id = s.id AND e.class_id = c.id
JOIN subjects sub ON sub.subject_code = x.subject_code;

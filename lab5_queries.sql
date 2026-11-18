-- ============================================
-- VUA-SEN307 Lab 5: SELECT, Filtering and Joins
-- Name: onyeka stephen chidera   Matric: vug/sen/24/11898
-- ============================================

USE sen307_202411898;   -- <-- change to your own database name (sen307_<11898>)

-- Recap: check that your Week 6 data is there (no count should be zero)
SELECT 'Departments' AS tbl, COUNT(*) AS total FROM Department
UNION ALL SELECT 'Lecturers', COUNT(*) FROM Lecturer
UNION ALL SELECT 'Students', COUNT(*) FROM Student
UNION ALL SELECT 'Courses', COUNT(*) FROM Course
UNION ALL SELECT 'Enrolments', COUNT(*) FROM Enrolment
UNION ALL SELECT 'Allocations', COUNT(*) FROM CourseAllocation;


-- ============================================
-- Task 1: Students in one department, sorted A-Z
-- ============================================
SELECT s.matric_no, s.full_name, d.dept_name
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE d.dept_name = 'Software Engineering'
ORDER BY s.full_name ASC;
-- Explanation: Student is joined to Department on dept_id so we can filter by the
-- department's NAME instead of remembering its ID number. WHERE keeps only
-- Software Engineering students, and ORDER BY s.full_name ASC sorts them A-Z.
-- (If you moved yourself to Computer Science in Week 6, you will not appear here.)


-- ============================================
-- Task 2: Courses with their lecturers (INNER JOIN)
-- ============================================
SELECT c.course_code, c.course_title, l.full_name AS lecturer
FROM Course c
INNER JOIN CourseAllocation ca ON c.course_id = ca.course_id
INNER JOIN Lecturer l ON ca.lecturer_id = l.lecturer_id
ORDER BY c.course_code, l.full_name;
-- Explanation: Course and Lecturer are not linked directly, so we go
-- Course -> CourseAllocation -> Lecturer using two INNER JOINs. INNER JOIN returns
-- only rows that match in both tables. SEN307 appears twice because it is taught
-- by two lecturers.


-- ============================================
-- Task 3: Students and their courses (LEFT JOIN)
-- ============================================
-- Worked example: every student, including those with no enrolments
SELECT s.full_name, c.course_title
FROM Student s
LEFT JOIN Enrolment e ON s.student_id = e.student_id
LEFT JOIN Course c ON e.course_id = c.course_id
ORDER BY s.full_name;
-- Explanation: LEFT JOIN keeps ALL rows from the left table (Student) and fills the
-- right-hand columns with NULL where there is no match. Students with no
-- enrolments therefore still appear, with course_title = NULL.

-- Only the students with no courses
SELECT s.full_name, c.course_title
FROM Student s
LEFT JOIN Enrolment e ON s.student_id = e.student_id
LEFT JOIN Course c ON e.course_id = c.course_id
WHERE c.course_title IS NULL
ORDER BY s.full_name;
-- Explanation: adding WHERE c.course_title IS NULL keeps only the rows where the join
-- found no match, i.e. the students who are not enrolled in any course. This should
-- show the two students created in Week 6 (Hauwa Danjuma and Kelechi Ibe).


-- ============================================
-- Task 4: Filtering with AND / OR / IN / BETWEEN
-- ============================================
SELECT s.matric_no, s.full_name, s.gender, s.date_of_birth, d.dept_name
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE s.gender = 'F'
  AND d.dept_name IN ('Software Engineering', 'Artificial Intelligence')
  AND s.date_of_birth BETWEEN '2004-01-01' AND '2005-12-31'
ORDER BY s.date_of_birth;
-- Explanation: this combines AND, IN and BETWEEN. It returns female students who are in
-- Software Engineering OR Artificial Intelligence (IN is a short way to write
-- several OR conditions) and who were born between 1 Jan 2004 and 31 Dec 2005
-- (BETWEEN is inclusive of both dates). I used department names instead of IDs
-- so the query does not depend on which ID numbers MySQL gave the departments.

-- Same idea using OR as well (brackets are needed when mixing AND with OR)
SELECT s.matric_no, s.full_name, s.gender, s.date_of_birth, d.dept_name
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE s.gender = 'F'
  AND (d.dept_name = 'Software Engineering' OR d.dept_name = 'Artificial Intelligence')
  AND s.date_of_birth BETWEEN '2004-01-01' AND '2005-12-31'
ORDER BY s.date_of_birth;
-- Explanation: gives the same result as above. The brackets around the OR matter:
-- without them AND is evaluated before OR and the filter would return the wrong rows.


-- ============================================
-- Task 5: Paginating enrolments with LIMIT and OFFSET
-- ============================================
-- Page 1 (rows 1-10)
SELECT * FROM Enrolment
ORDER BY enrolment_id
LIMIT 10 OFFSET 0;
-- Explanation: LIMIT 10 returns at most 10 rows and OFFSET 0 skips none, so this is page 1.

-- Page 2 (rows 11-20)
SELECT * FROM Enrolment
ORDER BY enrolment_id
LIMIT 10 OFFSET 10;
-- Explanation: OFFSET 10 skips the first 10 rows, so this returns rows 11-20 (page 2).
-- Why always use ORDER BY with LIMIT? Without ORDER BY, MySQL does not guarantee any
-- row order, so the same query could return different rows or overlapping pages.
-- ORDER BY enrolment_id makes the order fixed, so each page is predictable.


-- ============================================
-- Challenge (optional): Task 3 rewritten with RIGHT JOIN
-- ============================================
SELECT s.full_name, c.course_title
FROM Course c
RIGHT JOIN Enrolment e ON e.course_id = c.course_id
RIGHT JOIN Student s ON s.student_id = e.student_id
ORDER BY s.full_name;
-- Explanation: RIGHT JOIN keeps all rows from the RIGHT table. By starting from Course
-- and finishing with Student on the right, every student is kept, so the result is
-- the same as the LEFT JOIN version in Task 3.
-- Which is easier to read? The LEFT JOIN version, because it reads left to right
-- starting from the table we care about (Student) and adds the related tables after
-- it. The RIGHT JOIN version has to start from the "wrong" end, so it is harder to follow.

/* 1. Design the structure of the DB .*/
/* 2. FOREIGN KEY, ON DELETE, ON UPDATE */

-- DROP TABLE
DROP TABLE IF EXISTS answer;
DROP TABLE IF EXISTS result;
DROP TABLE IF EXISTS assignment;
DROP TABLE IF EXISTS question;
DROP TABLE IF EXISTS test;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS teacher;

-- teacher(id, name, surname)
CREATE TABLE teacher (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL
);

-- student(id, name, surname)
CREATE TABLE student (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL
);

-- test(id, name, tacherid_author)
CREATE TABLE test (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    teacher_id INT NOT NULL,
    FOREIGN KEY (teacher_id) REFERENCES teacher(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- question(id , testid, question_text, correct, i1, i2, i3)
CREATE TABLE question (
    id SERIAL PRIMARY KEY,
    test_id INT NOT NULL,
    question_text VARCHAR(50) NOT NULL,
    correct VARCHAR(1) NOT NULL,
    i1 VARCHAR(1) NOT NULL,
    i2 VARCHAR(1) NOT NULL,
    i3 VARCHAR(1) NOT NULL,
    FOREIGN KEY (test_id) REFERENCES test(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- assignment(assignmentid, test_id, teacherid, studentid, assignment_time)
CREATE TABLE assignment (
    id SERIAL PRIMARY KEY,
    test_id INT NOT NULL,
    teacher_id INT NOT NULL,
    student_id INT NOT NULL,
    time TIMESTAMP NOT NULL,
    FOREIGN KEY (test_id) REFERENCES test(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teacher(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (student_id) REFERENCES student(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- result(resultid, assignmentid, completion_time, score)
CREATE TABLE result (
    id SERIAL PRIMARY KEY,
    assignment_id INT NOT NULL,
    time TIMESTAMP,
    score REAL,
    FOREIGN KEY (assignment_id) REFERENCES assignment(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- answer(resultid, questionid, text_answer)
CREATE TABLE answer (
    result_id INT NOT NULL,
    question_id INT NOT NULL,
    student_answer VARCHAR(1),
    PRIMARY KEY (result_id, question_id),
    FOREIGN KEY (result_id) REFERENCES result(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (question_id) REFERENCES question(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


/* 3. Fill each table with at least 3 records .*/

-- teacher(id, name, surname)
INSERT INTO teacher (name, surname) VALUES
('Ana', 'Lopez'),
('Carlos', 'Garcia'),
('Maria', 'Ruiz');

-- student(id, name, surname)
INSERT INTO student (name, surname) VALUES
('Juan', 'Perez'),
('Lucia', 'Martin'),
('Pedro', 'Santos');

-- test(id, name, tacherid_author)
INSERT INTO test (name, teacher_id) VALUES
('Test1', 1),
('Test2', 2),
('Test3', 3),
('Test4', 1),
('Test5', 2);

-- question(id, testid, question_text, correct, i1, i2, i3)
INSERT INTO question (test_id, question_text, correct, i1, i2, i3) VALUES
(1, 'Which is the capital of Slovakia?', 'A', 'B', 'C', 'D'),
(2, '2 + 2 = ?', 'C', 'A', 'B', 'D'),
(3, 'What is 1+1 in binary', 'B', 'A', 'C', 'D'),
(4, 'What is a synonym of happy?', 'D', 'A', 'C', 'B'),
(5, '5 + 13?', 'D', 'A', 'C', 'B');

-- assignment(assignmentid, test_id, teacherid, studentid, assignment_time)
INSERT INTO assignment (test_id, teacher_id, student_id, time) VALUES
(1, 1, 1, '2025-11-10 00:00:00'),
(2, 2, 2, '2025-11-01 00:00:00'),
(3, 3, 3, '2025-10-30 00:00:00'),
(4, 2, 1, '2025-11-15 00:00:00'),
(5, 1, 2, '2025-11-15 00:00:00');

-- result(resultid, assignmentid, completion_time, score)
INSERT INTO result (assignment_id, time, score) VALUES
(1, NULL, NULL),
(2, NOW(), 2.5),
(3, NOW(), 10.0),
(4, NOW(), 9.0),
(5, '2025-11-20 00:00:00', 1.0),
(5, '2025-12-20 00:00:00', 5.0); -- the second attempt of the assignment

-- answer(text_answer, resultid, questionid)
-- two attempts for test 5, question 5
INSERT INTO answer (student_answer, result_id, question_id) VALUES
(NULL, 1, 1),
('B', 2, 2),
('B', 3, 3),
('D', 4, 4),
('B', 5, 5),
('D', 6, 5);


/*
/* 4. When a teacher leaves the school, we want to transfer his tests to another teacher. Write a query that changes the author/owner of the test to another teacher (teacher IDs can be constants). */
UPDATE test
SET teacher_id = 1
WHERE teacher_id = 3;


DELETE FROM teacher
WHERE id = 3;


/* 5. Write queries that, for a given test ID (constant), delete this test from the database along with all its assignments and results. */
DELETE FROM test
WHERE id = 5;
*/

/* 6. Teachers have a request to add information about when the student can complete the assigned test. Write a query that adjusts the
structure of the tables so that for each assignment it is possible to record the date by which the student must complete the test. */
ALTER TABLE assignment
ADD COLUMN due_date DATE;

UPDATE assignment
SET due_date = '2025-12-30'
WHERE id = 1;


/* 7. SELECT queries. */

/* 1. List the students and their assigned test: name, surname, test name, assignment time, completion time.*/
-- 1 Juan Perez: test 1, test 4
-- 2 Lucia Martin: test 2, test 5 x2 times
-- 3 Pedro Santos: test 3
SELECT s.name AS student_name, s.surname AS student_surname, t.name AS test_name, a.time AS assignment_time, r_latest.last_completion_time AS completion_time
FROM assignment a JOIN student s ON a.student_id = s.id JOIN test t ON a.test_id = t.id
LEFT JOIN (SELECT assignment_id, MAX(time) AS last_completion_time
    FROM result
    WHERE time IS NOT NULL
    GROUP BY assignment_id
    ) r_latest ON a.id = r_latest.assignment_id
ORDER BY a.time DESC;


/* 2. Complete the list from the previous task with information about the student's result from the given test .*/
SELECT s.name AS student_name, s.surname AS student_surname, t.name AS test_name, a.time AS assignment_time, r_last.time AS completion_time, r_last.score AS result_percentage
FROM assignment a JOIN student s ON a.student_id = s.id JOIN test t ON a.test_id = t.id
LEFT JOIN (SELECT DISTINCT ON (assignment_id) assignment_id, id, time, score
            FROM result
            WHERE time IS NOT NULL
            ORDER BY assignment_id, time DESC
        ) r_last ON r_last.assignment_id = a.id
ORDER BY a.time DESC;


/* 3. Complete the previous list with information on whether the student answered all the test questions. */
SELECT s.name AS student_name, s.surname AS student_surname, t.name AS test_name, a.time AS assignment_time, r_last.score AS result_percentage,
    CASE
        WHEN r_last.score IS NULL THEN 'no'
        WHEN COALESCE(a_count.answered_count, 0) = COALESCE(q_count.question_count, 0) THEN 'yes'
        ELSE 'no'
    END AS finished

FROM assignment a JOIN student s ON a.student_id = s.id JOIN test t ON a.test_id = t.id
/* Last test result */
LEFT JOIN (SELECT DISTINCT ON (assignment_id) assignment_id, id, time, score
            FROM result
            WHERE time IS NOT NULL
            ORDER BY assignment_id, time DESC
        ) r_last ON r_last.assignment_id = a.id
/* Total number of questions */                                   
LEFT JOIN (SELECT q.test_id, COUNT(*) AS question_count
            FROM question q
            GROUP BY q.test_id
        ) q_count ON t.id = q_count.test_id
/* Answered questions */
LEFT JOIN (SELECT r.assignment_id, COUNT(DISTINCT ans.question_id) AS answered_count
            FROM (SELECT DISTINCT ON (assignment_id) id, assignment_id
                FROM result
                WHERE time IS NOT NULL
                ORDER BY assignment_id, time DESC
            ) r
            LEFT JOIN answer ans ON ans.result_id = r.id
            GROUP BY r.assignment_id
          ) a_count ON a_count.assignment_id = a.id
ORDER BY a.time DESC;


/* 4. Write the questions answered correctly by each student, within any assignment.*/
SELECT student_name, student_surname, question_text, correct_answer
FROM (SELECT DISTINCT s.name AS student_name, s.surname AS student_surname, q.id AS question_id, q.question_text, q.correct AS correct_answer
    FROM student s JOIN assignment a ON s.id = a.student_id JOIN result r ON a.id = r.assignment_id JOIN answer ans ON r.id = ans.result_id JOIN question q ON ans.question_id = q.id
    WHERE ans.student_answer = q.correct 
    AND NOT EXISTS (
          SELECT 1
          FROM assignment a2
          JOIN result r2 ON a2.id = r2.assignment_id
          JOIN answer ans2 ON r2.id = ans2.result_id
          WHERE a2.student_id = s.id AND ans2.question_id = q.id AND ans2.student_answer <> q.correct
      )
) wrong
ORDER BY student_name, question_id;

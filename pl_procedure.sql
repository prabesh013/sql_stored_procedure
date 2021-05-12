-- CREATE TABLE email_lists(email VARCHAR2(200));

-- INSERT INTO email_lists VALUES('prabesh.nepal@cotiviti.com');

-- SELECT * FROM email_lists;

-- DROP TABLE email_lists;

-- CREATE OR REPLACE PROCEDURE email_extractor
-- AS 
-- BEGIN
--     dbms_output.put_line('Hello World!'); 
-- END;
-- /

-- EXECUTE email_extractor;

-- REGEXP_SUBSTR


-- SELECT REGEXP_SUBSTR ('TechOnTheNet is a great resource', '(\S*)(\s)')
-- FROM dual;


-- SELECT REGEXP_SUBSTR ('TechOnTheNet is a great resource', '(\S*)(\s)*', 1, 5)
-- FROM dual;

-- SELECT REGEXP_SUBSTR('ra m.nepal@cotiviti.com','^(\w)+.')
-- FROM dual;



SELECT TRIM(BOTH '.' FROM REGEXP_SUBSTR('ram.nepal@cotiviti.com','^(\w)+.')) first_name,
TRIM(BOTH '@' FROM TRIM(BOTH '.' FROM REGEXP_SUBSTR('ram.nepal@gmail.com','.(\w)+@'))) last_name, 
TRIM(BOTH '@' FROM TRIM(BOTH '.' FROM REGEXP_SUBSTR('ram.nepal@gmail.com','@(\w)+.'))) domain
FROM dual


-- CREATE TABLE email_lists(email VARCHAR2(200));

-- INSERT INTO email_lists VALUES('prabesh.nepal@cotiviti.com');

-- SELECT * FROM email_lists;

-- DROP TABLE email_lists;

-- CREATE OR REPLACE PROCEDURE email_extractor
-- AS 
-- BEGIN
--     dbms_output.put_line('Hello World!'); 
-- END;
-- /

-- EXECUTE email_extractor;

-- REGEXP_SUBSTR


-- SELECT REGEXP_SUBSTR ('TechOnTheNet is a great resource', '(\S*)(\s)')
-- FROM dual;


-- SELECT REGEXP_SUBSTR ('TechOnTheNet is a great resource', '(\S*)(\s)*', 1, 5)
-- FROM dual;

-- SELECT REGEXP_SUBSTR('ra m.nepal@cotiviti.com','^(\w)+.')
-- FROM dual;



-- SELECT TRIM(BOTH '.' FROM REGEXP_SUBSTR('ram.nepal@cotiviti.com','^(\w)+.')) first_name,
-- TRIM(BOTH '@' FROM TRIM(BOTH '.' FROM REGEXP_SUBSTR('ram.nepal@gmail.com','.(\w)+@'))) last_name, 
-- TRIM(BOTH '@' FROM TRIM(BOTH '.' FROM REGEXP_SUBSTR('ram.nepal@gmail.com','@(\w)+.'))) domain
-- FROM dual;


CREATE TABLE email_lists(email VARCHAR2(200));

INSERT INTO email_lists VALUES('tony.stank@stark.com');
INSERT INTO email_lists VALUES('elon.musk@tesla.com');
INSERT INTO email_lists VALUES('donald.trump@america.com');
INSERT INTO email_lists VALUES('amanda.cerny@vine.com');
INSERT INTO email_lists VALUES('ram.nepal@gmail.com');

SELECT * FROM email_lists;

CREATE TABLE tbl_emails(
    tbl_email VARCHAR2(200),
    tbl_first_name VARCHAR2(50),
    tbl_last_name VARCHAR2(50),
    tbl_domain_name VARCHAR2(50)
);


CREATE OR REPLACE PROCEDURE email_extractor
AS 
BEGIN
    FOR e IN (SELECT email FROM email_lists) 
    LOOP 
        INSERT INTO tbl_emails
        SELECT
            e,
            TRIM(BOTH '.' FROM REGEXP_SUBSTR(e,'^(\w)+.')),
            TRIM(BOTH '@' FROM TRIM(BOTH '.' FROM REGEXP_SUBSTR(e,'.(\w)+@'))), 
            TRIM(BOTH '@' FROM TRIM(BOTH '.' FROM REGEXP_SUBSTR(e,'@(\w)+.')))
        FROM dual;
    END LOOP;
END;
/
EXECUTE email_extractor;

SELECT * FROM tbl_emails;

-- CREATE OR REPLACE PROCEDURE email_extractor
-- AS 
-- BEGIN
--     FOR e IN (SELECT email FROM email_lists) 
--     LOOP 
--         dbms_output.put_line(e.email);
--     END LOOP;
-- END;
-- /
-- EXECUTE email_extractor;

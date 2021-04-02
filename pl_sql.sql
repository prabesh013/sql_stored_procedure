-- creating table 
CREATE TABLE covid_data (
    country_name VARCHAR2(100),
    total_cases NUMBER(15),
    total_deaths NUMBER(15),
    total_recovered NUMBER(15),
    total_serious NUMBER(15)
);

-- display the information about the table
SELECT * FROM covid_data;
SELECT COUNT(*) FROM covid_data;
DESC covid_data;

-- view for top countries in the table
CREATE OR REPLACE VIEW vw_top_countries
AS
    SELECT 
        ROW_NUMBER() OVER(ORDER BY cd.total_cases DESC) sn, cd.country_name cname, cd.total_cases tcases
    FROM 
        covid_data cd
    FETCH NEXT 20 ROWS ONLY;
    
-- view for the bottom countries in the table
CREATE OR REPLACE VIEW vw_bottom_countries
AS
    SELECT 
        ROW_NUMBER() OVER(ORDER BY cd.total_cases ASC) sn, cd.country_name cname, cd.total_cases tcases
    FROM 
        covid_data cd
    FETCH NEXT 20 ROWS ONLY;

-- view top and bottom 20 countries
SELECT * FROM vw_top_countries;   
SELECT * FROM vw_bottom_countries;

-- joining the two side table
SELECT  
    *  
FROM  
    vw_top_countries 
LEFT JOIN  
    vw_bottom_countries 
USING(sn); 

-- table that holds new data
CREATE TABLE new_covid_data(
    country_name VARCHAR2(100),
    new_cases NUMBER(15),
    new_deaths NUMBER(15)
);
DESC new_covid_data;

-- procedure to update the tables
CREATE OR REPLACE PROCEDURE UPDATE_NEW_PRC
(
    p_country_name IN VARCHAR2, 
    p_new_cases IN NUMBER,
    p_new_deaths IN NUMBER,
    p_new_recovered IN NUMBER,
    p_new_serious IN NUMBER
)
IS
BEGIN
    -- this updates the table with total cases data
    UPDATE 
        covid_data
    SET 
        total_cases = total_cases + p_new_cases,
        total_deaths = total_deaths + p_new_deaths,
        total_recovered = total_recovered + p_new_recovered,
        total_serious = total_serious + p_new_serious
    WHERE
        UPPER(country_name) = UPPER(p_country_name);
    
    -- this updates the table with new cases data    
    UPDATE
        new_covid_data nw
    SET
        nw.new_cases = p_new_cases,
        nw.new_deaths = p_new_deaths
    WHERE
        UPPER(nw.country_name) = UPPER(p_country_name);
        
END;
/

--verify the working of procedure
SELECT * FROM covid_data WHERE country_name='Nepal';
SELECT * FROM new_covid_data;

EXECUTE UPDATE_NEW_PRC('Nepal',1,1,1,1);

SELECT * FROM covid_data WHERE country_name='Nepal';
SELECT * FROM new_covid_data;

-- finding position
CREATE OR REPLACE FUNCTION FIND_POSITION_FUNC
(
    p_country_name VARCHAR2
)
RETURN NUMBER
IS
    l_position NUMBER(5);
BEGIN
    SELECT 
        country_rank.c_pos INTO l_position
    FROM 
    (
        SELECT 
            cd.country_name c_name,  
            rownum c_pos
        FROM 
            covid_data cd
        ORDER BY cd.total_cases DESC
    ) country_rank
    WHERE UPPER(country_rank.c_name) = UPPER(p_country_name);
    RETURN l_position;
END;

CREATE OR REPLACE VIEW vw_position
AS
    SELECT 
        cd.country_name||' Position: '||FIND_POSITION_FUNC('Nepal')||' - '||'total: '||cd.total_cases||'; today: '|| ncd.new_cases||' - deaths: '||cd.total_deaths||'; today: '||ncd.new_deaths country
    FROM 
        covid_data cd
    JOIN
        new_covid_data ncd
    ON
        cd.country_name = ncd.country_name
    WHERE UPPER(cd.country_name)='NEPAL';

SELECT * FROM vw_position;

CREATE OR REPLACE VIEW vw_top_row
AS
    SELECT 
        SUM(cd.total_cases) total,
        SUM(cd.total_deaths) deaths,
        SUM(cd.total_recovered) recovered
    FROM 
        covid_data cd;

-- finding total number of active cases
CREATE OR REPLACE FUNCTION TOTAL_ACTIVE_FUN
RETURN NUMBER
IS
    l_total_active NUMBER(25);
BEGIN
    SELECT
        (SUM(cd.total_cases)-SUM(cd.total_deaths)-SUM(cd.total_recovered))
    INTO
        l_total_active
    FROM
        covid_data cd;
    RETURN l_total_active;
END;
/

CREATE OR REPLACE VIEW vw_active_side
AS
    SELECT 
        TOTAL_ACTIVE_FUN() active,
        SUM(cd.total_serious) serious,
        ROUND((SUM(cd.total_serious)/TOTAL_ACTIVE_FUN()*100),2) serious_per,
        (TOTAL_ACTIVE_FUN()- SUM(cd.total_serious)) mild,
        (100 - ROUND((SUM(cd.total_serious)/TOTAL_ACTIVE_FUN()*100),2)) mild_per
    FROM
        covid_data cd;

SELECT * FROM vw_active_side;

-- finding the total number of closed cases
CREATE OR REPLACE FUNCTION TOTAL_CLOSED_FUN
RETURN NUMBER
IS
    l_total_closed NUMBER(25);
BEGIN
    SELECT
        (SUM(cd.total_deaths) + SUM(cd.total_recovered)) 
    INTO
        l_total_closed
    FROM
        covid_data cd;
    RETURN l_total_closed;
END;
/

CREATE OR REPLACE VIEW vw_closed_side
AS
    SELECT
        TOTAL_CLOSED_FUN() closed,
        (SUM(cd.total_deaths)) deaths,
        ROUND((SUM(cd.total_deaths)*100/TOTAL_CLOSED_FUN()),2) deaths_per,
        (SUM(cd.total_recovered)) recovered,
        (100-ROUND((SUM(cd.total_deaths)*100/TOTAL_CLOSED_FUN()),2)) recovered_per
    FROM
        covid_data cd;


SELECT * FROM vw_closed_side;
SELECT * FROM vw_active_side;
SELECT * FROM vw_position;
SELECT * FROM vw_top_countries;   
SELECT * FROM vw_bottom_countries;
    
CREATE OR REPLACE VIEW vw_final_select
AS
    SELECT
        top.cname "Top country",
        top.tcases "Top cases",
        pos."_1",
        pos."_2",
        pos."_3",
        pos."_4",
        pos."_5",
        pos."_6",
        pos."_7",
        pos."_8",
        bottom.cname "Bottom country",
        bottom.tcases "Bottom cases"
    FROM
        vw_top_countries top
    LEFT JOIN
        vw_bottom_countries bottom
    ON top.sn=bottom.sn
    LEFT JOIN
        (
        SELECT 1 rsn,' ' "_1",' ' "_2",' ' "_3",' ' "_4",' ' "_5",' ' "_6",' ' "_7",' ' "_8" FROM dual
        UNION
        SELECT 2 rsn,'Total cases:',' ',' ',' ','Deaths:',' ','Recovered:',' ' FROM dual
        UNION
        SELECT 3 rsn,''||total,' ' " ",' ' " ",' ' " ",''||deaths,' ' " ",''||recovered,' ' " " FROM vw_top_row
        UNION
        SELECT 10 rsn,'Active',' ' " ",' ' " ",' ' " ",' ' " ",' ' " ",'Closed cases',' ' " " FROM dual
        UNION
        SELECT 11 rsn,'Cases',' ' " ",''||vas.active,' ' " ",' ' " ",' ' " ",''||closed,' ' " " FROM  vw_active_side vas,vw_closed_side vcs WHERE rownum < 2
        UNION
        SELECT 12 rsn,' ' " ",' ' " ",'currently infected patients',' ' " ",' ' " ",' ' " ",'Cases which had an outcome',' ' " " FROM dual
        UNION
        SELECT 15 rsn, ' ' " ",''||vas.mild||'('||vas.mild_per||'%)',' ' " ",''||vas.serious||'('||vas.serious_per||'%)',' ' " ",''||vcs.recovered||'('||vcs.recovered_per||'%)',' ' " ",''||vcs.deaths||'('||vcs.deaths_per||'%)' FROM vw_active_side vas,vw_closed_side vcs WHERE rownum < 2
        UNION
        SELECT 16 rsn, ' ' " ",'in mild condition',' ' " ",'serious or critical',' ' " ",'Recovered/discharged',' ' " ",'Deaths' FROM vw_active_side vas,vw_closed_side vcs WHERE rownum < 2
        UNION
        SELECT 20 rsn, country " ",' ' " ",' ' " ",' ' " ",' ' " ",' ' " ",' ' " ",' ' " " FROM vw_position
        ) pos  
    ON top.sn = pos.rsn
    ORDER BY top.sn;



SELECT * FROM vw_final_select;
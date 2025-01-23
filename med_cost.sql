CREATE SCHEMA g1;
CREATE SCHEMA g2;
CREATE SCHEMA g3;

CREATE TABLE g1.individuals (
    individual_id SERIAL PRIMARY KEY,
    age INT,
    sex VARCHAR(10),
    children INT NOT NULL
);

SELECT * FROM g1.individuals;

CREATE TABLE g2.lifestyle (
    individual_id INT,
	bmi FLOAT, 
    smoker VARCHAR(5),
    FOREIGN KEY (individual_id) REFERENCES g1.individuals(individual_id)
);

SELECT * FROM g2.lifestyle;

CREATE TABLE g3.region (
    individual_id INT,
    region VARCHAR(20),
    charges FLOAT,
    FOREIGN KEY (individual_id) REFERENCES g1.individuals(individual_id)
);

SELECT * FROM g3.region;

-- Data Analysis

-- southwest
SELECT region, SUM(charges) AS "Total Charges"
FROM g3.region
WHERE region = 'southwest'
GROUP BY region;

-- southeast
SELECT region, SUM(charges) AS "Total Charges"
FROM g3.region
WHERE region = 'southeast'
GROUP BY region;

-- northwest
SELECT region, SUM(charges) AS "Total Charges"
FROM g3.region
WHERE region = 'northwest'
GROUP BY region;

-- northeast
SELECT region, SUM(charges) AS "Total Charges"
FROM g3.region
WHERE region = 'northeast'
GROUP BY region;

-- Child Coverage Distribution by Age Group
WITH age_grouped AS (SELECT children, CASE
WHEN age BETWEEN 0 AND 18 THEN '0-18'
WHEN age BETWEEN 19 AND 35 THEN '19-35'
WHEN age BETWEEN 36 AND 50 THEN '36-50'
WHEN age > 50 THEN '51-64'
ELSE 'Unknown'
END AS age_grouped
FROM g1.individuals
)
SELECT age_grouped, children, COUNT(*) AS "Children Count"
FROM age_grouped
GROUP BY age_grouped, children
ORDER BY age_grouped, children;

-- Age Group Distribution by Region
WITH age_grouped AS (SELECT CASE
WHEN age BETWEEN 0 AND 18 THEN '0-18'
WHEN age BETWEEN 19 AND 35 THEN '19-35'
WHEN age BETWEEN 36 AND 50 THEN '36-50'
WHEN age > 50 THEN '51-64'
ELSE 'Unknown'
END AS age_grouped, r.region
FROM g1.individuals i
JOIN g3.region r ON i.individual_id = r.individual_id
)
SELECT age_grouped, region, COUNT(*) AS "Total Count"
FROM age_grouped
GROUP BY age_grouped, region
ORDER BY age_grouped, region;

-- Gender-Based Distribution of Smokers and Non-Smokers by Region
SELECT i.sex, r.region, l.smoker, COUNT(*) AS "Total Count"
FROM g1.individuals i
JOIN g2.lifestyle l ON i.individual_id = l.individual_id
JOIN g3.region r ON i.individual_id = r.individual_id
GROUP BY i.sex, r.region, l.smoker;

-- Average Costs by Sex and Smoker Status by region
SELECT 
    i.sex, 
	r.region,
    l.smoker, 
    AVG(r.charges) AS "Avg Charges"
FROM g1.individuals i
JOIN g2.lifestyle l ON i.individual_id = l.individual_id
JOIN g3.region r ON i.individual_id = r.individual_id
GROUP BY i.sex, r.region, l.smoker
ORDER BY l.smoker, "Avg Charges";

-- Average BMI by Region
SELECT r.region, AVG(l.bmi) AS "Avg BMI"
FROM g2.lifestyle l
JOIN g3.region r ON l.individual_id = r.individual_id
GROUP BY r.region
ORDER BY "Avg BMI";
DROP DATABASE IF EXISTS barganha;
CREATE DATABASE barganha;

USE barganha;

SELECT * FROM general; # We imported a csv (DF) already cleaned in Python.

ALTER TABLE general 
modify column date varchar(88); 

ALTER TABLE general 
ADD PRIMARY KEY (date);         # Making date the Primary Key of the table "general"

DROP TABLE IF EXISTS location;
CREATE TABLE location(country_id CHAR (88) PRIMARY KEY, country VARCHAR(88), users INT);

INSERT INTO location (country_id, country, users)
VALUES ("PT", "Portugal", 25326), 
	   ("BR", "Brasil", 499), 
	   ("ES", "Spain", 82),
       ("FR", "France", 56), 
       ("US", "USA", 54), 
       ("CN", "China", 47), 
       ("AO", "Angola", 45);
 
SELECT * FROM location;

DROP TABLE IF EXISTS jobs;
SELECT * FROM jobs; # We were unable to import the file as csv so we converted it to json and imported

ALTER TABLE jobs 
ADD COLUMN Level INT auto_increment PRIMARY KEY;       # Making views the Primary Key of the table "jobs"

SELECT * FROM jobs;

DROP TABLE IF EXISTS route;
CREATE TABLE route(id INT AUTO_INCREMENT PRIMARY KEY,channel VARCHAR(88), users INT);

INSERT INTO route (channel, users)
VALUES ("Direct", 14587), 
	   ("Organic Search", 9714), 
       ("Referral", 8229), 
       ("Unassigned", 128), 
       ("Organic Social", 92), 
       ("E-mail", 15);
 
SELECT * FROM route;

DROP TABLE IF EXISTS channel_route;
CREATE TABLE channel_route(id INT, channel VARCHAR(88) PRIMARY KEY, country_id CHAR(88), date VARCHAR(88), level INT,
							FOREIGN KEY (country_id) REFERENCES location(country_id),
                            FOREIGN KEY (id) REFERENCES route(id),
                            FOREIGN KEY (level) REFERENCES jobs(level),
                            FOREIGN KEY (date) REFERENCES general(date));

SELECT * FROM channel_route;


######################################################################################################################################
# Questions to Answer:

# 1. Traffic Analysis: What is the overall trend on the website (traffic over the past six months)?

SELECT SUM(users) AS total_users
FROM general;  

# Answer: 34824

# 2. Which channels (organic search, direct, referral, social media, paid search, etc.) are driving the most traffic to the website?

SELECT channel, MAX(users) AS top_channel
FROM route
GROUP BY channel
LIMIT 1;                  # We can change this by taking desired number of channels and order by

# Answer: Direct 14587

# 3. Are there any significant fluctuations or patterns in traffic that need to be addressed? (GET THE 10 MAX VALUES / AND CHECK WHICH DATES IT HAS MORE ACCESSES)

SELECT date, MAX(users) AS fluctuations
FROM general
GROUP BY date
ORDER BY fluctuations DESC
LIMIT 10; 

# 4. Conversion Rate Analysis: What is the current conversion rate on the website? (SUM TOTAL OF USER + TOTAL OF CLICK)

SELECT SUM(users) /  SUM(clicks) AS conversion_rate
FROM general; 

# Answer: 3.9159

# 5. User Engagement Analysis: What are the most popular pages or content on the website based on user engagement metrics? (GET THE 5 TOP PAGES/ VACANCIES AVAILABLE)

SELECT Job, MAX(views) AS engagements
FROM jobs
GROUP BY job
ORDER BY engagements DESC
LIMIT 5; 

# 6. What is the total number of new users in the past six months? (GET TOTAL OF USER AND SUBTRACT BY NEWS USERS)

SELECT SUM(users) - SUM(new_users) AS total_new_users
FROM general;

# Answers: 8624

# 7. Revenue Analysis: What has been the total revenue generated by the website over the past six months?

SELECT SUM(earnings) AS total_earnings
FROM general;

# Answers: 2295.810000000001

# 8. Are there any seasonal or cyclical patterns in revenue that need to be considered? MAX AND MIN REVENUE

# Max

SELECT date, users, MAX(earnings) AS best_day
FROM general
GROUP BY date, users
ORDER BY best_day DESC
LIMIT 10; 

# Min

SELECT date, users, MIN(earnings) AS bad_days
FROM general
GROUP BY date, users
ORDER BY bad_days ASC
LIMIT 10;

# 9. What is the revenue per click? (GET TOTAL REVENUE AND SPLIT IT BY CLICK)

SELECT SUM(earnings) /  SUM(clicks) AS revenue_per_click
FROM general; 

# Answer: 0.25815922635780963

# 10. How many users will be needed to increase revenue by 30%?

SELECT
    SUM(users) AS total_users,
    SUM(clicks) AS total_clicks,
    SUM(earnings) AS current_total_revenue,
    SUM(earnings) * 1.3 AS target_total_revenue,
    SUM(earnings) * 0.3 AS required_total_revenue_increase,
    (SUM(earnings) * 1.3) / (SUM(earnings) / SUM(clicks)) - SUM(clicks) AS additional_clicks_needed,
    ((SUM(earnings) * 1.3) / (SUM(earnings) / SUM(clicks)) - SUM(clicks)) * (SUM(users) / SUM(clicks)) AS additional_users_needed
FROM general;




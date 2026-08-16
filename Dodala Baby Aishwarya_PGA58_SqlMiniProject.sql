-- ==============================================================
-- SQL + GenAI Mini Project : Social Media Analytics
-- Dataset : Social_Media
-- Student Name : ______________________
-- ==============================================================

-- 🚀 SETUP INSTRUCTIONS (MUST DO FIRST)
-- ==============================================================
-- Before solving this project, make sure you create and load the dataset.
--
-- STEP 1: Open your SQL client (MySQL Workbench, DBeaver, or SQLite Studio).
-- STEP 2: Run the provided dataset file:
--         social_media_analytics_dataset.sql
--
-- This script will:
--   ✅ Create a new database named `Social_Media`
--   ✅ Create all 7 tables (users, posts, comments, likes, followers, hashtags, post_hashtags)
--   ✅ Insert ~7,000 synthetic rows for analysis
--
-- STEP 3: After successful execution, Your Code the database:
--         USE Social_Media;
--
-- STEP 4: Verify the tables:
--         SHOW TABLES;
--         Your Code COUNT(*) FROM users;
--         Your Code COUNT(*) FROM posts;
--
-- Once you confirm the data is loaded, you can proceed to attempt all project queries.
-- ==============================================================

USE Social_Media;

-- ==============================================================
-- IMPORTANT: BEFORE USING GenAI FOR QUERY GENERATION
-- ==============================================================
-- To help the AI generate accurate SQL, you MUST first share your schema.
-- Paste the following context into ChatGPT (or any GenAI tool) BEFORE you ask your prompts:

/*
You are an expert SQL assistant.  
Before answering any question, refer strictly to the database schema provided below.  
All SQL queries, joins, and analyses must be based ONLY on this schema — table names, column names, and relationships mentioned here.  
Do not assume any extra tables or columns unless explicitly stated.  
If a question is ambiguous, clarify it using the schema context rather than inventing new fields.  
Once you understand the schema, wait for my analytical question and generate the most accurate SQL query for it.

Tables and Key Columns:
  1. users(user_id, username, join_date, country)
  2. posts(post_id, user_id, content, created_at)
  3. comments(comment_id, post_id, user_id, comment_text, created_at)
  4. likes(like_id, post_id, user_id, created_at)
  5. followers(follower_id, user_id, follower_user_id, follow_date)
  6. hashtags(hashtag_id, tag_name, category)
  7. post_hashtags(id, post_id, hashtag_id)

Relationships:
  • Each user can create multiple posts.
  • Each post can have multiple likes and comments.
  • Users can follow each other (self-join in followers table).
  • Posts can be tagged with multiple hashtags (many-to-many via post_hashtags).
*/

-- Once you paste the schema, THEN use prompts like:
--   "Generate SQL to find top 10 active users combining posts and comments."
--   "Find trending hashtags used in more than 20 posts."
-- ==============================================================




-- ==============================================================
-- Q1. Most Active Users (Posts + Comments)
-- ==============================================================
-- Objective : Find top 10 users based on combined number of posts and comments.
-- Example GenAI Prompt :
--   "Write SQL to find top 10 active users combining posts and comments count."
-- Write your query below 👇
-- --------------------------------------------------------------
-- Your Code ...


SELECT
    u.user_id, u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT p.post_id) + COUNT(DISTINCT c.comment_id) AS total_activity
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
GROUP BY
    u.user_id,
    u.username
ORDER BY
    total_activity DESC
LIMIT 10;

-- Solution Summary -- 
/* 1. Started with the users table to include all registered users in the analysis.
2. Used LEFT JOIN to connect the posts and comments tables so that users with no posts or comments are also considered.
3. Counted the number of unique posts (post_id) and unique comments (comment_id) made by each user using COUNT(DISTINCT ...).
4. Calculated the Total Activity by adding the total number of posts and comments for each user.
5. Grouped the results by user_id and username to generate activity statistics for every user.
6. Sorted the results in descending order of Total Activity to identify the most active users.
7. Displayed only the Top 10 users using the LIMIT 10 clause.*/ 

-- ==============================================================
-- Q2. Most Liked Posts and Creators
-- ==============================================================
-- Objective : Identify posts with maximum likes along with their creator.
-- Example GenAI Prompt :
--   "Show top 10 posts with most likes and username."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    p.post_id,
    u.username,
    COUNT(l.like_id) AS total_likes
FROM posts p
JOIN users u
    ON p.user_id = u.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
GROUP BY
    p.post_id,
    u.username
ORDER BY
    total_likes DESC
LIMIT 10;

-- Solution Summary -- 
/* 1. Started with the posts table since each record represents a social media post.
2. Joined the users table to retrieve the username of the creator for each post.
3. Used a LEFT JOIN with the likes table to include all posts, even those with zero likes.
4. Counted the number of likes for each post using COUNT(l.like_id) to calculate the total likes received.
5. Grouped the results by post_id and username so that each post appears only once with its corresponding like count.
6. Sorted the posts in descending order based on the total number of likes to identify the most popular posts.
7. Displayed only the Top 10 most liked posts using the LIMIT 10 clause. */



-- ==============================================================
-- Q3. Top Countries by Average Engagement
-- ==============================================================
-- Objective : Find countries with the highest average likes per post.
-- Example GenAI Prompt :
--   "Which countries have highest average likes per post?"
-- --------------------------------------------------------------
-- Your Code ...

SELECT
    u.country,
    ROUND(AVG(IFNULL(l.like_count, 0)), 2) AS avg_likes_per_post
FROM posts p
JOIN users u
    ON p.user_id = u.user_id
LEFT JOIN (
    SELECT
        post_id,
        COUNT(*) AS like_count
    FROM likes
    GROUP BY post_id
) l
    ON p.post_id = l.post_id
GROUP BY
    u.country
ORDER BY
    avg_likes_per_post DESC;

-- Solution Summary -- 
/* 1. Started with the posts table because engagement is measured for each post.
2. Joined the users table to identify the country of the user who created each post.
3. Created a subquery on the likes table to calculate the total number of likes received by every post.
4. Used a LEFT JOIN to ensure posts with zero likes were also included in the analysis.
5. Applied IFNULL() to replace missing like counts with 0 before calculating the average.
6.Used the AVG() function to calculate the average likes per post for each country.
7.Rounded the average to two decimal places using ROUND() for better readability.
8.Grouped the results by country and sorted them in descending order to identify the countries with the highest average engagement. */ 

-- ==============================================================
-- Q4. Trending Hashtags (Used in >20 Posts)
-- ==============================================================
-- Objective : Find hashtags that appear in more than 20 posts.
-- Example GenAI Prompt :
--   "Find hashtags used in more than 20 posts."
-- --------------------------------------------------------------
-- Your Code ...

SELECT
    h.hashtag_id,
    h.tag_name,
    COUNT(DISTINCT ph.post_id) AS total_posts
FROM hashtags h
JOIN post_hashtags ph
    ON h.hashtag_id = ph.hashtag_id
GROUP BY
    h.hashtag_id,
    h.tag_name
HAVING COUNT(DISTINCT ph.post_id) > 20
ORDER BY total_posts DESC;

-- Solution Summary -- 
/*1. Started with the hashtags table to retrieve the details of each hashtag.
2.Joined the post_hashtags table, which serves as a bridge between posts and hashtags, to identify the posts associated with each hashtag.
3.Used COUNT(DISTINCT ph.post_id) to calculate the total number of unique posts in which each hashtag appears.
4.Grouped the results by hashtag_id and tag_name so that each hashtag is displayed only once with its corresponding post count.
5.Applied the HAVING COUNT(DISTINCT ph.post_id) > 20 condition to filter hashtags that appear in more than 20 posts, as specified in the question.
6.Sorted the results in descending order of total_posts to display the most frequently used hashtags first.
7. In the provided dataset, no hashtag appears in more than 20 posts, so the query returns no records. This indicates that the SQL query is correct, but the dataset does not contain any hashtags that satisfy the given condition.*/

-- ==============================================================
-- Q5. Top Influencers (Users with Most Followers)
-- ==============================================================
-- Objective : List users with the highest follower count.
-- Example GenAI Prompt :
--   "Find users with maximum followers."
-- --------------------------------------------------------------
-- Your Code ...

SELECT
    u.user_id,
    u.username,
    COUNT(f.follower_user_id) AS total_followers
FROM users u
LEFT JOIN followers f
    ON u.user_id = f.user_id
GROUP BY
    u.user_id,
    u.username
ORDER BY
    total_followers DESC
LIMIT 10;

-- Solution Summary -- 
/*1.Started with the users table to include all registered users in the analysis.
2.Used a LEFT JOIN to connect the followers table based on the user_id, ensuring that users with no followers are also included in the results.
3.Counted the number of followers for each user using COUNT(f.follower_user_id) to calculate the total followers received by each user.
4.Grouped the results by user_id and username so that each user appears only once with their corresponding follower count.
5.Sorted the results in descending order of total_followers to identify the users with the largest follower base.
6.Displayed only the Top 10 users with the highest number of followers using the LIMIT 10 clause. */


-- ==============================================================
-- Q6. Followers Who Never Interacted
-- ==============================================================
-- Objective : Identify users who follow others but have never liked or commented.
-- Example GenAI Prompt :
--   "Show users who follow others but never interacted."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    u.user_id,
    u.username
FROM users u
JOIN followers f
    ON u.user_id = f.follower_user_id
LEFT JOIN likes l
    ON u.user_id = l.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
WHERE l.like_id IS NULL
  AND c.comment_id IS NULL
GROUP BY
    u.user_id,
    u.username
ORDER BY
    u.user_id;


-- Solution Summary -- 
/* 1.Started with the users table to retrieve the details of all registered users.
2.Joined the followers table using follower_user_id to identify users who are following at least one other user.
3. Used LEFT JOIN with the likes table to check whether these users have liked any posts.
4. Used another LEFT JOIN with the comments table to verify whether they have commented on any posts.
5. Applied the WHERE clause with l.like_id IS NULL and c.comment_id IS NULL to filter users who have never performed either interaction.
6. Grouped the results by user_id and username to ensure each qualifying user appears only once.
7. Ordered the output by user_id for a clear and organized result. */

-- ==============================================================
-- Q7. Hashtags with Highest Engagement
-- ==============================================================
-- Objective : Calculate total engagement (likes + comments) for each hashtag.
-- Example GenAI Prompt :
--   "Calculate engagement score per hashtag."
-- --------------------------------------------------------------
-- Your Code ...

SELECT
    h.hashtag_id,
    h.tag_name,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
FROM hashtags h
JOIN post_hashtags ph
    ON h.hashtag_id = ph.hashtag_id
JOIN posts p
    ON ph.post_id = p.post_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY
    h.hashtag_id,
    h.tag_name
ORDER BY
    total_engagement DESC;

-- Solution Summary -- 

/*1.Started with the hashtags table to retrieve the details of each hashtag.
2.Joined the post_hashtags table to identify all posts associated with every hashtag.
3.Joined the posts table to access the posts linked to each hashtag.
4.Used LEFT JOIN with the likes and comments tables so that posts with no likes or comments are also included in the analysis.
5.Counted the number of unique likes using COUNT(DISTINCT l.like_id) and unique comments using COUNT(DISTINCT c.comment_id) to avoid duplicate counting caused by joins.
6.Calculated the Total Engagement by adding the total likes and total comments for each hashtag.
7.Grouped the results by hashtag_id and tag_name so that each hashtag appears only once with its engagement metrics.
8.Sorted the results in descending order of total_engagement to identify the hashtags generating the highest overall engagement. */



-- ==============================================================
-- Q8. Busiest Posting Hours or Days
-- ==============================================================
-- Objective : Find which hour/day sees most posting activity.
-- Example GenAI Prompt :
--   "Write SQL to show which hour or weekday sees most posts."
-- --------------------------------------------------------------
-- Your Code ...

SELECT
    HOUR(created_at) AS posting_hour,
    COUNT(post_id) AS total_posts
FROM posts
GROUP BY
    HOUR(created_at)
ORDER BY
    total_posts DESC;
    
-- Solution Summary -- 
/* 1.Started with the posts table since it contains the date and time when each post was created.
2.Used the HOUR(created_at) function to extract the hour (0–23) from the post timestamp.
3.Applied the COUNT(post_id) function to calculate the total number of posts created during each hour.
4.Grouped the results by the extracted hour so that each hour appears only once with its corresponding post count.
5.Sorted the results in descending order of total_posts to identify the busiest posting hours.
6. This analysis helps determine the time of day when users are most active in creating posts. */

-- ==============================================================
-- Q9. Inactive Users
-- ==============================================================
-- Objective : Find users who have never posted, liked, or commented.
-- Example GenAI Prompt :
--   "Find users who have never posted, liked, or commented."
-- --------------------------------------------------------------
-- Your Code ...

SELECT
    u.user_id,
    u.username
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON u.user_id = l.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
WHERE
    p.post_id IS NULL
    AND l.like_id IS NULL
    AND c.comment_id IS NULL
ORDER BY
    u.user_id;

-- Solution Summary -- 
/* 1. Started with the users table to include all registered users in the analysis.
2.Used a LEFT JOIN with the posts table to check whether each user has created any posts.
3.Used another LEFT JOIN with the likes table to determine whether each user has liked any posts.
4.Connected the comments table using a LEFT JOIN to verify whether each user has made any comments.
5.Applied the WHERE clause with p.post_id IS NULL, l.like_id IS NULL, and c.comment_id IS NULL to filter users who have never performed any of these activities.
6.Ordered the results by user_id to present the inactive users in an organized manner.
7.This query helps identify completely inactive users who have registered on the platform but have not engaged in posting, liking, or commenting. */

-- ==============================================================
-- Q10. Top Countries with Most Influencers
-- ==============================================================
-- Objective : Identify countries with the highest number of influencers.
-- Example GenAI Prompt :
--   "Generate SQL to find countries that have the most followed users."
-- --------------------------------------------------------------
-- Your Code ...
SELECT
    country,
    COUNT(user_id) AS total_influencers,
    SUM(follower_count) AS total_followers
FROM (
    SELECT
        u.user_id,
        u.country,
        COUNT(f.follower_user_id) AS follower_count
    FROM users u
    LEFT JOIN followers f
        ON u.user_id = f.user_id
    GROUP BY
        u.user_id,
        u.country
) AS t
GROUP BY
    country
ORDER BY
    total_followers DESC,
    total_influencers DESC;

-- Solution Summary -- 


-- ==============================================================
-- BONUS CHALLENGES
-- ==============================================================
-- 1. Engagement rate = (likes + comments) / posts

SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    ROUND(
        (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) /
        NULLIF(COUNT(DISTINCT p.post_id), 0),
        2
    ) AS engagement_rate
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY
    u.user_id,
    u.username
ORDER BY
    engagement_rate DESC;

/*Solution Summary
Started with the users table to include all registered users.
Joined the posts, likes, and comments tables to collect engagement data for each user's posts.
Counted the total number of posts, likes, and comments using COUNT(DISTINCT ...).
Calculated the engagement rate using the formula (Likes + Comments) / Posts.
Used NULLIF() to avoid division by zero for users with no posts.
Rounded the engagement rate to two decimal places and sorted the results in descending order. */



-- 2. Mutual followers

SELECT
    f1.user_id,
    f1.follower_user_id AS mutual_friend
FROM followers f1
JOIN followers f2
    ON f1.user_id = f2.follower_user_id
   AND f1.follower_user_id = f2.user_id
ORDER BY
    f1.user_id;

/* Solution Summary
Used the followers table twice with different aliases to compare follower relationships.
Matched records where two users follow each other.
The join condition checks that User A follows User B and User B follows User A.
Returned the user IDs involved in mutual following relationships.
Ordered the results by user_id for easier interpretation. */

-- 3. Most used hashtags by top 5 influencers

SELECT
    h.tag_name,
    COUNT(ph.post_id) AS total_usage
FROM hashtags h
JOIN post_hashtags ph
    ON h.hashtag_id = ph.hashtag_id
JOIN posts p
    ON ph.post_id = p.post_id
WHERE p.user_id IN (
    SELECT user_id
    FROM (
        SELECT
            u.user_id,
            COUNT(f.follower_user_id) AS followers
        FROM users u
        LEFT JOIN followers f
            ON u.user_id = f.user_id
        GROUP BY
            u.user_id
        ORDER BY
            followers DESC
        LIMIT 5
    ) AS top_users
)
GROUP BY
    h.hashtag_id,
    h.tag_name
ORDER BY
    total_usage DESC;
    
/*    Solution Summary
Identified the top five influencers based on follower count.
Retrieved the posts created by these influencers.
Joined the post_hashtags and hashtags tables to identify hashtags used in their posts.
Counted the number of times each hashtag was used.
Grouped the results by hashtag and sorted them in descending order of usage.
This analysis highlights the hashtags most frequently used by the platform's top influencers. */
    
-- 4. Country-wise engagement leaderboard
SELECT
    u.country,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement
FROM users u
JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON p.post_id = l.post_id
LEFT JOIN comments c
    ON p.post_id = c.post_id
GROUP BY
    u.country
ORDER BY
    total_engagement DESC;


/* Solution Summary
Started with the users table to identify the country of each post creator.
Joined the posts table to retrieve all posts created by users from each country.
Used LEFT JOIN with the likes and comments tables to include all engagement records.
Counted the total likes and comments received by posts from each country using COUNT(DISTINCT ...).
Calculated the total engagement by adding the total likes and total comments.
Grouped the results by country and sorted them in descending order of total engagement.
This leaderboard helps compare engagement levels across different countries and identify the most active regions. */
-- --------------------------------------------------------------

-- ==============================================================
-- REFLECTION
-- ==============================================================
-- 1. How did GenAI assist you in solving these queries?

/* GenAI helped by understanding each business requirement and converting it into the appropriate SQL query.
It suggested the correct SQL clauses such as JOIN, GROUP BY, HAVING, ORDER BY, and aggregate functions.
It helped identify and fix errors by matching the queries with the actual dataset schema.
GenAI also provided optimized query structures and explained the logic behind each solution through detailed solution summaries, 
making it easier to understand and learn. */

-- 2. What optimization tips did you learn?

/* Use LEFT JOIN only when it is necessary; otherwise, use INNER JOIN for better performance.
Select only the required columns instead of using SELECT *.
Use COUNT(DISTINCT ...) to prevent duplicate values caused by joins.
Apply filtering conditions early using the WHERE clause to reduce the amount of data processed.
Use GROUP BY and HAVING appropriately when working with aggregate functions.
Sort results only when required, as ORDER BY can increase query execution time.
Use indexes on frequently searched or joined columns such as user_id, post_id, and hashtag_id to improve performance. */

-- 3. What business insights stood out to you?
-- ==============================================================
/* User engagement can be measured by combining posts, likes, comments, and follower counts.
Highly followed users (influencers) play a significant role in increasing platform engagement.
Popular hashtags help identify trending topics and improve content visibility.
Monthly user growth provides insights into the platform's growth over time.
Country-wise engagement analysis helps identify the most active user regions and supports targeted marketing strategies.
Identifying inactive users enables businesses to create re-engagement campaigns and improve user retention.
Analyzing posting hours and days helps determine the best times to publish content for maximum audience reach. */
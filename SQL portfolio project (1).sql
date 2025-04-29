SELECT * FROM badges;
SELECT * FROM comments;
SELECT * FROM post_history;
SELECT * FROM post_links;
SELECT * FROM posts;
SELECT * FROM tags;
SELECT * FROM users;
SELECT * FROM votes;

-- Explore the structure and first 5 rows of each table.

describe badges;
describe comments;
describe post_history;
describe post_links;
describe posts;
describe tags;
describe users;
describe votes;

select * from badges limit 5 ;
select * from comments limit 5 ;
select * from post_history limit 5 ;
select * from post_links limit 5 ;
select * from posts limit 5 ;
select * from tags limit 5 ;
select * from users limit 5 ;
select * from votes limit 5 ;

-- Identify the total number of records in each table.

select count(*) from badges;
select count(*) from comments;
select count(*) from post_history;
select count(*) from post_links;
select count(*) from posts;
select count(*) from tags;
select count(*) from users;
select count(*) from votes;

-- Find all posts with a view_count greater than 100
select * from posts 
where view_count > 100;

-- Display comments made in 2005, sorted by date of creation
select * from comments 
where post_id= 2005
order by creation_date;

-- Count the total number of votes for each post_id.
select post_id,count(vote_type_id) as vote_counts
from votes
group by post_id;

-- Calculate the count and average score of posts per post_tag_id.
select post_tag_id,count(score) as score_count,avg(score) as avg_score
from posts
group by post_tag_id;

--  Combine the post_history and posts tables to display the title of posts and the corresponding changes made in the post history
 select ph.*,p.title
 from post_history ph
 join posts p on ph.user_id=p.user_id;
 
 -- Show user details and the total badges earned by each user.
 select u.id,u.display_name,u.reputation,u.creation_date,count(b.id) as total_badges
 from users u
 join badges b on u.id=b.user_id 
 group by u.id,u.display_name,u.reputation,u.creation_date ;
 
 -- Fetch the titles of posts, their comments, and the users who made those comments
select p.title,c.text,u.id,u.display_name
from users u
 join posts p on p.user_id=u.id
 join comments c on c.user_id=u.id;

 -- Combine post_links with posts to list related questions.
 select pl.*,p.title
 from post_links pl
 join posts p on pl.post_id=p.id;
 
-- Find the users who have earned badges and also made comments.
 select distinct u.id, u.display_name
 from users u
 join comments c on c.user_id=u.id
 join badges b on b.user_id=u.id;
  
-- Find all users with the highest reputation 

 select * from users 
 where reputation in ( select max(reputation) from users);
 
 -- Retrieve posts with the highest score in each post_tag_id

 
 -- with a correrlated query
 select *
from posts p
where (post_tag_id, score) in (select post_tag_id,max(score)
									from posts
									where post_tag_id = p.post_tag_id)
order by post_tag_id;


 -- with CTE
 select p.*
from posts p
join (
    select post_tag_id, max(score) as max_score
    from posts
    group by post_tag_id
) as max_scores
on p.post_tag_id = max_scores.post_tag_id and p.score = max_scores.max_score
order by max_scores.max_score;

-- For each post, fetch the number of related posts from post_links.
 
 -- with a join
 select p.id, p.title, COUNT(pl.related_post_id) as num_related_posts
from posts p
left join post_links pl on p.id = pl.post_id
group by p.id, p.title
order by p.id;
 
 -- with CTE
 with related_post as ( select post_id,count(related_post_id) as counts
						from post_links group by post_id)
 select * from posts p
 join related_post on related_post.post_id=p.id;

-- Rank posts based on their score within each post_tag_id.
select *, rank() over(partition by post_tag_id order by score desc) as post_ranks
from posts;

-- Calculate the running total of badges earned by users in chronological order.
select *, count(user_id) over (partition by user_id order by date) as total_badges
from badges ;

-- Find out the date for each user on which their total badges went over 1.

 
  with badge_counts as (
    select user_id, date,
           row_number() over (partition by user_id order by date) as count
    from badges
)
select user_id, min(date) as min_date
from badge_counts
where count > 1
group by user_id;

-- Create a CTE to calculate the average score of posts by each user and use it to:

select user_id,avg(score) as score from posts group by user_id order by user_id;

-- Show user_ids, display_name, reputation and avg_score for users with an average score above 40.
 
 with avg_scores as (select user_id,avg(score) as score from posts group by user_id order by user_id)
 
 select u.id,u.display_name,u.reputation,av.score
 from users u
 join avg_scores av
 on av.user_id=u.id
where av.score>40;

-- Rank users based on their average post score. Show user_ids,display_name, reputation, avg_score and rank.

with avg_score as (select user_id,avg(score) as score from posts group by user_id order by user_id)
select u.id,u.display_name,u.reputation,av.score ,rank() over(order by av.score) as ranks
from users u
join avg_score av
on u.id=av.user_id
order by ranks;

-- NEW INSIGHTS AND QUESTIONS

-- Total no of posts made by each user
select u.id,u.display_name,count(p.user_id) as post_count
from users u
join posts p
on u.id=p.user_id
group by u.id,u.display_name
order by u.id;

-- Find posts with the highest score for each post_tag_id

with max_scores as (select post_tag_id, max(score) as max_score
    from posts
    group by post_tag_id)
select p.id, p.title, p.score, p.post_tag_id
from posts p
join max_scores m on p.post_tag_id = m.post_tag_id and p.score = m.max_score;

-- most recent comment made by each user

select c.user_id,c.text,md.dates
from comments c
join
(select user_id,max(creation_date) as dates from comments group by user_id) as md
on c.user_id=md.user_id and c.creation_date=md.dates;

-- find posts made by user 1005 and 1002
 select * 
 from posts
 where user_id in (1005,1002);

 -- Show all details of users who earned 'Silver Helper' badge
 
 select u.*,b.name
 from users u
 join badges b on b.user_id=u.id
 where b.name= "Silver Helper";
 
 
 


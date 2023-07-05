drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup (userid, gold_signup_date)
VALUES (1, '2017-09-22'),
       (3, '2017-04-21');
       
drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users (userid, signup_date)
VALUES (1, '2014-09-02'),
       (2, '2015-01-15'),
       (3, '2014-04-11');


drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales (userid, created_date, product_id)
VALUES (1, '2017-04-19', 2),
       (3, '2019-12-18', 1),
       (2, '2020-07-20', 3),
       (1, '2019-10-23', 2),
       (1, '2018-03-19', 3),
       (3, '2016-12-20', 2),
       (1, '2016-11-09', 1),
       (1, '2016-05-20', 3),
       (2, '2017-09-24', 1),
       (1, '2017-03-11', 2),
       (1, '2016-03-11', 1),
       (3, '2016-11-10', 1),
       (3, '2017-12-07', 2),
       (3, '2016-12-15', 2),
       (2, '2017-11-08', 2),
       (2, '2018-09-10', 3);



drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;

select * from product;
select * from goldusers_signup;
select * from users;

-- what is total each customer spent on the company?--
SELECT s.userid, sum(p.price) as total_amount_spent
FROM sales s
INNER JOIN product p ON s.product_id = p.product_id
group by s.userid;

-- how many days each customer visited the company's site?

SELECT userid, count(distinct created_date) as times_visited
FROM sales
GROUP BY userid;

-- what was the first product purchased by each customer?--


SELECT *
FROM (
  SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk
  FROM sales
) a 
WHERE rnk = 1;


-- What is the most purchased item on the menu and how many times was it purchased by all customers?--
select product_id, count(product_id) as mostpurchased from sales
 group by product_id order by count(product_id) desc limit 1 ; 
 
 select userid, count(product_id) from sales where product_id = 2
 group by userid order by userid;
 
 -- most popular item for each customer?--
select * from
(select *, rank() over (partition by userid order by cnt desc) rnk from
(select userid, count(product_id) cnt, product_id from sales group by userid, product_id)a)b
where rnk = 1;

-- which item was purchased first by the customer after they became a member?--

select* from (select*, rank() over (partition by userid order by Created_date asc) as rnk from
(select s.userid, s.product_id, s.created_date, g.gold_signup_date 
from sales s inner join goldusers_signup g on s.userid = g.userid
where s.created_date>=g.gold_signup_date) b)c where rnk = 1;

-- which item was purchased just before they became member?--
select * from (select*, rank() over (partition by userid order by created_date desc) as rnk from
(select s.userid, s.product_id, s.created_date, g.gold_signup_date 
from sales s inner join goldusers_signup g on s.userid = g.userid
where s.created_date<=g.gold_signup_date) b)c where rnk = 1; 


-- total orders and amount spent for each member before they became a member?--
select userid, count(created_date), sum(price) from
(select a.*,p.price from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s 
inner join goldusers_signup g on g.userid = s.userid and created_date<=gold_signup_date) 
a inner join product p on p.product_id = a.product_id)b group by userid order by userid asc;




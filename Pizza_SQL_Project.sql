create database pizzahut;
Create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)) ;

Create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));





-- Que 1. Retrive Total number of order placed.
select count(order_id) as total_orders from orders










-- Que 2. Calculate total revenue generated from Pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_Sales
FROM
    order_details
        JOIN
    pizzas






-- Que 3. Identity the highest priced pizza

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
ORDER BY pizzas.price DESC
LIMIT 10;








-- Que 4. Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as order_count 
from pizzas join order_details
using (pizza_id)
group by pizzas.size order by order_count desc;









-- Que 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.name
ORDER BY quantity DESC;








-- Que 6 .Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    order_details USING (pizza_type_id)
        JOIN
    pizzas USING (pizza_id)
GROUP BY pizza_types.category
ORDER BY quantity DESC;








-- Que 7.Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) as Hour, COUNT(order_id) as Count
FROM
    orders
GROUP BY HOUR(order_time)


-- Que 8. Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) from pizza_types
group by category


-- Que 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details USING (order_id)
    GROUP BY 1) order_quantity;




-- Que 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;




-- Que 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    (SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_Sales
        FROM
            order_details
                JOIN
            pizzas using(pizza_id)) * 100) AS revenue
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.category
ORDER BY revenue DESC





-- Que 12. Analyze the cumulative revenue generated over time.

select order_date,
round(sum(revenue) over(order by order_date),2) as cum_revenue from 
(select 
orders.order_date, 
round(sum(order_details.quantity * pizzas.price),2) as revenue
from order_details join pizzas
using (pizza_id)
join orders
using (order_id)
group by orders.order_date) as sales 

-- Que 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select  name, revenue 
from
(select 
category, name, revenue, rank()
over(partition by category order by revenue) as rn 
from 
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas 
using (pizza_type_id)
join order_details
using (pizza_id)
group by  pizza_types.category, pizza_types.name) as a) as b 
where rn <=3;

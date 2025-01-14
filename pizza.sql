select * from order_details
select * from orders
select * from pizza_types
select * from pizzas


--Basic:
--Retrieve the total number of orders placed.
select count(order_id) as Total_Orders from orders


--Calculate the total revenue generated from pizza sales.
select 
round(sum(order_details.quantity * pizzas.price), 2)as Total_Sales
from order_details join pizzas	
on order_details.pizza_id = pizzas.pizza_id

--Identify the highest-priced pizza.
select top 1
pizza_types.name, pizzas.price	
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc

--Identify the most common pizza size ordered.
select pizzas.size,count(order_details.order_details_id) as count_of_pizzas
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size 


--List the top 5 most ordered pizza types along with their quantities.
select top 5 
pizza_types.name, sum(order_details.quantity) as total_count
from pizza_types
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by total_count desc


--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity) as qunatity
from pizza_types join pizzas
on pizza_types.pizza_type_id  = pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category 
order by qunatity desc


--Determine the distribution of orders by hour of the day.
select * from orders
select day(time) from orders
select GETDATE()
select day(2025-01-09)

select extract(hour from time) as order_time from orders
--Join relevant tables to find the category-wise distribution of pizzas.

select count(name), category from pizza_types
group by category
order by count(name) desc


--Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) as avg_pizza_ordered from
( select orders.date, sum(order_details.quantity) as quantity
 from orders join order_details
 on orders.order_id = order_details.order_id
 group by orders.date ) as Total_quantity

--Determine the top 3 most ordered pizza types based on revenue.
select top 3 
pizza_types.name,
round(sum(order_details.quantity * pizzas.price),0) as revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc

--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(sum(order_details.quantity * pizzas.price) /
(select 
round(sum(order_details.quantity * pizzas.price), 2)as Total_Sales
from order_details join pizzas	
on order_details.pizza_id = pizzas.pizza_id) * 100,2)
as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id	
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc 


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name, revenue , rn from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join  order_details
on order_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category, pizza_types.name) as a)as b
where rn <= 3
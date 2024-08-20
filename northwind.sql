Use [Northwind]

--1.	Calculate the total number of customers, products, suppliers and employees.
SELECT (SELECT COUNT(*) FROM Customers) [# Customers],
(SELECT COUNT(*) FROM Products) [# Products],
(SELECT COUNT(*) FROM Suppliers) [# Suppliers],
(SELECT COUNT(*) FROM Employees) [# Employees]


--2.	Select product name, unit price and their corresponding supplier company name for products. 
--[Tables to use: Products, Suppliers]
SELECT ProductName, UnitPrice, s.CompanyName
FROM Products p INNER JOIN Suppliers s
ON p.SupplierID = s.SupplierID

-- Alternative way
--SELECT ProductName, UnitPrice, s.CompanyName
--FROM Products p, Suppliers s
--WHERE p.SupplierID = s.SupplierID
	

--3.	Modify step 2 so that only products that have not been discontinued will be displayed 
--(for discontinued, True=1, False=0).

SELECT ProductName, UnitPrice, s.CompanyName, p.Discontinued
FROM Products p INNER JOIN Suppliers s
ON p.SupplierID = s.SupplierID
WHERE p.Discontinued = 0


--4.	Select the orderID, product name, unit price, quantity, discount and calculate the total amount for the top 20 items. 
--Note: total amount = (unit price * quantity) – discount. [Tables to use: Order Details, Products]

SELECT TOP(20) od.OrderID, p.ProductName, od.UnitPrice, od.Quantity, od.Discount, 
od.UnitPrice * od.Quantity - od.Discount [Total Amount]
FROM [Order Details] od INNER JOIN Products p
ON od.ProductID = p.ProductID



--5.	Select order dates and show the total amount of items sold on those dates. 
--[Tables to use: Order Details, Orders]

-- Step 1
--SELECT o.OrderID, o.OrderDate, od.Quantity
--FROM Orders o INNER JOIN [Order Details] od
--ON o.OrderID = od.OrderID

-- Step 2
SELECT o.OrderID, o.OrderDate, SUM(od.Quantity) [Total Items]
FROM Orders o INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.OrderDate


--6.	What is the average daily sale?

DECLARE @total AS float
DECLARE @count AS float
SET @total = (SELECT SUM(od.UnitPrice * od.Quantity - od.Discount) [Total Sales] FROM [Order Details] od)
SET @count = (SELECT COUNT(DISTINCT o.OrderDate) [Total Sales Day] FROM Orders o)
SELECT @total [Total Sales], @count [Total Days], @total / @count as [Avg Daily Sales]


--7.	Which days have sales been below average?

-- We need the SQL FROM Q6
DECLARE @total AS float
DECLARE @count AS float
SET @total = (SELECT SUM(od.UnitPrice * od.Quantity - od.Discount) [Total Sales] FROM [Order Details] od)
SET @count = (SELECT COUNT(DISTINCT o.OrderDate) [Total Sales Day] FROM Orders o)
SELECT @total [Total Sales], @count [Total Days], @total / @count as [Avg Daily Sales]

-- Avg Sales Per Day
SELECT o.OrderDate, 
SUM(od.UnitPrice * od.Quantity - od.Discount)/COUNT(DISTINCT o.OrderID) [Avg Sales Per Day],
@total / @count as [Avg Daily Sales]
FROM Orders o INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.OrderDate
HAVING SUM(od.UnitPrice * od.Quantity - od.Discount)/COUNT(DISTINCT o.OrderID) > @total / @count


--8.	Which employee has the biggest sale in terms of amount sold?

-- partly similar to Q4
SELECT TOP(3) e.FirstName + ' ' + e.LastName [Full Name], o.OrderID, od.UnitPrice * od.Quantity - od.Discount [Total Amount]
FROM Orders o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
GROUP BY e.FirstName, e.LastName, o.OrderID, od.UnitPrice, od.Quantity, od.Discount
ORDER BY od.UnitPrice * od.Quantity - od.Discount DESC

--9.	Which employee has the biggest sale in terms of quantity sold?

-- Very similar to Q8 and partly similar to Q5
SELECT TOP(3) e.FirstName + ' ' + e.LastName [Full Name], o.OrderID, SUM(od.Quantity) [Total Items]
FROM Orders o INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Employees e ON o.EmployeeID = e.EmployeeID
GROUP BY e.FirstName, e.LastName, o.OrderID
ORDER BY SUM(od.Quantity) DESC

--10.	Which product sells best and which doesn’t?

DECLARE @best AS varchar(50)
DECLARE @bestQty AS int
DECLARE @worst AS varchar(50)
DECLARE @worstQty AS int

SET @best =
(SELECT TOP(1) p.ProductName -- get the best selling product name
FROM [Order Details] od INNER JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY od.ProductID, p.ProductName
ORDER BY SUM(od.Quantity) DESC)

SET @bestQty =
(SELECT TOP(1) SUM(od.Quantity) -- get the best selling product quatity
FROM [Order Details] od INNER JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY od.ProductID, p.ProductName
ORDER BY SUM(od.Quantity) DESC)

SET @worst =
(SELECT TOP(1) p.ProductName -- get the worst selling product name
FROM [Order Details] od INNER JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY od.ProductID, p.ProductName
ORDER BY SUM(od.Quantity))

SET @worstQty =
(SELECT TOP(1) SUM(od.Quantity) -- get the worst selling product quantity
FROM [Order Details] od INNER JOIN Products p
ON od.ProductID = p.ProductID
GROUP BY od.ProductID, p.ProductName
ORDER BY SUM(od.Quantity))

SELECT @best [Best Selling Item], @bestQty [Best Selling Qty], @worst [Worst Selling Item], @worstQty [Worst Selling Qty]


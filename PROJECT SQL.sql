--Project 

--You have been hired by the company as a Data Analyst. The Organization would like to get insights to address various 
--business challenges related to customer segmentation. 


--Customer Segmentation:

--Problem: How can we segment our customer base to better understand their behavior and needs?
--Questions: Can you group customers based on their recency, frequency, and monetary value? What are the different 
--customer segments that emerge from the analysis?



--UNDERSTANDING THE TABLE

SELECT * FROM [AdventureWorks2017].[Sales].[Customer]

--19820 CUSTOMERS
SELECT COUNT(DISTINCT CustomerID)
FROM [AdventureWorks2017].[Sales].[Customer]

--10 TERRITORIES
SELECT COUNT(DISTINCT TerritoryID) 
FROM [AdventureWorks2017].[Sales].[Customer]

SELECT * FROM [AdventureWorks2017].[Production].[Product]

--504 PRODUCTS
SELECT COUNT (DISTINCT ProductID)
FROM [AdventureWorks2017].[Production].[Product]


SELECT * FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]

--SALES CAME FROM 10 TERRITORIES
SELECT COUNT(DISTINCT TerritoryID) 
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]

--TOP 3 TERRITORIES IS 4,6,1
SELECT TerritoryID, SUM(TotalDue) AS Revenue FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]
GROUP BY TerritoryID
ORDER BY Revenue DESC

--OUR BEST SALES MEN ARE 276, 277, 275
SELECT SalesPersonID, SUM(TotalDue) AS Revenue 
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]
GROUP BY SalesPersonID
ORDER BY Revenue DESC


SELECT * FROM [AdventureWorks2017].[Sales].[SalesOrderDetail]

-- PRODUCT 782 GROSSED THE HIGHEST AMOUNT
SELECT ProductID, SUM(LineTotal) AS Revenue FROM [AdventureWorks2017].[Sales].[SalesOrderDetail]
GROUP BY ProductID
ORDER BY Revenue DESC



SELECT * FROM [AdventureWorks2017].[Production].[Product]
SELECT * FROM [AdventureWorks2017].[Sales].[Customer]
SELECT * FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]
SELECT * FROM [AdventureWorks2017].[Sales].[SalesOrderDetail]

--Customer x SalesOrderHeader = CustomerID(foreign key)
--SalesOrderDetail x SalesOrderHeader = SalesOrderID (foreign key)
-- Product x SalesOrderDetails = ProductID(foreign key)


-- TABLE JOINS
SELECT C.CustomerID, S.AccountNumber 
FROM [AdventureWorks2017].[Sales].[Customer] C INNER JOIN [AdventureWorks2017].[Sales].[SalesOrderHeader] S
ON C.CustomerID = S.CustomerID

SELECT P.ProductID, S.LineTotal FROM [AdventureWorks2017].[Production].[Product] P
INNER JOIN [AdventureWorks2017].[Sales].[SalesOrderDetail] S
ON P.ProductID=S.ProductID


--SalesOrderHeader (Subtotal = Monetary)
--SalesOrderHeader (OrderDate = Recency)
--SalesOrderHeader (CustomerID = Frequency)


Select count(*) from [AdventureWorks2017].[Sales].[SalesOrderHeader]

Select count(*) from [AdventureWorks2017].[Sales].[SalesOrderDetail]

Select * from [AdventureWorks2017].[Sales].[SalesOrderHeader] -- 30k rows (details about each other)
Select * from [AdventureWorks2017].[Sales].[SalesOrderDetail] --121k rows (shows items in each bucket)



--FREQUENCY
SELECT CustomerID, COUNT(*) AS FREQUENCY
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]
GROUP BY CustomerID
ORDER BY FREQUENCY DESC

SELECT MAX(ORDERDATE) FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]


--FREQUENCY, RECENCY, MONETARYVALUE

SELECT CustomerID, COUNT(CustomerID) AS FREQUENCY, SUM(SUBTOTAL) AS MONETARYVALUE,
DATEDIFF(DAy, MAX(orderDate), '2014-06-30 00:00:00.000') AS RECENCY
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]
GROUP BY CustomerID
ORDER BY FREQUENCY DESC

--TURN INTO A TABLE (RFM)
SELECT CustomerID, COUNT(CustomerID) AS FREQUENCY, SUM(SUBTOTAL) AS MONETARYVALUE,
DATEDIFF(DAy, MAX(orderDate), '2014-06-30 00:00:00.000') AS RECENCY
into [AdventureWorks2017].[Sales].RFM
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader]
GROUP BY CustomerID
ORDER BY FREQUENCY DESC

SELECT * FROM [AdventureWorks2017].[Sales].RFM

--TURN INTO A TABLE (RFMSCORE)
SELECT CustomerID,FREQUENCY,MONETARYVALUE,RECENCY, 
NTILE (4) OVER (ORDER BY RECENCY) AS RECENCY_SCORE,
NTILE (4) OVER (ORDER BY FREQUENCY) AS FREQUENCY_SCORE,
NTILE (4) OVER (ORDER BY MONETARYVALUE) AS MONETARYVALUE_SCORE
INTO [AdventureWorks2017].[Sales].RFMSCORE
FROM [AdventureWorks2017].[Sales].RFM

SELECT * FROM [AdventureWorks2017].[Sales].RFMSCORE

--TURN INTO A TABLE (RFMCASTED)
SELECT CustomerID,FREQUENCY,MONETARYVALUE,RECENCY,RECENCY_SCORE,FREQUENCY_SCORE,MONETARYVALUE_SCORE,
CAST (RECENCY_SCORE AS VARCHAR)+ CAST (FREQUENCY_SCORE AS VARCHAR)+ CAST (MONETARYVALUE_SCORE AS VARCHAR) AS RFMSCORE
INTO [AdventureWorks2017].[Sales].RFMCASTED
FROM [AdventureWorks2017].[Sales].RFMSCORE

SELECT * FROM [AdventureWorks2017].[Sales].RFMCASTED 


--What are the different customer segments that emerge from the analysis?

SELECT RFMSCORE,
CASE
    WHEN RFMSCORE in (144, 244) THEN 'BEST CUSTOMERS'
    WHEN RFMSCORE in (411, 311) THEN 'WORST CUSTOMERS'
END
FROM [AdventureWorks2017].[Sales].RFMcasted

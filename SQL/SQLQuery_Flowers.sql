CREATE DATABASE Caxki_srah;
go
use Caxki_srah;
go

--Ashxatoxner
CREATE TABLE Employee (
    id INT NOT NULL PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    phone_number NVARCHAR(20) NOT NULL,
    address_ NVARCHAR(50) NOT NULL,
    birthday DATE NOT NULL,
	SSN NVARCHAR(20) NOT NULL,
    email NVARCHAR(50) CHECK (email LIKE '%@%.%') NOT NULL,
    gender NVARCHAR(20) NOT NULL,
    position_id INT NOT NULL,
 CONSTRAINT CK_Phone CHECK (phone_number NOT LIKE '+374%[^0-9]%' AND LEN(phone_number) = 12)
);

--Pashton
CREATE TABLE Position (
    ID INT NOT NULL,
    position_name NVARCHAR(50) NOT NULL,
    salary MONEY NOT NULL,
	CONSTRAINT PK_Position PRIMARY KEY (ID) 
);

--Vacharq
CREATE TABLE Sales (
    Sale_id INT NOT NULL,
    flower_id INT NOT NULL,
    sales_quantity INT NOT NULL,
    price MONEY NOT NULL,
    sale_date DATE NOT NULL,
    employee_id INT NOT NULL,
    shipping_id INT,
    payment_method NVARCHAR(50) NOT NULL,
);

ALTER TABLE Sales
ADD CONSTRAINT PK_Sales PRIMARY KEY (Sale_id);


--Araqum

CREATE TABLE Shipping (
    Ship_id INT NOT NULL PRIMARY KEY,
    shipping_date DATE NOT NULL,
    shipping_address NVARCHAR(255) NOT NULL,
    shipping_pay MONEY,
);

--Caxikner
CREATE TABLE Flowers (
    F_id INT NOT NULL,
    flower_name NVARCHAR(50) NOT NULL,
    flower_quantity INT,
    flower_price MONEY NOT NULL,
    supplier_id INT NOT NULL,
    CONSTRAINT PK_Flowers PRIMARY KEY (F_id) 
);


--Matakarar
CREATE TABLE Supplier (
    Sup_id INT NOT NULL PRIMARY KEY,
    firstname NVARCHAR(50) NOT NULL,
    lastname NVARCHAR(50) NOT NULL,
    sup_phone NVARCHAR(20) NOT NULL,
    sup_email NVARCHAR(50) NOT NULL,
    s_address NVARCHAR(50) NOT NULL,
);


--Foreign keys
--1
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee
FOREIGN KEY (position_id) REFERENCES Position(ID);

--2
ALTER TABLE Sales 
ADD CONSTRAINT FK_Sales 
FOREIGN KEY (flower_id) REFERENCES Flowers(F_id);

--3
ALTER TABLE Sales 
ADD CONSTRAINT FK_Saless 
FOREIGN KEY (employee_id) REFERENCES Employee(id);

--4
ALTER TABLE Sales 
ADD CONSTRAINT FK_sale
FOREIGN KEY (shipping_id) REFERENCES Shipping(Ship_id);

--5
ALTER TABLE Flowers 
ADD CONSTRAINT FK_Flowers
FOREIGN KEY (supplier_id) REFERENCES Supplier(Sup_id);



--Checks

ALTER TABLE Employee
ADD CONSTRAINT CK_Gender CHECK (gender IN ('Male', 'Female'));

ALTER TABLE  Employee 
ADD CONSTRAINT CK_BD CHECK (DATEDIFF(YEAR, birthday, GETDATE()) >= 18);

ALTER TABLE Employee 
ADD CONSTRAINT CK_SSN CHECK (SSN NOT LIKE '%[^0-9]%' AND LEN(SSN) = 10)

ALTER TABLE Supplier 
ADD CONSTRAINT CK_SPhone CHECK (sup_phone NOT LIKE '+374%[^0-9]%' AND LEN(sup_phone) = 12);

ALTER TABLE Supplier
ADD CONSTRAINT CK_Semail CHECK (sup_email LIKE '%@%.%')

ALTER TABLE Sales
ADD CONSTRAINT CK_PaymentMethod CHECK (payment_method IN ('Cash', 'Card'));


--UNIQUE
--1
ALTER TABLE Employee 
ADD UNIQUE(SSN);

--2
ALTER TABLE Employee
ADD CONSTRAINT UC_Email UNIQUE (email);

--3
ALTER TABLE Position
ADD CONSTRAINT UC_PositionName UNIQUE (position_name);

--4
ALTER TABLE Flowers
ADD CONSTRAINT UC_FlowersName UNIQUE (flower_name);

--DEFAULTS
--1
ALTER TABLE Sales
ADD CONSTRAINT DF_PaymentMethod DEFAULT 'Cash' FOR payment_method;

--2
ALTER TABLE Sales
ADD CONSTRAINT DF_SaleDate DEFAULT GETDATE() FOR sale_date;

--3
ALTER TABLE Flowers
ADD CONSTRAINT DF_FlowerQuantity DEFAULT 0 FOR flower_quantity; 



--Trigger
--vacharqi het kap unenan miayn vacharoxnery
CREATE TRIGGER tSalesEmployee
ON Sales
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Employee e ON i.employee_id = e.id
        JOIN Position p ON e.position_id = p.ID
        WHERE p.position_name != 'Vacharox'
    )
    BEGIN
        IF UPDATE(employee_id)
        BEGIN
            RAISERROR ('Only employees with the position "Vacharox" can be related to sales. This operation has been aborted due to an update.', 16, 1);
        END
        ELSE
        BEGIN
            RAISERROR ('Only employees with the position "Vacharox" can be related to sales. This operation has been aborted due to an insert.', 16, 1);
        END
        ROLLBACK TRANSACTION;
    END
END;

-- Update 
UPDATE Sales
SET employee_id = 2
WHERE Sale_id = 11; 


--araqumy katarvi henc vacharqi ory
CREATE TRIGGER ShippingDate
ON Shipping
AFTER INSERT
AS
BEGIN
    DECLARE @SalesDate DATE;
    DECLARE @DeliveryDate DATE;
    DECLARE @SaleID INT;

    SELECT @SaleID = s.Sale_id, @DeliveryDate = i.shipping_date
    FROM inserted i
    INNER JOIN Sales s ON i.Ship_id = s.sale_id;


    SELECT @SalesDate = sale_date
    FROM Sales
    WHERE Sale_id = @SaleID;

    IF @SalesDate != @DeliveryDate
    BEGIN

        RAISERROR ('Delivery date must match the sales date.', 16, 1);
        ROLLBACK TRANSACTION;
    END;
END;



--INSERT TABLES
INSERT INTO Position(ID, position_name, salary)
VALUES(5,'Vacharox', 90000),
(6,'Dizayner', 120000),
(7,'Tnoren', 400000),
(4,'Hashvapah', 200000),
(3,'Havaqarar', 80000);


INSERT INTO Employee(id, first_name, last_name, phone_number, address_, birthday, SSN, email, gender, position_id)
VALUES
    (1, 'Garik', 'Sargsyan', '+37499658741', 'Yerevan, Armenian St 123', '1990-01-01', '2514631548', 'g.sargsyan@gmail.com', 'Male', 5),
    (2, 'Susan', 'Asatryan', '+37433541122', 'Vanadzor, Shahumyan St 3', '1995-02-15', '1455163318', 's.asatryan@gmail.com', 'Female', 6),
    (3, 'Hrach', 'Aghajanyan', '+37499874111', 'Gyumri, Marshallyan St 12', '2000-12-31', '3666141741', 'h.aghajanyan@gmail.com', 'Male', 7),
    (4, 'Anna', 'Sedrakyan', '+37493655889', 'Yerevan Abovyan St 48', '1998-04-10', '1147859635', 'annasedrakyan@gmail.com', 'Female', 4),
    (5, 'Maria', 'Petrosyan', '+37499874521', 'Armavir Baxramyan St 13', '2001-06-15','5874691221', 'mariapetrosyan@gmail.com', 'Female', 6),
    (6, 'Karine', 'Bakunc', '+37433547896', 'Yerevan Shahumyan St 7', '1980-10-15', '1478523698', 'karinebakunc@gmail.com', 'Female', 3),
    (7, 'Ani', 'Grigoryan', '+37499874541', 'Kapan  St 48', '1990-04-10', '2511463987', 'anigriogoryan@gmail.com', 'Female', 5);
    
INSERT INTO Supplier(Sup_id, firstname, lastname, sup_phone, sup_email, s_address)
Values
(1, 'Armen', 'Adunc', '+37499254111', 'armen.adunc@mail.ru', 'Yerevan, Isakov St 64'),
(2, 'Narek', 'Avetisyan', '+37491254788', 'narek.avetisyan@gmail.com', 'Gyumri, Haxtanak St 12'),
(3, 'Vahe', 'Shalunc', '+37494113369', 'shalunc@mail.ru', 'Vanadzor, Tumanyan St 47'),
(4, 'Gevorg', 'Petrosyan', '+37497144458', 'gpetrosyan@gmail.com', 'Dilijan, Tsaturyan St 79'),
(5, 'Ashot', 'Grigoryan', '+37433255587', 'ashgrigoryan@mail.ru', 'Abovyan, Paruyr Sevak St 55');


INSERT INTO Flowers(F_id, flower_name, flower_quantity, flower_price, supplier_id)
VALUES
(1, 'Vard', 100, 800, 1),
(2, 'Kakach', 150, 450, 2),
(3, 'Ericuk', 200, 350, 3),
(4, 'Yasaman', 120, 500, 4),
(5, 'Kholorc', 80, 1500, 5),
(6, 'Arevacaxik', 900, 1250, 1),
(7, 'Mexak', 220, 850, 2),
(8, 'Manushak', 90, 250, 3),
(9, 'Pion', 130, 1000, 4),
(10, 'Qrisantem', 110, 800, 5),
(11, 'Cncaxik', 70, 300, 1),
(12, 'Iris', 100, 1100, 2),
(13, 'Shushan', 150, 650, 3),
(14, 'Nargiz', 200, 400, 4),
(15, 'Gerbera', 120, 200, 5);

INSERT INTO Shipping(Ship_id, shipping_date, shipping_address, shipping_pay)
VALUES
(1, '2024-02-24', 'Yerevan, Tumanyan St', 0),
(2, '2024-02-25', 'Yerevan, Shinararner St', 1000),
(3, '2024-02-26', 'Yerevan, Gyumri St ', 1200),
(4, '2024-01-27', 'Yerevan, Davit Bek St', 1000),
(5, '2024-02-28', 'Yerevan, Komitas Ave', 800),
(6, '2024-03-01', 'Yerevan, Arshakunyats Ave', 600),
(7, '2024-01-02', 'Yerevan, Azatutyan Ave, ', 500),
(8, '2024-01-03', 'Yerevan, Tigran Mets Ave', 1400),
(9, '2024-03-04', 'Yerevan, Nalbandyan St', 700),
(10, '2024-01-05', 'Yerevan, Sayat-Nova Ave', 600),
(11, '2024-01-06', 'Yerevan, Komitas St', 1500),
(12, '2024-02-07', 'Yerevan, Mashtots Ave', 0),
(13, '2024-02-08', 'Yerevan,Abovyan St,', 700),
(14, '2024-03-09', 'Yerevan, Hanrapetutyan St', 500),
(15, '2024-03-10', 'Yerevan, Baghramyan Ave', 2100),
(16, '2024-01-11', 'Yerevan, Zakyan St', 2200),
(17, '2024-02-12', 'Yerevan, Tumanyan St', 0),
(18, '2024-02-13', 'Yerevan, Saryan St', 400),
(19, '2024-01-14', 'Yerevan, Nalbandyan St', 500),
(20, '2024-03-15', 'Yerevan, Teryan St', 600),
(21, '2024-03-25', 'Yerevan, Malkhasyan St', 1600),
(22, '2024-04-05', 'Yerevan, Shinararner St', 1500),
(23, '2024-03-17', 'Yerevan, Azatutyan St', 1000),
(24, '2024-04-07', 'Yerevan, Buzand St', 750),
(25, '2024-03-11', 'Yerevan, Halabyan St', 800),
(26,  '2024-04-02', 'Yerevan, Charents St', 400),
(27, '2024-01-15', 'Yerevan, Mashtoc Ave', 0),
(28, '2024-02-18', 'Yerevan, Abovyan St', 1200),
(29, '2024-03-04', 'Yerevan, Moskovyan St', 0),
(30, '2024-03-31', 'Yerevan, Koryun St', 300),
(31, '2024-04-03', 'Yerevan Teryan St',900);



--vacharqi qanakov pakasecnum e bazayum arka caxikneri qanaky
CREATE TRIGGER SubFlower
ON Sales
AFTER INSERT
AS
BEGIN
    UPDATE Flowers
    SET flower_quantity = flower_quantity - i.sales_quantity
    FROM Flowers f
    INNER JOIN inserted i ON f.F_id = i.flower_id;
END;

-- stugum e erb caxikneri qanaky poqr a 10-ic avelacnum e 15-ov
CREATE TRIGGER IncreaseFlower
ON Sales
AFTER INSERT
AS
BEGIN
    DECLARE @MinStockThreshold INT = 10;

    UPDATE Flowers
    SET flower_quantity = CASE 
                            WHEN flower_quantity < @MinStockThreshold 
                            THEN flower_quantity + 15 
                            ELSE flower_quantity 
                          END
    WHERE F_id IN (SELECT DISTINCT flower_id FROM inserted);
END;




INSERT INTO Sales(Sale_id, flower_id, sales_quantity, price, sale_date, employee_id, shipping_id, payment_method)
VALUES
(11, 1, 50, 1500, '2024-02-24', 7, 1, 'Card'),
(12, 2, 30, 1000, '2024-02-25', 1, NULL, 'Cash'),
(13, 3, 40, 500, '2024-02-26', 7, 3, 'Card'),
(14, 4, 40, 750, '2024-02-27', 7, NULL, 'Cash'),
(15, 5, 25, 1800, '2024-02-28', 1, 5, 'Card'),
(16, 6, 150, 1500, '2024-03-01', 1, NULL, 'Cash'),
(17, 7, 65, 1000, '2024-01-02', 1, 7, 'Card'),
(18, 8, 45, 500, '2024-03-03', 7, NULL, 'Cash'),
(19, 9, 55, 1300, '2024-03-04', 7, 9, 'Card'),
(20, 10, 65, 1000,'2024-02-05', 7, NULL, 'Cash'),
(21, 11, 50, 600, '2024-01-14', 1, 19, 'Card'),
(22, 12, 25, 1400, '2024-03-15', 1, 20, 'Card'),
(23, 13, 55, 800, '2024-03-07', 7, NULL, 'Cash'),
(24, 14, 40, 700, '2024-01-27', 1, 4, 'Card'),
(25, 15, 30, 500, '2024-03-10', 1, 15, 'Cash');
INSERT INTO Sales(Sale_id, flower_id, sales_quantity, price, sale_date, employee_id, shipping_id, payment_method)
VALUES
(26, 1, 20, 1500, '2024-03-10', 7, NULL, 'Card'),
(27, 2, 45, 1000, '2024-02-25', 7, 2, 'Cash'),
(28, 3, 67, 500, '2024-03-12', 1, NULL, 'Card'),
(29, 4, 24, 750, '2024-03-09', 1, 14, 'Cash'),
(30, 5, 31, 1800, '2024-01-14', 1, NULL, 'Card'),
(31, 6, 440, 1500, '2024-02-12', 1, 17, 'Cash'),
(32, 7, 50, 1000, '2024-02-07', 7, 12, 'Card'),
(33, 8, 25, 500, '2024-02-08', 7, 13, 'Cash'),
(34, 9, 35, 1300, '2024-03-18', 1, NULL, 'Card'),
(35, 10, 14, 1000, '2024-01-11', 7, 16, 'Cash'),
(36, 11, 13, 600, '2024-03-01', 1, 6, 'Card'),
(37, 12, 39, 1400, '2024-02-13', 1, 18, 'Cash'),
(38, 13, 62, 800, '2024-01-22', 7, NULL, 'Card'),
(39, 14, 57, 700, '2024-01-14', 7, 8, 'Cash'),
(40, 15, 23, 500, '2024-02-07', 1, 10, 'Card');
INSERT INTO Sales(Sale_id, flower_id, sales_quantity, price, sale_date, employee_id, shipping_id, payment_method)
VALUES
(41, 1, 25, 1500, '2024-03-15', 7, NULL, 'Card'),
(42, 2, 35, 1000, '2024-04-03', 7, 11, 'Cash'),
(43, 3, 70, 500, '2024-04-01', 1, NULL, 'Card'),
(44, 4, 35, 750, '2024-03-25', 1, 21, 'Cash'),
(45, 5, 23, 1800, '2024-03-27', 1, NULL, 'Card'),
(46, 6, 150, 1500, '2024-04-05', 1, 22, 'Cash'),
(47, 7, 78, 1000, '2024-03-17', 7, 23, 'Card'),
(48, 8, 20, 500, '2024-03-08', 7, NULL, 'Cash'),
(49, 9, 39, 1300, '2024-04-18', 1, NULL, 'Card'),
(50, 10, 30, 1000, '2024-04-07', 7, 24, 'Cash'),
(51, 11, 7, 600, '2024-03-11', 1, 25, 'Card'),
(52, 12, 34, 1400, '2024-04-02', 1, 26, 'Cash'),
(53, 13, 30, 800, '2024-03-22', 7, NULL, 'Card'),
(54, 14, 55, 700, '2024-01-15', 7, 27, 'Cash'),
(55, 15, 45, 500, '2024-02-18', 1, 28, 'Card'),
(56, 2, 37, 1000, '2024-04-25', 1, NULL, 'Card');
INSERT INTO Sales(Sale_id, flower_id, sales_quantity, price, sale_date, employee_id, shipping_id, payment_method)
VALUES
(57, 3, 20, 500, '2024-03-04', 7, 29, 'Cash'),
(58, 4, 21, 750, '2024-04-04', 7, NULL, 'Card'),
(59, 6, 160, 1500, '2024-03-31', 1, 30, 'Card'),
(60, 7, 26, 1000, '2024-03-17', 1, NULL, 'Cash'),
(61, 14, 45, 700, '2024-04-03', 7, 31, 'Card'),
(62, 15, 20, 500, '2024-04-07', 1, NULL, 'Cash');


--Vacharqi qanaky chgerazanci bazayum arka caxikneri qanakin
CREATE TRIGGER ExcessiveSales
ON Sales
FOR INSERT
AS
BEGIN
    
    DECLARE @TotalFlowerStock INT;
    SELECT @TotalFlowerStock = SUM(flower_quantity)
    FROM Flowers;

    DECLARE @TotalSalesQuantity INT;
    SELECT @TotalSalesQuantity = SUM(sales_quantity)
    FROM inserted;

    IF @TotalSalesQuantity > @TotalFlowerStock
    BEGIN

        RAISERROR ('Transaction aborted: Number of sales exceeds the number of flowers in the database.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO Sales
        SELECT *
        FROM inserted;
    END
END;

INSERT INTO Sales(Sale_id, flower_id, sales_quantity, price, sale_date, employee_id, shipping_id, payment_method)
VALUES
(577, 3, 205, 500, '2024-03-04', 7, 29, 'Cash');


--Selects

--Stanal ashxatakicneri anunnery aranc arajin ev verjin tareri ete anuni erkarutyuny 5-ic mec e
SELECT 
    first_name,
    last_name,
    CASE 
        WHEN LEN(first_name) >= 5 THEN SUBSTRING(first_name, 2, LEN(first_name) - 2) 
        ELSE first_name 
    END AS modified_first_name,
    CASE 
        WHEN LEN(last_name) >= 5 THEN SUBSTRING(last_name, 2, LEN(last_name) - 2) 
        ELSE last_name 
    END AS modified_last_name
FROM Employee;


--heraxosi verji nishhy zuyg
SELECT *
FROM Employee
WHERE CAST(RIGHT(phone_number, 1) AS INT) % 2 = 0;

--yuraqanchyur pashtonum ashxatoxneri tivy ayd pashtoni mijin ashxatavarcy ete ayn mec e 100000
SELECT 
    e.position_id,
    COUNT(*) AS employee_count,
    AVG(p.salary) AS average_salary
FROM Employee e
JOIN Position p ON e.position_id = p.ID
GROUP BY e.position_id
HAVING AVG(p.salary) > 100000;


--Stanal ashx anun+azg+tariq
SELECT first_name+' '+last_name+' '+'is'+ ' '+cast(DATEDIFF(YEAR,birthday,GETDATE()) AS Nvarchar(20))+ ' '+ 'years old' as Midashtum
FROM Employee

--yuraqanchyur ashxatakci arancin vacharqic stacvac ekamuty
SELECT e.id AS employee_id,
       e.first_name,
       e.last_name,
       p.position_name,
           SUM(s.sales_quantity * s.price)  AS total_revenue
FROM Sales s
JOIN Employee e ON s.employee_id = e.id
JOIN Position p ON e.position_id = p.ID
JOIN Flowers f ON s.flower_id = F_id
GROUP BY e.id, e.first_name, e.last_name, p.position_name;

--amenashat vacharvox caxikner
SELECT TOP 3 f.flower_name, 
             SUM(s.sales_quantity) AS total_sales_quantity
FROM Sales s
JOIN Flowers f ON s.flower_id = f.F_id
GROUP BY f.flower_name
ORDER BY total_sales_quantity DESC;

--amen amsva ekamuty
SELECT DATENAME(month, s.sale_date) AS sale_month,
       SUM((s.price-f.flower_price) * s.sales_quantity) AS total_revenue
FROM Sales s
JOIN Flowers f ON s.flower_id = F_id
WHERE YEAR(s.sale_date) = 2024
GROUP BY DATENAME(month, s.sale_date);




 --vardi vacharqic stacvac ekamuty
IF EXISTS (
    SELECT s.flower_id
    FROM Sales s 
    JOIN Flowers f ON s.flower_id = f.F_id 
    WHERE f.flower_name = 'Vard'
)
BEGIN
    SELECT SUM(s.sales_quantity * s.price) AS yndhanur
    FROM Sales s
    JOIN Flowers f ON s.flower_id = f.F_id 
END;


--ete caxikneri gneri mijiny poqr e 1000 barcracru 5%-ov
SELECT * INTO Flowers1
FROM Flowers

DECLARE @AveragePrice MONEY;

SELECT @AveragePrice = AVG(flower_price)
FROM Flowers1;

WHILE @AveragePrice < 1000
BEGIN
 
    UPDATE Flowers1
    SET flower_price = flower_price * 1.05;

    SELECT @AveragePrice = AVG(flower_price)
    FROM Flowers1;
    SELECT 'Current average price: ' + CAST(@AveragePrice AS VARCHAR(20));
END;



--stanal caxikneri nor gin arjeqy barcracnelov 10%-ov, qani der amboxch apranqi gumarayin arjeqy chi gerazancel 3000000 ete maxvalue-n mec e 200000 break
SELECT * INTO Flowers3
FROM Flowers

DECLARE @TotalValue MONEY
DECLARE @MaxValue MONEY
DECLARE @Threshold MONEY
SET @Threshold = 3000000 

SELECT  @TotalValue =SUM(flower_price * flower_quantity)
FROM Flowers3

SELECT  @MaxValue = MAX(flower_price * flower_quantity)
FROM Flowers3



WHILE @TotalValue <= @Threshold
BEGIN
    IF @MaxValue > 1200000
    BEGIN
        PRINT 'Maximum value exceeds 1200,000.'
        BREAK
    END
 
    UPDATE Flowers3
    SET flower_price = flower_price * 1.10

    SELECT @TotalValue = SUM(flower_price * flower_quantity)
    FROM Flowers3

    SELECT @MaxValue = MAX(flower_price * flower_quantity)
    FROM Flowers3
END

SELECT * FROM Flowers3

--verjin mek amsva yntacqum katarvac araqumneri mijiny ete 1000-ic mec e gumary, hakarak depqum qanaky
DECLARE @avg INT
SELECT @avg = AVG(shipping_pay)
FROM Shipping
WHERE MONTH(shipping_date) = MONTH(DATEADD(MONTH, -1, GETDATE()));

IF @avg > 1000
BEGIN
    SELECT SUM(shipping_pay) AS total_shipping_pay
    FROM Shipping
    WHERE MONTH(shipping_date) = MONTH(DATEADD(MONTH, -1, GETDATE()));
END
ELSE
BEGIN
    SELECT COUNT(*) AS number_of_shipments
    FROM Shipping
    WHERE MONTH(shipping_date) = MONTH(DATEADD(MONTH, -1, GETDATE()));
END


--sahmanel bonus ashxatakicneri hamar ovqer vacharel en 300 caxik kam berel en 10000 drami ekamut
	SELECT 
    e.id AS EmployeeID,
    e.first_name + ' ' + e.last_name AS EmployeeName,
    SUM(s.sales_quantity) AS TotalFlowersSold,
    SUM(s.sales_quantity * (s.price- f.flower_price)) AS TotalSalesRevenue,
    CASE
        WHEN SUM(s.sales_quantity) > 300 OR SUM(s.sales_quantity * (s.price- f.flower_price)) > 100000 THEN SUM(s.sales_quantity * f.flower_price) * 0.05
        WHEN SUM(s.sales_quantity) < 50 AND SUM(s.sales_quantity * (s.price- f.flower_price)) < 50000 THEN 0
        ELSE NULL
    END AS BonusAmount
FROM 
    Employee e
JOIN 
    Sales s ON e.id = s.employee_id
JOIN 
    Flowers f ON s.flower_id = f.F_id
GROUP BY 
    e.id, e.first_name, e.last_name


--stanal nor gin avelacnelov 10%-i chapov qani der amboxch apranqi gumarayin arjeqy chi gerazancel 20000, erb maxval>3000 break, tpel avelacvac tokosi chapy
DECLARE @TotalValue MONEY;
SELECT @TotalValue = SUM(flower_price)
FROM Flowers;

DECLARE @Interest MONEY = 0;
DECLARE @MaxAllowedValue MONEY = 0;

WHILE (@TotalValue <= 20000)
BEGIN
    UPDATE Flowers
    SET flower_price = flower_price * 1.10;
    
    SELECT @TotalValue = SUM(flower_price)
    FROM Flowers;

    SELECT @MaxAllowedValue = MAX(flower_price)
	FROM Flowers;

    IF @MaxAllowedValue > 3000
    BEGIN
        PRINT 'Maximum value exceeds 5000. Aborting the cycle.';
        BREAK; 
    END

    SET @Interest = @Interest + (@TotalValue * 0.10);
END;


PRINT 'Amount of added interest: ' + CONVERT(VARCHAR, @Interest);



--sahmanel zexch 5% hanelov vacharqi gnic qani der amboxch vacharqi gumarayin arjeqy mec e 800000 ete minimaly<50000 break
DECLARE @TotalSales MONEY;

SELECT @TotalSales = SUM(price*sales_quantity)
FROM Sales;

DECLARE @DiscountApplied BIT = 0;
DECLARE @MinAllowedValue MONEY = 0;

WHILE (@TotalSales > 800000 AND @MinAllowedValue <= 5000)
BEGIN

    IF @DiscountApplied = 0
    BEGIN
        UPDATE Sales
        SET price = price * 0.95;
  
        SET @DiscountApplied = 1;
    END

    SELECT @TotalSales = SUM(price * sales_quantity)
    FROM Sales;

    SELECT @MinAllowedValue = MIN(price * sales_quantity)
    FROM Sales
	

    IF @MinAllowedValue <= 100000
    BEGIN

        PRINT 'Minimum value is less than or equal to 5000. Stopping the cycle.';
        BREAK; 
    END
END;

PRINT 'Updated total sales amount: ' + CONVERT(VARCHAR, @TotalSales);


*/


--PROCERURES

--HAshvum e konkret caxki vacharqic stacvac ekamuty

CREATE PROCEDURE CalculateSalesRevenueForFlower
    @flowerName NVARCHAR(50),
    @salesRevenue MONEY OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Sales s 
        JOIN Flowers f ON s.flower_id = f.F_id 
        WHERE f.flower_name = @flowerName )
    BEGIN
        
        SELECT @salesRevenue = SUM(s.sales_quantity * s.price)
        FROM Sales s
        JOIN Flowers f ON s.flower_id = f.F_id 
        WHERE f.flower_name = @flowerName;
    END
    ELSE
    BEGIN
        SET @salesRevenue = 0;
    END
END;
DECLARE @salesRevenue MONEY;
EXEC CalculateSalesRevenueForFlower 'Pion', @salesRevenue OUTPUT;
SELECT @salesRevenue AS SalesRevenueForVard;


--stexcum e vacharqi hashvetvutyun tvyal jamanakahatvaci hamar 

CREATE PROCEDURE SalesReport1
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    DECLARE @SalesReport TABLE (
        ProductName NVARCHAR(50),
        TotalSales INT,
        TotalQuantitySold INT,
        TotalRevenue MONEY, --ekamut
        TotalCost MONEY, --arjeq
        TotalProfit MONEY --shahuyt
    );

    INSERT INTO @SalesReport (ProductName, TotalSales, TotalQuantitySold, TotalRevenue, TotalCost, TotalProfit)
    SELECT 
        f.flower_name AS ProductName,
        COUNT(*) AS TotalSales,
        SUM(s.sales_quantity) AS TotalQuantitySold,
        SUM(s.sales_quantity * s.price) AS TotalRevenue,
        SUM(f.flower_price*f.flower_quantity) AS TotalCost,
        SUM(s.sales_quantity * s.price) - SUM(f.flower_price*f.flower_quantity) AS TotalProfit
    FROM 
        Sales s
    INNER JOIN 
        Flowers f ON s.flower_id = f.F_id
    WHERE 
        s.sale_date BETWEEN @StartDate AND @EndDate
    GROUP BY 
        f.flower_name, s.flower_id; -- Include s.flower_id in the GROUP BY clause

    SELECT * FROM @SalesReport;
END;

EXEC SalesReport1 '2024-01-01', '2024-04-07';


--sahmanel bonus ashxatakicneri hamar ovqer vacharel en 300 caxik kam berel en 10000 drami ekamut

CREATE PROCEDURE EmployeeBonuses
    @MinFlowersSold INT,
    @MinTotalRevenue MONEY,
    @Bonus FLOAT
AS
BEGIN
    UPDATE Position
    SET salary = salary + ISNULL(B.BonusAmount, 0) -- Add bonus amount to the current salary
    FROM (
        SELECT 
            e.position_id,
            SUM(s.sales_quantity) AS TotalFlowersSold,
            SUM(s.sales_quantity * s.price) AS TotalSalesRevenue,
            CASE
                WHEN SUM(s.sales_quantity) > @MinFlowersSold OR SUM(s.sales_quantity * s.price ) > @MinTotalRevenue THEN SUM(s.sales_quantity * f.flower_price) * @Bonus
                WHEN SUM(s.sales_quantity) < @MinFlowersSold AND SUM(s.sales_quantity * s.price ) < @MinTotalRevenue THEN 0
                ELSE NULL
            END AS BonusAmount
        FROM 
            Employee e
        JOIN Sales s ON e.id = s.employee_id
        JOIN Flowers f ON s.flower_id = f.F_id
        GROUP BY 
            e.position_id
    ) B 
    WHERE Position.ID = B.position_id;

    SELECT 
        e.id AS EmployeeID,
        e.first_name + ' ' + e.last_name AS EmployeeName,
        p.salary AS SalaryWithBonus
    FROM 
        Employee e
    JOIN Position p ON e.position_id = p.ID;
END;

EXEC EmployeeBonuses @MinFlowersSold = 300, @MinTotalRevenue = 10000, @Bonus = 0.05;



--sahmanel zexch 5% hanelov vacharqi gnic qani der amboxch vacharqi gumarayin arjeqy mec e 800000 ete minimaly<50000 break
CREATE PROCEDURE UpdateSales
AS
BEGIN
    DECLARE @TotalSales MONEY;
    DECLARE @MinAllowedValue MONEY = 0;

    SELECT @TotalSales = SUM(price * sales_quantity)
    FROM Sales;

    WHILE (@TotalSales > 800000 AND @MinAllowedValue <= 5000)
    BEGIN

        BEGIN
            UPDATE Sales
            SET price = price * 0.95;
        END

        SELECT @TotalSales = SUM(price * sales_quantity)
        FROM Sales;

       
        SELECT @MinAllowedValue = MIN(price * sales_quantity)
        FROM Sales;

     
        IF @MinAllowedValue <= 100000
        BEGIN
            PRINT 'Minimum value is less than or equal to 5000. Stopping the cycle.';
            BREAK; 
        END
    END;

  
    PRINT 'Updated total sales amount: ' + CONVERT(VARCHAR, @TotalSales);
END;

EXEC UpdateSales;
SELECT * FROM Sales

--araqman gni zexchum 50%-wv marti 8-aprili 7

CREATE PROCEDURE CalculateTotalShippingCostWithDiscount
AS
BEGIN
    SELECT 
        Ship_id AS DeliveryID,
        shipping_date AS ShippingDate,
        shipping_address AS ShippingAddress,
        shipping_pay AS OriginalShippingCost,
        CASE 
            WHEN shipping_date BETWEEN '2024-03-08' AND '2024-04-07' THEN shipping_pay * 0.5
            ELSE shipping_pay
        END AS DiscountedShippingCost
    FROM 
        Shipping;
END;


EXEC CalculateTotalShippingCostWithDiscount;



--FUCTIONS

--Scaliar

CREATE FUNCTION GetShippingInfoForLastMonth ()
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @result NVARCHAR(100);
    DECLARE @avg INT;
    SELECT @avg = AVG(shipping_pay)
    FROM Shipping
    WHERE MONTH(shipping_date) = MONTH(DATEADD(MONTH, -1, GETDATE()));
    IF @avg > 1000
    BEGIN
        SELECT @result = CONVERT(NVARCHAR(100), SUM(shipping_pay))
        FROM Shipping
        WHERE MONTH(shipping_date) = MONTH(DATEADD(MONTH, -1, GETDATE()));
    END
    ELSE
    BEGIN
        SELECT @result = CONVERT(NVARCHAR(100), COUNT(*))
        FROM Shipping
        WHERE MONTH(shipping_date) = MONTH(DATEADD(MONTH, -1, GETDATE()));
    END
    RETURN @result;
END;
DECLARE @result NVARCHAR(100);
SET @result = dbo.GetShippingInfoForLastMonth();
SELECT @result AS ShippingInfoForLastMonth;

--hashvarkel vacharqi mijin giny konkret matakarari koxmic matakararvac apranqneri hamar
CREATE FUNCTION dbo.SupplierAvg
(
    @SupplierID INT
)
RETURNS MONEY
AS
BEGIN
    DECLARE @AveragePrice MONEY;

    SELECT @AveragePrice = AVG(s.price)
    FROM Sales s
    INNER JOIN Flowers f ON s.flower_id = f.F_id
    WHERE f.supplier_id = @SupplierID;

    RETURN @AveragePrice;
END;


DECLARE @SupplierID INT = 1;

DECLARE @AveragePrice MONEY;


SET @AveragePrice = dbo.SupplierAvg(@SupplierID);

PRINT 'Average sales price for Supplier ' + CAST(@SupplierID AS VARCHAR) + ': ' + CAST(@AveragePrice AS VARCHAR);


/*

--yst id-i veradarcnum e pashtoni anvanumy ashxatakci
CREATE FUNCTION dbo.EmployeePosition
(
    @EmployeeID INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @PositionName NVARCHAR(50);

    SELECT @PositionName = p.position_name
    FROM Employee e
    INNER JOIN Position p ON e.position_id = p.ID
    WHERE e.id = @EmployeeID;

    RETURN @PositionName;
END;


DECLARE @EmployeeID INT = 1; 

SELECT dbo.EmployeePosition(@EmployeeID) AS PositionName;
*/

--Table function
--poxancel pashtoni anuny ev stanal texekatvutyun ashxatoxi masin

CREATE FUNCTION dbo.GetEmpByPosition
(
    @PositionName NVARCHAR(50)
)
RETURNS @EmployeeTable TABLE (
    EmployeeID INT,
    EmployeeName NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Email NVARCHAR(50),
    Position NVARCHAR(50)
)
AS
BEGIN
    DECLARE @EmployeePosition NVARCHAR(50);
    SET @EmployeePosition = '';

    WHILE @EmployeePosition != @PositionName
    BEGIN
     
        SELECT TOP 1 @EmployeePosition = p.position_name
        FROM Employee e
        INNER JOIN Position p ON e.position_id = p.ID
        WHERE p.position_name > @EmployeePosition
		ORDER BY p.position_name;

        IF @EmployeePosition IS NULL
            BREAK;

        IF @EmployeePosition = @PositionName
        BEGIN
            INSERT INTO @EmployeeTable (EmployeeID, EmployeeName, PhoneNumber, Email, Position)
            SELECT 
                e.id AS EmployeeID,
                e.first_name + ' ' + e.last_name AS EmployeeName,
                e.phone_number AS PhoneNumber,
                e.email AS Email,
                p.position_name AS Position
            FROM 
                Employee e
            INNER JOIN 
                Position p ON e.position_id = p.ID
            WHERE 
                p.position_name = @PositionName;
        END;
    END;

    RETURN;
END;

SELECT * 
FROM dbo.GetEmpByPosition('Dizayner');


--dasakargel yst gneri

CREATE FUNCTION CategorizeFlowersByPrice()
RETURNS TABLE
AS
RETURN (
    WITH CategorizedFlowers AS (
        SELECT 
            F_id AS FlowerID,
            flower_name AS FlowerName,
            flower_price AS FlowerPrice,
            CASE 
                WHEN flower_price < 500 THEN 'Low'
                WHEN flower_price >= 500 AND flower_price <= 1000 THEN 'Medium'
                ELSE 'High'
            END AS PriceCategory
        FROM 
            Flowers
    )
    SELECT * FROM CategorizedFlowers
);

SELECT * FROM dbo.CategorizeFlowersByPrice();
--nshvac mijakayqum amen orva vacharqn u gumary
CREATE FUNCTION GetSalesByDate
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS @SalesTable TABLE (
    SaleID INT,
    SaleDate DATE,
    FlowerID INT,
    FlowerName NVARCHAR(100),
    SalesQuantity INT,
    TotalPrice MONEY
)
AS
BEGIN
    DECLARE @CurrentDate DATE;
    SET @CurrentDate = @StartDate;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO @SalesTable (SaleID, SaleDate, FlowerID, FlowerName, SalesQuantity, TotalPrice)
        SELECT 
            s.Sale_id AS SaleID,
            s.sale_date AS SaleDate,
            s.flower_id AS FlowerID,
            f.flower_name AS FlowerName,
            s.sales_quantity AS SalesQuantity,
            s.sales_quantity * s.price AS TotalPrice
        FROM 
            Sales s
        INNER JOIN 
            Flowers f ON s.flower_id = f.F_id
        WHERE 
            s.sale_date = @CurrentDate;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate); -- Increment date
    END;

    RETURN;
END;


SELECT * FROM dbo.GetSalesByDate('2024-01-01', '2024-01-31');


--MSTVF

--veradarcnum e axyusak vacharqi tvyalnerov + ashxatox+ vcharman exanak
CREATE FUNCTION GetEmployeeSalesDetails (@EmployeeID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT S.Sale_id,
           S.flower_id,
           S.sales_quantity,
           S.price,
           S.sale_date,
           S.employee_id,
           S.shipping_id,
           S.payment_method,
           CASE 
               WHEN E.gender = 'Male' THEN 'Mr. ' + E.last_name
               WHEN E.gender = 'Female' THEN 'Ms. ' + E.last_name
               ELSE E.first_name + ' ' + E.last_name
           END AS employee_name,
           CASE 
               WHEN S.payment_method = 'Cash' THEN 'Paid in cash'
               WHEN S.payment_method = 'Card' THEN 'Paid by card'
               ELSE 'Payment method not specified'
           END AS payment_status
    FROM Sales S
    INNER JOIN Employee E ON S.employee_id = E.id
    WHERE S.employee_id = @EmployeeID
);


SELECT * 
FROM dbo.GetEmployeeSalesDetails(7);



CREATE VIEW EmployeeSalesView AS
SELECT
    e.id AS employee_id,
    e.first_name,
    e.last_name,
    COUNT(s.Sale_id) AS total_sales,
    SUM(s.price*s.sales_quantity) AS total_revenue
FROM
    Employee e
LEFT JOIN
    Sales s ON e.id = s.employee_id
GROUP BY
    e.id, e.first_name, e.last_name;


	SELECT * FROM EmployeeSalesView;

--VIEWS


--1

CREATE VIEW SalesDetailView AS 
SELECT    
		s.Sale_id,
		s.flower_id,
		s.sale_date,
		s.employee_id,
		s.sales_quantity,
		s.price,
		s.shipping_id,
		s.payment_method
FROM    
	Sales s
WHERE    s.shipping_id is NULL;

--insert
INSERT INTO SalesDetailView(Sale_id, flower_id,sale_date, employee_id, sales_quantity, price, shipping_id, payment_method)
VALUES(100, 2, '2024-04-25', 7, 25, 1000, NULL, 'Card'),
(101, 14, '2024-04-30', 1, 10, 700, NULL, 'Cash' );


-- Update ere vacharqi mijin qanaky mec e 150-ic caxikneri giny +20% hakarak depqum -10%
DECLARE @avg_sales DECIMAL(10, 2);
SELECT @avg_sales = AVG(sales_quantity)
FROM SalesDetailView;

IF @avg_sales > 150
BEGIN
    UPDATE SalesDetailView
    SET price = price * 1.20;
END
ELSE
BEGIN
    UPDATE SalesDetailView
    SET price = price * 0.90;
END

--del
DELETE 
FROM SalesDetailView 
WHERE MONTH(sale_date) = 1 AND payment_method LIKE 'Card';  


--
CREATE VIEW SalesEmpFLView AS
SELECT s.Sale_id,
    s.sale_date,
    s.sales_quantity,
    s.price,
    s.payment_method,
    f.flower_name,
    f.flower_price,
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name
FROM Sales s
INNER JOIN Flowers f ON s.flower_id = f.F_id
INNER JOIN Employee e ON s.employee_id = e.id
WHERE flower_price>=500 And CAST(RIGHT(phone_number, 1) AS INT) % 2 = 1;


--update
-- Update Request
UPDATE SalesEmpFLView
SET flower_price = CASE 
                        WHEN payment_method = 'Card' THEN flower_price * 1.1
                        WHEN payment_method = 'Cash' AND sales_quantity > 50 THEN flower_price * 0.95
                        ELSE flower_price
                   END;

--
-- Update Request
UPDATE SalesEmpFLView
SET flower_price = flower_price * 1.2
WHERE sale_date BETWEEN '2024-03-08' AND '2024-04-07';


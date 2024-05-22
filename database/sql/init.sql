CREATE DATABASE shop;
USE shop;

-- 工作人员表
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Gender CHAR(1),
    Age INT,
    MonthlySalary DECIMAL(10, 2) DEFAULT 0
);

-- 商品表
CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    Brand VARCHAR(100),
    UnitPrice DECIMAL(10, 2),
    Quantity INT DEFAULT 0
);

-- 会员表
CREATE TABLE Member (
    MemberID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100),
    MembershipStartDate DATETIME DEFAULT NOW(),
    MembershipEndDate DATETIME
);

-- 销售表
CREATE TABLE Sales (
    SalesID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    SaleTime DATETIME,
    ActualUnitPrice DECIMAL(10, 2),
    SoldQuantity INT,
    MemberID INT,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);

-- 采购源表
CREATE TABLE Source (
    SourceID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100)
);

-- 采购表
CREATE TABLE Purchase (
    PurchaseID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    PurchaseTime DATETIME DEFAULT NOW(),
    PurchaseUnitPrice DECIMAL(10, 2),
    PurchaseQuantity INT,
    SourceID INT NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (SourceID) REFERENCES Source(SourceID)
);

-- 创建视图，获取每日、每月、每年的销售额统计
CREATE VIEW DailySales AS
SELECT DATE(SaleTime) AS Day, SUM(ActualUnitPrice * SoldQuantity) AS TotalSales
FROM Sales
GROUP BY Day;

CREATE VIEW MonthlySales AS
SELECT DATE_FORMAT(SaleTime, '%Y-%m') AS Month, SUM(ActualUnitPrice * SoldQuantity) AS TotalSales
FROM Sales
GROUP BY Month;

CREATE VIEW YearlySales AS
SELECT YEAR(SaleTime) AS Year, SUM(ActualUnitPrice * SoldQuantity) AS TotalSales
FROM Sales
GROUP BY Year;

-- 创建视图，获取总收支统计
CREATE VIEW TotalIncome AS
SELECT SUM(ActualUnitPrice * SoldQuantity) AS Income
FROM Sales;

CREATE VIEW TotalStaffExpense AS
SELECT SUM(MonthlySalary) AS StaffExpense
FROM Staff;

CREATE VIEW TotalProductExpense AS
SELECT SUM(PurchaseUnitPrice * PurchaseQuantity) AS ProductExpense
FROM Purchase;

CREATE VIEW TotalExpense AS
SELECT StaffExpense, ProductExpense
FROM TotalStaffExpense, TotalProductExpense;

-- 创建事件，定期自动删除到达有效期限的会员
DELIMITER $$
CREATE EVENT ExpiredMembership
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DELETE FROM Member WHERE MembershipEndDate < NOW();
END$$
DELIMITER ;

-- 从货源购入商品
DELIMITER $$
CREATE PROCEDURE PurchaseProduct(IN p_ProductID INT, IN p_SourceID INT, IN p_PurchaseTime DATETIME, IN p_PurchaseUnitPrice DECIMAL(10, 2), IN p_PurchaseQuantity INT)
proc_label: BEGIN  -- 定义一个标签
    -- 开启事务
    START TRANSACTION;

    -- 检查是否存在该货源
    IF NOT EXISTS (SELECT * FROM Source WHERE SourceID = p_SourceID) THEN
        -- 如果不存在该货源，则返回错误信息
        SELECT 'Source not found for the given sourceID' AS ErrorMessage;
        LEAVE proc_label;  -- 使用LEAVE语句退出代码块
    END IF;

    -- 从货源购入商品
    INSERT INTO Purchase (ProductID, PurchaseTime, PurchaseUnitPrice, PurchaseQuantity, SourceID) VALUES (p_ProductID, p_PurchaseTime, p_PurchaseUnitPrice, p_PurchaseQuantity, p_SourceID);

    -- 更新商品表中的数量
    UPDATE Product SET Quantity = Quantity + p_PurchaseQuantity WHERE ProductID = p_ProductID;

    -- 提交事务
    COMMIT;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE SellProduct(IN p_ProductID INT, IN p_SaleTime DATETIME, IN p_SoldQuantity INT, IN p_MemberID INT)
proc_label: BEGIN  -- 定义一个标签
    DECLARE v_ActualUnitPrice DECIMAL(10, 2);
    DECLARE v_UnitPrice DECIMAL(10, 2);
    DECLARE v_Quantity INT;

    -- 开启事务
    START TRANSACTION;

    -- 获取商品的单价和数量
    SELECT UnitPrice, Quantity INTO v_UnitPrice, v_Quantity FROM Product WHERE ProductID = p_ProductID;

    -- 检查商品的数量是否足够
    IF v_Quantity < p_SoldQuantity THEN
        -- 如果商品数量不足，则回滚事务并返回错误信息
        ROLLBACK;
        SELECT 'Insufficient product quantity' AS ErrorMessage;
        LEAVE proc_label;  -- 使用LEAVE语句退出代码块
    END IF;

    -- 判断是否是会员
    IF p_MemberID IS NOT NULL THEN
        -- 如果是会员，则9折出售
        SET v_ActualUnitPrice = v_UnitPrice * 0.9;
    ELSE
        -- 如果不是会员，则按原价出售
        SET v_ActualUnitPrice = v_UnitPrice;
    END IF;

    -- 卖出商品
    INSERT INTO Sales (ProductID, SaleTime, ActualUnitPrice, SoldQuantity, MemberID) VALUES (p_ProductID, p_SaleTime, v_ActualUnitPrice, p_SoldQuantity, p_MemberID);

    -- 更新商品的数量
    UPDATE Product SET Quantity = Quantity - p_SoldQuantity WHERE ProductID = p_ProductID;

    -- 提交事务
    COMMIT;
END$$
DELIMITER ;

-- 创建用户
CREATE USER 'shop_admin'@'%' IDENTIFIED BY 'shoppassword';
-- 授予新用户对shop数据库的所有权限
GRANT ALL PRIVILEGES ON shop.* TO 'shop_admin'@'%';
-- 刷新权限，使更改立即生效
FLUSH PRIVILEGES;

-- 自动备份（未测试）
DELIMITER $$
CREATE EVENT IF NOT EXISTS db_backup
ON SCHEDULE EVERY 1 DAY STARTS '2024-05-23 03:00:00'
DO
BEGIN
    SET @backup_file = CONCAT('/backup_dir/shop_', DATE_FORMAT(NOW(), '%Y%m%d'), '.sql');
    SET @cmd = CONCAT('mysqldump -u root -p mariadb shop > ', @backup_file);
    SELECT sys_exec(@cmd) INTO @exit_code;
END$$
DELIMITER ;

-- 预设数据

-- 工作人员表
INSERT INTO Staff (Name, Gender, Age, MonthlySalary)
VALUES
('张三', 'M', 30, 8000.00),
('李四', 'F', 28, 7500.00),
('王五十', 'M', 45, 9000.00);

-- 商品表
INSERT INTO Product (Name, Brand, UnitPrice, Quantity)
VALUES
('商品1', '品牌A', 100.00, 500),
('商品2', '品牌B', 200.00, 400),
('商品3', '品牌C', 500.00, 100);

-- 会员表
INSERT INTO Member (Name, MembershipStartDate, MembershipEndDate)
VALUES
('会员1', '2021-01-01', '2024-01-01'),
('会员2', '2021-02-01', '2024-02-01'),
('会员3', '2024-04-22', '2025-05-24');

-- 销售表
INSERT INTO Sales (ProductID, SaleTime, ActualUnitPrice, SoldQuantity, MemberID)
VALUES
(1, '2021-01-01 10:00:00', 100.00, 10, 1),
(2, '2021-01-02 11:00:00', 200.00, 20, 2),
(3, '2024-05-22 10:00:00', 500.00, 50, 3);

-- 采购源表
INSERT INTO Source (Name)
VALUES
('货源1'),
('货源2'),
('货源3');

-- 采购表
INSERT INTO Purchase (ProductID, PurchaseTime, PurchaseUnitPrice, PurchaseQuantity, SourceID)
VALUES
(1, '2021-01-01 09:00:00', 90.00, 100, 1),
(2, '2021-01-02 09:00:00', 180.00, 200, 2),
(3, '2024-05-22 09:00:00', 450.00, 500, 3);

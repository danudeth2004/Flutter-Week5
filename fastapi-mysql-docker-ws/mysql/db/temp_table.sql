CREATE TABLE `product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(256) NOT NULL,
  `description` varchar(256) NOT NULL,
  `price` float,
  PRIMARY KEY (`id`)
);

INSERT INTO `product` (`name`, `description`, `price`) 
VALUES ('Iphone16 Plus', 'Apple mobile phone', 55900);

INSERT INTO `product` (`name`, `description`, `price`) 
VALUES ('Samsung S25Ultra', 'Samsung mobile phone', 50900);

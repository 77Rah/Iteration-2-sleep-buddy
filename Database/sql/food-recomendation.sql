CREATE DATABASE  IF NOT EXISTS `food_recommendation` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `food_recommendation`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: food_recommendation
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `food_recommended`
--

DROP TABLE IF EXISTS `food_recommended`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `food_recommended` (
  `Food name` text,
  `Vegan (Yes/No)` text,
  `Recommended age range` text,
  `Energy (kcal/day)` int DEFAULT NULL,
  `Protein (Recommended Dietary Intake) (g/day)` double DEFAULT NULL,
  `Sugars (WHO recommended maximum) (g/day)` double DEFAULT NULL,
  `Dietary fibre (Adequate Intake) (g/day)` double DEFAULT NULL,
  `Calcium (Recommended Dietary Intake) (mg/day)` int DEFAULT NULL,
  `Iron (Recommended Dietary Intake) (mg/day)` double DEFAULT NULL,
  `Iodine (Recommended Dietary Intake) (Âµg/day)` double DEFAULT NULL,
  `Sodium (Adequate Intake) (mg/day, range)` int DEFAULT NULL,
  `Sodium (Upper Level) (mg/day)` text,
  `Potassium (Adequate Intake) (mg/day)` int DEFAULT NULL,
  `Magnesium (Recommended Intake) (mg/day)` int DEFAULT NULL,
  `Phosphorus (Recommended Dietary Intake) (mg/day)` int DEFAULT NULL,
  `Zinc (Recommended Dietary Intake) (mg/day)` double DEFAULT NULL,
  `Vitamin A (retinol activity equivalents) (Âµg RAE/day)` int DEFAULT NULL,
  `Vitamin C (mg/day)` double DEFAULT NULL,
  `Vitamin D (Adequate Intake) (Âµg/day)` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `food_recommended`
--

LOCK TABLES `food_recommended` WRITE;
/*!40000 ALTER TABLE `food_recommended` DISABLE KEYS */;
INSERT INTO `food_recommended` VALUES ('Oatmeal with berries (1 cup + 1/2 cup)','Yes','4â€“12',200,6,10,5,25,2,1,10,'',220,70,185,2.4,5,6,0),('Scrambled eggs & wholeâ€‘wheat toast (1 egg + 1 slice)','No','3â€“12',230,12,2,2.5,160,1.4,24,240,'',210,30,180,1.5,90,0,1.1),('Banana (1 medium)','Yes','3â€“12',105,1.3,14,3.1,6,0.3,2,1,'',422,32,26,0.2,9,10.3,0),('Yogurt parfait (150 g yogurt + fruit)','No','4â€“12',180,9,16,1,270,0.1,25,110,'',350,25,200,1.2,60,6,0),('Carrot sticks with hummus (80 g + 2 tbsp)','Yes','4â€“12',150,5,4,5.5,60,2,1,220,'',330,45,140,1.2,675,8,0),('Apple slices with peanut butter (1 small + 1 tbsp)','Yes','4â€“12',180,4,14,4,20,0.6,2,2,'',250,40,110,0.8,3,6,0),('Wholeâ€‘wheat spaghetti with lentil bolognese (1 cup)','Yes','4â€“12',300,14,6,8,60,4.5,2,180,'',520,80,240,2.5,60,12,0),('Chicken & vegetable stirâ€‘fry with rice (1 cup)','No','5â€“12',350,20,5,3,40,1.5,2,500,'',420,50,220,1.5,30,30,0),('Baked fish fingers with peas (3 fingers + 1/2 cup peas)','No','4â€“12',280,18,3,4.5,60,1.6,8,450,'',420,45,230,1.2,20,20,1.5),('Tofu scramble with vegetables (1 cup)','Yes','4â€“12',220,16,4,4,150,3,2,300,'',360,70,220,2,120,30,0),('Fortified soy milk (1 cup)','Yes','3â€“12',100,7,6,1,300,1,10,100,'',300,30,220,0.6,100,0,2.5),('Milk 2% (1 cup)','No','3â€“12',138,9.7,12,0,352,0.1,57,145,'',448,39,276,1.1,75,2.7,2.5),('Brown rice (cooked, 1 cup)','Yes','3â€“12',218,4.5,1,3.5,20,1,0,2,'',154,86,150,1.2,0,0,0),('Broccoli (steamed, 1 cup)','Yes','3â€“12',55,3.7,2.2,5.1,62,1,2,64,'',457,33,104,0.7,120,101,0),('Cheddar cheese (1 slice ~21 g)','No','4â€“12',85,4.8,0.2,0,149,0.1,5,137,'',24,6,113,1.1,74,0,0.1),('Egg (1 large)','No','3â€“12',72,6.3,0.4,0,28,0.9,24,71,'',69,6,99,0.7,75,0,1.1),('Black bean burger (with wholeâ€‘grain bun, 1 patty)','Yes','6â€“12',320,15,6,9,120,4,2,500,'',620,80,260,2.8,30,6,0),('Mac & cheese (wholeâ€‘grain, 1 cup)','No','3â€“12',320,13,5,3,250,1.6,5,700,'',180,45,250,1.5,90,0,0.1),('Fruit salad (1 cup)','Yes','3â€“12',80,1,16,2.5,20,0.4,2,5,'',300,20,30,0.2,45,45,0),('Baked sweet potato fries (1 cup)','Yes','4â€“12',180,3,7,5,40,0.8,2,150,'',475,45,90,0.5,950,3,0),('Vegetable bacon pizza (1 slice)','No','5â€“12',285,12,4,3,200,2,8,600,'',180,25,200,1.5,150,4,0.2),('Toasted cheese & tomato sandwich (wholeâ€‘grain)','No','4â€“12',300,14,6,4,300,2,5,650,'',330,50,250,2.2,200,6,0.1),('Tofuâ€“veggie noodle bowl (1 bowl)','Yes','5â€“12',350,18,6,5,200,3.5,2,550,'',520,70,260,2.5,150,20,0),('Chicken quesadilla (wholeâ€‘grain, 1 wedge)','No','5â€“12',320,20,3,3,250,1.8,5,650,'',260,35,230,1.6,120,4,0.1),('Lentil soup (1 cup)','Yes','4â€“12',200,12,4,7.5,50,3.3,2,400,'',365,45,180,2,15,4,0);
/*!40000 ALTER TABLE `food_recommended` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-22 19:33:41

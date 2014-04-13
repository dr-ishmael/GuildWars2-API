CREATE DATABASE  IF NOT EXISTS `gw2api` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `gw2api`;
-- MySQL dump 10.13  Distrib 5.6.13, for Win32 (x86)
--
-- Host: 127.0.0.1    Database: gw2api
-- ------------------------------------------------------
-- Server version	5.6.16

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `recipe_tb`
--

DROP TABLE IF EXISTS `recipe_tb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recipe_tb` (
  `recipe_id` mediumint(8) unsigned NOT NULL,
  `recipe_type` varchar(32) NOT NULL,
  `output_item_id` mediumint(8) unsigned NOT NULL,
  `output_item_qty` smallint(5) unsigned NOT NULL,
  `unlock_method` varchar(16) NOT NULL,
  `craft_time_ms` smallint(5) unsigned NOT NULL,
  `discipline_rating` smallint(5) unsigned NOT NULL DEFAULT '0',
  `discipline_armorsmith` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `discipline_artificer` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `discipline_chef` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `discipline_huntsman` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `discipline_jeweler` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `discipline_leatherworker` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `discipline_tailor` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `discipline_weaponsmith` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `ingredient_1_id` mediumint(8) unsigned NOT NULL,
  `ingredient_1_qty` smallint(5) unsigned NOT NULL,
  `ingredient_2_id` mediumint(8) unsigned DEFAULT NULL,
  `ingredient_2_qty` smallint(5) unsigned DEFAULT NULL,
  `ingredient_3_id` mediumint(8) unsigned DEFAULT NULL,
  `ingredient_3_qty` smallint(5) unsigned DEFAULT NULL,
  `ingredient_4_id` mediumint(8) unsigned DEFAULT NULL,
  `ingredient_4_qty` smallint(5) unsigned DEFAULT NULL,
  `recipe_warnings` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`recipe_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-04-13 11:10:07

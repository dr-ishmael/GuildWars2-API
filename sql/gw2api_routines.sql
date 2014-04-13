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
-- Temporary table structure for view `recipe_vw`
--

DROP TABLE IF EXISTS `recipe_vw`;
/*!50001 DROP VIEW IF EXISTS `recipe_vw`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `recipe_vw` (
  `recipe_id` tinyint NOT NULL,
  `recipe_type` tinyint NOT NULL,
  `output_item_id` tinyint NOT NULL,
  `output_item_name` tinyint NOT NULL,
  `output_item_qty` tinyint NOT NULL,
  `unlock_method` tinyint NOT NULL,
  `recipe_sheet_name` tinyint NOT NULL,
  `craft_time_ms` tinyint NOT NULL,
  `discipline_rating` tinyint NOT NULL,
  `discipline_armorsmith` tinyint NOT NULL,
  `discipline_artificer` tinyint NOT NULL,
  `discipline_chef` tinyint NOT NULL,
  `discipline_huntsman` tinyint NOT NULL,
  `discipline_jeweler` tinyint NOT NULL,
  `discipline_leatherworker` tinyint NOT NULL,
  `discipline_tailor` tinyint NOT NULL,
  `discipline_weaponsmith` tinyint NOT NULL,
  `ingredient_1_id` tinyint NOT NULL,
  `ingredient_1_name` tinyint NOT NULL,
  `ingredient_1_qty` tinyint NOT NULL,
  `ingredient_2_id` tinyint NOT NULL,
  `ingredient_2_name` tinyint NOT NULL,
  `ingredient_2_qty` tinyint NOT NULL,
  `ingredient_3_id` tinyint NOT NULL,
  `ingredient_3_name` tinyint NOT NULL,
  `ingredient_3_qty` tinyint NOT NULL,
  `ingredient_4_id` tinyint NOT NULL,
  `ingredient_4_name` tinyint NOT NULL,
  `ingredient_4_qty` tinyint NOT NULL,
  `recipe_warnings` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `recipe_vw`
--

/*!50001 DROP TABLE IF EXISTS `recipe_vw`*/;
/*!50001 DROP VIEW IF EXISTS `recipe_vw`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `recipe_vw` AS select `r`.`recipe_id` AS `recipe_id`,`r`.`recipe_type` AS `recipe_type`,`r`.`output_item_id` AS `output_item_id`,`o`.`item_name` AS `output_item_name`,`r`.`output_item_qty` AS `output_item_qty`,`r`.`unlock_method` AS `unlock_method`,`c`.`item_name` AS `recipe_sheet_name`,`r`.`craft_time_ms` AS `craft_time_ms`,`r`.`discipline_rating` AS `discipline_rating`,`r`.`discipline_armorsmith` AS `discipline_armorsmith`,`r`.`discipline_artificer` AS `discipline_artificer`,`r`.`discipline_chef` AS `discipline_chef`,`r`.`discipline_huntsman` AS `discipline_huntsman`,`r`.`discipline_jeweler` AS `discipline_jeweler`,`r`.`discipline_leatherworker` AS `discipline_leatherworker`,`r`.`discipline_tailor` AS `discipline_tailor`,`r`.`discipline_weaponsmith` AS `discipline_weaponsmith`,`r`.`ingredient_1_id` AS `ingredient_1_id`,`i1`.`item_name` AS `ingredient_1_name`,`r`.`ingredient_1_qty` AS `ingredient_1_qty`,`r`.`ingredient_2_id` AS `ingredient_2_id`,`i2`.`item_name` AS `ingredient_2_name`,`r`.`ingredient_2_qty` AS `ingredient_2_qty`,`r`.`ingredient_3_id` AS `ingredient_3_id`,`i3`.`item_name` AS `ingredient_3_name`,`r`.`ingredient_3_qty` AS `ingredient_3_qty`,`r`.`ingredient_4_id` AS `ingredient_4_id`,`i4`.`item_name` AS `ingredient_4_name`,`r`.`ingredient_4_qty` AS `ingredient_4_qty`,`r`.`recipe_warnings` AS `recipe_warnings` from ((((((`recipe_tb` `r` left join `item_tb` `o` on((`r`.`output_item_id` = `o`.`item_id`))) left join `item_tb` `c` on((`r`.`recipe_id` = `c`.`unlock_recipe_id`))) left join `item_tb` `i1` on((`r`.`ingredient_1_id` = `i1`.`item_id`))) left join `item_tb` `i2` on((`r`.`ingredient_2_id` = `i2`.`item_id`))) left join `item_tb` `i3` on((`r`.`ingredient_3_id` = `i3`.`item_id`))) left join `item_tb` `i4` on((`r`.`ingredient_4_id` = `i4`.`item_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-04-13 11:10:08

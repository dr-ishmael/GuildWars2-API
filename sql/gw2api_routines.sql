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
-- Temporary table structure for view `item_armor_vw`
--

DROP TABLE IF EXISTS `item_armor_vw`;
/*!50001 DROP VIEW IF EXISTS `item_armor_vw`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `item_armor_vw` (
  `item_id` tinyint NOT NULL,
  `item_name` tinyint NOT NULL,
  `armor_type` tinyint NOT NULL,
  `armor_class` tinyint NOT NULL,
  `armor_race` tinyint NOT NULL,
  `item_level` tinyint NOT NULL,
  `item_rarity` tinyint NOT NULL,
  `item_description` tinyint NOT NULL,
  `vendor_value` tinyint NOT NULL,
  `equip_prefix` tinyint NOT NULL,
  `equip_infusion_slot` tinyint NOT NULL,
  `suffix_item_id` tinyint NOT NULL,
  `buff_skill_id` tinyint NOT NULL,
  `buff_description` tinyint NOT NULL,
  `armor_infobox` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `item_armor_vw`
--

/*!50001 DROP TABLE IF EXISTS `item_armor_vw`*/;
/*!50001 DROP VIEW IF EXISTS `item_armor_vw`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `item_armor_vw` AS select `item_tb`.`item_id` AS `item_id`,`item_tb`.`item_name` AS `item_name`,`item_tb`.`item_subtype` AS `armor_type`,`item_tb`.`armor_class` AS `armor_class`,`item_tb`.`armor_race` AS `armor_race`,`item_tb`.`item_level` AS `item_level`,`item_tb`.`item_rarity` AS `item_rarity`,`item_tb`.`item_description` AS `item_description`,`item_tb`.`vendor_value` AS `vendor_value`,`item_tb`.`equip_prefix` AS `equip_prefix`,`item_tb`.`equip_infusion_slot` AS `equip_infusion_slot`,`item_tb`.`suffix_item_id` AS `suffix_item_id`,`item_tb`.`buff_skill_id` AS `buff_skill_id`,`item_tb`.`buff_description` AS `buff_description`,concat_ws('\n','{{armor infobox',concat('| id = ',`item_tb`.`item_id`),concat('| type = ',`item_tb`.`item_subtype`),concat('| class = ',`item_tb`.`armor_class`),concat('| level = ',`item_tb`.`item_level`),concat('| rarity = ',`item_tb`.`item_rarity`),concat('| value = ',`item_tb`.`vendor_value`),concat('| prefix = ',`item_tb`.`equip_prefix`),concat('| race = ',`item_tb`.`armor_race`),concat('| bound = ',(case when (`item_tb`.`flag_soulbindonacquire` = 1) then 'acquire' when (`item_tb`.`flag_soulbindonuse` = 1) then (case when (`item_tb`.`flag_accountbound` = 1) then 'accountsoul' else 'use' end) when (`item_tb`.`flag_accountbound` = 1) then 'account' end)),'}}') AS `armor_infobox` from `item_tb` where (`item_tb`.`item_type` = 'Armor') */;
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

-- Dump completed on 2014-03-09 23:27:25

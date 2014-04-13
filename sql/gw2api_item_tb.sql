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
-- Table structure for table `item_tb`
--

DROP TABLE IF EXISTS `item_tb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_tb` (
  `item_id` mediumint(8) unsigned NOT NULL,
  `item_name` varchar(128) NOT NULL,
  `item_type` varchar(32) NOT NULL DEFAULT '0',
  `item_subtype` varchar(32) DEFAULT NULL,
  `item_level` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `item_rarity` varchar(32) NOT NULL DEFAULT '0',
  `item_description` varchar(1024) DEFAULT NULL,
  `vendor_value` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `game_type_activity` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `game_type_dungeon` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `game_type_pve` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `game_type_pvp` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `game_type_pvplobby` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `game_type_wvw` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_accountbound` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_hidesuffix` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_nomysticforge` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_nosalvage` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_nosell` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_notupgradeable` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_nounderwater` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_soulbindonacquire` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_soulbindonuse` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `flag_unique` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `item_file_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `item_file_signature` char(40) NOT NULL DEFAULT '0',
  `equip_prefix` varchar(32) DEFAULT NULL,
  `equip_infusion_slot1` varchar(32) DEFAULT NULL,
  `equip_infusion_slot2` varchar(32) DEFAULT NULL,
  `buff_skill_id` mediumint(8) unsigned DEFAULT NULL,
  `buff_description` varchar(256) DEFAULT NULL,
  `suffix_item_id` mediumint(8) unsigned DEFAULT NULL,
  `armor_class` varchar(32) DEFAULT NULL,
  `armor_race` varchar(32) DEFAULT NULL,
  `bag_size` tinyint(3) unsigned DEFAULT NULL,
  `bag_invisible` tinyint(1) unsigned DEFAULT NULL,
  `food_duration_sec` mediumint(8) unsigned DEFAULT NULL,
  `food_description` varchar(256) DEFAULT NULL,
  `tool_charges` tinyint(3) unsigned DEFAULT NULL,
  `unlock_type` varchar(32) DEFAULT NULL,
  `unlock_color_id` smallint(5) unsigned DEFAULT NULL,
  `unlock_recipe_id` mediumint(8) unsigned DEFAULT NULL,
  `upgrade_type` varchar(32) DEFAULT NULL,
  `upgrade_suffix` varchar(32) DEFAULT NULL,
  `upgrade_infusion_type` varchar(32) DEFAULT NULL,
  `weapon_damage_type` varchar(32) DEFAULT NULL,
  `item_warnings` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`item_id`)
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

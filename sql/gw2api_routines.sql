CREATE DATABASE  IF NOT EXISTS `gw2api` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `gw2api`;
-- MySQL dump 10.13  Distrib 5.6.17, for Win32 (x86)
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
-- Temporary table structure for view `item_vw`
--

DROP TABLE IF EXISTS `item_vw`;
/*!50001 DROP VIEW IF EXISTS `item_vw`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `item_vw` (
  `item_id` tinyint NOT NULL,
  `item_name` tinyint NOT NULL,
  `item_type` tinyint NOT NULL,
  `item_subtype` tinyint NOT NULL,
  `item_level` tinyint NOT NULL,
  `item_rarity` tinyint NOT NULL,
  `item_description` tinyint NOT NULL,
  `vendor_value` tinyint NOT NULL,
  `game_type_activity` tinyint NOT NULL,
  `game_type_dungeon` tinyint NOT NULL,
  `game_type_pve` tinyint NOT NULL,
  `game_type_pvp` tinyint NOT NULL,
  `game_type_pvplobby` tinyint NOT NULL,
  `game_type_wvw` tinyint NOT NULL,
  `flag_accountbindonuse` tinyint NOT NULL,
  `flag_accountbound` tinyint NOT NULL,
  `flag_hidesuffix` tinyint NOT NULL,
  `flag_nomysticforge` tinyint NOT NULL,
  `flag_nosalvage` tinyint NOT NULL,
  `flag_nosell` tinyint NOT NULL,
  `flag_notupgradeable` tinyint NOT NULL,
  `flag_nounderwater` tinyint NOT NULL,
  `flag_soulbindonacquire` tinyint NOT NULL,
  `flag_soulbindonuse` tinyint NOT NULL,
  `flag_unique` tinyint NOT NULL,
  `icon_url` tinyint NOT NULL,
  `default_skin` tinyint NOT NULL,
  `default_skin_name` tinyint NOT NULL,
  `equip_prefix` tinyint NOT NULL,
  `equip_infusion_slot_1_type` tinyint NOT NULL,
  `equip_infusion_slot_1_item_id` tinyint NOT NULL,
  `equip_infusion_slot_2_type` tinyint NOT NULL,
  `equip_infusion_slot_2_item_id` tinyint NOT NULL,
  `buff_skill_id` tinyint NOT NULL,
  `buff_description` tinyint NOT NULL,
  `suffix_item_id` tinyint NOT NULL,
  `second_suffix_item_id` tinyint NOT NULL,
  `armor_class` tinyint NOT NULL,
  `armor_race` tinyint NOT NULL,
  `armor_defense` tinyint NOT NULL,
  `bag_size` tinyint NOT NULL,
  `bag_invisible` tinyint NOT NULL,
  `food_duration_sec` tinyint NOT NULL,
  `food_description` tinyint NOT NULL,
  `tool_charges` tinyint NOT NULL,
  `unlock_type` tinyint NOT NULL,
  `unlock_color_id` tinyint NOT NULL,
  `unlock_recipe_id` tinyint NOT NULL,
  `upgrade_type` tinyint NOT NULL,
  `upgrade_suffix` tinyint NOT NULL,
  `upgrade_infusion_type` tinyint NOT NULL,
  `weapon_damage_type` tinyint NOT NULL,
  `weapon_min_strength` tinyint NOT NULL,
  `weapon_max_strength` tinyint NOT NULL,
  `item_warnings` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `recipe_sheets_vw`
--

DROP TABLE IF EXISTS `recipe_sheets_vw`;
/*!50001 DROP VIEW IF EXISTS `recipe_sheets_vw`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `recipe_sheets_vw` (
  `item_id` tinyint NOT NULL,
  `item_name` tinyint NOT NULL,
  `item_name_de` tinyint NOT NULL,
  `item_name_es` tinyint NOT NULL,
  `item_name_fr` tinyint NOT NULL,
  `item_level` tinyint NOT NULL,
  `item_rarity` tinyint NOT NULL,
  `item_description` tinyint NOT NULL,
  `vendor_value` tinyint NOT NULL,
  `ingredient_1_name` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `skin_vw`
--

DROP TABLE IF EXISTS `skin_vw`;
/*!50001 DROP VIEW IF EXISTS `skin_vw`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `skin_vw` (
  `skin_id` tinyint NOT NULL,
  `skin_name` tinyint NOT NULL,
  `skin_type` tinyint NOT NULL,
  `skin_subtype` tinyint NOT NULL,
  `skin_description` tinyint NOT NULL,
  `flag_hideiflocked` tinyint NOT NULL,
  `flag_nocost` tinyint NOT NULL,
  `flag_showinwardrobe` tinyint NOT NULL,
  `icon_file_id` tinyint NOT NULL,
  `icon_url` tinyint NOT NULL,
  `armor_race` tinyint NOT NULL,
  `armor_class` tinyint NOT NULL,
  `weapon_damage_type` tinyint NOT NULL
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
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `recipe_vw` AS select `r`.`recipe_id` AS `recipe_id`,`r`.`recipe_type` AS `recipe_type`,`r`.`output_item_id` AS `output_item_id`,`o`.`item_name` AS `output_item_name`,`r`.`output_item_qty` AS `output_item_qty`,`r`.`unlock_method` AS `unlock_method`,`c`.`item_name` AS `recipe_sheet_name`,`r`.`craft_time_ms` AS `craft_time_ms`,`r`.`discipline_rating` AS `discipline_rating`,`r`.`discipline_armorsmith` AS `discipline_armorsmith`,`r`.`discipline_artificer` AS `discipline_artificer`,`r`.`discipline_chef` AS `discipline_chef`,`r`.`discipline_huntsman` AS `discipline_huntsman`,`r`.`discipline_jeweler` AS `discipline_jeweler`,`r`.`discipline_leatherworker` AS `discipline_leatherworker`,`r`.`discipline_tailor` AS `discipline_tailor`,`r`.`discipline_weaponsmith` AS `discipline_weaponsmith`,`r`.`ingredient_1_id` AS `ingredient_1_id`,`i1`.`item_name` AS `ingredient_1_name`,`r`.`ingredient_1_qty` AS `ingredient_1_qty`,`r`.`ingredient_2_id` AS `ingredient_2_id`,`i2`.`item_name` AS `ingredient_2_name`,`r`.`ingredient_2_qty` AS `ingredient_2_qty`,`r`.`ingredient_3_id` AS `ingredient_3_id`,`i3`.`item_name` AS `ingredient_3_name`,`r`.`ingredient_3_qty` AS `ingredient_3_qty`,`r`.`ingredient_4_id` AS `ingredient_4_id`,`i4`.`item_name` AS `ingredient_4_name`,`r`.`ingredient_4_qty` AS `ingredient_4_qty`,`r`.`recipe_warnings` AS `recipe_warnings` from ((((((`recipe_tb` `r` left join `item_tb` `o` on((`r`.`output_item_id` = `o`.`item_id`))) left join `item_tb` `c` on((`r`.`recipe_id` = `c`.`unlock_recipe_id`))) left join `item_tb` `i1` on((`r`.`ingredient_1_id` = `i1`.`item_id`))) left join `item_tb` `i2` on((`r`.`ingredient_2_id` = `i2`.`item_id`))) left join `item_tb` `i3` on((`r`.`ingredient_3_id` = `i3`.`item_id`))) left join `item_tb` `i4` on((`r`.`ingredient_4_id` = `i4`.`item_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `item_vw`
--

/*!50001 DROP TABLE IF EXISTS `item_vw`*/;
/*!50001 DROP VIEW IF EXISTS `item_vw`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `item_vw` AS select `item_tb`.`item_id` AS `item_id`,`item_tb`.`item_name` AS `item_name`,`item_tb`.`item_type` AS `item_type`,`item_tb`.`item_subtype` AS `item_subtype`,`item_tb`.`item_level` AS `item_level`,`item_tb`.`item_rarity` AS `item_rarity`,`item_tb`.`item_description` AS `item_description`,`item_tb`.`vendor_value` AS `vendor_value`,`item_tb`.`game_type_activity` AS `game_type_activity`,`item_tb`.`game_type_dungeon` AS `game_type_dungeon`,`item_tb`.`game_type_pve` AS `game_type_pve`,`item_tb`.`game_type_pvp` AS `game_type_pvp`,`item_tb`.`game_type_pvplobby` AS `game_type_pvplobby`,`item_tb`.`game_type_wvw` AS `game_type_wvw`,`item_tb`.`flag_accountbindonuse` AS `flag_accountbindonuse`,`item_tb`.`flag_accountbound` AS `flag_accountbound`,`item_tb`.`flag_hidesuffix` AS `flag_hidesuffix`,`item_tb`.`flag_nomysticforge` AS `flag_nomysticforge`,`item_tb`.`flag_nosalvage` AS `flag_nosalvage`,`item_tb`.`flag_nosell` AS `flag_nosell`,`item_tb`.`flag_notupgradeable` AS `flag_notupgradeable`,`item_tb`.`flag_nounderwater` AS `flag_nounderwater`,`item_tb`.`flag_soulbindonacquire` AS `flag_soulbindonacquire`,`item_tb`.`flag_soulbindonuse` AS `flag_soulbindonuse`,`item_tb`.`flag_unique` AS `flag_unique`,`item_tb`.`icon_url` AS `icon_url`,`item_tb`.`default_skin` AS `default_skin`,`skin_tb`.`skin_name` AS `default_skin_name`,`item_tb`.`equip_prefix` AS `equip_prefix`,`item_tb`.`equip_infusion_slot_1_type` AS `equip_infusion_slot_1_type`,`item_tb`.`equip_infusion_slot_1_item_id` AS `equip_infusion_slot_1_item_id`,`item_tb`.`equip_infusion_slot_2_type` AS `equip_infusion_slot_2_type`,`item_tb`.`equip_infusion_slot_2_item_id` AS `equip_infusion_slot_2_item_id`,`item_tb`.`buff_skill_id` AS `buff_skill_id`,`item_tb`.`buff_description` AS `buff_description`,`item_tb`.`suffix_item_id` AS `suffix_item_id`,`item_tb`.`second_suffix_item_id` AS `second_suffix_item_id`,`item_tb`.`armor_class` AS `armor_class`,`item_tb`.`armor_race` AS `armor_race`,`item_tb`.`armor_defense` AS `armor_defense`,`item_tb`.`bag_size` AS `bag_size`,`item_tb`.`bag_invisible` AS `bag_invisible`,`item_tb`.`food_duration_sec` AS `food_duration_sec`,`item_tb`.`food_description` AS `food_description`,`item_tb`.`tool_charges` AS `tool_charges`,`item_tb`.`unlock_type` AS `unlock_type`,`item_tb`.`unlock_color_id` AS `unlock_color_id`,`item_tb`.`unlock_recipe_id` AS `unlock_recipe_id`,`item_tb`.`upgrade_type` AS `upgrade_type`,`item_tb`.`upgrade_suffix` AS `upgrade_suffix`,`item_tb`.`upgrade_infusion_type` AS `upgrade_infusion_type`,`item_tb`.`weapon_damage_type` AS `weapon_damage_type`,`item_tb`.`weapon_min_strength` AS `weapon_min_strength`,`item_tb`.`weapon_max_strength` AS `weapon_max_strength`,`item_tb`.`item_warnings` AS `item_warnings` from (`item_tb` left join `skin_tb` on((`item_tb`.`default_skin` = `skin_tb`.`skin_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `recipe_sheets_vw`
--

/*!50001 DROP TABLE IF EXISTS `recipe_sheets_vw`*/;
/*!50001 DROP VIEW IF EXISTS `recipe_sheets_vw`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `recipe_sheets_vw` AS select `a`.`item_id` AS `item_id`,`a`.`item_name` AS `item_name`,`c`.`item_name_de` AS `item_name_de`,`c`.`item_name_es` AS `item_name_es`,`c`.`item_name_fr` AS `item_name_fr`,`a`.`item_level` AS `item_level`,`a`.`item_rarity` AS `item_rarity`,`a`.`item_description` AS `item_description`,`a`.`vendor_value` AS `vendor_value`,`b`.`ingredient_1_name` AS `ingredient_1_name` from ((`item_tb` `a` join `item_lang_tb` `c` on((`a`.`item_id` = `c`.`item_id`))) left join `recipe_vw` `b` on((`a`.`unlock_recipe_id` = `b`.`recipe_id`))) where ((`a`.`unlock_type` = 'CraftingRecipe') and (`a`.`item_description` like '%Chef%')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `skin_vw`
--

/*!50001 DROP TABLE IF EXISTS `skin_vw`*/;
/*!50001 DROP VIEW IF EXISTS `skin_vw`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `skin_vw` AS select `skin_tb`.`skin_id` AS `skin_id`,`skin_tb`.`skin_name` AS `skin_name`,`skin_tb`.`skin_type` AS `skin_type`,`skin_tb`.`skin_subtype` AS `skin_subtype`,`skin_tb`.`skin_description` AS `skin_description`,`skin_tb`.`flag_hideiflocked` AS `flag_hideiflocked`,`skin_tb`.`flag_nocost` AS `flag_nocost`,`skin_tb`.`flag_showinwardrobe` AS `flag_showinwardrobe`,`skin_tb`.`skin_file_id` AS `icon_file_id`,concat('https://render.guildwars2.com/file/',`skin_tb`.`skin_file_signature`,'/',`skin_tb`.`skin_file_id`,'.png') AS `icon_url`,`skin_tb`.`armor_race` AS `armor_race`,`skin_tb`.`armor_class` AS `armor_class`,`skin_tb`.`weapon_damage_type` AS `weapon_damage_type` from `skin_tb` where 1 */;
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

-- Dump completed on 2014-10-11 17:47:28

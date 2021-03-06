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
-- Table structure for table `skin_wiki_page_tb`
--

DROP TABLE IF EXISTS `skin_wiki_page_tb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `skin_wiki_page_tb` (
  `skin_id` mediumint(9) NOT NULL,
  `skin_page` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`skin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skin_wiki_page_tb`
--

LOCK TABLES `skin_wiki_page_tb` WRITE;
/*!40000 ALTER TABLE `skin_wiki_page_tb` DISABLE KEYS */;
INSERT INTO `skin_wiki_page_tb` VALUES (107,'Ahamid\'s Breastplate'),(108,'Ahamid\'s Tassets'),(109,'Ahamid\'s Doublet'),(110,'Ahamid\'s Breeches'),(111,'Ahamid\'s Guise'),(112,'Ahamid\'s Leggings'),(113,'Ahamid\'s Pauldrons'),(114,'Ahamid\'s Greaves'),(115,'Ahamid\'s Footwear'),(116,'Ahamid\'s Warfists'),(117,'Ahamid\'s Striders'),(118,'Ahamid\'s Wristguards'),(119,'Ahamid\'s Epaulets'),(120,'Ahamid\'s Grips'),(121,'Ahamid\'s Shoulderguard'),(122,'Ahamid\'s Visor'),(123,'Ahamid\'s Masque'),(124,'Ahamid\'s Visage'),(724,'Flame Legion Helm (heavy)'),(735,'Flame Legion Helm (medium)'),(756,'Radiant Mantle Skin'),(757,'Radiant Greaves Skin'),(758,'Radiant Warhelm Skin'),(759,'Radiant Vambraces Skin'),(760,'Radiant Greaves Skin'),(761,'Radiant Vambraces Skin'),(762,'Radiant Warhelm Skin'),(763,'Radiant Mantle Skin'),(764,'Radiant Greaves Skin'),(765,'Radiant Warhelm Skin'),(766,'Radiant Vambraces Skin'),(767,'Radiant Mantle Skin'),(768,'Hellfire Mantle Skin'),(769,'Hellfire Greaves Skin'),(770,'Hellfire Warhelm Skin'),(771,'Hellfire Vambraces Skin'),(772,'Hellfire Vambraces Skin'),(773,'Hellfire Warhelm Skin'),(774,'Hellfire Greaves Skin'),(775,'Hellfire Mantle Skin'),(776,'Hellfire Warhelm Skin'),(777,'Hellfire Greaves Skin'),(778,'Hellfire Vambraces Skin'),(779,'Hellfire Mantle Skin'),(800,'Fire God\'s Vambraces'),(802,'Fire God\'s Vambraces'),(804,'Fire God\'s Vambraces'),(814,'Heavenly Bracers'),(815,'Heavenly Bracers'),(816,'Heavenly Bracers'),(820,'Baroque Mask'),(821,'Baroque Mask'),(822,'Baroque Mask'),(823,'Icelord\'s Diadem'),(824,'Icelord\'s Diadem'),(825,'Icelord\'s Diadem'),(827,'Scarlet\'s Veil Skin'),(830,'Scarlet\'s Veil Skin'),(833,'Magnus\'s Left Eye Patch Skin'),(838,'Scarlet\'s Veil Skin'),(839,'Magnus\'s Left Eye Patch Skin'),(840,'Magnus\'s Right Eye Patch Skin'),(841,'Magnus\'s Left Eye Patch Skin'),(842,'Magnus\'s Right Eye Patch Skin'),(843,'Magnus\'s Right Eye Patch Skin'),(857,'Metal Aquabreather (Creator Zee)'),(858,'Cloth Aquabreather (Creator Zee)'),(859,'Leather Aquabreather (Creator Zee)'),(860,'Duelist Leggings Skin'),(861,'Duelist Breastplate Skin'),(865,'Heavy Plate Leggings'),(866,'Stately Garb Skin'),(868,'Stately Leggings Skin'),(869,'Duelist Helm Skin'),(870,'Pit Fighter Coat Skin'),(871,'Duelist Pauldrons Skin'),(872,'Duelist Boots Skin'),(877,'Pit Fighter Skirt Skin'),(878,'Dry Bones Garb Skin'),(882,'Dry Bones Leggings Skin'),(883,'Duelist Gauntlets Skin'),(885,'Stately Shoes Skin'),(886,'Dark Coat Skin'),(888,'Stately Mantle Skin'),(894,'Stately Helm Skin'),(895,'Dark Leggings Skin'),(897,'Pit Fighter Shoulderguard Skin'),(898,'Tactical Coat Skin'),(899,'Pit Fighter Sandals Skin'),(900,'Conquest Coat Skin'),(901,'Dry Bones Mantle Skin'),(902,'Stately Gloves Skin'),(903,'Tactical Leggings Skin'),(904,'Dry Bones Shoes Skin'),(905,'Pit Fighter Helm Skin'),(906,'Conquest Leggings Skin'),(907,'Dry Bones Hood Skin'),(911,'Dark Pauldrons Skin'),(912,'Dark Boots Skin'),(915,'Pit Fighter Wristguards Skin'),(916,'Tactical Boots Skin'),(917,'Plated Coat Skin'),(918,'Dry Bones Gloves Skin'),(919,'Dark Helm Skin'),(921,'Tactical Shoulders Skin'),(922,'Conquest Shoulders Skin'),(923,'Conquest Boots Skin'),(925,'Warden Coat Skin'),(926,'Warden Leggings Skin'),(927,'Warden Mask Skin'),(928,'Plated Leggings Skin'),(929,'Dark Gloves Skin'),(930,'Tactical Gloves Skin'),(932,'Plated Boots Skin'),(935,'Conquest Gloves Skin'),(936,'Plated Pauldrons Skin'),(937,'Warden Shoulder Pads Skin'),(938,'Warden Shoes Skin'),(942,'Plated Helm Skin'),(943,'Plated Gauntlets Skin'),(945,'Warden Gloves Skin'),(1041,'Consortium Breathing Mask Skin'),(1044,'Consortium Breathing Mask Skin'),(1045,'Consortium Breathing Mask Skin'),(1049,'Mask of the Silent Skin'),(1050,'Mask of the Silent Skin'),(1051,'Mask of the Silent Skin'),(1060,'Braham\'s Legplates Skin'),(1062,'Phoenix Pants Skin'),(1064,'Magitech Leggings Skin'),(1074,'Phalanx Heavy Legplate Skin'),(1079,'Braham\'s Chestplate Skin'),(1082,'Phoenix Vest Skin'),(1084,'Braham\'s Pauldrons Skin'),(1085,'Phoenix Mantle Skin'),(1087,'Magitech Jerkin Skin'),(1091,'Magitech Shoulderpads Skin'),(1092,'Braham\'s Warboots Skin'),(1095,'Phoenix Shoes Skin'),(1098,'Magitech Boots Skin'),(1101,'Phalanx Heavy Warplate Skin'),(1106,'Phalanx Heavy Shoulder Skin'),(1113,'Phalanx Heavy Warboot Skin'),(1116,'Deathly Avian Pauldrons Skin'),(1119,'Deathly Bull\'s Pauldrons Skin'),(1120,'Deathly Pauldrons Skin'),(1121,'Deathly Avian Mantle Skin'),(1123,'Deathly Bull\'s Mantle Skin'),(1126,'Deathly Mantle Skin'),(1128,'Deathly Avian Shoulderpads Skin'),(1131,'Deathly Bull\'s Shoulderpads Skin'),(1136,'Deathly Shoulderpads Skin'),(1137,'Island Shoulder Skin'),(1141,'Island Shoulder Skin'),(1143,'Island Shoulder Skin'),(1151,'Braham\'s Gauntlets Skin'),(1152,'Phoenix Gloves Skin'),(1153,'Magitech Armguards Skin'),(1157,'Phalanx Heavy Gauntlet Skin'),(1195,'Braham\'s Warhelm Skin'),(1196,'Phoenix Mask Skin'),(1197,'Magitech Helmet Skin'),(1201,'Phalanx Heavy Warhelm Skin'),(1202,'Zephyrite Wind Helm Skin'),(1203,'Zephyrite Wind Helm Skin'),(1204,'Zephyrite Wind Helm Skin'),(1205,'Zephyrite Sun Helm Skin'),(1206,'Zephyrite Sun Helm Skin'),(1207,'Zephyrite Sun Helm Skin'),(1208,'Zephyrite Lightning Helm Skin'),(1209,'Zephyrite Lightning Helm Skin'),(1210,'Zephyrite Lightning Helm Skin'),(1222,'Grenth Hood Skin'),(1223,'Grenth Hood Skin'),(1224,'Grenth Hood Skin'),(1225,'Stag Helm Skin'),(1226,'Stag Helm Skin'),(1227,'Stag Helm Skin'),(1250,'Mask of the Wanderer Skin'),(1251,'Mask of the Wanderer Skin'),(1252,'Mask of the Wanderer Skin'),(1253,'Flamekissed Vest Skin'),(1254,'Flamekissed Pants Skin'),(1255,'Flamekissed Shoes Skin'),(1256,'Flamekissed Mantle Skin'),(1257,'Flamekissed Gloves Skin'),(1258,'Flamekissed Mask Skin'),(1259,'Flamewrath Legplates Skin'),(1260,'Flamewalker Leggings Skin'),(1261,'Flamewrath Chestplate Skin'),(1262,'Flamewalker Coat Skin'),(1263,'Flamewrath Warboots Skin'),(1264,'Flamewalker Boots Skin'),(1265,'Flamewrath Pauldrons Skin'),(1266,'Flamewalker Shoulderpads Skin'),(1267,'Flamewrath Gauntlets Skin'),(1268,'Flamewalker Armguards Skin'),(1269,'Flamewrath Helm Skin'),(1270,'Flamewalker Hat Skin'),(1271,'Strider\'s Armguard Skin'),(1272,'Rampart Heavy Gauntlet Skin'),(1273,'Rampart Heavy Warhelm Skin'),(1274,'Rampart Heavy Legplate Skin'),(1275,'Rampart Heavy Pauldron Skin'),(1276,'Incarnate Light Shoe Skin'),(1277,'Incarnate Light Vest Skin'),(1278,'Incarnate Light Glove Skin'),(1279,'Incarnate Light Mask Skin'),(1280,'Incarnate Light Pant Skin'),(1281,'Incarnate Light Mantle Skin'),(1282,'Strider\'s Boot Skin'),(1283,'Strider\'s Tunic Skin'),(1285,'Strider\'s Faceguard Skin'),(1286,'Strider\'s Legging Skin'),(1287,'Strider\'s Spaulder Skin'),(1288,'Rampart Heavy Warboot Skin'),(1289,'Rampart Heavy Warplate Skin'),(1307,'Aetherblade Heavy Pauldron Skin'),(1308,'Aetherblade Heavy Legplate Skin'),(1309,'Aetherblade Light Mantle Skin'),(1310,'Aetherblade Light Pant Skin'),(1311,'Aetherblade Medium Legging Skin'),(1312,'Aetherblade Medium Shoulderpad Skin'),(1313,'Aetherblade Heavy Warplate Skin'),(1314,'Aetherblade Light Vest Skin'),(1315,'Aetherblade Medium Jerkin Skin'),(1316,'Aetherblade Heavy Warboot Skin'),(1317,'Aetherblade Light Shoe Skin'),(1318,'Aetherblade Medium Boot Skin'),(1319,'Aetherblade Heavy Gauntlet Skin'),(1320,'Aetherblade Light Glove Skin'),(1321,'Aetherblade Medium Armguard Skin'),(1322,'Aetherblade Heavy Warhelm Skin'),(1323,'Aetherblade Light Goggles Skin'),(1324,'Aetherblade Medium Helmet Skin'),(1325,'Toxic Mantle Skin'),(1326,'Toxic Mantle Skin'),(1327,'Toxic Mantle Skin'),(1328,'Toxic Gloves Skin'),(1329,'Toxic Gloves Skin'),(1330,'Toxic Gloves Skin'),(1331,'Trickster\'s Light Leggings Skin'),(1332,'Trickster\'s Light Mantle Skin'),(1333,'Trickster\'s Light Vest Skin'),(1334,'Trickster\'s Light Shoe Skin'),(1335,'Trickster\'s Light Glove Skin'),(1336,'Trickster\'s Light Mask Skin'),(1337,'Viper\'s Medium Legging Skin'),(1338,'Viper\'s Medium Shoulderpad Skin'),(1339,'Viper\'s Medium Jerkin Skin'),(1340,'Viper\'s Medium Boot Skin'),(1341,'Viper\'s Medium Armguard Skin'),(1342,'Viper\'s Medium Monocle Skin'),(1343,'Zodiac Heavy Warboot Skin'),(1344,'Zodiac Heavy Warplate Skin'),(1345,'Zodiac Heavy Gauntlets Skin'),(1346,'Zodiac Heavy Warhelm Skin'),(1347,'Zodiac Heavy Legplates Skin'),(1348,'Zodiac Heavy Pauldrons Skin'),(1349,'Zodiac Light Shoes Skin'),(1350,'Zodiac Light Vest Skin'),(1351,'Zodiac Light Gloves Skin'),(1352,'Zodiac Light Goggles Skin'),(1353,'Zodiac Light Pants Skin'),(1354,'Zodiac Light Mantle Skin'),(1355,'Zodiac Medium Boots Skin'),(1356,'Zodiac Medium Jerkin Skin'),(1357,'Zodiac Medium Armguards Skin'),(1358,'Zodiac Medium Helmet Skin'),(1359,'Zodiac Medium Leggings Skin'),(1360,'Zodiac Medium Shoulderpads Skin'),(1361,'Lawless Boots Skin'),(1362,'Lawless Shoulder Skin'),(1364,'Lawless Helmet Skin'),(1365,'Lawless Helmet Skin'),(1366,'Lawless Gloves Skin'),(1367,'Lawless Helmet Skin'),(1368,'Lawless Shoulder Skin'),(1369,'Lawless Boots Skin'),(1370,'Lawless Boots Skin'),(1371,'Lawless Shoulder Skin'),(1372,'Lawless Gloves Skin'),(1373,'Lawless Gloves Skin'),(1401,'Vigil\'s Honor Leggings (light)'),(1404,'Vigil\'s Honor Gloves (light)'),(1407,'Vigil\'s Honor Gloves (medium)'),(1408,'Vigil\'s Honor Leggings (medium)'),(1418,'Whisper\'s Secret Leggings (light)'),(1420,'Whisper\'s Secret Gloves (light)'),(1423,'Whisper\'s Secret Gloves (medium)'),(1425,'Whisper\'s Secret Leggings (medium)'),(1692,'Tactical Helm Skin'),(1800,'Conquest Helm Skin'),(2013,'Heavy Horns of the Dragon Skin'),(2014,'Light Horns of the Dragon Skin'),(2016,'Medium Horns of the Dragon Skin'),(2018,'Monocle (heavy)'),(2019,'Monocle (light)'),(2020,'Monocle (medium)'),(2021,'Air-Filtration Device of Antitoxin (heavy)'),(2022,'Air-Filtration Device of Antitoxin (medium)'),(2023,'Air-Filtration Device of Antitoxin (light)'),(2024,'Gas Mask Skin'),(2025,'Gas Mask Skin'),(2026,'Gas Mask Skin'),(2027,'Mask of the Night Skin'),(2028,'Mask of the Night Skin'),(2029,'Mask of the Night Skin'),(2343,'Savage Guild Back Banner Skin'),(2344,'Elegant Guild Back Banner Skin'),(2346,'Wind Catcher Skin'),(2347,'Sun Catcher Skin'),(2348,'Lightning Catcher Skin'),(2349,'Desert Rose Skin'),(2350,'Zephyr Rucksack Skin'),(2351,'Holographic Dragon Wing Cover'),(2352,'Holographic Shattered Dragon Wing Cover'),(2355,'Plush Quaggan Backpack Cover'),(2359,'Plush Moto Backpack Cover'),(2363,'Plush Charr Backpack Cover'),(2364,'Tiger Charr Backpack Cover'),(2365,'Pink Quaggan Backpack Cover'),(2366,'Cheetah Charr Backpack Cover'),(2367,'Quaggan Killer Whale Backpack Cover'),(2368,'Plush Tybalt Backpack Cover'),(2369,'Rox\'s Quiver Set'),(2370,'Green Quaggan Backpack Cover'),(2371,'Covert Charr Backpack Cover'),(2372,'Warrior Quaggan Backpack Cover'),(2374,'Toymaker\'s Bag'),(2378,'Beta Fractal Capacitor (Infused)'),(2379,'Fractal Capacitor (Infused)'),(2380,'Fires of Balthazar Skin'),(2381,'Antitoxin Injector Skin'),(3660,'Lovestruck Axe Skin'),(3661,'Tormented Rifle Skin'),(3663,'Tormented Pistol Skin'),(3664,'Lovestruck Longbow Skin'),(3666,'Tormented Hammer Skin'),(3667,'Tormented Staff Skin'),(3668,'Tormented Dagger Skin'),(3670,'Tormented Sword Skin'),(3671,'Lovestruck Short Bow Skin'),(3673,'Lovestruck Focus Skin'),(3674,'Tormented Torch Skin'),(3675,'Tormented Spear Skin'),(3676,'Tormented Focus Skin'),(3677,'Tormented Mace Skin'),(3678,'Tormented Harpoon Gun Skin'),(3679,'Tormented Greatsword Skin'),(3680,'Tormented Axe Skin'),(3681,'Tormented Longbow Skin'),(3682,'Tormented Short Bow Skin'),(3683,'Tormented Scepter Skin'),(3684,'Tormented Warhorn Skin'),(3685,'Tormented Shield Skin'),(3686,'Tormented Trident Skin'),(3687,'Greatsaw Greatsword Skin'),(3688,'Lovestruck Greatsword Skin'),(3691,'Lovestruck Hammer Skin'),(3692,'Lovestruck Mace Skin'),(3693,'Ghastly Grinning Shield Skin'),(3694,'Lovestruck Pistol Skin'),(3695,'Lovestruck Rifle Skin'),(3696,'Chain Sword Skin'),(3697,'Lovestruck Scepter Skin'),(3698,'Lovestruck Protector Skin'),(3699,'Lovestruck Staff Skin'),(3700,'Lovestruck Sword Skin'),(3701,'Lovestruck Flame Skin'),(3702,'Lovestruck Call Skin'),(3703,'Lovestruck Anlace Skin'),(3704,'Dreamthistle Focus Skin'),(3705,'Aetherized Pistol Skin'),(3706,'Dreamthistle Longbow Skin'),(3707,'Dreamthistle Mace Skin'),(3708,'Fused Longbow Skin'),(3709,'Dreamthistle Greatsword Skin'),(3710,'Aetherized Torch Skin'),(3711,'Scythe Staff Skin'),(3712,'Fused Axe Skin'),(3713,'Braham\'s Mace Skin'),(3714,'Fused Greatsword Skin'),(3715,'Aetherized Short Bow Skin'),(3716,'Fused Mace Skin'),(3717,'Dreamthistle Shield Skin'),(3718,'Fused Torch Skin'),(3719,'Sclerite Torch Skin'),(3720,'Aetherized Warhorn Skin'),(3721,'Dragon\'s Jade Flame Skin'),(3722,'Braham\'s Shield Skin'),(3723,'Dreamthistle Dagger Skin'),(3724,'Fused Rifle Skin'),(3725,'Fused Shield Skin'),(3726,'Zodiac Torch Skin'),(3727,'Dreamthistle Torch Skin'),(3728,'Fused Short Bow Skin'),(3729,'Aetherized Trident Skin'),(3730,'Sclerite Short Bow Skin'),(3731,'Dreamthistle Staff Skin'),(3732,'Fused Dagger Skin'),(3733,'Fused Warhorn Skin'),(3734,'Dragon\'s Jade Needler Skin'),(3735,'Aetherized Harpoon Gun Skin'),(3736,'Sclerite Warhorn Skin'),(3737,'Rox\'s Short Bow Skin'),(3738,'Dreamthistle Trident Skin'),(3739,'Winter\'s Arc Short Bow Skin'),(3740,'Dragon\'s Jade Harbinger Skin'),(3741,'Dreamthistle Harpoon Gun Skin'),(3742,'Zodiac Short Bow Skin'),(3743,'Zodiac Warhorn Skin'),(3744,'Dreamthistle Warhorn Skin'),(3745,'Dreamthistle Short Bow Skin'),(3746,'Aetherized Aspect Skin'),(3747,'Fused Staff Skin'),(3748,'Aetherized Axe Skin'),(3749,'Aetherized Longbow Skin'),(3750,'Dreamthistle Sword Skin'),(3751,'Aetherized Sword Skin'),(3752,'Aetherized Mace Skin'),(3753,'Fused Focus Skin'),(3754,'Sclerite Focus Skin'),(3755,'Aetherized Spear Skin'),(3756,'Fused Sword Skin'),(3757,'Dragon\'s Jade Aspect Skin'),(3758,'Aetherized Scepter Skin'),(3759,'Dreamthistle Spear Skin'),(3760,'Fused Pistol Skin'),(3761,'Zodiac Focus Skin'),(3762,'Sclerite Axe Skin'),(3763,'Sclerite Pistol Skin'),(3764,'Consortium Clipper Focus Skin'),(3765,'Dragon\'s Jade Flintlock Skin'),(3766,'Aetherized Rifle Skin'),(3767,'Dragon\'s Jade Reaver Skin'),(3768,'Sclerite Mace Skin'),(3769,'Winter\'s Sting Pistol Skin'),(3770,'Winter\'s Cutter Axe Skin'),(3771,'Dragon\'s Jade Cudgel Skin'),(3772,'Zodiac Axe Skin'),(3773,'Aetherized Greatsword Skin'),(3774,'Zodiac Pistol Skin'),(3775,'Dreamthistle Axe Skin'),(3776,'Dreamthistle Pistol Skin'),(3777,'Aetherized Shield Skin'),(3778,'Zodiac Mace Skin'),(3779,'Fused Scepter Skin'),(3780,'Marjory\'s Axe Skin'),(3781,'Sclerite Scepter Skin'),(3782,'Shark\'s Tooth Axe Skin'),(3783,'Sclerite Longbow Skin'),(3784,'Dragon\'s Jade Truncheon Skin'),(3785,'Zodiac Scepter Skin'),(3786,'Dragon\'s Jade Hornbow Skin'),(3787,'Sclerite Rifle Skin'),(3788,'Dreamthistle Scepter Skin'),(3789,'Winter\'s Reach Longbow Skin'),(3790,'Zodiac Longbow Skin'),(3791,'Dragon\'s Jade Blunderbuss Skin'),(3792,'Sclerite Shield Skin'),(3793,'Zodiac Rifle Skin'),(3794,'Araneae Longbow Skin'),(3795,'Dragon\'s Jade Wall Skin'),(3796,'Dreamthistle Rifle Skin'),(3797,'Aetherized Hammer Skin'),(3798,'Aetherized Dagger Skin'),(3799,'Winter\'s Shelter Shield Skin'),(3800,'Zodiac Shield Skin'),(3801,'Sclerite Greatsword Skin'),(3802,'Dead Stop Shield Skin'),(3803,'Dragon\'s Jade Avenger Skin'),(3804,'Winter\'s Edge Greatsword Skin'),(3805,'Tiki Totem Shield Skin'),(3806,'Zodiac Greatsword Skin'),(3807,'Chiroptophobia Greatsword Skin'),(3808,'Fused Hammer Skin'),(3809,'Sclerite Hammer Skin'),(3810,'Dragon\'s Jade Warhammer Skin'),(3811,'Winter\'s Brunt Hammer Skin'),(3812,'Zodiac Hammer Skin'),(3813,'Dreamthistle Hammer Skin'),(3814,'Aetherized Staff Skin'),(3815,'Kasmeer\'s Staff Skin'),(3816,'Bloody Prince Staff Skin'),(3817,'Sclerite Dagger Skin'),(3818,'Dragon\'s Jade Kris Skin'),(3819,'Winter\'s Needle Dagger Skin'),(3820,'Sclerite Staff Skin'),(3821,'Zodiac Dagger Skin'),(3822,'Dragon\'s Jade Quarterstaff Skin'),(3823,'Marjory\'s Dagger Skin'),(3824,'Winter\'s Timber Staff Skin'),(3825,'Severed Dagger Skin'),(3826,'Zodiac Staff Skin'),(3827,'Sclerite Sword Skin'),(3828,'Dragon\'s Jade Lacerator Skin'),(3829,'Winter\'s Slice Sword Skin'),(3830,'Zodiac Sword Skin'),(3831,'Silly Scimitar Skin'),(3832,'Shark\'s Tooth Sword Skin'),(3835,'Zenith Ward Skin'),(3836,'Zenith Scroll Skin'),(3837,'Zenith Cesta Skin'),(3838,'Zenith Short Bow Skin'),(3839,'Zenith Recurve Bow Skin'),(3840,'Zenith Mace Skin'),(3841,'Zenith Avenger Skin'),(3842,'Zenith Wake Skin'),(3843,'Zenith Impaler Skin'),(3844,'Zenith Reaver Skin'),(3845,'Zenith Harbinger Skin'),(3846,'Zenith Trident Skin'),(3847,'Zenith Flame Skin'),(3848,'Zenith Pistol Skin'),(3849,'Zenith Rifle Skin'),(3850,'Zenith Kris Skin'),(3851,'Zenith Thunder Skin'),(3852,'Zenith Spire Skin'),(3853,'Zenith Blade Skin'),(3854,'Basic Longbow'),(3855,'Basic Shield'),(3856,'Basic Torch'),(3857,'Basic Trident'),(3858,'Basic Speargun'),(3859,'Basic Warhorn'),(3860,'Basic Short Bow'),(3861,'Basic Mace'),(3862,'Basic Harpoon'),(3863,'Basic Focus'),(3864,'Basic Pistol'),(3865,'Basic Axe'),(3866,'Basic Scepter'),(3867,'Basic Rifle'),(3868,'Basic Greatsword'),(3869,'Basic Hammer'),(3870,'Basic Spear'),(3871,'Basic Dagger'),(3872,'Basic Staff'),(3873,'Basic Sword'),(4664,'Frenzy (weapon)'),(4690,'Annelid Rifle Skin'),(4694,'Grinning Gourd Rifle Skin'),(4787,'Knowledge is Power'),(4833,'Illusion (spear)'),(5243,'Sovereign Firearm Skin'),(5244,'Sovereign Beacon Skin'),(5245,'Sovereign Eviscerator Skin'),(5246,'Sovereign Punisher Skin'),(5248,'Sovereign Crescent Skin'),(5249,'King Toad\'s Torch Skin'),(5250,'Storm Wizard\'s Torch Skin'),(5251,'Super Torch Skin'),(5252,'Sovereign Protector Skin'),(5253,'Sovereign Herald Skin'),(5255,'King Toad\'s Short Bow Skin'),(5256,'Storm Wizard\'s Short Bow Skin'),(5258,'Super Short Bow Skin'),(5259,'King Toad\'s Warhorn Skin'),(5260,'Storm Wizard\'s Warhorn Skin'),(5261,'Super Warhorn Skin'),(5264,'Sovereign Warhammer Skin'),(5265,'Sovereign Artifact Skin'),(5266,'Slingshot Skin'),(5267,'Sovereign Greatbow Skin'),(5270,'King Toad\'s Focus Skin'),(5271,'King Toad\'s Pistol Skin'),(5272,'Storm Wizard\'s Focus Skin'),(5273,'Storm Wizard\'s Pistol Skin'),(5274,'Super Focus Skin'),(5277,'King Toad\'s Longbow Skin'),(5278,'Sovereign Spatha Skin'),(5279,'Super Pistol Skin'),(5280,'Sovereign Scepter Skin'),(5281,'King Toad\'s Axe Skin'),(5282,'Storm Wizard\'s Longbow Skin'),(5284,'Super Longbow Skin'),(5285,'Storm Wizard\'s Axe Skin'),(5287,'King Toad\'s Mace Skin'),(5288,'Super Axe Skin'),(5289,'Storm Wizard\'s Mace Skin'),(5290,'Sovereign Arquebus Skin'),(5292,'Super Mace Skin'),(5293,'King Toad\'s Scepter Skin'),(5294,'Sovereign Crusader Skin'),(5295,'Bell Focus Skin'),(5296,'Storm Wizard\'s Scepter Skin'),(5298,'King Toad\'s Rifle Skin'),(5299,'Super Scepter Skin'),(5300,'Storm Wizard\'s Rifle Skin'),(5301,'Super Rifle Skin'),(5305,'King Toad\'s Greatsword Skin'),(5306,'King Toad\'s Shield Skin'),(5307,'Storm Wizard\'s Greatsword Skin'),(5308,'Super Greatsword Skin'),(5309,'Storm Wizard\'s Shield Skin'),(5310,'Sovereign Cinquedea Skin'),(5311,'Super Shield Skin'),(5312,'Princess Wand Skin'),(5316,'Pop Gun Skin'),(5318,'King Toad\'s Dagger Skin'),(5320,'King Toad\'s Hammer Skin'),(5321,'Storm Wizard\'s Hammer Skin'),(5323,'Storm Wizard\'s Dagger Skin'),(5324,'Super Dagger Skin'),(5325,'Super Hammer Skin'),(5326,'Sovereign Pillar Skin'),(5327,'Candy-Cane Hammer Skin'),(5331,'King Toad\'s Staff Skin'),(5332,'Storm Wizard\'s Staff Skin'),(5334,'Super Staff Skin'),(5341,'King Toad\'s Sword Skin'),(5342,'Storm Wizard\'s Sword Skin'),(5343,'Wooden Dagger Skin'),(5344,'Super Sword Skin'),(5345,'Toy Staff Skin'),(5347,'Toy Sword Skin'),(5458,'Phoenix Axe Skin'),(5459,'Phoenix Dagger Skin'),(5460,'Phoenix Focus Skin'),(5461,'Phoenix Greatsword Skin'),(5462,'Phoenix Hammer Skin'),(5463,'Phoenix Longbow Skin'),(5464,'Phoenix Mace Skin'),(5465,'Phoenix Pistol Skin'),(5466,'Phoenix Rifle Skin'),(5467,'Phoenix Scepter Skin'),(5468,'Phoenix Shield Skin'),(5469,'Phoenix Short Bow Skin'),(5470,'Phoenix Staff Skin'),(5471,'Phoenix Sword Skin'),(5472,'Phoenix Torch Skin'),(5473,'Phoenix Warhorn Skin'),(5480,'Adventurer\'s Scarf (medium)'),(5481,'Adventurer\'s Spectacles (heavy)'),(5482,'Adventurer\'s Scarf (heavy)'),(5483,'Adventurer\'s Mantle (medium)'),(5484,'Adventurer\'s Scarf (light)'),(5485,'Adventurer\'s Spectacles (light)'),(5486,'Adventurer\'s Mantle (light)'),(5487,'Adventurer\'s Mantle (heavy)'),(5488,'Adventurer\'s Spectacles (medium)'),(5500,'Ley Line Staff Skin'),(5501,'Ley Line Mace Skin'),(5502,'Ley Line Short Bow Skin'),(5503,'Ley Line Hammer Skin'),(5504,'Ley Line Rifle Skin'),(5505,'Ley Line Sword Skin'),(5506,'Ley Line Warhorn Skin'),(5507,'Ley Line Dagger Skin'),(5508,'Ley Line Torch Skin'),(5509,'Ley Line Greatsword Skin'),(5510,'Ley Line Longbow Skin'),(5511,'Ley Line Shield Skin'),(5512,'Ley Line Scepter Skin'),(5513,'Ley Line Axe Skin'),(5514,'Ley Line Focus Skin'),(5515,'Ley Line Pistol Skin'),(5547,'Chaos Staff Skin'),(5550,'Chaos Longbow Skin'),(5551,'Chaos Torch Skin'),(5552,'Chaos Spear Skin'),(5555,'Chaos Hammer Skin'),(5557,'Chaos Sword Skin'),(5559,'Chaos Scepter Skin'),(5560,'Chaos Trident Skin'),(5561,'Chaos Shield Skin'),(5564,'Chaos Harpoon Gun Skin'),(5565,'Chaos Mace Skin'),(5568,'Chaos Dagger Skin'),(5569,'Chaos Short Bow Skin'),(5571,'Chaos Focus Skin'),(5573,'Chaos Pistol Skin'),(5575,'Chaos Warhorn Skin'),(5576,'Chaos Rifle Skin'),(5580,'Chaos Axe Skin'),(5584,'Chaos Greatsword Skin'),(5586,'Belinda\'s Greatsword Skin'),(5587,'Radiant Leggings Skin'),(5588,'Radiant Chestpiece Skin'),(5589,'Radiant Chestpiece Skin'),(5590,'Radiant Leggings Skin'),(5591,'Radiant Leggings Skin'),(5592,'Radiant Chestpiece Skin'),(5593,'Hellfire Chestpiece Skin'),(5594,'Hellfire Leggings Skin'),(5595,'Hellfire Chestpiece Skin'),(5596,'Hellfire Leggings Skin'),(5597,'Hellfire Chestpiece Skin'),(5598,'Hellfire Leggings Skin'),(5660,'Pinnacle Rifle Skin'),(5661,'Pinnacle Kris Skin'),(5662,'Pinnacle Cesta Skin'),(5663,'Pinnacle Harbinger Skin'),(5664,'Pinnacle Trident Skin'),(5665,'Pinnacle Flame Skin'),(5666,'Pinnacle Blade Skin'),(5667,'Pinnacle Spire Skin'),(5668,'Pinnacle Wake Skin'),(5669,'Pinnacle Short Bow Skin'),(5670,'Pinnacle Ward Skin'),(5671,'Pinnacle Scroll Skin'),(5672,'Pinnacle Reaver Skin'),(5673,'Pinnacle Pistol Skin'),(5674,'Pinnacle Mace Skin'),(5675,'Pinnacle Recurve Bow Skin'),(5676,'Pinnacle Impaler Skin'),(5677,'Pinnacle Thunder Skin'),(5678,'Pinnacle Avenger Skin');
/*!40000 ALTER TABLE `skin_wiki_page_tb` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-10-11 17:57:55

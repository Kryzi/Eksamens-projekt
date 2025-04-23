-- phpMyAdmin SQL Dump
-- version 4.6.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 23, 2025 at 07:42 AM
-- Server version: 5.7.14
-- PHP Version: 7.0.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mountain_top`
--
CREATE DATABASE IF NOT EXISTS `mountain_top` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `mountain_top`;

-- --------------------------------------------------------

--
-- Table structure for table `nonces`
--

CREATE TABLE `nonces` (
  `ip_address` varchar(255) NOT NULL,
  `nonce` char(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `nonces`
--

INSERT INTO `nonces` (`ip_address`, `nonce`) VALUES
('::1', 'ad19e386aece31afc6d0e6edf925f3521c311595b461552eb6313f40b97c823e');

-- --------------------------------------------------------

--
-- Table structure for table `players_secure`
--

CREATE TABLE `players_secure` (
  `id` int(11) NOT NULL,
  `player_name` varchar(40) CHARACTER SET utf8mb4 NOT NULL,
  `score` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `players_secure`
--

INSERT INTO `players_secure` (`id`, `player_name`, `score`) VALUES
(110, 'BowerRun', 466),
(111, 'GigagoatedPlayer', 500),
(112, 'PHPRowDatabaseUser', 631),
(113, 'player181', 234),
(114, 'player182', 235),
(115, 'GamifiedTroy', 451),
(116, 'player182', 723);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `nonces`
--
ALTER TABLE `nonces`
  ADD UNIQUE KEY `ip_address` (`ip_address`);

--
-- Indexes for table `players_secure`
--
ALTER TABLE `players_secure`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `players_secure`
--
ALTER TABLE `players_secure`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

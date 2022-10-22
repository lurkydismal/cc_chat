-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Sep 07, 2022 at 07:38 AM
-- Server version: 10.6.7-MariaDB-2ubuntu1.1
-- PHP Version: 8.1.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cc_chat`
--

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` bigint(255) NOT NULL,
  `peer` int(100) NOT NULL,
  `text` varchar(2000) NOT NULL,
  `timestamp` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `peer`, `text`, `timestamp`) VALUES
(1, 0, 'ttt', '2022-09-03'),
(2, 0, 'ttt', '2022-09-03'),
(3, 0, 'ttt', '2022-09-03'),
(4, 0, 'ttt', '2022-09-03'),
(5, 0, 'ttt', '2022-09-03'),
(6, 0, 'ttt', '2022-09-03'),
(7, 0, 'ttt', '2022-09-03'),
(8, 0, 'ttt', '2022-09-03'),
(9, 0, 'ttt', '2022-09-03'),
(10, 0, 'ttt', '2022-09-03'),
(11, 0, 'ttt', '2022-09-03'),
(12, 0, 'ttt', '2022-09-03'),
(13, 0, 'ttt', '2022-09-03'),
(14, 0, 'ttt', '2022-09-03'),
(15, 0, 'ttt', '2022-09-03'),
(16, 0, 'ttt', '2022-09-03'),
(17, 0, 'ttt', '2022-09-03'),
(18, 0, 'ttt', '2022-09-03'),
(19, 0, 'ttt', '2022-09-03'),
(20, 0, 'ttt', '2022-09-03'),
(21, 0, 'ttt', '2022-09-04'),
(22, 0, 'ttt', '2022-09-04'),
(23, 0, 'ttt', '2022-09-04'),
(24, 0, 'ttt', '2022-09-06'),
(25, 55, 'uuuu', '2022-09-06');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(100) NOT NULL,
  `name` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(128) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`) VALUES
(0, 'test', 'test@test', 'test'),
(55, 't', 't', 't');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `name` (`name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

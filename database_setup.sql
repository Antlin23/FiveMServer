-- FiveM Server Database Setup Script
-- Run this script in your MySQL database to create the necessary tables

-- Use the fivem1 database
USE fivem1;

-- Create users table for DJ system and general user management
CREATE TABLE IF NOT EXISTS `users` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(50) NOT NULL,
    `name` varchar(100) DEFAULT NULL,
    `role` varchar(20) DEFAULT 'user',
    `money` int(11) DEFAULT 0,
    `bank` int(11) DEFAULT 0,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    `last_login` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create DJ sessions table to track active music sessions
CREATE TABLE IF NOT EXISTS `dj_sessions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `booth_name` varchar(100) NOT NULL,
    `track_name` varchar(100) NOT NULL,
    `started_by` varchar(50) NOT NULL,
    `start_time` timestamp DEFAULT CURRENT_TIMESTAMP,
    `end_time` timestamp NULL DEFAULT NULL,
    `duration` int(11) DEFAULT NULL,
    `active` tinyint(1) DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create DJ booth locations table for dynamic booth management
CREATE TABLE IF NOT EXISTS `dj_booths` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(100) NOT NULL,
    `x` float NOT NULL,
    `y` float NOT NULL,
    `z` float NOT NULL,
    `heading` float DEFAULT 0,
    `radius` float DEFAULT 50.0,
    `active` tinyint(1) DEFAULT 1,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create music tracks table for dynamic track management
CREATE TABLE IF NOT EXISTS `music_tracks` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(100) NOT NULL,
    `file` varchar(255) NOT NULL,
    `duration` int(11) DEFAULT 180,
    `category` varchar(50) DEFAULT 'general',
    `active` tinyint(1) DEFAULT 1,
    `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default DJ booths (you can modify these coordinates)
INSERT INTO `dj_booths` (`name`, `x`, `y`, `z`, `heading`, `radius`) VALUES
('Bahama Mamas', -1382.4, -615.6, 31, 35.0, 50.0),
('Vanilla Unicorn', 127.5, -1284.5, 29.3, 120.0, 40.0),
('Galaxy Nightclub', 126.5, -1284.5, 29.3, 120.0, 45.0)
ON DUPLICATE KEY UPDATE `active` = 1;

-- Insert default music tracks (you'll need to add the actual .ogg files)
INSERT INTO `music_tracks` (`name`, `file`, `duration`, `category`) VALUES
('Electronic Beat', 'electronic_beat.ogg', 180, 'electronic'),
('Hip Hop Mix', 'hiphop_mix.ogg', 240, 'hiphop'),
('Rock Anthem', 'rock_anthem.ogg', 200, 'rock'),
('Chill Vibes', 'chill_vibes.ogg', 300, 'chill')
ON DUPLICATE KEY UPDATE `active` = 1;

-- Insert a default admin user (replace with your actual identifier)
-- You can find your identifier by running 'status' command in server console
INSERT INTO `users` (`identifier`, `name`, `role`, `money`, `bank`) VALUES
('fivem:6570909', 'Antlin23', 'admin', 10000, 50000)
ON DUPLICATE KEY UPDATE `role` = 'admin';

-- Create indexes for better performance
CREATE INDEX idx_users_identifier ON users(identifier);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_dj_sessions_booth ON dj_sessions(booth_name);
CREATE INDEX idx_dj_sessions_active ON dj_sessions(active);
CREATE INDEX idx_music_tracks_category ON music_tracks(category);
CREATE INDEX idx_music_tracks_active ON music_tracks(active);

-- Show created tables
SHOW TABLES;

-- Show sample data
SELECT 'Users Table:' as info;
SELECT identifier, name, role FROM users LIMIT 5;

SELECT 'DJ Booths:' as info;
SELECT name, x, y, z, radius FROM dj_booths WHERE active = 1;

SELECT 'Music Tracks:' as info;
SELECT name, file, duration, category FROM music_tracks WHERE active = 1; 
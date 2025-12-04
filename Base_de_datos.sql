-- Tabla de bandas
CREATE TABLE IF NOT EXISTS `pavel_bands` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(50) NOT NULL,
    `leader` varchar(50) NOT NULL,
    `xp` int(11) DEFAULT 0,
    `money` int(11) DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de miembros
CREATE TABLE IF NOT EXISTS `pavel_band_members` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `band_id` int(11) NOT NULL,
    `identifier` varchar(50) NOT NULL,
    PRIMARY KEY (`id`),
    KEY `band_id` (`band_id`),
    KEY `identifier` (`identifier`),
    CONSTRAINT `pavel_band_members_ibfk_1` FOREIGN KEY (`band_id`) REFERENCES `pavel_bands` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de objetos del armario
CREATE TABLE IF NOT EXISTS `pavel_wardrobe` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `band_id` int(11) NOT NULL,
    `identifier` varchar(50) NOT NULL,
    `items` longtext DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `band_id` (`band_id`),
    CONSTRAINT `pavel_wardrobe_ibfk_1` FOREIGN KEY (`band_id`) REFERENCES `pavel_bands` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de vehículos del garaje
CREATE TABLE IF NOT EXISTS `pavel_garage` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `band_id` int(11) NOT NULL,
    `plate` varchar(20) NOT NULL,
    `vehicle` longtext DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `band_id` (`band_id`),
    CONSTRAINT `pavel_garage_ibfk_1` FOREIGN KEY (`band_id`) REFERENCES `pavel_bands` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
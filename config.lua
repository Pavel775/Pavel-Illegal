Config = {}

-- Permisos para crear bandas
Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true
}

-- Actividades ilegales
Config.Activities = {
    ['robbery'] = {
        label = "Robo",
        minPolice = 2,
        reward = { min = 5000, max = 15000 },
        xp = 50,
        cooldown = 3600
    },
    ['drugs'] = {
        label = "Tráfico de Drogas",
        minPolice = 1,
        reward = { min = 3000, max = 10000 },
        xp = 30,
        cooldown = 1800
    }
}

-- Niveles de banda
Config.BandLevels = {
    { level = 1, xpRequired = 0, maxMembers = 5, rewardBonus = 1.0 },
    { level = 2, xpRequired = 200, maxMembers = 10, rewardBonus = 1.2 },
    { level = 3, xpRequired = 500, maxMembers = 15, rewardBonus = 1.5 },
    { level = 4, xpRequired = 1000, maxMembers = 20, rewardBonus = 1.8 },
    { level = 5, xpRequired = 2000, maxMembers = 25, rewardBonus = 2.0 }
}

-- Posiciones de los NPCs
Config.NPCPositions = {
    { coords = vector3(425.0, -977.0, 30.0), heading = 180.0, model = 'g_m_m_chigoon_01', type = 'wardrobe' },
    { coords = vector3(427.0, -975.0, 30.0), heading = 180.0, model = 'g_m_m_chiboss_01', type = 'safe' },
    { coords = vector3(429.0, -973.0, 30.0), heading = 180.0, model = 'g_m_m_chemwork_01', type = 'garage' }
}

-- Framework (se detecta automáticamente)
Config.Framework = nil
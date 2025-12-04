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
        cooldown = 3600
    },
    ['drugs'] = {
        label = "Tráfico de Drogas",
        minPolice = 1,
        reward = { min = 3000, max = 10000 },
        cooldown = 1800
    }
}

-- Framework (se detecta automáticamente)
Config.Framework = nil -- No tocar, se asigna en el servidor
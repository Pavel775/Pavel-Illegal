local cooldowns = {}

-- Función para detectar el framework
local function DetectFramework()
    if GetResourceState('es_extended') == 'started' then
        Config.Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Config.Framework = 'qbcore'
        QBCore = exports['qb-core']:GetCoreObject()
    else
        print("^1[ERROR]^0 No se detectó ESX ni QBCore. El script no funcionará correctamente.")
    end
end

-- Función para notificaciones
local function Notify(src, message, type)
    if Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', src, message)
    elseif Config.Framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', src, message, type or 'success')
    end
end

-- Función para obtener el jugador
local function GetPlayer(src)
    if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(src)
    end
end

-- Función para obtener el identificador del jugador
local function GetIdentifier(player)
    if Config.Framework == 'esx' then
        return player.identifier
    elseif Config.Framework == 'qbcore' then
        return player.PlayerData.citizenid
    end
end

-- Función para obtener el nivel de la banda
local function GetBandLevel(xp)
    for i = #Config.BandLevels, 1, -1 do
        if xp >= Config.BandLevels[i].xpRequired then
            return Config.BandLevels[i]
        end
    end
    return Config.BandLevels[1]
end

-- Función para obtener el ID de una banda por nombre
local function GetBandId(bandName, cb)
    MySQL.Async.fetchScalar('SELECT id FROM pavel_bands WHERE name = ?', { bandName }, function(id)
        cb(id)
    end)
end

-- Función para crear una banda en la base de datos
RegisterNetEvent('pavel_ilegal:createBand')
AddEventHandler('pavel_ilegal:createBand', function(bandName, leader)
    local src = source
    local player = GetPlayer(src)

    if player then
        local isAdmin = false
        if Config.Framework == 'esx' then
            isAdmin = Config.AdminGroups[player.getGroup()]
        elseif Config.Framework == 'qbcore' then
            isAdmin = Config.AdminGroups[player.PlayerData.job.name]
        end

        if isAdmin then
            MySQL.Async.fetchScalar('SELECT COUNT(*) FROM pavel_bands WHERE name = ?', { bandName }, function(count)
                if count == 0 then
                    MySQL.Async.execute('INSERT INTO pavel_bands (name, leader, xp, money) VALUES (?, ?, 0, 0)', { bandName, leader }, function(rowsChanged)
                        if rowsChanged > 0 then
                            Notify(src, "Banda creada: " .. bandName, 'success')
                        else
                            Notify(src, "Error al crear la banda.", 'error')
                        end
                    end)
                else
                    Notify(src, "La banda ya existe.", 'error')
                end
            end)
        else
            Notify(src, "No tienes permisos para crear bandas.", 'error')
        end
    end
end)

-- Detectar framework al iniciar el script
DetectFramework()
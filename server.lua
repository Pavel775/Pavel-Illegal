local bands = {}
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

-- Función para notificaciones (compatible con ESX y QBCore)
local function Notify(src, message)
    if Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', src, message)
    elseif Config.Framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', src, message)
    end
end

-- Función para obtener el jugador (compatible con ESX y QBCore)
local function GetPlayer(src)
    if Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'qbcore' then
        return QBCore.Functions.GetPlayer(src)
    end
end

-- Evento para crear una banda
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
            if not bands[bandName] then
                bands[bandName] = {
                    name = bandName,
                    leader = leader,
                    members = {},
                    reputation = 0,
                    money = 0,
                    activities = {}
                }
                Notify(src, "Banda creada: " .. bandName)
            else
                Notify(src, "La banda ya existe.")
            end
        else
            Notify(src, "No tienes permisos.")
        end
    end
end)

-- Evento para añadir miembros
RegisterNetEvent('pavel_ilegal:addMember')
AddEventHandler('pavel_ilegal:addMember', function(bandName, member)
    local src = source
    if bands[bandName] then
        table.insert(bands[bandName].members, member)
        Notify(src, "Miembro añadido a " .. bandName)
    else
        Notify(src, "La banda no existe.")
    end
end)

-- Evento para iniciar una actividad ilegal
RegisterNetEvent('pavel_ilegal:startActivity')
AddEventHandler('pavel_ilegal:startActivity', function(activityType, bandName)
    local src = source
    local player = GetPlayer(src)

    if player and bands[bandName] then
        local band = bands[bandName]
        local isMember = false
        local identifier = player.identifier or player.PlayerData.citizenid

        for _, member in ipairs(band.members) do
            if member == identifier then
                isMember = true
                break
            end
        end

        if isMember or band.leader == identifier then
            if not cooldowns[bandName] or not cooldowns[bandName][activityType] or cooldowns[bandName][activityType] < os.time() then
                local cops = 0
                for _, p in ipairs(GetPlayers()) do
                    local targetPlayer = GetPlayer(tonumber(p))
                    if targetPlayer then
                        if Config.Framework == 'esx' and targetPlayer.job.name == 'police' then
                            cops = cops + 1
                        elseif Config.Framework == 'qbcore' and targetPlayer.PlayerData.job.name == 'police' then
                            cops = cops + 1
                        end
                    end
                end

                if cops >= Config.Activities[activityType].minPolice then
                    local reward = math.random(Config.Activities[activityType].reward.min, Config.Activities[activityType].reward.max)
                    band.money = band.money + reward
                    band.reputation = band.reputation + 1

                    cooldowns[bandName] = cooldowns[bandName] or {}
                    cooldowns[bandName][activityType] = os.time() + Config.Activities[activityType].cooldown

                    Notify(src, "Actividad completada. Recompensa: $" .. reward)
                else
                    Notify(src, "No hay suficientes policías en servicio.")
                end
            else
                Notify(src, "La actividad está en cooldown.")
            end
        else
            Notify(src, "No eres miembro de esta banda.")
        end
    else
        Notify(src, "La banda no existe.")
    end
end)

-- Detectar framework al iniciar el script
DetectFramework()
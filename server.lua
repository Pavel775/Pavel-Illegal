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

-- Función para notificaciones
local function Notify(src, message)
    if Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', src, message)
    elseif Config.Framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', src, message)
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

-- Función para obtener el nivel de la banda
local function GetBandLevel(band)
    for i = #Config.BandLevels, 1, -1 do
        if band.xp >= Config.BandLevels[i].xpRequired then
            return Config.BandLevels[i]
        end
    end
    return Config.BandLevels[1]
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
                    xp = 0,
                    money = 0,
                    level = 1,
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
        local band = bands[bandName]
        local currentLevel = GetBandLevel(band)
        if #band.members < currentLevel.maxMembers then
            table.insert(band.members, member)
            Notify(src, "Miembro añadido a " .. bandName)
        else
            Notify(src, "La banda ha alcanzado el límite de miembros para su nivel.")
        end
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
        local identifier = player.identifier or player.PlayerData.citizenid
        local isMember = false

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
                    local activity = Config.Activities[activityType]
                    local currentLevel = GetBandLevel(band)
                    local reward = math.floor(math.random(activity.reward.min, activity.reward.max) * currentLevel.rewardBonus)
                    local xp = activity.xp

                    band.money = band.money + reward
                    band.xp = band.xp + xp

                    cooldowns[bandName] = cooldowns[bandName] or {}
                    cooldowns[bandName][activityType] = os.time() + activity.cooldown

                    Notify(src, string.format("Actividad completada. Recompensa: $%s | XP: %s", reward, xp))
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

-- Evento para depositar dinero en la caja fuerte
RegisterNetEvent('pavel_ilegal:depositMoney')
AddEventHandler('pavel_ilegal:depositMoney', function(bandName, amount)
    local src = source
    local player = GetPlayer(src)

    if player and bands[bandName] then
        local band = bands[bandName]
        local identifier = player.identifier or player.PlayerData.citizenid
        local isMember = false

        for _, member in ipairs(band.members) do
            if member == identifier then
                isMember = true
                break
            end
        end

        if isMember or band.leader == identifier then
            if player.getMoney() >= amount then
                player.removeMoney(amount)
                band.money = band.money + amount
                Notify(src, "Depositaste $" .. amount .. " en la caja fuerte.")
            else
                Notify(src, "No tienes suficiente dinero.")
            end
        else
            Notify(src, "No eres miembro de esta banda.")
        end
    else
        Notify(src, "La banda no existe.")
    end
end)

-- Evento para retirar dinero de la caja fuerte
RegisterNetEvent('pavel_ilegal:withdrawMoney')
AddEventHandler('pavel_ilegal:withdrawMoney', function(bandName, amount)
    local src = source
    local player = GetPlayer(src)

    if player and bands[bandName] then
        local band = bands[bandName]
        local identifier = player.identifier or player.PlayerData.citizenid
        local isMember = false

        for _, member in ipairs(band.members) do
            if member == identifier then
                isMember = true
                break
            end
        end

        if isMember or band.leader == identifier then
            if band.money >= amount then
                band.money = band.money - amount
                player.addMoney(amount)
                Notify(src, "Retiraste $" .. amount .. " de la caja fuerte.")
            else
                Notify(src, "La banda no tiene suficiente dinero.")
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
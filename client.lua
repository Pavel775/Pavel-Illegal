local bandNPCs = {}

-- Asegúrate de que el menú esté oculto al inicio
CreateThread(function()
    Wait(1000)
    SendNUIMessage({ action = 'hideMenu' })
end)

-- Comando para abrir el menú
RegisterCommand('pavelilegal', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMenu',
        menuType = 'main'
    })
end)

-- Evento para cerrar el menú
RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Evento para crear una banda
RegisterNUICallback('createBand', function(data, cb)
    local bandName = data.bandName
    local leader = data.leader
    TriggerServerEvent('pavel_ilegal:createBand', bandName, leader)
    cb('ok')
end)

-- Función para crear NPCs
local function CreateNPCs()
    for _, npc in ipairs(Config.NPCPositions) do
        RequestModel(GetHashKey(npc.model))
        while not HasModelLoaded(GetHashKey(npc.model)) do
            Wait(1)
        end

        local ped = CreatePed(4, GetHashKey(npc.model), npc.coords, npc.heading, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        table.insert(bandNPCs, {
            ped = ped,
            type = npc.type,
            coords = npc.coords
        })
    end
end

-- Función para interactuar con NPCs
Citizen.CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, npc in ipairs(bandNPCs) do
            local distance = #(playerCoords - npc.coords)
            if distance < 2.0 then
                DrawText3D(npc.coords.x, npc.coords.y, npc.coords.z + 1.0, "[E] Interactuar")

                if IsControlJustPressed(0, 38) then
                    SetNuiFocus(true, true)
                    SendNUIMessage({
                        action = 'openNPCMenu',
                        npcType = npc.type
                    })
                end
            end
        end
    end
end)

-- Función para dibujar texto 3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Crear NPCs al iniciar el script
CreateThread(function()
    CreateNPCs()
end)
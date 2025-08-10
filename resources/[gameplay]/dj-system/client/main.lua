local PlayerData = {}
local currentBooth = nil
local isNearBooth = false
local musicPlaying = false

-- Initialize
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Check if player is near any DJ booth
        for i, booth in pairs(Config.DJBooths) do
            local distance = #(playerCoords - booth.coords)
            
            if distance <= 3.0 then
                if not isNearBooth then
                    isNearBooth = true
                    currentBooth = booth
                    TriggerEvent('dj:showHelpText', true)
                end
                break
            else
                if isNearBooth and currentBooth == booth then
                    isNearBooth = false
                    currentBooth = nil
                    TriggerEvent('dj:showHelpText', false)
                end
            end
        end
        
        Citizen.Wait(1000)
    end
end)

-- Key controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isNearBooth and currentBooth then
            -- Show help text
            DrawText3D(currentBooth.coords.x, currentBooth.coords.y, currentBooth.coords.z + 1.0, "Press ~y~E~w~ to open DJ menu")
            
            -- Handle key presses
            if IsControlJustPressed(0, Config.Controls.openMenu) then
                TriggerServerEvent('dj:checkPermission')
            end
            
            if IsControlJustPressed(0, Config.Controls.stopMusic) then
                TriggerServerEvent('dj:stopMusic', currentBooth.name)
            end
        end
    end
end)

-- Events
RegisterNetEvent('dj:permissionGranted')
AddEventHandler('dj:permissionGranted', function()
    OpenDJMenu()
end)

RegisterNetEvent('dj:permissionDenied')
AddEventHandler('dj:permissionDenied', function()
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"DJ System", Config.Messages.noPermission}
    })
end)

RegisterNetEvent('dj:musicStarted')
AddEventHandler('dj:musicStarted', function(boothName, trackName)
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"DJ System", string.format(Config.Messages.musicStarted, boothName)}
    })
    
    -- Start audio for all players in range
    TriggerServerEvent('dj:startAudio', currentBooth.name, trackName)
end)

RegisterNetEvent('dj:musicStopped')
AddEventHandler('dj:musicStopped', function(boothName)
    TriggerEvent('chat:addMessage', {
        color = {255, 165, 0},
        multiline = true,
        args = {"DJ System", string.format(Config.Messages.musicStopped, boothName)}
    })
    
    -- Stop audio for all players
    TriggerServerEvent('dj:stopAudio', currentBooth.name)
end)

RegisterNetEvent('dj:showHelpText')
AddEventHandler('dj:showHelpText', function(show)
    if show then
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 255},
            multiline = true,
            args = {"DJ System", "You're near a DJ booth! Press E to open the menu."}
        })
    end
end)

-- Functions
function OpenDJMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openMenu",
        tracks = Config.MusicTracks,
        boothName = currentBooth.name
    })
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- NUI Callbacks
RegisterNUICallback('playMusic', function(data, cb)
    TriggerServerEvent('dj:playMusic', currentBooth.name, data.track)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end) 

-- Add Bahama Club blip on map
Citizen.CreateThread(function()
    local bahamaCoords = vector3(-1393, -586.44, 30.22) -- Bahama Mamas location
    local blip = AddBlipForCoord(bahamaCoords.x, bahamaCoords.y, bahamaCoords.z)
    SetBlipSprite(blip, 93) -- Club icon
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 27) -- Purple
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Bahama Club")
    EndTextCommandSetBlipName(blip)
end)
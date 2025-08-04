local activeAudio = {}
local audioSources = {}

-- Initialize audio system
Citizen.CreateThread(function()
    for i, booth in pairs(Config.DJBooths) do
        -- Create blip for each DJ booth
        local blip = AddBlipForCoord(booth.coords.x, booth.coords.y, booth.coords.z)
        SetBlipSprite(blip, booth.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, booth.blip.scale)
        SetBlipColour(blip, booth.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(booth.blip.name)
        EndTextCommandSetBlipName(blip)
    end
end)

-- Handle audio playback using HTML5 audio
RegisterNetEvent('dj:playAudio')
AddEventHandler('dj:playAudio', function(boothName, trackName, boothCoords)
    local booth = GetBoothByName(boothName)
    if not booth then return end
    
    -- Stop any existing audio at this booth
    if activeAudio[boothName] then
        StopAudio(boothName)
    end
    
    -- Start new audio using HTML5
    SendNUIMessage({
        type = "playAudio",
        boothName = boothName,
        trackName = trackName,
        boothCoords = booth.coords,
        radius = booth.radius
    })
    
    activeAudio[boothName] = {
        trackName = trackName,
        booth = booth,
        startTime = GetGameTimer()
    }
    
    print("^2[DJ System]^7 Music started at " .. boothName .. " - " .. trackName)
end)

-- Handle audio stopping
RegisterNetEvent('dj:stopAudio')
AddEventHandler('dj:stopAudio', function(boothName)
    StopAudio(boothName)
    print("^3[DJ System]^7 Music stopped at " .. boothName)
end)

-- Stop audio function
function StopAudio(boothName)
    if activeAudio[boothName] then
        -- Stop HTML5 audio
        SendNUIMessage({
            type = "stopAudio",
            boothName = boothName
        })
        activeAudio[boothName] = nil
    end
end

-- Get booth by name
function GetBoothByName(name)
    for i, booth in pairs(Config.DJBooths) do
        if booth.name == name then
            return booth
        end
    end
    return nil
end

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for boothName, audio in pairs(activeAudio) do
            StopAudio(boothName)
        end
    end
end)

-- Audio distance checking and volume control
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for boothName, audio in pairs(activeAudio) do
            local booth = audio.booth
            local distance = #(playerCoords - booth.coords)
            
            -- Update volume based on distance
            if distance <= booth.radius then
                local volume = 1.0 - (distance / booth.radius)
                volume = math.max(0.1, volume) -- Minimum volume
                
                SendNUIMessage({
                    type = "updateVolume",
                    boothName = boothName,
                    volume = volume
                })
            else
                -- Player is too far, stop audio
                StopAudio(boothName)
            end
        end
    end
end)

-- Test audio function (for debugging)
RegisterCommand('testaudio', function(source, args)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    print("^3[DJ System]^7 Testing audio...")
    print("Player position: " .. playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z)
    
    -- Find nearest booth
    for i, booth in pairs(Config.DJBooths) do
        local distance = #(playerCoords - booth.coords)
        print("Distance to " .. booth.name .. ": " .. distance .. "m")
        
        if distance <= 10.0 then
            print("^2[DJ System]^7 Near " .. booth.name .. ", testing audio...")
            TriggerEvent('dj:playAudio', booth.name, 'electronic_beat.ogg', booth.coords)
            break
        end
    end
end, false) 
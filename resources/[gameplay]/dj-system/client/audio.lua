local activeAudio = {}
local audioSources = {}
local lastPlayerPosition = vector3(0, 0, 0)
local activeMusicSessions = {} -- Track active music sessions from server

-- Initialize audio system (removed blip creation)
Citizen.CreateThread(function()
    -- No blips needed - only entrance should have map blips
    print("^2[DJ System]^7 Audio system initialized (no map blips)")
end)

-- Player position tracking for 3D audio
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100) -- Update every 100ms for smooth 3D audio
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        -- Only send position if player has moved significantly
        if #(playerCoords - lastPlayerPosition) > 0.5 then
            lastPlayerPosition = playerCoords
            
            SendNUIMessage({
                type = "updatePlayerPosition",
                x = playerCoords.x,
                y = playerCoords.y,
                z = playerCoords.z
            })
        end
    end
end)

-- Handle audio playback using HTML5 audio
RegisterNetEvent('dj:playAudio')
AddEventHandler('dj:playAudio', function(boothName, trackName, boothCoords)
    local booth = GetBoothByName(boothName)
    if not booth then return end
    
    -- Store the music session
    activeMusicSessions[boothName] = {
        trackName = trackName,
        booth = booth,
        startTime = GetGameTimer()
    }
    
    -- Start audio if player is in range
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - booth.coords)
    
    if distance <= booth.radius then
        StartAudio(boothName, trackName, booth)
    end
    
    print("^2[DJ System]^7 3D Music started at " .. boothName .. " - " .. trackName)
end)

-- Handle audio stopping
RegisterNetEvent('dj:stopAudio')
AddEventHandler('dj:stopAudio', function(boothName)
    StopAudio(boothName)
    activeMusicSessions[boothName] = nil
    print("^3[DJ System]^7 3D Music stopped at " .. boothName)
end)

-- Start audio function
function StartAudio(boothName, trackName, booth)
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
    
    print("^2[DJ System]^7 Audio started for " .. boothName)
end

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
        
        -- Check active audio sessions
        for boothName, audio in pairs(activeAudio) do
            local booth = audio.booth
            local distance = #(playerCoords - booth.coords)
            
            if distance > booth.radius then
                -- Player is too far, stop audio but keep session active
                StopAudio(boothName)
                print("^3[DJ System]^7 Audio stopped (too far) for " .. boothName)
            end
        end
        
        -- Check if player re-entered any active music session areas
        for boothName, session in pairs(activeMusicSessions) do
            local booth = session.booth
            local distance = #(playerCoords - booth.coords)
            
            if distance <= booth.radius and not activeAudio[boothName] then
                -- Player re-entered area, restart audio
                StartAudio(boothName, session.trackName, booth)
                print("^2[DJ System]^7 Audio restarted for " .. boothName)
            end
        end
    end
end)

-- Command to display current position
RegisterCommand('getpos', function(source, args)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    print("^3[DJ System]^7 Current Position:")
    print("^6X:^7 " .. playerCoords.x)
    print("^6Y:^7 " .. playerCoords.y)
    print("^6Z:^7 " .. playerCoords.z)
    print("^6Heading:^7 " .. playerHeading)
    print("^6Vector3:^7 vector3(" .. playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z .. ")")
    print("^6For config:^7 coords = vector3(" .. playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z .. "), heading = " .. playerHeading .. ".0")
end, false)

-- Command to display position continuously
RegisterCommand('showpos', function(source, args)
    local showPosition = true
    
    Citizen.CreateThread(function()
        while showPosition do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            
            -- Display position on screen
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 215)
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(string.format("Position: X: %.2f, Y: %.2f, Z: %.2f, H: %.2f", 
                playerCoords.x, playerCoords.y, playerCoords.z, playerHeading))
            DrawText(0.5, 0.1)
            
            -- Display vector3 format
            SetTextScale(0.3, 0.3)
            AddTextComponentString(string.format("vector3(%.2f, %.2f, %.2f)", 
                playerCoords.x, playerCoords.y, playerCoords.z))
            DrawText(0.5, 0.15)
            
            Citizen.Wait(0)
        end
    end)
    
    -- Stop after 30 seconds or when player presses a key
    Citizen.SetTimeout(30000, function()
        showPosition = false
        print("^3[DJ System]^7 Position display stopped. Use /showpos again to restart.")
    end)
    
    print("^3[DJ System]^7 Position display started. Press any key or wait 30 seconds to stop.")
end, false)

-- Test 3D audio function (for debugging)
RegisterCommand('test3daudio', function(source, args)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    print("^3[DJ System]^7 Testing 3D audio...")
    print("Player position: " .. playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z)
    
    -- Find nearest booth
    for i, booth in pairs(Config.DJBooths) do
        local distance = #(playerCoords - booth.coords)
        print("Distance to " .. booth.name .. ": " .. distance .. "m")
        
        if distance <= 10.0 then
            print("^2[DJ System]^7 Near " .. booth.name .. ", testing 3D audio...")
            TriggerEvent('dj:playAudio', booth.name, 'electronic_beat.ogg', booth.coords)
            break
        end
    end
end, false)

-- Command to test stereo panning
RegisterCommand('testpan', function(source, args)
    print("^3[DJ System]^7 Testing stereo panning...")
    
    SendNUIMessage({
        type = "testPanning"
    })
end, false)

-- Debug command to show active sessions
RegisterCommand('djsessions', function(source, args)
    print("^3[DJ System]^7 Active Music Sessions:")
    for boothName, session in pairs(activeMusicSessions) do
        print("^6" .. boothName .. "^7: " .. session.trackName)
    end
    
    print("^3[DJ System]^7 Active Audio:")
    for boothName, audio in pairs(activeAudio) do
        print("^6" .. boothName .. "^7: " .. audio.trackName)
    end
end, false) 
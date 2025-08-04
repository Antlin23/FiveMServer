local activeMusic = {}
local staffPlayers = {}

-- Initialize
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print("^2[DJ System]^7 Resource started successfully")
        LoadStaffPlayers()
    end
end)

-- Load staff players from database
function LoadStaffPlayers()
    MySQL.Async.fetchAll("SELECT identifier, role FROM users WHERE role IN ('admin', 'moderator', 'dj')", {}, function(result)
        if result then
            for i, row in ipairs(result) do
                staffPlayers[row.identifier] = row.role
            end
            print("^2[DJ System]^7 Loaded " .. #result .. " staff members")
        end
    end)
end

-- Check player permission
RegisterNetEvent('dj:checkPermission')
AddEventHandler('dj:checkPermission', function()
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    if IsPlayerStaff(source, identifier) then
        TriggerClientEvent('dj:permissionGranted', source)
    else
        TriggerClientEvent('dj:permissionDenied', source)
    end
end)

-- Play music
RegisterNetEvent('dj:playMusic')
AddEventHandler('dj:playMusic', function(boothName, trackName)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    if not IsPlayerStaff(source, identifier) then
        TriggerClientEvent('dj:permissionDenied', source)
        return
    end
    
    -- Check if music is already playing at this booth
    if activeMusic[boothName] then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 165, 0},
            multiline = true,
            args = {"DJ System", Config.Messages.alreadyPlaying}
        })
        return
    end
    
    -- Find the track
    local track = nil
    for i, t in pairs(Config.MusicTracks) do
        if t.name == trackName then
            track = t
            break
        end
    end
    
    if not track then
        TriggerClientEvent('chat:addMessage', source, {
            color = {255, 0, 0},
            multiline = true,
            args = {"DJ System", "Invalid track selected."}
        })
        return
    end
    
    -- Start music
    activeMusic[boothName] = {
        track = track,
        startedBy = GetPlayerName(source),
        startTime = os.time()
    }
    
    -- Notify all players in range
    local booth = GetBoothByName(boothName)
    if booth then
        local players = GetPlayers()
        for i, playerId in ipairs(players) do
            local playerPed = GetPlayerPed(playerId)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - booth.coords)
            
            if distance <= booth.radius then
                TriggerClientEvent('dj:playAudio', playerId, boothName, track.file, booth.coords)
            end
        end
        
        -- Notify DJ
        TriggerClientEvent('dj:musicStarted', source, boothName, trackName)
        
        -- Auto-stop after track duration
        Citizen.SetTimeout(track.duration * 1000, function()
            if activeMusic[boothName] then
                TriggerEvent('dj:stopMusic', boothName)
            end
        end)
    end
end)

-- Stop music
RegisterNetEvent('dj:stopMusic')
AddEventHandler('dj:stopMusic', function(boothName)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    if not IsPlayerStaff(source, identifier) then
        TriggerClientEvent('dj:permissionDenied', source)
        return
    end
    
    if activeMusic[boothName] then
        activeMusic[boothName] = nil
        
        -- Stop audio for all players
        local players = GetPlayers()
        for i, playerId in ipairs(players) do
            TriggerClientEvent('dj:stopAudio', playerId, boothName)
        end
        
        -- Notify DJ
        TriggerClientEvent('dj:musicStopped', source, boothName)
    end
end)

-- Check if player is staff
function IsPlayerStaff(source, identifier)
    -- Check if player has admin permissions (using FiveM's built-in system)
    if IsPlayerAceAllowed(source, "command") then
        return true
    end
    
    -- Check database roles
    if staffPlayers[identifier] then
        for i, role in pairs(Config.StaffRoles) do
            if staffPlayers[identifier] == role then
                return true
            end
        end
    end
    
    return false
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

-- Player joined event
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    -- Load player's staff status
    MySQL.Async.fetchScalar("SELECT role FROM users WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(role)
        if role then
            staffPlayers[identifier] = role
        end
    end)
end)

-- Player dropped event
AddEventHandler('playerDropped', function(reason)
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)
    
    if staffPlayers[identifier] then
        staffPlayers[identifier] = nil
    end
end)

-- Command to reload staff list
RegisterCommand('reloaddjstaff', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command") then
        LoadStaffPlayers()
        if source ~= 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                multiline = true,
                args = {"DJ System", "Staff list reloaded successfully."}
            })
        end
    end
end, false)

-- Command to list active music
RegisterCommand('djstatus', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, "command") then
        local status = "Active DJ Sessions:\n"
        local count = 0
        
        for boothName, music in pairs(activeMusic) do
            count = count + 1
            local elapsed = os.time() - music.startTime
            status = status .. string.format("- %s: %s (Started by: %s, Elapsed: %d seconds)\n", 
                boothName, music.track.name, music.startedBy, elapsed)
        end
        
        if count == 0 then
            status = "No active DJ sessions."
        end
        
        if source == 0 then
            print(status)
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                multiline = true,
                args = {"DJ System", status}
            })
        end
    end
end, false) 
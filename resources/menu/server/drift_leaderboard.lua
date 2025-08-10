local driftLeaderboard = {}

-- Load leaderboard from DB on resource start
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.Async.fetchAll('SELECT * FROM drift_leaderboard ORDER BY score DESC LIMIT 20', {}, function(results)
            driftLeaderboard = {}
            for _, row in ipairs(results) do
                driftLeaderboard[row.identifier] = { name = row.player_name, score = row.score }
            end
        end)
    end
end)

-- Save/update a player's score
RegisterNetEvent('drift:saveScore')
AddEventHandler('drift:saveScore', function(identifier, playerName, score)
    MySQL.Async.execute(
        'INSERT INTO drift_leaderboard (identifier, player_name, score) VALUES (@identifier, @player_name, @score) ON DUPLICATE KEY UPDATE score = GREATEST(score, @score), player_name = @player_name',
        {
            ['@identifier'] = identifier,
            ['@player_name'] = playerName,
            ['@score'] = score
        },
        function()
            -- Reload leaderboard from DB
            MySQL.Async.fetchAll('SELECT * FROM drift_leaderboard ORDER BY score DESC LIMIT 20', {}, function(results)
                driftLeaderboard = {}
                for _, row in ipairs(results) do
                    driftLeaderboard[row.identifier] = { name = row.player_name, score = row.score }
                end
            end)
        end
    )
end)

RegisterNetEvent('drift:getLeaderboard')
AddEventHandler('drift:getLeaderboard', function()
    local src = source
    local sorted = {}
    for _, data in pairs(driftLeaderboard) do
        table.insert(sorted, data)
    end
    table.sort(sorted, function(a, b) return a.score > b.score end)
    TriggerClientEvent('drift:sendLeaderboard', src, sorted)
end)


local playerCash = {}

-- Load cash from DB when player joins
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    MySQL.Async.fetchAll('SELECT cash FROM player_cash WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(results)
        if results[1] then
            playerCash[src] = results[1].cash
        else
            playerCash[src] = 0
            -- Insert new player into DB
            MySQL.Async.execute('INSERT INTO player_cash (identifier, player_name, cash) VALUES (@identifier, @player_name, 0)', {
                ['@identifier'] = identifier,
                ['@player_name'] = name
            })
        end
    end)
end)

RegisterNetEvent('drift:addCash')
AddEventHandler('drift:addCash', function(amount)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    if not playerCash[src] then playerCash[src] = 0 end
    playerCash[src] = playerCash[src] + amount
    -- Update DB
    MySQL.Async.execute('UPDATE player_cash SET cash = @cash WHERE identifier = @identifier', {
        ['@cash'] = playerCash[src],
        ['@identifier'] = identifier
    })
    TriggerClientEvent('drift:cashUpdated', src, playerCash[src])
end)

RegisterNetEvent('drift:payForDriftTune')
AddEventHandler('drift:payForDriftTune', function(cost)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    if not playerCash[src] then playerCash[src] = 0 end
    playerCash[src] = playerCash[src] - cost
    if playerCash[src] < 0 then playerCash[src] = 0 end
    MySQL.Async.execute('UPDATE player_cash SET cash = @cash WHERE identifier = @identifier', {
        ['@cash'] = playerCash[src],
        ['@identifier'] = identifier
    })
    TriggerClientEvent('drift:cashUpdated', src, playerCash[src])
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    playerCash[src] = nil -- Remove cash data when player leaves
end)

RegisterCommand('bal', function(source, args, rawCommand)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    MySQL.Async.fetchAll('SELECT cash FROM player_cash WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(results)
        local cash = 0
        if results[1] then cash = results[1].cash end
        TriggerClientEvent('drift:cashUpdated', src, cash)
    end)
end, false)
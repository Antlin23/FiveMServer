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

-- Send leaderboard to client
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
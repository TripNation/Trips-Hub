--[[
    Trips Hub - Main Router
    Automatically detects the current game by PlaceId or GameId
    and loads the corresponding script module.
--]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Configuration
local Config = {
    HubName = "Trips Hub",
    Version = "1.0.0",
    -- Replace with your GitHub username and repository name once published
    BaseUrl = "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/TripsHub/main/games/",
    DebugMode = true,
}

-- Notification helper
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or Config.HubName,
            Text = text or "",
            Duration = duration or 5,
        })
    end)
end

-- Supported Games Table
-- Format: [PlaceId] = "filename.lua"
local SupportedGames = {
    -- Example entries (replace with your games):
    -- [8737899170] = "pet_simulator.lua",
    -- [155615604]  = "prison_life.lua",
}

-- Supported Universes (useful for games with multiple sub-places/lobbies)
-- Format: [GameId] = "filename.lua"
local SupportedUniverses = {
    -- [12345678] = "game_universe.lua",
}

-- Detection Logic
local currentPlaceId = game.PlaceId
local currentGameId = game.GameId

if Config.DebugMode then
    print(string.format("[%s] Initializing... PlaceId: %d | GameId: %d", Config.HubName, currentPlaceId, currentGameId))
end

-- Determine script to execute
local targetScript = SupportedGames[currentPlaceId] or SupportedUniverses[currentGameId]

if targetScript then
    notify(Config.HubName, "Game recognized! Loading script...", 3)
    local scriptUrl = Config.BaseUrl .. targetScript
    
    local success, result = pcall(function()
        return game:HttpGet(scriptUrl)
    end)
    
    if success and result and #result > 0 then
        local execSuccess, execErr = pcall(function()
            loadstring(result)()
        end)
        if not execSuccess then
            warn(string.format("[%s] Failed to execute %s: %s", Config.HubName, targetScript, tostring(execErr)))
            notify(Config.HubName, "Execution error in game script!", 5)
        end
    else
        warn(string.format("[%s] Failed to fetch script from: %s", Config.HubName, scriptUrl))
        notify(Config.HubName, "Failed to download game script.", 5)
    end
else
    -- Fallback: Load universal script for unsupported games
    notify(Config.HubName, "Game not specifically mapped. Loading Universal Hub...", 4)
    local universalUrl = Config.BaseUrl .. "universal.lua"
    
    local success, result = pcall(function()
        return game:HttpGet(universalUrl)
    end)
    
    if success and result and #result > 0 then
        pcall(function()
            loadstring(result)()
        end)
    else
        warn(string.format("[%s] Could not load universal script from: %s", Config.HubName, universalUrl))
        notify(Config.HubName, "Failed to load Universal script.", 5)
    end
end

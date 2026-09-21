--[[
    Trips Hub - Universal Module
    Loaded when a game is not specifically mapped.
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Trips Hub | Universal",
    Icon = 0,
    LoadingTitle = "Trips Hub",
    LoadingSubtitle = "by TripNation",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TripsHub",
        FileName = "UniversalConfig"
    },
    KeySystem = false,
})

-- Player Tab
local PlayerTab = Window:CreateTab("Player", 4483362458)

local WalkspeedSlider = PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid").UseJumpPower = true
            character:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
    end,
})

-- Teleport / Server Tab
local ServerTab = Window:CreateTab("Server", 4483362458)

ServerTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            game.Players.LocalPlayer
        )
    end,
})

ServerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and servers and servers.data then
            for _, s in ipairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceId, s.id, game.Players.LocalPlayer)
                    break
                end
            end
        end
    end,
})

Rayfield:Notify({
    Title = "Trips Hub Loaded",
    Content = "Universal features are ready!",
    Duration = 5,
    Image = 4483362458,
})

--[[
    Trips Hub - Official Loader
    Run this script in your Roblox executor.
--]]

local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TripNation/Trips-Hub/main/main.lua"))()
end)

if not success then
    warn("[Trips Hub] Failed to load hub: " .. tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Trips Hub",
            Text = "Failed to load Trips Hub! Check F9 console.",
            Duration = 6,
        })
    end)
end

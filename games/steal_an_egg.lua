--[[
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                            TRIPS STEALER GUI                              ║
    ║                  Advanced Script for Roblox Steal an Egg                  ║
    ║        Modern Dark Glassmorphism Theme with Mint/Teal Neon Accents        ║
    ║                                                                           ║
    ║  Features:                                                                ║
    ║   • 🥚 Smart 2-Phase Auto Steal (Rarity, Biome, Category, Mutation, KG) ║
    ║   • ⚔️ Bat Kill Aura, Auto-Equip, Anti-Guard Hit, Anti-Trap               ║
    ║   • ⚙️ Auto Equip Best Pet, Treadmill Train & Upgrade, Base Upgrade        ║
    ║   • 🐣 Auto Place Egg, Auto Hatch Ready, Auto Sell Pets                   ║
    ║   • 🎁 1-Click Codex Rewards, Group Perks, Away Earnings, Monster Feed    ║
    ║   • 🏃 Speed, Jump, Infinite Jump, Noclip, Fly, Instant Biome Teleports   ║
    ║   • 👁️ Real-time Egg ESP (Rarity Color-coded), Player ESP, Biome Radar   ║
    ║   • 📱 Mobile & PC Friendly: Floating [T] Badge + RightControl / Insert   ║
    ╚═══════════════════════════════════════════════════════════════════════════╝
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsService = game:GetService("Stats")

-- Ensure LocalPlayer is loaded
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- =============================================================================
-- SAFE PARENTING & CONTAINER RESOLUTION
-- =============================================================================
local GUI_NAME = "TripsStealer_Core_UI"

local function GetSafeParent()
    if gethui then
        local success, hui = pcall(gethui)
        if success and hui then return hui end
    end
    
    local successCore, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if successCore and coreGui then
        local testGui = Instance.new("Folder")
        local successParent = pcall(function()
            testGui.Parent = coreGui
            testGui:Destroy()
        end)
        if successParent then
            return coreGui
        end
    end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    return playerGui or game:GetService("CoreGui")
end

local GuiParent = GetSafeParent()

-- Clean up any previous instances
pcall(function()
    if gethui and gethui():FindFirstChild(GUI_NAME) then
        gethui()[GUI_NAME]:Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild(GUI_NAME) then
        game:GetService("CoreGui")[GUI_NAME]:Destroy()
    end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild(GUI_NAME) then
        pg[GUI_NAME]:Destroy()
    end
end)

-- =============================================================================
-- NETWORKING & REMOTES RESOLVER
-- =============================================================================
local Networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")

local function GetRemote(name)
    if not Networking then
        Networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
    end
    if Networking then
        return Networking:FindFirstChild(name)
    end
    return nil
end

local function SendNotification(title, text, dur)
    -- Disabled: suppress bottom-right screen notification popups on enable/disable
end

-- =============================================================================
-- THEME & PALETTE
-- =============================================================================
local Theme = {
    Background = Color3.fromRGB(15, 17, 20),
    Sidebar = Color3.fromRGB(12, 14, 16),
    TopBar = Color3.fromRGB(18, 20, 24),
    CardBg = Color3.fromRGB(20, 23, 27),
    CardBorder = Color3.fromRGB(35, 41, 48),
    InnerCard = Color3.fromRGB(26, 30, 36),
    Accent = Color3.fromRGB(225, 45, 215),        -- Vibrant Magenta-Pink (Matching Graffiti Logo)
    AccentHover = Color3.fromRGB(245, 75, 235),   -- Glowing Neon Pink
    AccentDark = Color3.fromRGB(140, 35, 185),    -- Deep Electric Purple
    AccentPurple = Color3.fromRGB(168, 55, 255),  -- Electric Violet Purple
    AccentPink = Color3.fromRGB(255, 40, 190),    -- Hot Pink
    Text = Color3.fromRGB(235, 240, 245),
    TextMuted = Color3.fromRGB(140, 150, 162),
    TextDark = Color3.fromRGB(90, 100, 112),
    ToggleOff = Color3.fromRGB(38, 43, 50),
    ToggleSlider = Color3.fromRGB(230, 235, 240),
    SliderBg = Color3.fromRGB(28, 33, 40),
    Danger = Color3.fromRGB(240, 70, 70),
    Warning = Color3.fromRGB(240, 180, 50),
    FontRegular = Enum.Font.Gotham,
    FontMedium = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    FontCode = Enum.Font.Code
}

-- =============================================================================
-- SCREEN GUI CREATION
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

-- =============================================================================
-- CENTER MODAL POPUP WINDOW (ANIMATED & AUTO-DISMISS)
-- =============================================================================
local activeModal = nil

local function ShowCenterModal(title, message, dur)
    pcall(function()
        if activeModal and activeModal.Parent then
            activeModal:Destroy()
            activeModal = nil
        end

        local modalDuration = dur or 4.0

        local ModalBackdrop = Instance.new("Frame")
        ModalBackdrop.Name = "TripsCenterModal"
        ModalBackdrop.Size = UDim2.new(1, 0, 1, 0)
        ModalBackdrop.Position = UDim2.new(0, 0, 0, 0)
        ModalBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ModalBackdrop.BackgroundTransparency = 1
        ModalBackdrop.BorderSizePixel = 0
        ModalBackdrop.ZIndex = 2000
        ModalBackdrop.Parent = ScreenGui
        activeModal = ModalBackdrop

        local ModalCard = Instance.new("Frame")
        ModalCard.Name = "ModalCard"
        ModalCard.Size = UDim2.new(0, 440, 0, 190)
        ModalCard.AnchorPoint = Vector2.new(0.5, 0.5)
        ModalCard.Position = UDim2.new(0.5, 0, 0.5, 30)
        ModalCard.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
        ModalCard.BackgroundTransparency = 1
        ModalCard.BorderSizePixel = 0
        ModalCard.ClipsDescendants = true
        ModalCard.ZIndex = 2001
        ModalCard.Parent = ModalBackdrop

        local ModalCorner = Instance.new("UICorner")
        ModalCorner.CornerRadius = UDim.new(0, 12)
        ModalCorner.Parent = ModalCard

        local ModalStroke = Instance.new("UIStroke")
        ModalStroke.Color = Theme.Accent
        ModalStroke.Thickness = 1.8
        ModalStroke.Transparency = 1
        ModalStroke.Parent = ModalCard

        -- Top Header / Title
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "TitleLabel"
        TitleLabel.Size = UDim2.new(1, -40, 0, 30)
        TitleLabel.Position = UDim2.new(0, 20, 0, 14)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Font = Theme.FontBold
        TitleLabel.Text = "⚠️  " .. (title or "Notice")
        TitleLabel.TextColor3 = Theme.Accent
        TitleLabel.TextSize = 15
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextTransparency = 1
        TitleLabel.ZIndex = 2002
        TitleLabel.Parent = ModalCard

        -- Close [X] Button
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Name = "CloseBtn"
        CloseBtn.Size = UDim2.new(0, 26, 0, 26)
        CloseBtn.Position = UDim2.new(1, -36, 0, 14)
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Font = Theme.FontBold
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = Theme.TextMuted
        CloseBtn.TextSize = 14
        CloseBtn.ZIndex = 2002
        CloseBtn.Parent = ModalCard

        -- Message Body
        local BodyLabel = Instance.new("TextLabel")
        BodyLabel.Name = "BodyLabel"
        BodyLabel.Size = UDim2.new(1, -40, 0, 75)
        BodyLabel.Position = UDim2.new(0, 20, 0, 48)
        BodyLabel.BackgroundTransparency = 1
        BodyLabel.Font = Theme.FontMedium
        BodyLabel.Text = message or ""
        BodyLabel.TextColor3 = Theme.Text
        BodyLabel.TextSize = 13
        BodyLabel.TextWrapped = true
        BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
        BodyLabel.TextYAlignment = Enum.TextYAlignment.Top
        BodyLabel.TextTransparency = 1
        BodyLabel.ZIndex = 2002
        BodyLabel.Parent = ModalCard

        -- Bottom Progress Timer Bar
        local ProgressBg = Instance.new("Frame")
        ProgressBg.Name = "ProgressBg"
        ProgressBg.Size = UDim2.new(1, 0, 0, 3)
        ProgressBg.Position = UDim2.new(0, 0, 1, -3)
        ProgressBg.BackgroundColor3 = Color3.fromRGB(30, 36, 44)
        ProgressBg.BorderSizePixel = 0
        ProgressBg.ZIndex = 2002
        ProgressBg.Parent = ModalCard

        local ProgressBar = Instance.new("Frame")
        ProgressBar.Name = "ProgressBar"
        ProgressBar.Size = UDim2.new(1, 0, 1, 0)
        ProgressBar.BackgroundColor3 = Theme.Accent
        ProgressBar.BorderSizePixel = 0
        ProgressBar.ZIndex = 2003
        ProgressBar.Parent = ProgressBg

        -- Understood / OK Button
        local OkBtn = Instance.new("TextButton")
        OkBtn.Name = "OkBtn"
        OkBtn.Size = UDim2.new(0, 110, 0, 28)
        OkBtn.Position = UDim2.new(1, -130, 1, -42)
        OkBtn.BackgroundColor3 = Theme.InnerCard
        OkBtn.BorderSizePixel = 0
        OkBtn.Font = Theme.FontBold
        OkBtn.Text = "Understood"
        OkBtn.TextColor3 = Theme.Accent
        OkBtn.TextSize = 12
        OkBtn.AutoButtonColor = false
        OkBtn.ZIndex = 2002
        OkBtn.Parent = ModalCard

        local OkCorner = Instance.new("UICorner")
        OkCorner.CornerRadius = UDim.new(0, 6)
        OkCorner.Parent = OkBtn

        local OkStroke = Instance.new("UIStroke")
        OkStroke.Color = Theme.CardBorder
        OkStroke.Thickness = 1
        OkStroke.Parent = OkBtn

        OkBtn.MouseEnter:Connect(function()
            OkBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 50)
        end)
        OkBtn.MouseLeave:Connect(function()
            OkBtn.BackgroundColor3 = Theme.InnerCard
        end)

        local isClosing = false
        local function CloseModal()
            if isClosing then return end
            isClosing = true
            TweenService:Create(ModalBackdrop, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(ModalCard, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.5, 20),
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(ModalStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
            TweenService:Create(TitleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
            TweenService:Create(BodyLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
            TweenService:Create(OkBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
            task.wait(0.28)
            ModalBackdrop:Destroy()
            if activeModal == ModalBackdrop then activeModal = nil end
        end

        CloseBtn.MouseButton1Click:Connect(CloseModal)
        OkBtn.MouseButton1Click:Connect(CloseModal)

        -- Smooth Fade & Slide In
        TweenService:Create(ModalBackdrop, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.55
        }):Play()
        TweenService:Create(ModalCard, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 0
        }):Play()
        TweenService:Create(ModalStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Transparency = 0 }):Play()
        TweenService:Create(TitleLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
        TweenService:Create(BodyLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()

        -- Animate progress bar over modalDuration
        TweenService:Create(ProgressBar, TweenInfo.new(modalDuration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0)
        }):Play()

        -- Auto-close timer
        task.delay(modalDuration, function()
            if not isClosing and ModalBackdrop and ModalBackdrop.Parent then
                CloseModal()
            end
        end)
    end)
end

-- =============================================================================
-- CUSTOM TRIPS GRAFFITI "T" LOGO & FLOATING TOGGLE BUTTON
-- =============================================================================
local TripsTLogoB64 = "iVBORw0KGgoAAAANSUhEUgAAAKAAAACwCAYAAACIGWW2AABwgklEQVR42u39ebwl11XfDX/X3lV1hjv33FJrHq3BsixhG2wieTZgJhOZML6GEAhhCG/eDPAkD4ogDyEhDw4kQMKUGHAgboznSbaxZUmWJWuwZamlltRq9dx95+lMVbX3ev/Yu+qcK9uhNU9d+lzfdve959SpWrWG3/qt37I8Pw8BxIigvPYdsPXXhPP+wVZzZbure78y8jPP8TlebwALZxt4lcAe5dTxhG/08/EwqqpG3vRfXt/+lp/73qu/hXvvOcRH1m7GSfdvxnXbjxzgPTmg8etZulbXGZgVuNbDDf4b/ch2fmSsYH6mpNjp0dMtbPHIhEUmwUwmNA/P8+F3j1z7l7TRJs+/U7rOiux2Yq/8oTfNvPXnPv1L/75gHN6792vyhc59bkX9Ozpm4WfxvBuuSeCm8pk7l+sNfN4MDW63C39/E7u4rrXE0vkWvUTRSw3JFQZzZiHLmy2tzU2ZblsaWEkRtYgYDAl9v8o2/b5LZ/ngT8F1Fnb7l7IRJjxP3bL1E+/87vE3+EN/M9DP3vdQsjv9W1ScOj/wqrwdeDfc5J+Zt7/Ghte+wQMebmKG66Zg7XLBv1GRq/vSuXSCibMymTCZmSClSUKTRDIsKVYSJ2o8GEWkfukD/jYVzD/cLj9QntDd/zgY+Q0vWU/4PDTAS9QrTNFKP3DkVj53dK+sNJaYzY+x6ufJZJwBPX2ab1cMrxC8XPCqW3nbeSX6ZuAtifRek8n0zoZM05QxGjJBKk1vJS2MWgUvIKJ4vJbi1UuBsyBYFUQEj6NgHcUPGkz9zDbeUc5yw88/S0b4vAz5z0MD/LwBvOA/vUfv/a4mzYHrFfTpMM7mMmVz2tEHbw4/e415il4wGt5uV4XXTXz/rpLu2w36/Uj2uimzpd0ym2kyTkLTJZI6gwogijOFFragoFShxGOABKWBZZoU1LMqikHw8T8VlxTaHSTS/rnt/EB6Qm/4mWfICB/3YD0+lwXYprBbg6c/VYTU57SdH207WfioItcqjml20ZRpjuveuwrtvXWNzy4+hSe6CrMlwHW8z36KP36DgZ9MpPm2ttkyPWG20pQJMtq5QcRTGlUnBUo/PCFYhSkMO0k5TRqcq5bTMWwjYdpbzjANPs4Kv84CmySlqx0OFl8CnIoIiTZLK+1Gqb3fmeNDv/T05YRV7jrMj8/nFxqP8O0lvNN989+7JokG+azlpc/XKlgA3cV1rZ7p/oJX/5ZEyQaUn06wv7PIJ1ern3kyRc7Q2/3IpGP+nUb0n7Rk6soJcxrjZhsNaRUCgjpTqqePlxxPqsJmEr2QjJdLg4tocJ6m7DApTSScTVEGZ2IMYPhvZonflkW2SpN1v8LB8nbAB5xJLAnNUkizQovfW+RDPz/6+Z8gJCTR6Nzwd1Wm+I43QPkTVpJvVXwfZVVxxzz6mEEe86QPJrT2LPHBwxvzmuts9JzPqDHKkzWOZ8sIn4lz2M6Pbhsw91NWkp9qy+ZzpswOxuzWMiFRcMZRmoF6coQxtZwvKVeS8mpt64WasV0sqILzoA6Hx6EoKWxpIdMNyhNd2uuef2dn+XPpsEWarPg5Dpd3IPH0BYNgsdIoIclK7b97idP/Fex03xjm+UYGt01HwisAM3z/ZZ61txr4oYaZvGpCTmfMbEbVo1JQaE6hPQp65LrOQNfWnBYPKP6LhvSzTU6//Tj/Y+5xD+0zYojCU8bEqjwiFBBww9OJzY1UpGj8s3sSry8xDGVL7P//qpT/dNKctmPa7KJlpgpBRNSbASU99dIQw0Um5Rod09f6NhdJRoqCK8EV5CgeQdot5LRJ5KKt8MqtyJYWPLaKfuEI+Z55xnL4ZTPHh2SFTTRZ9Ic4Wt6DlQRVHSLuYlVIVCFB3aWLfHJPzAn90Nj2SLjeX29w13B98hVuv9xQvlXEflcqrde0ZWsyZjbTZMKlpF4l+FsJL6gg6vAUFKbQbjLQDj1doqsLFNqd8yqfyGi9d5YPfFoQfXz0eI4M8JoEthnYnZ9cHlJdtG9opM9iRRZu5gxvujyV8Xt3JJcyZrbkghi0MH2UHMMW4Nu1wXdpS660LTIVpSgotaREkKyFOW8LcsUWuHgGLt+KbGujXQe3HEY/sh//1Tm8Opy1jGP5OXOcz7HKNA3m/aOccPdhJYsGWH2JCtYCcznZ5R1WF2Bd4O3fxBO+z47zPy80DF4pyLcZya7NyC5um21mzGyhIS3NaBaqmJzS9NRjRRAEJ4qqkiCkGFIEK4kqRhF8rn3T90vJmp+lows47d1hyf7LZXzLX93EDWW8lk+bk5EnEg63cs24k/ZHBNdy6g8pPKy4Q4I/5pFjBj2RMLWwwIfXnphxjBrq1xnr4w31SXzwAFiP84bvnzGn7d6VXOUcg0QR+iqcIxnfQ5u3aYvTjYEyp3QFjgQZn0Eu3468aidcvhl2jCGTBi2AfV38Jx/Bf24/LK2jWDRJUBFFRVIMPymPcY92mZQms+4h5v3eaIAjdiXiRSXx+HtX+MwVj89Zp+ns8hQXCcXlkFydSPbyRJoXNmUqackMDZkgk6ZPaZaIl77mpuNzAWWntHgN23mDzpDbguNScowBB32Hx+gxqzk5SoLSxJJgQawq3vd1XZb9wWTVH8NreWdC41fn+egnnk5vKE/Ui2ySt35ik7ngbWOyiQHrlNql1D4lfUqKrtN8yVGcADfr1M159JCgRxQOAPMgyw2y1ZSzVo7xh90n2yeG6+K5z36Dz7Dt8UZq4ZJynFv+1VZz7m/sTC7Jc/KkocLP6QzfTYtxp6ADcoDGJHLJ6cjrzoBXboNtjfAqfWDFw4NL6K2PoXcfRHtdVFLIElRBVTR4N5FC4V1mP/u0x5i0OO4eYMk/SiIJdcKvoKEqScDfOdDBzwt6kSF5uRV7fkLjAivNszLaYxnjZGaChozRME1NtFEKRgtKU+DNQBwGz3aaXOzb/D2d4VVmE6fRRMqS0pckWARD3yjLmeNh6XOPW+UOlnhEO/TU0ZaEVARFEEl9Vxd1vnwo7egCVrM/s8i/nOUjJ54OI5Qn6kWmeOO/2Gov/fc77cV5Qc9aLEYQjzMeZ0stKLXAUVDqgEIHeEocfUrtUTLIPa6r6lY9fsHhjoM74dUvAvOCWXDonMUtOexsBiuOVneCdv8w7+tT5yNP/Jjg2t/fYS//2e3Jhfma9pLLpcmfu814X5Bbgz13J/La8+GVO2BXExzQcUhhQ5i97xh666Pw4Bxa5qgx+CRAqaoSA6rEoAqr6vhxc4B5cpra5Ij7Giu6D4ONBqiAxDadwZBqJuM2Y4KUNqlpkUmLNLT0yoTUKyqFlpLjpABRPBM25UwzxmWDMa50Y1yeTLCDBglCxyr9wpHtmKD902fhHu1S7u2hBzqY2R7GewRDt2nYm/a4sTjBF/wc81rQAqwQkU31S/4xFt3BRMkPJWp/cpaPfeaptkOfABAdvIrB3trRE7an2zMRI0JCrkoJpBhnyUilqQZRERMzbUVR8XjjKVNHOe3VTTvcmU5LPCWF9vFa4ilwmuPIcRSloj3Fd/o66G7mu9aUt3UVvwayCn5V0AWv5boia4p2Fd9TWPfouuAKweSG5sCSDhy9yxJJUXXG45kEUEehnuSqa5DvPRvOB/oOjpYgCbrs0XsPoF98BA7MB2NLU7TRwHuPeiB6C0VQAadKitARGIhgMYBH6ZNJm4ZMYGliycjMOJm0sdIgoSGJpKFoUFXFS6leCgrpa2k8pTGitKzlHBnnXNfisrzJZcU4ZzPG9Mw4ZluL7vKA7lIvGLkFO4DWt55G88e245YQBsBKru6RAfntK/TuWaR8aJ0L+y0utRfyA40z+LA7ysf9Udb9gLHw+cxmcx5NmciPlvedMWDw8Wne9A+X+cyfPxUjfAIGuNsDTNLas6arsyW9bU2mXYGX0xCm1TIvKus4ulrKAHASYowoGFWxGLUYbyUjxWgDwUj4VwRUvVQ+2ePFU1qvOqGiE6oOT4mKR1VjT8Hh1aNa4nA4LVAcisMxwKvDS2znIuppSSKZV0qjwITY4KqSBMk2wY0e/XwBF1nYVMBXHkG/tA+OL4ZgkWaoEdQL3oNiUBEQE7NkwUc40GBYp2CAx2Lw4tiWXoyVjIQGqKIKIgGS8ao4PH0tZJ3cOjwiQstYNpOxkzYXapvzyybn+ia7SBkno7F9HHv1ZvS8CQYHB3QfWGKwmtM3jnnJucS3KExK8i3TuIedaN9hrFWShOzSjOzyCca7u3D7BvS/vML6bbNsPir8tLmQNyS7+KPiQb7il2gaQ6F92rI52WWvLA+7u4yn+LMZeevOJf+p//hkjfCJtOIUMAf40PIMb/lKoYO3TIj1axT2Qhr8lpth0ShdoywYJ8fImVN0AWUezxyOJYUVnHQoGeAkJ0Q5h4I6Cd0Bg8FogHFRg6hVq0KmErzJSHOf+GdFa2wNUQEN7TIUFcWLxwFGRQHxoJZxL+AV0gzUoFZhYJB7Bf/AreiJg0ADsizkaqqoE1SG4RZEtXpo4uPjUUSEdYUcTyNevJQm4oVCcgp1lFXIVk+GYUwSdkibM6XJmdrkDJ9xTtFgp2ZM0qBJip1qwblt9KpJ7Ctm0MzSvXuV7o2z9B5epaRkIk35pC5ylmakeQt2TYg9u4WuA4c9q/9tv5TGqbEWWhbaCXY6Q6ZTxl6zg2J/j4UHFtmRT/BrzVfze/l9fNwdpI3BaUlDJkxCqn3tl5bGf5jiLftWuPH9T8YIn2AvOPRenRY393X9LR60ATwo0EHZ5DybvLLLF3pF4LQEM8KCMZpbw7pRWUN1XT1L4lhQx7x65qVgWZRVhS6GdZysaUlPHL2QUYpXgxfBqY85lGDirTcYFQQR4p/CO1egL6oYqcwmGNAYJlhGkkKWgijSENTlsLwMtoGYBB+NjirMquBlxPi0CsMxF1QQMSxLSamelhg84NTj8ExpxjYZZ4dpcBopuzTlDN9gW5ky41MmSEhiRe22N+GMMfScCcyVUyQXjpNMWPKHO6x/eo7Vz89SLHcBg7QtKQ1mKbjZz/NGuYCuloxdtklpWREH/ZtO6NqDx/Fpgvpwzk6DRw+xwmDGUrwRBjjGNWNFi1C1i2DE0vULDFgTSwqqpUHeO8Pbekt88uNPtDB5ggZYV5d35LqGozSpCifEsT/1XJaX9M/egbztHNg3jx5Zh6Uesl5iujm2GLAJ1U0biVcx1W0SrCcY7MCodq1KR9COKh086wJreNbV0xXoqI//3+m6KF2UgSo9DZ2JnJCblii5Kv3oF1UFr0oLAypgDZqYUN7YBLpraFkCJlS2UoXbkAVX3jb8fTTMWMqqhp8VLOuVH1Yo8Gw2Kb+uZ7DLN5kuhBaCYFAsvtXAzzRwW5roGRO4XeOYc8ZpnN0imbaQgzsyoPORWdZvnaPz8AolBSazmLEUVaFQZVwtf+gPME2LnbbBkuRMXjQJDtWFQjq3z1GmCaaRhvOWaHgqeA1/LtXjnJBKysNujTv9HE2xOJRELR1dgMDwkQbj2mO1gbr/uY3vvnyW3bMjIPrTbYAhD2yRfGWgy8sl/elMGq6jXvZJyWUqyLonOf/l6LXxV9ZzGAxgtY/OdShWurDcg8UeujbAr/WElQHSzWFQILlXcTmJU2ZAZ2rYL6IvlUetv0v8JwUJF7KMYT0XpSBkfE4c/0wX5EGcZjFoj4kNRp804ut51AD9LuocJNmwshUZKTZGq97oYEfCcvhZWPElXhQLdPD8hGzhNTpFN3HYnZvIZ9ro1nFk6zh2WxszlZHMZMhYfA4HUOztsPrwCr17l+g/usKgP8AbgbbFSAN1ULqQe6ZY9soqH9Uj/LI5Hy09yVQLe0YbLaB4oKO9o118O8HHHovTmAZ5rTrUeDE4oEnCbf4YXc2ZkDRm3QVdvxBAbR1QSmpO55X5Yblna6GD3wd+APaYZ4qOpQAn+MzsJt7ySK7dqxvSVq+5PEjB95o2LC6K3jUP+zepTJawPYNGBpsnYPtWJNpOCFMgJUgBUhaqZYHmA6RToqsFxWofv9qDlQH0BtDLoVeggwIKj+SK9Ao0LxHvwSmiGnyKQgMwXnAKVlJeYRp8TbsIigEmTLxONgMvoTshQL8fWm1iIk4nQ88nqKqKj94QJHoQJPy7wSOUKixIDhoegh3S5Ht0mn7RxVxyIfaaS7EpSDPUMHig6/ELfQZLXfoHV+kfXGYw36HoDcLFygy0E4wK3guOodE7lAzDe90BHAMuStoMukrzvM3IVAM60LtzhUIAI/iYuIYcPBiw12B8Pn6ONVHu1hOkIngUIyk9P89A1zAiiCZ0dYWMqeQ8eU3xIJ95xxa+753z7H7fyYbi5MmzSfTuXHtXixhvUfMAhXhr1Ba5Mr8K01tgMYF7HkZnj6GtFiQp0mhAO0NaGdqwSDNV2gnaskjbIo0WTBvYLIgxiAlhChvbwYVH1YfbXni0H42yX0C/QLoFLOfoYhdd7uHmu7ijK9jS8Sozpv9Leqh6jAgtAPUh7MZ8UBT8oA/YaKbhSQnhFg2eL2KRIqgaVDRmmSKKxDxVWMBh1NMRw9+XzZxVWtZaGe1zz0WXPfgC1+vj1noU82vkyyFC9DsDytJBIpBaJIZYVfBe67DvowE6oKUpX2aeL/jjvMxMsl0yeqrMnDUdIsOxgu4Dq2jDoCq4WL077ynjQ+YlPLo5Tlqk3KdzHNY1GlhUFEMIv4oDTQGlIS0O6xe5Rv+JLPCYLnDw/zmXn/7Uo/zhSTGWnoQBhs6D0/K2vq7+tMeTiuEoqssCm/AUJ5aQs2O+tPco7PsKBMJSHUpDKWBRYxFj0VDyghkm/MSLpBIYxVr74OB1JEIfosEFoYI6JWIkoL72tIjlZb7JjJEIjQhjMUETm1bFdLCyfieSmeJ7itEq9Pph9RtzqOBNPEPDkJgGLFOCCJNiebtOkruS7OwL0fEWstqnc/u99JbWcD5gh2rBW4NmFtOwEMOj1yq3jHnm4947NGk873ePUaKcLROMacpaWmI3tTA59B/s0l3s4tsmeE8NaYiXmPtJlceqeAxORG5zB3CUCA0N5zJg3c9hMHVaZFSAhHPkUjmul3Och7c4Bi1g5WQaHU/CAK/1cBMJ5r6BLmuhRZKKYUEcB7VkE4LOziJdj1YhzjSRtIlE7KtuLkeLUoqQjJQjSVWwgMp6ht6oyvlimNDKUBn+SvROiohU7zcAdkjKy2jwJemRIbQ1xr4kq1piSAm+28UFQ9K68hWDVx2FX+pqeLQD4uOnyxV6An0xfKdMcJ4TBmNjtM88C9Yd63fcR3d+ERqNKrTHCrvKL+PraQi1Vb9O43Xz8RqUAhOaciOHeZgVWqRcJFP4EsxECzPVgDXo7FkmV8Vg8EbwXnGqwetJTCPE4BASEma1wx4/RwOLw5OQsuaPM9B1rNg4umgppeAivYotZto95G+3mTY+dID3HD/ZEGyeuAHeEE0keajQwQlHbiyiPfXslRLEwuoKrPUhB3IXvJPzqHOCd4JX1Gu0wMoiJRTD1kBikSSBNIHEhu9p/J5UXxa1BrESwGFjgsGLhGglMUTGwqEAjBheLW1KwCI0Kmu1STwVgbLEDwaoGA03ZaTwGOl4xCRg1DOJ1p5dGIiyjqdBwt9nG1p6Sc4+R6TVkM7d97M+PwfNRnytcIm8Ro8k4fUdIVQOw2N835inOQQrljn6fMgdIMWQieFs06ZXerKt45ipjPJYzuqjq/jM4FRC3icGRzC4EiglvJcTIRHLfX6WJd8jEVO7sTU9UTUaI8Bl8CRcxbUc8LeZJQ4yxdR7n4g1PQkDDGewyCdXPcWDuXYwGC/AIzgwCfT7yFo3eLS8RLAjv1v5CT9CR/JVKRk7dxJD65C9NiwGpLZb1ZHwVHuNAGsoRnxdlZoaMXyFNsk0IIgNJJqOrUOK5jlaFLEMJXZdhqF3+FVXwqJiNrTjRAw5ypzv8WqZ5Co3Rj4+qY0zztHevQ+xfuwo0mgGI5Lh1fAyxOKcGkodhsdgjAZvbDBAMZQImWR8Qg5znDWsGCYlY4s0GKjS2DIRbseBLp21PpraUPX6yggrQw/GWBl+jucuf0StGAWjIoaCLl0/jxETijVFPZ4ptnOxXOZv51OJUR56DT90U7hpu/0zZYAEYigoel9OBxC1KPs0D2BlWaJLq8EAi2LI/KjxEr6eXVXdRIlGJOGrynWqvNBHI/OjXoi6O1E7VkVUVbSGnkXIgQtpchoppSpZVckmSYydAnmBOlUVG405eihGQ63gEfFixIuN7ZjK+A0SPW7fOL5TxxHnaFxwMfnhY6zuf1S10Yg3Prxt5Xkqw/KxjRk+d/ysEoy1MhyHkEnKQb/G59xh2iT0tWSntJnUBoWxpFvGwMHawTUK1fo967xyw/+HUiGRhCPa4TFdDMUHiiFhXWcp6Me0KKTlpZScwcV0Zc3v0wdpMfn+3bwzj/ahz6ABxtaTcldBD4cnA46IsoSS4NC1JZECKAcbclEdxfQqgDd6yMqDbcDbKrA4xlVFo9GZ+FrBWBxaA6l1SAuvEcOxIRcYF8vl0qTEk1L1cZOhEy4KnHeiYsNDEN8/eFuqUCyhMInVYzS86kExGObJucBM8W1lm/WpSXAJKw89gE+z6M2i7x8NuRpCoq8fMBND7zDkltG4S1WsCh/RfazrgEwSSpTTpU3mLTQS0pkmftHRObiOt1A6KKMnrYy4xMT3MzgFQ8J9fo6u5mLqPNSz5mejsVTJSBgzPZdLeUDvsl0WdZLpD38TOtzTbYDX+soDDvyqOookwbCknqPBwYl216EELV30XsS8QWpjA4OIBHRDY58ssOlUqb5LDKl1Ah4DcOURLbGtrzpqxCMfTTYUY8JraJEAafSwYpL4ZFg074eer0gsOkYKAuqiIzLqQ56ood6O/w4Wyxw5b/JTbE9mkLHNLD36MLlYvAk32imUMYw6lRGPWHklE3IzhTI+qAkJTVJamjAhGV9lnjv8LC0sngAtnc4YzgvZxBjpVEb/SI/15S6SDkNsldu6usCq/mzpieM+PYrBqo+kioGu0teVQCOrakCFhAbbONPv1a9Yg33kVfz9u0cbFs/gXHAoRCYxjw50sODUbcnEuo46OWo8l4pFuyuo6yG+HIEttIZgYAiraAR00WGvVevAFqwr5Bw64kZFtSYijEAjkZkSSaGMXK8Y/B2XaIstldGJAWtr1Ic8x3tiVzmkm04QjSSIGJJFxGgIY+EhiQ+AqAqFwIS1nOHGWEsSBisLDPIcrK29tKoJOR2CF41ejjq5T0UwahE1lCgdHHMMOOo7HNI1DrDGo7oUz1Dw6skk4Qw7waBUpqZDO2X9cJe+9xhJogcPntXVmbhErwupJBzyyxzw82QYFI+RjA5zOB2QSBaQDMBTMqZbcCbxh9hLqs2bQ/h9RnvBGwuRw9y4uJnv2FeSb2nR8h61+00JNlMGPeiugrrQUcBEXmCFlQQrqRz60AKGbZLgeaIvrDyaVGFcY7g2dYjX2HuVukoLnqzypwL0UM4i41KaDOLNw5o6S3D5AB/DKBJoUqqiscIeqXoRFdXgnZEhvRR6lJyn4yQGVsrYxbA25m+VzYRzTLDxvcIDWaCyrqUu+JwT9Dio6xymxxFdZ1F7dLTA4REVUoiQiOBUGcOyyTQpBBrTLShg+cgapRGSqttRpygaOx/R+5rQSflacZyeLxmTNIZfR8cvYCSRGBAQhFILptjBKguywnGaND7+zRnqz4gyQhjsLjS/t/C9V4vdrIaCR3wumKZKOYDOcjS2IV8utLRqRopUMbcyvoqpAia0tqoCBYnBPRhliLtSG1uFoqDgJZiQPg6Kl1i4tBRegY11R0TAXbR9X9ZNevUqobkX2nQjRYj6gDFGL1mfU8gDo2EXAmKEBIMVQxpZOt4IhULHe5al4Bh9jmiX49rnCOuc0J6s4rRHicNjFBI1JAhtslDRC5Ra4NUFPBDPlKSMa4o3luZ0i3K5YG2ph09M7eWG2ENV2EidDuUCDzNLEq+xINLzSwz8Kgaj1WcUERyOCbbrEX0wKXTQ28QZd4Wr/MSUKp6yNIdS3J+zBhKesiOiWipYV6Kri8HEZKRJDyG514pZoqI1ycCMgMmyoWDRONVV/Z3WkLOOeECpPWzVdRnW3Fobfl+UaxhnXCyliYyc6MJ8kYc+cAjnWoHPPlINdaRoiB5RtIaIKmZWCKESe7RrOOa1x6wOmNMBB6Qrx+izqDnLWrCuTgt1aDyTFCOJGGmTqUFAPCUFhfboaZdcuwxYZ6BdttmLaDJOqSWbpUVDU3wqNMcbdI516fQKtGEpq9RHhsyd2vuJkJJyTFc45helDr+kdHQeT1mDz0NIzJPS0EU9ImAefRfvOnwD73nCQ2NPwQC3xaaYeTBnPVCzRJhXZdl7tigUc0dDmSAEimkVar9RDRQr3VElqaH3q7oiG1txFSY4NMyhwMlIsywYngqmyupUOcM16FsoRUlEQk/YG1xehMZ7nVvW3luHiKWpUIAN3rf69yaGW3Sem1hgVXNmGbAmjoGWUqgHDcioBRISWiS0JYufw1NorqX26OkCfV0lZ51cuxS+h5cCxaPqSKSN1SxOhsBpMonxgZ6VJAlLx9fJ1ZFiI9OFOg+sIJ1QfUNDLHuK43S10DFJRVG8lnT9YqCMVbkMdfZEk0x74kD9Yzfw+vKJ0LCeBgO8pLr8ewe61nPkzQTrFynlqMAWMfjeGqlYZsm5w6yzagwZKS01mJpnJ8M0HhNFfILnkhE9JyOCETNC/AyIW2V5JuY4VagUYePkmamK59B8n0B4DWO1Jw7NZYcrB/H9pe7QeCT0qGP1SIULitT4uY9G6FQxKnzBz/MJTjBDKHBSEppY2pKpYFH14inxOHraYaBrwci0w0DXKQkzMoqrr0z4lAbRBMXRkAkSaaA4jAg7ZIzSeSbaTVDD6mIPsXaEREuNa7oNOCr0tWSvP06EXlRIpK8r5HQwYodMoVh2KWAkUUeB4sOwDHvkWVTHCpXwVlrHFnVwrNDi3Jak2tNSDorn5SYFHK70TJiMczHc7HvcqEvcR0kBtDBkIngzzKGGXr6mfQaeqoxCOMOWsEajq9jQlU1Wv1tdOJVhaF4Xzyto8dd+jFIksiBAvcM5F3ujuiFcsQGMHvmSDb2c0EmQQECdxNKSNFS46inoa6kDcu3S11XNtSOF9inooFrGG2zigxWn5dQO05LovUNx5EhpYrB4KUkwzEgTp9Ceaonrl7reKZDEbgDt60JEYhhWwUrCHB2O6SKpBqjFiNWOzuK1ECuBLV45QI1zD56SAQM8rvtkCpCnmgMqII/wycGMvvlQ4fvnjplxdaocMTn4LNCcmpas1+UyJ1xmJvlZO8XdFHyKLn+rXY7jaWjgymicp6j+G5YOo31j+QZTpUMDHta/G0rmkaAf9PqmxGKMDbfFRPjGufBVs1+GjfpaykFN9HaPN0apvWAOrOGiFJuh51eZdffjtI/D4TWEUcQoWgMvj09p483WDZ8hNiLwODLGkdg5aZExY1qUIrQmmnTm+wz6BdKwoeshw4gz7OyE321IyqNunq72aUsigaZf6LqfC9dy9CEeOb08eD8MpuC50QcMlbDCwyX9a0DUoDxKAd4jpoW89o0gi+T7H8MfPo7t93klGa/MNvETMs0nWeej2mEv4TOM1d5m1MzsyD2J1CwdrXFHfd7QS6r6uvAIV8+H6nGEWx0gEhMJ0T708kyCD+NqQeUgVsXUtCipz6+CkSp8D4VclXXK6LUtfV2h42dpyCRWkwCCiK2B0Mrj18aoJkzLVYaDR9WHrnSN6gtt2VRDMFtMkwmaeCM0soy542sUKEk0UD8CcgfPR+0VC4V97sQIUmvo+VXJtRODgENUYlpDfZ45/ern/XMsUKlfzbWDjxIPh3A4IxjXR9YFPesCzJkXYMpVOH6E/OGD+CNz7BiUvMtM8A/SaW7SLrt1jbulT46jpWEGw5Kw6o/Jsjugtk4KTX37/XAUfINzHuKHVfPOsNO+goa0UFz44KoRuK7A6xKn4CWYToX3RYbNkI1St22GOWL1LiD01NOjFKNGVRSvOYLBUWBIMKSiOFTCedX5JmHctMRhSLBiY9dZMLTE0lCvhXfkqnibSTv+NExJk8Qn2MTSsKkur/fx1tRpg9dh0eFHWNBGEpbocdjNkkbFBoPQ1QWUEtE4uipDKh21B+zjKHgqYgFP0QBDJeyRh0IlXBiLsKCeFStsKnLK3iqc2ATLA2TrJJw7ib3wZZjOEsXho/gHD5IcXuKtPuOtyXZukz5/oUvcSY6P2UruO6zpMWkyFubKIvZVQytCzOOGBcgwgguqDpFEKkwaNBogQ8Ir4J2j9B41doR6xbAPXOdPRodjn8PipPK/A/EUGjNLJYTiaGBO+oFxpw1UHE5LECWlwRgzbOE0dnAGYzKDp+FzdbrOqi6zYFY5ZjvMiqPEklbYnKrCjDQxasgaGd7BamcAse0XHhzdQIAI7TfISDjOCda0SxYUENTjpKMLNYMI/XpxHgEKclzNY3tODDBUwilysNBu4dUlKcav4WUJ2OQV3+9gLDAwcGwNPeGRzCBTLeSil2EuOx9dmCd/9Aj6taO8ek252uzinRzmUe3REkXERODC0GYCLyWOMt788DxHWjwVOX60YwJKKm0yaeN9iaJRciK21SPnTZ3DaZjprUJgJO3HibeqmzA0Ph6XBxokTuPVMHp8kKQWJPJSUCIkpEzLGWziHH8657BDzjK72Ewmjn3+UR7i3mRWj9CRHj2WKXR1IGIOqZp9qbReZyRtu1i8bDXjaCm0x5oMypLOoABrvgHVa5RBFD7/vuJE6K5ISHcGfp1c16IB6hAR07oLiqjQY40w3fycecBQCSfoIafFcY87I5NM17WQo5Sch0X73fDJTYp78C7cicfQNAstLmNRa5GxBnY8w0tCD8VKQP89pYSqMAntHwp6rDLOJhpYglKfxsDlRr47DXCMr9J4BKuGJF4wamBVR+gKGitgqcif1QjnSE4aqXCoDDOm6t+dQoKhL55C3VAVXMsRpDJmylJS4shlTeb0oWSeB/iKqu/oCl2W41BU+ZBBv5LoxL0Z6d2W8Ue365X79/Bfmju4dj9qxhT1Voxs0wAptccbrHUHFM6TJGmdm7qaSGFGPLbQ1ZJDbj7MIceeVU+X8ZpjJI2Jb90bqE1NMOS6jhOPhFziOckBFZATfLozo295rCA/o8WYlsAhPEiKDrrDNpcYnMsDXuZd/GzA2mrQ37MWa9M6tBLhY0sauxpKSc4qc2yWMxmTaXq6Ts6AOIA5FEvAYTCiKlSDmqYGcgxWQ9jWkdLOOxc5iab2ai7WoUN6WFQ/iPljAGxlgxfsR4EQG184eGsdsoBE64xvzZ/IHcVXDXZgZfy14GiQqpHMtnXHjx3mz+4YveALfBi44pJU2tNC4pW+pCRMmRZehGYzY3apF0YKRkKvH8EuqyLKiGWeDou6Hg0wPLRdna+HTVWHmV/N7wgXzRd0gWSUcPxcFCFBZd7jHst999uxMwjCcRN1kvMe+CD0IxETQ2wUjKk6HbZ27GVE+DTicGEct2KmaKSBOxY4xDbOZac5j7ZOaqoJPVboSl86rMs6c+TapRRHoT0FJzU0IxqBXUHNsMXkna/Ig/F6hzahH8lyVEcrbYmkWR3OCYvQD2Ij0ZN6fFDJ0dFZGMG6hHZa0rt5lZve3ORb/95WOe2mkn65okdFEbosxCnEtQQmSpgx8IdlxsSuBjOG0FK2TUkYMw3UClmasNbLQ/itK13ZABWFkKxkJuFIuUBXO7QlCximDrSnSxE58EHqUIc6Xqr0EEqDGc+1p0KGwZrn0ABnox4K+wv6gFGjcJwcpI0M+lAUiEnqwZ5ArBrS6ytvV0Emrq5bK7ijAj8MXjSEMFWO6UOkNmOnnG23Ms0mxlml9Ac5zDJLMi+HdYFHRVSNkHhTDbIDDUlAbChHYoKkRRm7INWQe1V8xJsoXkCCNLQMscZqMCn0hxN66mJ1Hg1QC60MvurGJNqiKdOs6docIH1WT7so2UnpE72jXIqPoGSB2nRdXLNwjQCaImcnNGp0tEVGw1tMYlAPnX6JWBsA/oohHsmyvsY2FafC4WJ25FGzDPwqTvsbvFr4dMYbSRKnxe2CmRTMVY6+inosJnnO94QIfm9JF1UviQgnvKPEI2UORQ6NFioWL9UwSxgNClXq0HsEhH0DCqi6IX8aArQGy0H/NR7j3nVHXlraiVHXUkqxNDUMlvvco70EOy5YwwiDD6IUSIyfzpW14SsqPhJwdGQM0ctwKk9jrlhPucQx0r5UZYfEmZJyQ+vGq8fSVFGLo79gDOo9m666+gIdm92udzxypyCFombsG19rOdfE7kSpyrRt0SAlySx54emVJRgzPC8jI54wYIAihp4rOO4WasFMg0pPl1BUjQyxfwUSSTXMSucfFpXvDeG9jOCOedJFiHnqpretglP3FXRx4k2CMItjxQiJL9GyH2k8ltGGvo50PzxDQ6xIktSKG3FgeIT3F2KhmoTG2qTuvOZcveplkzrzLZm0jzdlk0EoRTGQ/U3KxKUq7lGkMBVcZ3VIaKhe2vny8e0qCbMp1cx6JJDGCTwd8XyjN7g7pEpQCckNy/Lwd5Z2zNHKY3E8tXf8xIKcPthVZpJ6VS8CS99Ymyc5LZEGoBLEjhqIs6RpQq/ryL1G0aFhz7ce/6pMhoQV6bHKOjakEeJx9FkN11tHFYRFMyYST1Ea+KwSZvoZMiHNc2iAgX5d0j9c+O5KSWGtiK6gLCEY9WgeW4VmyAhG7LDNJdWAjIhiKCN6L3XfR0Q29kJioSEoOhiw+sgefv/4Mf7mQMoEk+xE1StiEPHdBT58VFUGDlcTHKzEWY9IcDACpS/r3m4dukaCkB+h+/v4+74mIpiaV9fRquhQUZzoaN8knkAmLRTFUR5VhTZbP/GBfZ899JuHfq9txGRo8plF1u8O96hiGIdrbUnPSMhixQ+T0kQxpCZlpZPHUszUX6Pkg+paW0k5pov0fDcgoZpooQPNdVVH2UUqitWGpjouTst7NpM8ZEW2NKVd3x1FWk90FuRpNMBwnM70vGMwX/oBgtE+nvkII2keoBjFjszZyob5jfrG15XbaC+YkZF2U4Nv4V8cOb0sXIxzJtu0mmeZnSCGyBluEDgw3quOjALoSB4XBm+888Opt9heCzCMyoZEviIpVDlVhRHGr766GhUkttI24gZKok3jA1o4B9DlpuOS+Tc9Jve9u/Ar/3qCmXdGrb3RkULdyVXtRLLTDUnNJZ+SNipCYlPWYh5bTb2NYn/1TIiEUcxj5Wx8OIyKWPq6itNBFM0cFl1ttvjwABafeYRPDtoyMX2mPb92DAbaz2UOWJMSNvHG46Xm5xnQAZ4T+OCdB73Y9UrrSTMZGfYelvhGVYO4twsW+7h+w+NyoVDUlDbO7SjHGtMJzSub53PP2lcQcaj6MeIUq1NXQ8MBZ45eqypCvG5IA6KHHlbCOpQzq9VA6mGlkN85oIcPjJYIlOvj17AppLSlwxwet1RpcM/nn3gI+GddYPGbbAVYpjE9QbIp6qpKIgnT0qZanrJWlIgxeKP1zPRwwH6I/w20ZM4tqZWk1kwc+JXYwpQRjQdhXLabRd2PobgRmNpiJlvf2riCveXXJPLaG092acPT5AHDQjxV9jspAKtePYdDnxCKXvBYNglD4BXQG0ctnYp4RELf1VBKQO7MSGd35H5UUKgmtDCSDFZYz0MwmB6f3j7W+L7XfLtuZqd4GYAEOULFjEiBjBIK6kcBpz7YYuwQhJFJcCNDT56hpNkQG4wjBnG6bIAbqR+DZLA8bh93U8ZFpfCCXRtOGl5vgsroNcnX66pcH5OOZLuVbMxI4r16ybCMSwtnQnXec2VQv6q8uBlRc9CqALGs+R6LfiUA8hKGjPosR6+tI2jBuI4xmfRZmv++s87/EmzeOb3DNt/2bVfqFNskoqTjo52x58AAKyjGPxrAyXC7DpGHEFT06xxQoj6bNyKxHylDapCpZTRKqEPBkJw1JIkqQkIbVRlArww/0F4/urzgONZw2832slSngj8+/Kh+iPk9bt26alAwpe4WDDVpNnqRISNGR3KtIeNEydWNzE47Jb5uVVUFRXxrPK5vkM5IZ8mHsLsh9DJK9lTsGQktYzBO8TQkpUGGE6VXenKvoGaEcs9IRyd4aFHLMusMGAQ8VJFCO5L79boAERFUlAl2eMeAnM49f3bgPX3Ysjq7vtZrLk+5rXZ74UOuvfxkCalPWw4Yr+7BXHt4nFiEuagOZYoB+BIxNs6BUMmYyddprUQ+XTWXISojW4WGpNygydRE8APYUwSl832HDq3Pfuqn7vu15DCPtFOaYk32PysTc5VnqpTrq4GpqKqlTmvNv6Ecrwb8Moo2jtKY/OOUGojCmH0t64elKhSqkYJAnk2wpHgt+gnp+mhb8+96yMGfmUoLkbBqq0lGQopD6JRl2FlXD7prJB+YEb2ZAP7P+gVKLeJjJfR1DUeOqVqMEXnfxJm6zgKe8nPhBPcefXT5wPt++su/nhznYBv1Iur+x3OMA9YrHI46eni8JMCSOrpGyMoSyqJmnviRfYNazdOO5Fl5DFwVQOpHQpiO9BRSWijaH6o0i17Oz77rUXnw/5dock7TNP7qhPvoJyMPJQ9wSBJT5+E8bAV4BdDZDOc8dFSad1T9amNWWlHzfRT4GgxBpKDSLzqkTqPEwQRUdL2jnc4TudIWc05GO6IGpbTI1EqKitBzLnhpEXXV1GFU0qoedKJk8aybHwFnrA782gY2bPWAT7LFHNZ7sTS/VOlDXgE/d6/Z81Dqmpcl8L4FPvvJqAfjniMDrGJ/ebCk7xRnEhGWKFlD2O5LinwQ9m7U+jCmvo1+w8xa6KUWkZBA3OWhtd8kDg1ZTWkBZsMN/Bp/sITybwBW3DD2CuLjbIkSVag0wj3E+RFX93el5vp93YKmkZ5vxSgZZcY4UfLoaUOf2ImqVxFbwzqGNJpiuQrf34N7T/oht8gZVrK67JkyYySSMqCk9B4kKCr4EUIrI4RZjyHXkhVdxY50hoLGz3DxgOKZ0K2aSpZ0WJqf4YKvdvgCsFu/FOqs33w6tpc+TSG4Ch/2cOnLOaelsaBr6piXKBjp+mBsbH8xAtVKdZWoJG7zarNHHcaGrX6tvUgY6C4p4pW7fnTDZhJ6qNeNiOS4UsWHwaZIJtDYLUBC302jcPKwbTUiz1sb5lA4aZgZSF24hAJKMaHbEEXXhvO0oKS0VMLEzOpwI+bfdQMDBuhhWyLNCM5bpswYYCiUQJAPD5ZAyLGrzsdoXttxA9Z9FytJTZSt6FeBvBFIFtvMWb6kT5/1PUf407gspYJov9E1fs4MMBxLfHrVU5woNcdiIxRThpSi7Ifm/BAHDJWvRG0/GYr79GoKp1QIvQyLQo19k4rEoL3HJcAakvjdbkNIUC2CF42cmEqJy0TWiHc10WCD0Y3glogEJdfRyVEZgZOMoRAVJ5Fbp4LXcpi0xtuU0QziFlouj1a4f/fu5OuNwW5KaFCVNW0aG1ZIjE66DWn4pi6iEpOxqh362sOIRbBaaI+Sfr3SwkTu5TbO1RVOUDL4UigDr7H/x2v8HBqgBghB1GlxtAzVlXpVFuJN17xft72G2NpwMKasBbODorzT4SiQSqkblNwQDFaNJhBywL9zH54bITtIhFh0dGapCst1D7Wi9VdaLhro+qP5nzEjAz7Vzg2vpXoqZQYXxyqHE3+elBaeAk+x9MSqx8+3rSTTRsIknIgwIWP1sh8/sqfEa6WuOtL6FAkQjHTiBqlgArmu47WMRNxwLRqMMa7TclwfwZLe9mQ7Hc8aGSFs78aDHqzmBBQ4HhE9X/SxxuAlKDkho/3Jak4hVBldXLVtqN52FKiSYXoiCPG0YiXpeic/Eqg1A8dF4Un1MbRHEBoZ6U9XoPRQFIXRetwzqpgaB3XUU4yMlOroIEWsglNakfDgV5/IOGOLYtKQTMUBdjFiscZiMSSkQQNQdESEaKjYxUgFv6JrsboPLYGBXx8WIPHbOFu0RZKsMddvMvW1/EnifM8yDANgHi3D0lMMwlEJxFOKXhQnGjE8GZU8G4Kl3aEOVpDKjbiaPM6LhPxFuyfJ1vE6wqvxI194cKWP8w2MKHTJCG2sEipiCNGMGF+lklBWXZxYs2rtg4aFTCZNPDkOt3Jy1/T66MXdlCFpq6qqeqwXPpV/mRvLuzimixTqsKSkNEhIsZJiJSF0OwyiFkvCklsIsSfOsRS6XhufEauKZTPb1NOXgeQH38pPHjo5qOg59YC1VsyBQjuoiCQYjpGTG6CIzQqT4GOHxOtwc5EORTQim6TaeeUkwjAjS+6VjDYpBk/v7zDA6xkuvR4qpJeVHnNldOo3dDwqyKcGcr3UjFKVStJiBIqJv5DHpYPVQI+rukEjD1BKU0sGCHKS+5JDiE5JTzdkidAonXaNoKz7Drf7Pdwle5mRKbaZzWwy00yaScZknEwaYZZZodSSebfEsl+OWwckCq31RrjiRjzCZjldF3SWXPv3/vWTkF17DgywwgLlWKldHKVNMCxqwbp4xpwP1XAtNhkVQKt8peo0iKVTjaCJxNleByMMGETIGKuC3NpJJqllRUIwES6pPVcUTfcbhjofN3RuKuUtqTcKDVUaqukxQyGhnTec2dMNEE4oQhpxj2ZVQJ0czJXQ2pezvr7g97amzGlqaYil2rbpWWSZObeAlg4jloSUVNIaBPd4ch0gGjCEkKPmFPTqgX6JC61ndIce0K/hGDysT1L14FkOwdVFssdKBrnTgbGgqziWKcU4H2AOY75O0rZmHEfEvoNH1MTBIq0HiYZtMyGjQdBWkfWTNMC8EpxRlDIOqaPhvJz3I+SCjeCtjlbNI7rR1arWIRs6iEl69SMn69lIJTM0aEWeoKyeJMzl4Tq7wqf3G/XXL/qH7eHyDjfrHqTrl/EKhjQG35QGTRISVJW+79PXLn3fJff9Wke2yk9z7eCitvdQo6FBg5YsyhwJycM8g8fTaIDV+ob2cY+bL7VE8HTwrIogPgdXgIyohDJcQVB1SVyUtQhrPiql+lJlg9SGktGSUEn+XV6krjALGCoKljJEF5EhyqMjageVwVXahTVwPapJyJC0oGKiZ/WM7j3eKCJiaUpDXEA713lCvMvr7DyfeLeo+ZTHZU7XyuPuLg6Vt7LgHqHj5ig1R7BRCqlBMvKVSpNU2vF7C8HT8/PhUQhyyQhCkwkSUVnhBG3GDz1TFfDTnQMqIAt8eG2zfsdhhzvNqPEdvJ03osZ7yrJXq8BXrbDRG06UiehQxifDqojHSzGCl4SnNKNJh1XArJ7MBRK0X82eUFXBJsjjiqlafhWrZWQOZIM6/tBDoox0UUz9bAyqgaTY4/G4DfSx8F/GQHsIvvsEbq7CbgVokPxoT3u3IJMXnWUuz+f1QLLoHwqyRs6SyjipjMVw6qFe8hOuZaFdBtqlr4uIGlImN+h3t2TaC2r6LHtDdoJnqAJ+BoqQMCHnGBwutf8qa2Zw9AMrRttomddrB8zjVl/5eOMLlC5ljAhhN7D3bgOMEsJNi1IHQHlSeZRHi2EYD2tdXdRWVq84F/yAleHWIh43TVaH5JGdJV7NUD0hrjqtqdyqcSa41ovDiMWqkVJ6oHb1CV5gD9ebY9wwfzrv+O5ljn+q4dvnvNp8x+AoD6cHeQy0xGtBV4+SaxdHgcfhyHH1+GqYVDEkkkgDQ4OMCUzcaZ+oAXHikH72uFbn89wAIy1L3eFCe3HyQjhOSeG9eJ8rxmxYRTWqMgVhpLFHWWv/BSWpkhHNUwyWpjalpAeYtZM5p8h3qf+2jJMaqhpzwOGY5WjxUeOCXmroSEcm4aj3bAShS1c/J5XM5ai0QFDQz2iJo0Aw608i1fFwnT3C7ofP1h9+/awc+Ksv+d5r3irvKL5V3ipfNXeax/wjJLoOUuAoKckpGFAywFOqp4zXNQhxlPRIpEGLTQgJkIviRTUpUrI8vu/zPQfcMLV1oCQPMKjCCUpKrPoy6JVU2sR+xAtWMowD0cAmiQVBqYMYxirNPMFKRiYNU9D14BZPJkR4nNOoTiqja0qhXm445PVtHOSphterin0I0wzbXlUrrhR9PIF2ZNuTYsmwkkquAxXoPbnwttvBdfYx/teBC/ScNy7q0T/8X/6/pnv0tuQ63ur+KT/tr5E3sEXOpiHTZIwRtLMmaOg4GWOSyJgktEgZw9KkZEBf10hIaMs0hTi8DFxGo/hGzOznqQesZHvtvpIujlIMyjH6dEVpDwZRG2XY1R5Z/hJGGjVsOjeVan18Uk1UGg1AQUMtic3Je9SM4r8rgdK+VjstZTh5N1wQGM5luPhhqIg/pOhHBYW4dUg3MGPC91DcjKj5iG7Q/LOkijpT0CsMjd6Tv9a7HVxv7uKGLvAz23n7Rz/hP/hvv+xvfuWb5VrelrzJf595c7nXzco9/h5zUPbJss7Sk3UptaSgj5O8Vm1Q9Qzo4FDOta8JSw01V0vLv4BC8CUVV+VA7tfVmcImCHM6YEk8rSLHiY2TpLFVJMORxhTLKo6BFpIE6pV6iq8To0xpkWJxUvbRrH8yKL3AelXxikKJC94qDsaXI8Pww6m4kV1usnFt6pBlMrr6ILTiiAJHiopXHVbwKJYkyo77gcH2nlp4q5g018sJbvjI59BPfD9v/eH36vv/yQfKT77qIjkvu4ALGGc7F8vVfkkXWJZlljhGnxVychdUW3PKYIxSas887G/TgTmfVDLt6Jy+gAzwhqiWZU6U5CsF+XQiTbempSwaZVtRUohGnWWte5N1OFZhWQvKMP0vgki1TrmWVBEho0WCwZP3ZpjoL51cWtCVURgmbiESL0Gnb3S75jdaUFiJRSobVokNK2WNhuwi7UoilcGNPD6CDVIWKD63tAdPQ3jTcN2vs69HSuDPLPbPNun3Xf1V/eo77ubm1yZkl47plk0WNNOxGE1UFJP6KOLpY4tTRN2KPyQP6hKiVtdY4wVkgOGYpz83TfOoo5hu0GJNB7IsXo2DjvRRE7xghfsNKUSGZc3xYWlo3EdRjAhjx14qDTUopfruZl7WX+IzJ3GX3KAKwVURUmpc1xUtS0dUGkZnT6hHr+Ooeexp14TPDaF4VLOwurUycsFTHCVOyv4O3ZQ/8rRd9d0xUb7OOHa7Q7z/TuBOg+EKfmnLAX3050oZ/NuurhTgE9ABat4nJOthf45fUMzVQvpd4MtSeyHnYYIXCBA9Ssu6qVTco07zoBUjyof8HI/Qo4mlaYIkx4ZCJIa35ag7XE2POR3EvqpE7XyjzcgmKSi6D/O7+UniF/3IsEFEoj593NlWlpRl0AYc9pvNyFzH6DKcYRenqogr6TOMGVbBVPqtozqBiiFRE1S18i1sK57+61/1a8OEnefi7C5+e75g/eC0bKYl095IKpakN8NZP7PCZ35uhc/84jJ/e4Mh+biVpoC4avBaGZgXkgESaVmo+gdz7SqotjDcygI/7+/lv/lHuV9X8ECbhLakJFEloURkxQ9keMMcJYNaQNLEtVRN2uopyemvmuEM4d+RA5qOIycuvKDEU0j0en7jwOfIEuohAeHr9gXLSEvO1AabUw61YzbMBAcvnpJFycqyeDkXl8/cra0m7LZ6QDp0Nl8mV7DdnBkVZtWsc2RTYDa/pgXXJI5yJqMVCamKqjNK+kIzwPqlv7zuT4ijkIaZ1DEsBY7P6Sy/7R/kN/19vNc/yl06zxz9OJzpWQv4WCR3FpTVjtqIAIIwJhOIeDxu/SQZxQg+95rXwbJQpTRxP2/c5hSWVFfKAZGUKhvZ2kMOow43fjJcnuPEDy15qDJd7y9JSOPIlS/+Oz/teBYOEbRkMPa6V1zA+RNnxCc1SR1ZGoz05WWMWu1p2URKVqUq0g7Sci+kHPAmB8guXvvBw3rT3YfKu67cnrysbMqETTUlFXBaclDXeJRVbuQQ45IxIw2mNdUj0ifDikcptaTUInpACYKTGB1jSrt04lDP38UornSsfVEPD8VJsRyliYnkV1MbUe31Ku2XjUsKNyzJho1UMleF+ThMUEMyMSfMaKKqFFoOLNY/kxjbiAGiWkycf/4W117YxKeWP+XBpG0mGmEmYCnyDYvxbbKDNRalxzoixjrV5KkOHj3bHlDhOrOHG/KE5q/kfl2O5V/mSHEnK+44znsMCS1JGYuTvTklR3Wde3WBdc0xUZa9EiSXOCgTMMBUJmSCDit4zMLJM4plUMn4SjS0SsTH14qnG3u/9aoE1ainp8NFnzLaqtMaqnE151Dw6oYhOP51U9qqUuJxgxHNymf0UA8p2YN/8aGb7AMnDpFIajyD4470SHj/2dDWliw7x5xNSxrVxj3r0eQFGIIDUr/IJ2/0uP8i0ky3yK5iwT3EvuKzLLiH6frVsAlSMlIymjQYk0btSwwJTgsqHDA04FISyWhoI6jLnyQVK84srysF6r0YMbjYD/YIufOBE1hRw8TUsxWjGnlDR2A3eMtR4W83QsdnZMVNtdUzIaOgQHEFz8pxk1OQl3HtX36s/7EP/HnvTxoWnRPDL5zgLzohfam4nM3JM5qbaJlWHKlSm+LTx00dPv9hmCF96HpzOnv++WFduLKr6697nX1rfp/emcy5Q6xwELDSMNM0ZUKbZpKEFhInHIw0CTIfJUYaCBYbv7eiaHmY9TzZLr7vgsOIEa+Ci2Qur0LpfE0mkFput2Jsa73LqGLEjgyJDiXPIuJXjni92vtJre9Lqg2clAC9UdXeZ9IBAtzL/9sReMdM+t0v18LNLrrPHw/vfYOH602YtelP77BNpmUbwn5Ql3iy5AWHA442QfewOz+Hf/j3D/n7PzOhY5f9bPJL+RflluRmfyuiAwZ+Xlf1QPB0YrBk8RY7Cl+S0MLGnWhxppZxO0npeqiWPTnppYpSxGHPavcQRRzUrguO6BGHo5ahqRE9nGqtYzMc8KmXbcfOSKluw067esdfhGwyaeHp4cT1Qq1yncDuZ6UWUWC2+Mi9Q5im2mx5Q/SAbvy0KybZfMdWkdIq4o1Rbb5Aq+AKCrje7OdPTpzFxW+9T+/88n93/2/2PVzt/13yS3qReSWZbGJMNtNmMxltvBYM/Kp2/SIFa5RxG0+bSRq0SCQjkzRO8tv85AkSdqDqS+LmIYB+3PhRqkYdlVGWzrDQiMNSojokToTe9UgRItW2zNGcz9cDniGPFTJJA7apmvPsHjrEaSvPt1FyrMnk5K6/t52djenYpBRxuPaTFR56Hhjg0Aj38qdHX8FZb3rYP/RnP+/+bbJP99pflh8qf4p/5M+3V9Gy06Q0yRinyZQ02UrGDIaEga6xzjxTnEZbJyhYBzLA+r87dt0QOx9LHYfLw7BnWL3Vj+tkfKl4Xy2jqUY2q0Xbtt6t5kbk0ivjjItrhtN2Msz5wjyLH3axxWDVkNPHQ5/n5LjBf6OQLyKssaaDLzq3y5wZNjBRYtDBC9gDbjTCO3jvque2/0+i9gd/o/ivD/9j98vpMQ4k1+qb9Fp9h57H1UzLVpoyHuca0lj9Gnq6wmN6u8zodjk3eZkMzIBYyJ7kB23n4ErFC5EIkWuoyEvRkWVa+vXaL8LIJqZhUbKBrForpPoaF6w6rFWfuSqmCkps7b1nhef8uCYJbcP+5//FZ//Q3rh2M5YkVdWDCWZPFB7yL7Qc8BsyNzyYeT7yvh/h+k9+UL/4U3+kv//jYzSu2C67aLPZj7EVkYwea95o35f0KckFrOQ6MF+Rz3BJfjZ93wmqRSeZhGckXYfrgJsUMah6ehoW0+SlQ32cS9G4fEZkg+7fqNfTKPTIhvmRiqyqI2/sh3OcQi06F3BH21d9irTLKAw6oh2jT6VSPoPp37xLbro0KczrMtoPQfLzJ/h058lsQn8eGmB9vxxcZ9/LDavAbyv6n7fw5tcf04N/oezfbsl8ok0xJElVlxrSCPMan7PKn5W/pykpk7T1ZDntK/TWZ3R8FWRn2ASi0sfhBfplGdH/4Xio14r7JyN61cOB+povGDmKGkOxQ0f6wIzoLccXFEOpDtR1n/xlrGZ0d7uNJfSTnt1VgEf45Jwob9vM2888xrFjcFfxDfLFF7QBPo65cVUiSAF8dpq3zBvMDqV0iKal9j6jlJ8DuVBINoGcJcLlBqMwwAmk2ngC7/l257m18FpiNQOl3ueR+yDf41URM7LIrwrHWgHPpt7gVOGA1VjmMDccacPJqMx63MiJENjiT9oADex29113X3bZp37qFdrxW7e57Qtn8Mp7Izn1qcA6osAxPnrw6yvlF3QO+M2euruilOjbGopPYzvLR/X1L6zyhd9Y5aZ3rfDZ7xGSH0Mlro4xMZT5kw7B8GtekbxaGmNE6FNSxmUvhWrd861kGHw9smlGVreGbUReR5SxRsQf62F0CVI5o3IgEnvMZUhdO0/G8wn4cfvWd7xq9z//6mWrF97+GvdtH23aydselS9+bbN5+z8eqXSfQqWMeaY93/PBAEc+9EEVEQlKn5Xeu5kMTI23t+E6u87RyQnZxIw5XYdQsDcn/zkVxS95PEaMavCjIBan0I+27EcG0RnZLFnJ2w6Vp3TD8pdKI9DXlBqpg/GoqEjYkekwpE+wE3K9EXa7lnn9j231p73/jy7/1xff+tv/vbztP767/I3N/8xtteedm9D4gy287Verou8p3BP/TPenn08GCOQS1qw04iCTicsEbyqhdMJuV9IZP1PO4iw5Xyuw12BPck3j9dEUXNdLUeu25FGSrFDPQAvUDJVRh6oNZoNrcBU5YUSwnHpAPQgTSbU82/sNjkVxlFpQUCBPoIIP9+kGf87M289U737/d1/58/6Hf+l1xdieprn3Y/Pmnu4hmWJTkUDhxf/bad5yxdNghLyEDHDKWiRp0hjpToU7f37drW+2z53exsWTZyo0KiKAfSLiPuC7QSojKKr0Y+e2VA2bic1we5PfKIs+PKVqHFNlIybIMDWQWJhQTchVIrA1Q9BjIzvnG3m6rycoXGMEeGxp+ftelb16/NriFeWRf9u1d//lMh+65QEeyB+jryvWaalCKmB+nBFu5vP5SJ4fp7FuLdaOM8M8xwPiJr5ZBwED+HzzGd+6SV+2fqm+76YxRAr16htPLNbrSigAjBJHtJ1KDR4P99YNZ39H9Z9rySwZcgGHBYvU28TDj9WQtFbK6goUUkpJgYPiGzgDL9xQITzmcZsksNiLTkvP1o8deIi9g4MMUs+jjcMsFbN0dQ1HKYJRK3p5+K2b/CkDPKnjuG3ySrtFdvCYPhDKC/XNAA0E8BDS5T1ffkReba5xYzKmHZ3PDCc7MVMNp5t1p0GK12DCimtR3IgYeaKBpJqPFBCjWzGH+jQjEm4yXD3rGVmyVkMvUVdQlFz7lDpANrJhBOL6OX/GeXBGD7549PHVQUNs/4HBfrrF5xiwRt4vWGGJNb8UDdAxyS6WdZ/yAjmeJwbo0lSa2YxM1fmZoJEG1HMKMsXWT39m9pYD9zN3ViHrOM2PWRofDTfv5J50T7HqNfSCw0xJSSFhGNNiGajjuK7igS1MYkkoqvyt7v1SFyejHZFqYKlS9JJabWoIy6gqpVSD9jbmgNtM6OhcfWXLb/7d8+Wsq5eYG6zz9k9P6NQvHuS9x2BdwoSMueuo2yc9v4KJxN4BfQrNWeUYO7hShUwK+rdXofv57gWf8xwh3FJvm4jdbmYwkkkUT0yHjObrZYWblsezie84Knt/v6fr/9XSeuMinzw8UrWdzGTcErggEiSGIo5lZ6QsaY8P+vv4pN/Lp/yDfFofoG8KrBkWG14rlSypV3nVhAStFgT6oeI/I5VwzAsD60cRbPSAu8ud49ds2Wq2feQ97/jV1936z/979ib5rkkj2d9fkxPvCTnhuR6QlPZHCtYfW9Tj2YI/ni/pCb/q53SdBT2XNxQ7uCKb5WtrDewfPpEH86VsgNGldJO2tJNtdhJRQxjJTFIe18Y7nn/8gY7e/HMrfPYXFvn4A08UdPWYNUdRU6T6FCEjNJbb3SGO+zVShAYJR/0K97hDWJLa4NBKpsMM1zlU45k1g0Zrsce6lNHhhh0neSTZhhBsBH9sfe2t37n5Lad/9+Db+u/7i3v0IXPUpRSlqr92C187L25Ltwt8eC3R9EdKyuMFZRNsskkusBfxXTaTycb9fKgrmvz4IjcdjnMyp3LAk5PPnWy0syzd3Jwk7bfwdJB6B+0lunHks6rsrvUnD5RWjF+zXGqJqoqKUqjDGcjFs0ifJmno/6onVcOC71Da0AzUWuVv2NutvVzNHxxZAxGFjzbocgj0dV28lkgMwV5hjPa2PUuH/I9+7I9lvzwos3JQCp+rkTQpdH1y+HmvNXPc8MVp/c7XCP56J/6aVQ5NLbF/radrtzY0+60VPvfVCrY5lQOerA/UVrMx4dLTdm7S5tKkdFhDYxGyUbbiBj98qm96Euhqf8kzwKuPQzieQhypWKZosKhdskg26GjOTDKONYZiRPN5CEBLPVuiG3UIQ+KnVR/FVM4TVUcuvbCrTkfV79tfeNjdb/abPamoLZzm2pSZZp/1x1bYvzd2JWo+3zI3HAB+Er2mCUuT29neWeTWTu9Zap+9CHNAm41vm7LbL572TRoYmyBh2/TTOjFmyDqeAaq5xE1FDLzDK1ydnMkm06LnB/Q1Z3sywxXpWahI2K4kkJLQlIzMJLXG8igGGJ5nq5WHjMt0N3yMkgHVgGY4rkrnufEuEf1XpeZ4dY2MieaAlSVV93OwZz2yXnTkITSBeHBTH+6dDYyV6+yzYHzydA9RPccecE+cX0xatqm6Y3KSaSZYDJ/T8jSLJjlk1VPmIpoK4h1ecg0bJjebSb6veSXH/TpWLNvMNImk5HgaKiSkHDdLLLlVjEmZYIpxnaQbeNUYEYwxde6nI+MeWg81iRYM0A1NkHGF6+yS3/0fN/MdfwtcU+hq37H+0WVuO/BNlgD6SOOXxxE8noV8/UUWgkOkcv7II8elXUzotGzB+dw/gT7vSRw3VH2KnscNVDSrBHQLPIkkqMC4aXJpMgMSNooXAi2X0KHgw6u3sJQvMmj2yUVJTcpZ5jReYa7EmqQGpmF0r51ukGgTjAxYUccAS2JH6FMKsMAn7gTuZAO9alb+D/nuc4H36YvIAHd7BaY4Z+8Dy4cX/q+1v9g8Z4701ZFa9Mujsr9Px0VLkB7oAPxE9bcFHisWNZBWGoQCmUlJVOhKzl+v3cy3nbOTd77qWu69cZU/XrmZBTfLPeVXWUxWeHP2Vkxs6fl6yc7IaFK1qV2Egk5U/0/XYLe7ip9uL9HbAsU2TYpWQpqnxq5dOnb5kfcv/cpKeLWbKq6ff46M7oUiUPnkxIxWuGFp2rzxn77PvecPWtKYMFLePNDBrz/dVPB1bK+Bdp2WGJOoVyddzcPAuwipWBJJERPEizJp8IHel7hIp/iXP/vtsAse+Gifpm2SuIxxDIfLQ+wxD3B58gqc5qESriKWmJG0qd5/bBDxBn5sSq/96QfZ+5oCt92jbco0yhHb4pH8yGxTrnmoZRufPMe+7K/vHPznR58i6fRpLRtfRJ2QgPEt+8++92y+85Y11a0LfPauZ+aJ29bzrHc9ngSLkpNrSSIJJR5jLAkWi2BNQlcHHOot8kMXXcviX8EDD65wiz+Aq+RCxJJpxmNuPxeYS4Lya6XiIFJr3BA7I1EMU1CvRtKfTKXNLnsGZ7GLixtnubNaOxHN6WRFsq83d/p9q/efvr888vr7y73/Zsq+9X9elJ3xH+/o/fHhWGzoSz0EP51PgsL15rEALxx4Zl4/JPOeN695VQSLqrKuXZzxlOKjbFAQUTMqrLkB1hruOHSUL7sllljncHmMNe3iapkPQ5+cAQUZjTjAPtyjJCMfRaJIUairTTFlNnOWPVe2+DFpyKS0ZIKLWtu4bMcuv6mV0sf7+ztz+v5Hbpv4i5X3/cJXBvt+8CzzD37lgL/hT0cQjBdM35dvuAH+eVMV3RSZuNdLxPie5gt7nYU9mnDa987IORc2TNsNtGd2ppu5qLGLXB0iQbew0q5ec32+1LuPQ8UCJ1hg3i+ypGv0tT/c3qSephnn4uxSjFgecXvp+XWspPR1mY4/MeIJo8aCJCRY41XNrDshh/xR2V8e52u9o9zfneOr87NyfLkvm5vj5pJXbDJvvOJi/z36xnLh6GDyLr37e2fk/O1d9n/0+UOne25wwGfiyfPfbG716XsDv+bERS9l6FKSaxG2r3tP35f01bFOwVg2xuZkhiW/zoJbYsEv0tUOJQVo2EfkUabNTFhCHTcNDXfExRxQ6hV3KpgYOkUFQ9O0mDKbmDLjbErGmTETJFjmej3u2tPlvg8X5DaX8z47nb7nd3/R/UzyE/mA7Ge32+/94yBffZ15hiASeSZwv6fTA77Ajq0WDviMXW+aMKdd3ZJJ5zQ3hXp6GpbUjEmLhITclRR4DJZEU+4dPBQ9l6l1NgyCo8RKwquya2nJGB54qLyPnl8jkYxc11j3x4cMn0hICGwci5WUhETCWlVDSkbLjNM0TabNOFPpGGalxczxlMabncj3e77t6CvM8l3j+V3my98yqeebDh/628q7P98Ljpe4AZ5t4IBPOPO1Y7Ll29tms3MUJiWhbSY4Xq5yxC1QimeMFkYTuj5nWiaxknDYz1GKw6nHqaMUR9O0eHV6LafZMwPNXiyPlA/QcSskktLX1WCAYjbKpUsQmjOSYLFiJQ3aX5LRNGOkJiOVAANJy+KWM7KbLL4H/bsd6b6dZq992B11h96w2b7yljX9633PoBHyEuADPpslnKyGhdomqtVL2LEm0NUB9xeHOGqWuMicxSQT9Cm4KnsFZ6Tn8JB/jLliHlVlk9nKhdnLGJcpBr7AGIuIjfMgjHRC2KCSH0Nw4M2ox4sLouU4Btqjr326vsuSpFgRSu8oWgOOHWjh/oUys7PF1Cu9XHD3t/CY2UfXLf7WdVz3LbvDHjl5oRUlLzkDFFgKdCgfVbIcXj1GDFYsIoYV3+V2fz/nmNM5x5xFKY7NTPEaexV5vYIrQDcFBYkJ+jGoqQ0wEKFNPZiuIyptw/FNF9cZOi1xDLRk1a9IoikYKMXRI2fNd0lTSzdRLr90O9/zq2fwvh/wdvP8GUXfrF/5ed/5YeDPnwcY4Qt1KOnZOCpKFkveD/BxYs1VCgb1bjrFaMjRHvFHudfvwykMvKPrBjgcTkoKyaP8rlWP0UofRkap+9XUnNYKvXF1Q9xcicOp0zApl5NTsOpXdUmXWPYrLPolTrgFDvgTHCzmmM0W+MStX2Xtb0q+9dKz8JrSkraWUv5CwAZ3e06F4Od7CLbrJQMchQRNPxcp8kmt51xJb6RkHPdz9DTnUnMxiSRhxasarTodguB0WOxWSv5alSoVkTXOhnh1YrSS8vB4ckqtpumCP1jx8+qlkFI8PfoYMSSSYUQ40Z/njz56C61mSo8l26CpXdZfuY3bL5uFe19odKyXoAG6xVLyID8UJ+Kc+mqb6obAoJGuv6wr7NV9XGouxUm1gtrU5FQT1a8SYyMxIbTdJFL1gxH60aRQg/peWKQKOdXGmyBsnuK1oK89GjIWVjtoIE9oWvK+/Z9joOukRik0KQ1JNqB8A3BvJOz653v1+xI0wEDJsiTLXstCcYmRzHucuNjRCKuqzAaFUw+kpMy5BfZxgHPlXErKoDGIEBofBhElEbAjWY1EzxZ3vtTsmGqFdC3lVkv4+pgXNnAUDOhhWYkaOCGWOzwFPQrCcJNoE8EC/W95mjabP6uFzEvIAG+ImqXNFY/rgp+yGFzcHBwKhqBkGnnN0RA1SutmHHIHmDRTbDXbGWiJmOHAuQgYARtpjGEjkx1Z2WWkXnEoiGq1m9MT9Gp8tRxGnJRYAjQjOqBPB8FqUOsKKYNSSsmAhIakOkGf1bMZyrQ971gvp4qQeIwxuaaUq17KSnwhbDkf1YSR4fr60UuUYHnMPUapOYkYMQKJERIRrCjWRAOM9CsjST2uiXhFvOpQwEi0UkrQEIoDHFNQaq65DjSnR649BvR0EP+c06PQASWllporeGmwCcFPXx9UFZRnYfXDKQN8kse1XNcDWXe+iGIFXlzcyC4bdgB/fTSyktH1HY64IzRMQmqQTJDUBPq2VUglHbms1X4TENWRXWBDYFDxwRRVKzxQHaWU9KTQnhYMcDqg1C65dii1T0k/GuEANMPQQMF+nmvNS6kX/IKEAd/HdV5V1lxcp6CqYbWC8HWgsdbbzqu5YI/BMKuzaFKSWYMxBA8Ytzgk9V5Z6tU6o7uOh/lhLdkrojFV1FAley0qQ8RRxK985HuO10JKHUiDrRgSoCyv5dpTMMyzjytfZ76xznKVjF+ikZJfrWvQMb59wQevpwqaazGitiEbZThGHKGiWCw9P2CxnGdXtoPcFIgaUk0YT6CVNHBROdiQUq3DrsUtR1SoNypDigRjrZS/GpW0UYXw6FBrMGSoDseE7GJZH0Zh9YYgYvKC6oYkL3hU5Qkg/1fx39PD3Jyt8Wg/7CE2dWXJ45QMdNRraYSqa9nekmPlMS5onsa4aZArHM/n+HJ/Pw/1HyKTDK/lkIyKwUqz3vckJBgSrGQk0sBKRugHJySmTUGHE4N74/MQlyFWa8JqvEaxtJnS0/WY3IrR7BBP3wjDKQM8GahgjDdvS+C1nv6komMeaQuMC3ZMYErx4wYzATLm0bGH+csJI3Y80cYWx8CrqBWtxpPChqRKfk1q7T8dGmWsjK1aelqy5OfZu/YID5b7OZrP0XWrJCRxyMmDenYmr0Qkw8TtToKJFXcF90hNVFWUVFss+n14CixpgGZCKS1VCikIJX02yWU0dYt2dY6E1pefP6r7LxEDtMgkuL9pyxZSGY831WJIQ1+3XvsVmCeiBG1AsVgy77XESBJUS2M/uAZfdHSaraqKDbn2WWOZo4PD3NP7ImvlMlYyMjLaphUaexrkjlSgxXQwavVULjRo3wSVLqe+Bq1BybWUNXdYR7FI+bqSyFCQc4F+J6uyz+a6rtOc8dmlWkHhplMG+AwfHq43q9zwyBjXfGjKnPddW+0FRUnffh1lOyLBWqmEK6h442OeZjWJWy01gtFaa0hXhcJAB6z5FVZ1hY6uUGhRcwIn7aaA5PmCUNhEANv7CLEECpdXHzVpqrrPkdKilaZRK0YQQQpdp89yGBkIlspI7Ry2vWtfpjiXXVxZ3si/TBKS2/4RF331hheQJMeLIAcMLSfFf2BZH/veabarx9vqbg03Wfo6x6v7YD6wYCRur6zAXZGsNtzCD1jVNVb8Iit+kTwuDAokrgSnIYsM670cwfcmWAkhuGkyJpIWY0mDyfg1k7WYGWsy3swYn0zY1d7Cnfcf5LcPf5pxG5bydHUJrzlGknrv5siYHahhQI838k84Il+SJT0g42x+9w3c4IOm9k2nDJBnaQ1p+ACtj/T83FzHz28ZM9u8D2K7TJgW4kqSwjAmYzTtGNYmgCexYG1I7lPbYs0XNKSBQehqj1W/RF+DdhYoM3ZzLB4MRlKsJGSScX56Pk3GaCYJU1nKdJIy0UwYbyZsnkyZmU4Ym7C0xqE5BmY7sBOYAi4GPg5//IUvozJcYLOuc0MmfKx6Jf6P0YR15nm5vJOdnOPex39KmjJ285xe+TdwpYEbSk7BMM9mBXydXWX34jiv+8iSP/yT47LdGUzSFc9rZBf/7vTX484VxsZbiE3oL8PqUs5Kv2R20OdIb5U51+Vouca69lEVzbQpW8xOrCRRKF1HN2fG0GtwIuwwu9gmMzgLqQR6ed6HldzTW4PZY0oiJYkobWC8AdOFMnY5tH8m444/PcRNnT2MpykgDPyK9v0SRhLRobhq2J+sRnssyulyNa/lp/xH+GUZ6HI+xvZ/8kIRJH/R9oJTWn/a8cd+omMW7JjZQlscn8/38IC5jNe89TwpDpTau63g0HzBkbLHibLLnO+y4Nfpa0GJV8GIx0tmkpqn4tWNqJ9KXWB4LE49R4vjTGbjOO/VOZEkws6JBzFD2EaMUAh0S8GsKWOXKOZu2P3IvZRJTywtQFnzR1TJgVQj8Bf7x0YHrMpmuYxv51+6G/kNPa570jGm/tEJ3ndfIKLe4HiJTcU9D47dDjBL3PhFpbx10e+3gFPvUQv/6dCt9G7MYcGwdq+yug5lDolaGmJpm6a2pKGh8Z+oGYqmqWDViFUjiYox0e8ZjNgIppiaxiBG8CLqNNSzASRGnYYvr2guQWw43wbjW1Lu+cgyny8eZkJaiiRaas66zoZCSDXAOKFs0ZJ1tnEFl/Ou4gv8h+Sg3p62mfmlOT76P16ILOgXWSvuGgOilrE/6OgsK/4wiDBOxtfkEL93y82kuSF5dfiwxlZT40aHE2pEFnTcjE7chVPNi9TLBqXumFTo4OgquLCwWrWM6oBl/CqAUqDbF8Yv9gy+Bn/45bvosBoAHhVW9YgW2ouzyZWwUWDbzMglOi7b3Z38p2xeH1xsM/Pj83z4d17oxvciMcCbHCBNzvigqH903j2UOC29wzOO4U/cbdxyx0G2b8/wDU9e1msEK58W5TQq3EbrIV6pSKcY3bjZMvSJ0+gNNzTYghFSKJQKhUKhQt+BtDzbtyZ86rZFbi/uY9w04/bGghV3ONAWFNBQazt6iEKfZXuQW5KctY9NsfM1c3zoz18MxvdiISMoXGOP8YddQ/o7ufZkwT9Sg8eZTfTX527k0a922LUjY1CWuLCOWR63UxBVqSdCgsSGjEjzUu8Frnqyk8nEiOZLXHYNOIXCK7mHgYcclU5X2HGm5+hDhr96+HZyCXs+jaSs+qPkuh6LHh+lLlucx1vUkjHQxWOZTn7niv7t24/wlw+/WIzvRcSGCV5Qce8xYo4uuf22x5K30qRJwkE5xq8d/RRFN2PbppRuGdh3LhqSH9F7DkRSE6mjKl69KF4I45T1WlbBMm0nUROEh0RF8aI+LjJ0ntoL9gpotj1TacoHvnKMPeV9NKUJGJwvWXYHax3qSllhQrbzSvkRZ6RtDPzveT74CbgqrbZl8iI5zItm1INr7BKfWUH8vweV4+Ue9XERw4Q2uFMf5I9mb2M8HaORenqujB2KIb9ER3YL1luO4sSblyFH2qFM2HHGaYUyZIRHXDFpPOA08GB6AzjjNOWBw4bPLn0RzyASVg2r/hADXQneTwn9XwwXci1z3GPXOaFtTt8dvN65/oWgfP8S5QMGL7jsiz82JI8NdDk95u72lhQVoUWDT/Vv4RNLe8Ck9KSgVB8rWa0ZL1pNletwC00Fv4zqTZ6ZnoYYU2WTWqnlh/pE1PkQinsDlekZRz7I+NThhznsA1sGVEo/YNnvxyBoJAUaSRmTrVzKt7rH+JJVLb92Af/wjkC1f/F4vhcjITWay0190IUG46y4w6z5OQxZcBze8fHOTezLTwBCn1xKwpRbNduhIE6G8kJO3MgmuSBcuclOsTWZoRCnG8WItFoJH/YCezAWnRiz3HWwz5e7X4hrEsFIqiv+AIV2Qr6pGsWOPBfKt9IwpR5gDy0m/uwmXl/CNS9KGRXz4hQ/yO0mOZ2ENifc1+jpPABWDH0/4JbB7XR9Dw+U6vC+qoxVhssWwsimH65MB1WMWC5ung0mAjUy7Nh6D05VHCpeoXSQZF7mFhNuWbudheIoiSQIhoFfZ9kfqAkQgTOYYmnxLfw9vUc/kfZ1dXUbu/5ytPV4ygBfAJ7QI3KmXEgmY5S6xnF3N4pDsKSSsObWuKu4hyIyoR0hF/QjcEpcq1qzkgFyHC9rnM10MonDbZwlHtlhUy/5NIobNHhw7SgP9O+mIQ18HIBacA/htF+zY4JODZwplzMuk+5O/1lp0/ybvfzp0ZD/oS8U5fuXqgHGi3lNYmg3dtkdJIAhYaDrHHdfQ7BxV2/CklvkvuJrOLx4vGikTIX/XPw7rRkwAy04r3Ea5zZPY0ChRobW9viFSBVAbcWIo+BL3U8HYxOwJKz5o6z5o2FqLuZ+VhIcyuVcq7fpp+0aC+UUm36HF/nxIvSAgzQzjca5zc00aYMYLE3W3BGOu69ivMXjSElZcgs8VDwQtx9VPY24gOZxxndu8zSuaJ9LIUWYAQ79EY0WtGGg1oRpE2mRcHvvNo7nh0glATWUOmDBPRRn5SIOKQaPYyvnYHzT3e4/bBu0P3aA3V+Jmi/PVPjVUwb4tB8+Feln52+eZkq2i9EwGGQl8YvuIebcgySaoepJSJl3czxS7g3OTBCvXnwkjqoKfV9wSesMvmXsPEpx+Oqm6devDqoXtKqXlmQ8UuznK907aJpm8LySsuAfIde1+PoB6bFq8Sjn8Vru5EO2y3w+xuQN4SX3yCkP+II6XCbiGqe9ahNbZGfVrBVVSRKaOu8fYMHvw5DFcGxZcnM8Uuyh9C4mcp6BzxGB101dwNUT51EYr74qk4e7GDYI2QYM0EsqCat+jc+tfypyaBQrKWv+KCv+ADaSkAyC0SDzu00uoCQvH5XbbZPx3Ud5/z3P0IDRMy67+5KfC/Zq5czWZs5tnIZTJ+BXQG6z0rbTcrY/4b7Kkt9PQgvVYIQrboFHivsoNcfjOa05wfdtuYJLxk5nIMUwXAZBg8cJUIZg7FTFaKBhfWr9E6yWS9jY1it1wKzbMzLfEcXKoyrqFj1P9/DpRNWtWCai97tEnzm46pQBPhMXVt7Hv1pacUvH/vpjX9LSyCACK7027R8stPdgQiM53VziD7svsuwfxZKh6sRi6ek6D+Rf4cLJGX54x9VMJC26PkdUCLNDw73AQe85KL7U3Bj1tEj5QvfzHBg8TNOEUC8Ic24PpXbidFzQh05pYGmwWc5mSQ66JT1kEhrvmedvHg7e7wYPp4qQF9BxnXkn73Qt2r/1G/O/Lx/r/O92QiJGGr97lA8datF41wl9sNfSKS4x1+hj5RdY9A9jaWoAgi1OB3x86W+5ee0BMkkQNTjVry+2axmZ0KFT8TImmdzZu4d7urfRkgaeEisZC+5h1vwRbJTtsJJgw+5NWjKBqOGYPoglxeOOhFd/YY1XckqkHKJIt/R57Kstu/OOge8fSrC/taCf/BO4Ku3whYPjvGx2noPf+wp5SznFFnO//wwNadGWragEbG/gC+7qPEBfHec2zsaQ0PcuesBh0qcIpQSssE0mewf7+EznozRMGvO+jDV/jFl3HwlJBJstCRkpLRJJmeEM5vUgXV3wVhpWcZ8d8Ogtlaj6KQN8gWKCfT3wcM6Bz/bYFxc+H3NwTdLnb+9scd7MY+x57RvkumJadpl7/I1YnIyZLYKqGDGSkvBg71H250c4LT2NGTMhuTpc3IseFtqoeFXaksmR4ggfXfsABh9Wt5Iw8GscLe8MoZok6FCHCWISSdjCWRTqOar3kZB6wVgPnx+w7+ZTBvjCD8c27AZ5lcCeeCMPKFxncz7+iZQzL3qY+17xo/Zn8s261d6mnxLVAW2zFUuqHkfTNJgvF7m3/wAiKWeku8RipaBEFVFUWpLJbDnHB1Z2U/h+HIgPuN6R8g4cvaD1JwZLSkqThAZTZgczuksf0M9gsALiBbHgbhmw//OnDPBFEY5fFXOps01cQaewB1DzvfyHDz/IbVffqbde/FPmJ/KXmcvsLXozXX+cTFpkMomiJGLxWrK3/zCHi6NsSTaz2U6LU5XUpyzoAn+z8jd0ymUSk9Tl0GF3BwNdIpUmJoRdzWhJkwlSaXI+38oe/ZztMG+ajKsT50WM9fgvD9j/6VMG+MJvywns8cIBH2+kxmUuHpA97HY/xP/9/q9w+xVf4NZLfs78aH4VV5u/5fOy5o8CQlNmAgNQIBMr88Us9/f30pU+O7OdLJZL7F75Kzpuhcw0UFUMhqPuHnr+BKm0NATjVNJofCpwubyJo/ogj/DF9TE2z06ZnVPruuiMmAT07gH7P/FSMcAXqz6gWjFK8urXKS//xQne/K5NXHd6AHWvjyLe18t7+In+u/mtH+jq0l//qPvHjQaUf2D/s26xZzKveznqvsRAV8RKKiEkNzEot61+gb9YeA8fWv0gvXKNBItXhyXhhPsa6/4IqbSiOmBCQpOmjOON52V8G+oLdx83mzYz/8qIv/d0e5YI1gfpDsZ4erSeTxngc+T5zNt3vr3t9ZX/+/Lyqpvf2P6e35mSmf+BrN+7yXznu4ZD3Dd4wPwMV5cdPvdO0eK//oL/19n9cp/+mvk1fy6XscoJjpR3sOAeUSFVMHgtacsYq+Uy626JVBr1/Mlx91VW/EEyWlGILZWETJoyDmI4i8s4Tc9yn+cv0kx57xKf/gMr2dk7zSSWTMJSG53iJXS86HBAI/iPHZ/7128Zf/M7b/vd38n/57f/3/mFXJEnYjeh7k+38D1XjigJ+Gp72zqf/4UZxv7Z/1P8Jn9U/tfkB/nZ8tvkB8FYXSgf5FBxK2v+aNjlISZsVpewVsFoyqy7nxW/n4QERDSsvk7JaCMIWzmLK/Qa93H+JC3p3vZyXvtToO22HRu7bNPZZLQipE2bEVX/Uwb4gvJ+u923n3lNs6kTP/jLl/0j5z9gzIdvuyvpJv3EqB0oKo7eOxmKG9WtKeU6O8tH330Wp73xC/qZfb/HDdlZcpn/e/Iu35A2XT3B0fLLHCvvoe+XQIOwkWrJEX8HK/4glsbIuGdCShODpc0Mr+O7/Cf0D5MlPTZ7hl7ygzdxQx+2jzcnXOvK153LBJtEpQRoMaLqf8oAX2DHTQfm2m3M5PvvvdP+yuc+ILu7n2TBH6akEFHxikx/c6XVa5LH+OBNl/Omb13Tpff8b//ryX5/R3Iu3+YmZScJDTr+KIfdl5h1e+j7ZY65r7Duj2CxcVWDjb2OFEtCJhO8UX5IP6d/Kfv13mKK037wfv7gUJXuFYXLzurs8GfKWTicB01eLGTTl2QvGK5bdlI++oHeX+uNycfLR/1eFtwhBXWJjBul3Pt/MN8SrrNf4d/PrfCpd7W0/c69evPDe7klTZnRVCaxNBGEFb+fg+4WujqPpZJ1M7X3MySIZFwjP6Z3caO/13/BTrH5x47w3s/DNUmwjqsWjq8tPvY7N37UdJNlJz41BhOVTp/yDIiegmGeE/D5932Dc+ZLyf9BT1eTAV01YiWT6SxndV9J8Ys5B3oBlP7m7Ty4znb54H1n8qN/1mN2oi9Lr/JaeGLrTcQGAuHIIlYh7HRLCbrPr9J/oHv1Vn+nfiydZuafneCjfxI1/MpquLzFWQ9+Rb/65mU/v8mI3mFJfqHLvs43P78XX9X4Ykwr/DRv/HHg3yh6lpXMefWf9wx+cZWbHjl5JfmfTuEPi8289SJFH/SUvhogCq8gLgqbGlGJgbdJKi0u1u/Uefb5+/lUOqHT/9ccH/v3Q+PbKDV8IW/fsoI5bzONe/awO+cFuPf3lAF+Aw3p83lbY5HyXEd/sMItjz7xXWjXG7hBp3j9Ky3Jl0WslppHcFrEaCoqDlVfGIxNpUlKk228TFc4Lid4yLRk7Ffm/Ed/8xsY34YH5rna1cYpfcBnTrzyEXYPgAcexwR+ot0FLfAulURTmhT01UhqVfW44v4I9IdFkvO8Ou/xJIxzlAd1ncNFU6f+rzn96Luj8blvrndd7TvZ7V9Kxvci35S0O/Lrrzf1QpAnKWuhFIklNS2ZqjUSFPIlbvzVTLlClX8jCKX2dZmDrq8LSapjt8zz8XeHXO+m8u8wrGrfyUvK+F4Kq7o0djyeZE81DAQVlIklY0I3xelhABpt3rrzBJ/uDFj9H4k0y0SaxmuugQ3je8H4n3FA+Xk143HKAJ+ZI7UI4xEjjotmjBCmmHosbZ+WieRMuUB9mLOMhvGMU+rllAd8CRwl3WZTGpxmT1PIqvueNMjSMI60mu0amzHfNvNKVVoi+Cj6duo4ZYBPTyRvtiRjV7pDLU2CFqVPHWUarmDa3HzupH7nq69ijGkwqgLN8Ls3nPJ+pwzwqd5lb9t2gu2tSQwi4EE18ZSZeoD23IMPPyaHvrqm0zKRey8C8uhQw/qZVAN7fo1ZnjLAZ+YymXHbZIsdw5JGWXFJE7JGMNIH9uzrPvYn//rIf0xWZWEM9fOC+d1gv9f6U9fvlAE+VWdjmmnK5uk2DcbC3IcYY6ARXNGvmi63/qOBmfuRgV/5lZT0NUt8+r4Ygv2p0MtLDoh+mo5ZiS23tk1LNm2aoM2ErLKiaGm0Zq7sEUE8nv/1LHQ09JQHfMnlgK6RTArbLtikE0xjxKqKx1M2Hre93YauRw18nzpOecCnBYhJTRtOu3CarWzlKHsICjHSfrLb208dpzzgE4h3Y0V33ujkHbAtmcJ5h4gRQzI4dYVOGeAzeFzrVaHNjrvunrtffu+mW2QlWctLHRiPX7Mk94ef232q0j11PFPH9UYQxvj23xvnzbpdvl9n5G06Y17/L6hJsKeOUyX9M3yNBNEtXPtjBeblFnvrAjd+8KXG3Tt1nHp4T13El/a1qgaFtp2qeJ+m4/8PpDvt4UggQPkAAAAASUVORK5CYII="
local TripsTLogoAsset = "rbxassetid://10709790387" -- Fallback asset

pcall(function()
    if getcustomasset or getsynasset then
        local fileName = "TripsTLogo.png"
        if writefile and not (isfile and isfile(fileName)) then
            if crypt and crypt.base64decode then
                writefile(fileName, crypt.base64decode(TripsTLogoB64))
            elseif syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode then
                writefile(fileName, syn.crypt.base64.decode(TripsTLogoB64))
            elseif base64_decode then
                writefile(fileName, base64_decode(TripsTLogoB64))
            end
        end
        if isfile and isfile(fileName) then
            if getcustomasset then
                TripsTLogoAsset = getcustomasset(fileName)
            elseif getsynasset then
                TripsTLogoAsset = getsynasset(fileName)
            end
        end
    end
end)

local FloatingBtn = Instance.new("ImageButton")
FloatingBtn.Name = "TripsFloatingToggle"
FloatingBtn.Size = UDim2.new(0, 52, 0, 58)
FloatingBtn.AnchorPoint = Vector2.new(0.5, 0)
FloatingBtn.Position = UDim2.new(0.5, 0, 0, 18)
FloatingBtn.BackgroundTransparency = 1
FloatingBtn.BorderSizePixel = 0
FloatingBtn.AutoButtonColor = false
FloatingBtn.Image = TripsTLogoAsset
FloatingBtn.ScaleType = Enum.ScaleType.Fit
FloatingBtn.ZIndex = 500
FloatingBtn.Parent = ScreenGui

-- Ooze Drip Particle Container (Under Floating "T")
local OozeContainer = Instance.new("Frame")
OozeContainer.Name = "OozeContainer"
OozeContainer.Size = UDim2.new(1, 0, 1, 40)
OozeContainer.Position = UDim2.new(0, 0, 0, 0)
OozeContainer.BackgroundTransparency = 1
OozeContainer.BorderSizePixel = 0
OozeContainer.ClipsDescendants = false
OozeContainer.ZIndex = 498
OozeContainer.Parent = FloatingBtn

-- Dripping Ooze Droplet Emitter
local DripPoints = {
    { Pos = UDim2.new(0.48, 0, 0.94, 0), BaseSize = Vector2.new(4, 5.5), Fall = 26 }, -- Bottom arrow tip
    { Pos = UDim2.new(0.22, 0, 0.58, 0), BaseSize = Vector2.new(3, 4.5), Fall = 16 }, -- Left drip prong
    { Pos = UDim2.new(0.82, 0, 0.52, 0), BaseSize = Vector2.new(3, 4.5), Fall = 16 }, -- Right drip prong
    { Pos = UDim2.new(0.35, 0, 0.88, 0), BaseSize = Vector2.new(2.5, 4), Fall = 20 }  -- Lower left drip
}

local function SpawnOozeDrip()
    if not FloatingBtn or not FloatingBtn.Parent then return end
    
    local pt = DripPoints[math.random(1, #DripPoints)]
    local startX = pt.Pos.X.Scale + (math.random(-2, 2) / 100)
    local startY = pt.Pos.Y.Scale
    local baseW = pt.BaseSize.X
    local baseH = pt.BaseSize.Y
    local fallDist = pt.Fall + math.random(-3, 6)
    
    -- Droplet Frame with Pink & Purple Ooze Gradient
    local droplet = Instance.new("Frame")
    droplet.Name = "OozeDroplet"
    droplet.Size = UDim2.new(0, baseW * 0.4, 0, baseH * 0.4)
    droplet.Position = UDim2.new(startX, 0, startY, 0)
    droplet.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    droplet.BorderSizePixel = 0
    droplet.ZIndex = 499
    droplet.Parent = OozeContainer

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(1, 0)
    dropCorner.Parent = droplet

    local dropGrad = Instance.new("UIGradient")
    dropGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 45, 210)), -- Vibrant Pink
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(180, 50, 255)), -- Neon Purple
        ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 15, 175)) -- Deep Ooze Dark Purple
    })
    dropGrad.Rotation = 90
    dropGrad.Parent = droplet

    -- Phase 1: Swell & Hang at the tip
    local swellTime = 0.38 + (math.random(0, 15) / 100)
    local swellTween = TweenService:Create(droplet, TweenInfo.new(swellTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, baseW, 0, baseH * 1.2),
        Position = UDim2.new(startX, 0, startY + 0.02, 2)
    })
    swellTween:Play()
    
    swellTween.Completed:Connect(function()
        if not droplet or not droplet.Parent then return end
        
        -- Phase 2: Detach and fall down, stretching into teardrop
        local fallTime = 0.42 + (math.random(0, 12) / 100)
        local fallTween = TweenService:Create(droplet, TweenInfo.new(fallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(startX, 0, startY + 0.02, fallDist),
            Size = UDim2.new(0, baseW * 0.75, 0, baseH * 1.9)
        })
        fallTween:Play()
        
        fallTween.Completed:Connect(function()
            if not droplet or not droplet.Parent then return end
            
            -- Phase 3: Dissolve / Splash fadeout
            local fadeTween = TweenService:Create(droplet, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, baseW * 1.4, 0, baseH * 0.5),
                BackgroundTransparency = 1
            })
            fadeTween:Play()
            fadeTween.Completed:Connect(function()
                droplet:Destroy()
            end)
        end)
    end)
end

-- Continuous Dripping Ooze Loop
task.spawn(function()
    while true do
        task.wait(math.random(32, 68) / 100)
        if FloatingBtn and FloatingBtn.Parent then
            pcall(SpawnOozeDrip)
            if math.random(1, 3) == 1 then
                task.delay(0.12, function()
                    pcall(SpawnOozeDrip)
                end)
            end
        else
            break
        end
    end
end)

-- Subtle hover & press feedback
FloatingBtn.MouseEnter:Connect(function()
    TweenService:Create(FloatingBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 56, 0, 62)
    }):Play()
end)

FloatingBtn.MouseLeave:Connect(function()
    TweenService:Create(FloatingBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 52, 0, 58)
    }):Play()
end)

-- Draggable Floating Button (PC & Mobile Touch)
local dragFloat, dragFloatStart, floatStartPos, dragMoved
FloatingBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragFloat = true
        dragMoved = false
        dragFloatStart = input.Position
        floatStartPos = FloatingBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragFloat = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragFloat then
        local delta = input.Position - dragFloatStart
        if math.abs(delta.X) > 2 or math.abs(delta.Y) > 2 then
            dragMoved = true
        end
        FloatingBtn.Position = UDim2.new(
            floatStartPos.X.Scale,
            floatStartPos.X.Offset + delta.X,
            floatStartPos.Y.Scale,
            floatStartPos.Y.Offset + delta.Y
        )
    end
end)

-- =============================================================================
-- MAIN WINDOW FRAME (750 x 480)
-- =============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 480)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.CardBorder
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

-- =============================================================================
-- DUST PARTICLES ENGINE (BACKGROUND FX)
-- =============================================================================
local ParticleContainer = Instance.new("Frame")
ParticleContainer.Name = "TripsDustParticleContainer"
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.BorderSizePixel = 0
ParticleContainer.ClipsDescendants = true
ParticleContainer.ZIndex = 1
ParticleContainer.Parent = MainFrame

local dustParticles = {}
local DustParticlesActive = true

local function CreateDustParticle()
    local p = Instance.new("Frame")
    local sz = math.random(2, 4)
    p.Name = "Dust"
    p.Size = UDim2.new(0, sz, 0, sz)
    p.Position = UDim2.new(math.random(1, 99) / 100, 0, math.random(1, 99) / 100, 0)
    p.BackgroundColor3 = Color3.fromRGB(200, 245, 230)
    p.BackgroundTransparency = math.random(45, 80) / 100
    p.BorderSizePixel = 0
    p.ZIndex = 1
    p.Parent = ParticleContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = p

    local speedY = math.random(8, 22) / 1000
    local speedX = math.random(-8, 8) / 1000
    local swayFreq = math.random(15, 35) / 10
    local swayAmp = math.random(3, 8) / 1000
    local phase = math.random(0, 628) / 100

    return {
        Object = p,
        SpeedY = speedY,
        SpeedX = speedX,
        SwayFreq = swayFreq,
        SwayAmp = swayAmp,
        Phase = phase
    }
end

for i = 1, 30 do
    table.insert(dustParticles, CreateDustParticle())
end

local dustClock = 0
RunService.RenderStepped:Connect(function(dt)
    if DustParticlesActive and MainFrame.Visible then
        dustClock = dustClock + dt
        for _, p in ipairs(dustParticles) do
            local currentPos = p.Object.Position
            local newY = currentPos.Y.Scale - (p.SpeedY * dt * 2.5)
            local sway = math.sin(dustClock * p.SwayFreq + p.Phase) * p.SwayAmp * dt
            local newX = currentPos.X.Scale + (p.SpeedX * dt * 2.5) + sway

            if newY < -0.02 then
                newY = 1.02
                newX = math.random(1, 99) / 100
            end
            if newX < -0.02 then newX = 1.02 elseif newX > 1.02 then newX = -0.02 end

            p.Object.Position = UDim2.new(newX, 0, newY, 0)
        end
    end
end)

local function SetDustParticles(enabled, tintColor)
    DustParticlesActive = enabled
    ParticleContainer.Visible = enabled
    if tintColor then
        for _, p in ipairs(dustParticles) do
            p.Object.BackgroundColor3 = tintColor
        end
    end
end

-- =============================================================================
-- MATRIX BINARY RAIN ENGINE (GREEN 0 / 1 FALLING EFFECT)
-- =============================================================================
local MatrixContainer = Instance.new("Frame")
MatrixContainer.Name = "TripsMatrixContainer"
MatrixContainer.Size = UDim2.new(1, 0, 1, 0)
MatrixContainer.BackgroundTransparency = 1
MatrixContainer.BorderSizePixel = 0
MatrixContainer.ClipsDescendants = true
MatrixContainer.Visible = false
MatrixContainer.ZIndex = 1
MatrixContainer.Parent = MainFrame

local matrixColumns = {}
local MatrixRainActive = false

local function CreateMatrixColumn(colIndex, totalCols)
    local xPos = (colIndex - 0.5) / totalCols
    local streamLength = math.random(6, 11)
    local speed = math.random(20, 42) / 100
    local startY = - (math.random(0, 80) / 100)

    local labels = {}
    for j = 1, streamLength do
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Bit_" .. tostring(j)
        lbl.Size = UDim2.new(0, 14, 0, 14)
        lbl.Position = UDim2.new(xPos, -7, startY - ((j - 1) * 0.034), 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Code
        lbl.Text = math.random(0, 1) == 1 and "1" or "0"
        lbl.TextSize = 11
        lbl.ZIndex = 1
        
        -- Head of stream is luminous light-green, tail fades out
        if j == 1 then
            lbl.TextColor3 = Color3.fromRGB(190, 255, 190)
            lbl.TextTransparency = 0.1
        else
            local fade = (j / streamLength)
            lbl.TextColor3 = Color3.fromRGB(0, math.floor(255 - (fade * 130)), math.floor(80 - (fade * 40)))
            lbl.TextTransparency = 0.25 + (fade * 0.6)
        end
        
        lbl.Parent = MatrixContainer
        table.insert(labels, lbl)
    end

    return {
        Labels = labels,
        Length = streamLength,
        Speed = speed,
        HeadY = startY,
        X = xPos,
        CharChangeTimer = 0
    }
end

for i = 1, 32 do
    table.insert(matrixColumns, CreateMatrixColumn(i, 32))
end

RunService.RenderStepped:Connect(function(dt)
    if MatrixRainActive and MainFrame.Visible then
        for _, col in ipairs(matrixColumns) do
            col.HeadY = col.HeadY + (col.Speed * dt)
            col.CharChangeTimer = col.CharChangeTimer + dt

            local shouldMutate = col.CharChangeTimer >= 0.08
            if shouldMutate then
                col.CharChangeTimer = 0
            end

            for j, lbl in ipairs(col.Labels) do
                local bitY = col.HeadY - ((j - 1) * 0.034)
                lbl.Position = UDim2.new(col.X, -7, bitY, 0)
                if shouldMutate and math.random(1, 4) == 1 then
                    lbl.Text = math.random(0, 1) == 1 and "1" or "0"
                end
            end

            -- When stream falls past bottom, loop to top
            if col.HeadY - (col.Length * 0.034) > 1.05 then
                col.HeadY = - (math.random(5, 30) / 100)
                col.Speed = math.random(20, 42) / 100
                for j, lbl in ipairs(col.Labels) do
                    lbl.Text = math.random(0, 1) == 1 and "1" or "0"
                end
            end
        end
    end
end)

local function SetMatrixRain(enabled)
    MatrixRainActive = enabled
    MatrixContainer.Visible = enabled
end

-- =============================================================================
-- TRIPS MENU CUSTOM GRAFFITI BACKGROUND GRAPHIC (100% TRANSPARENT PNG)
-- =============================================================================
local TripsMenuLogoB64 = "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"
local TripsMenuLogoAsset = "rbxassetid://10709790387" -- Fallback asset

pcall(function()
    if getcustomasset or getsynasset then
        local fileName = "TripsMenuTransparent.png"
        if writefile then
            if crypt and crypt.base64decode then
                writefile(fileName, crypt.base64decode(TripsMenuLogoB64))
                writefile("TripsMenuLogo.png", crypt.base64decode(TripsMenuLogoB64))
            elseif syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode then
                writefile(fileName, syn.crypt.base64.decode(TripsMenuLogoB64))
                writefile("TripsMenuLogo.png", syn.crypt.base64.decode(TripsMenuLogoB64))
            elseif base64_decode then
                writefile(fileName, base64_decode(TripsMenuLogoB64))
                writefile("TripsMenuLogo.png", base64_decode(TripsMenuLogoB64))
            end
        end
        if isfile and isfile(fileName) then
            if getcustomasset then
                TripsMenuLogoAsset = getcustomasset(fileName)
            elseif getsynasset then
                TripsMenuLogoAsset = getsynasset(fileName)
            end
        end
    end
end)

local TripsWatermarkContainer = Instance.new("Frame")
TripsWatermarkContainer.Name = "TripsWatermarkContainer"
TripsWatermarkContainer.Size = UDim2.new(1, 0, 1, 0)
TripsWatermarkContainer.BackgroundTransparency = 1
TripsWatermarkContainer.BorderSizePixel = 0
TripsWatermarkContainer.ClipsDescendants = true
TripsWatermarkContainer.Visible = true
TripsWatermarkContainer.ZIndex = 1
TripsWatermarkContainer.Parent = MainFrame

-- 100% Transparent Custom Graffiti "Trips Menu" Background Graphic
local TripsMenuLogoImage = Instance.new("ImageLabel")
TripsMenuLogoImage.Name = "TripsMenuLogoImage"
TripsMenuLogoImage.Size = UDim2.new(0, 480, 0, 255)
TripsMenuLogoImage.AnchorPoint = Vector2.new(0.5, 0.5)
TripsMenuLogoImage.Position = UDim2.new(0.5, 0, 0.5, 12)
TripsMenuLogoImage.BackgroundTransparency = 1
TripsMenuLogoImage.BorderSizePixel = 0
TripsMenuLogoImage.Image = TripsMenuLogoAsset
TripsMenuLogoImage.ImageTransparency = 0.52
TripsMenuLogoImage.ScaleType = Enum.ScaleType.Fit
TripsMenuLogoImage.ZIndex = 1
TripsMenuLogoImage.Parent = TripsWatermarkContainer

local function SetTripsWatermark(enabled)
    TripsWatermarkContainer.Visible = enabled
end


-- Connect Floating Button to toggle MainFrame
FloatingBtn.MouseButton1Click:Connect(function()
    if dragMoved then
        dragMoved = false
        return
    end
    MainFrame.Visible = not MainFrame.Visible
end)

-- =============================================================================
-- TOP BAR (HEADER)
-- =============================================================================
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

local TopBarLine = Instance.new("Frame")
TopBarLine.Name = "Line"
TopBarLine.Size = UDim2.new(1, 0, 0, 1)
TopBarLine.Position = UDim2.new(0, 0, 1, -1)
TopBarLine.BackgroundColor3 = Theme.CardBorder
TopBarLine.BorderSizePixel = 0
TopBarLine.Parent = TopBar

-- Logo Badge (Custom Graffiti T)
local LogoBadge = Instance.new("ImageLabel")
LogoBadge.Name = "LogoBadge"
LogoBadge.Size = UDim2.new(0, 28, 0, 30)
LogoBadge.Position = UDim2.new(0, 10, 0.5, -15)
LogoBadge.BackgroundTransparency = 1
LogoBadge.BorderSizePixel = 0
LogoBadge.Image = TripsTLogoAsset
LogoBadge.ScaleType = Enum.ScaleType.Fit
LogoBadge.Parent = TopBar

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0, 130, 1, 0)
TitleLabel.Position = UDim2.new(0, 46, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Theme.FontBold
TitleLabel.Text = "TRIPS STEALER"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Live Performance Stats (FPS / Ping)
local StatsContainer = Instance.new("Frame")
StatsContainer.Name = "StatsContainer"
StatsContainer.Size = UDim2.new(0, 240, 1, 0)
StatsContainer.Position = UDim2.new(0, 180, 0, 0)
StatsContainer.BackgroundTransparency = 1
StatsContainer.Parent = TopBar

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 75, 1, 0)
FpsLabel.Position = UDim2.new(0, 0, 0, 0)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = 'FPS: <font color="#FF28BE">60</font>'
FpsLabel.RichText = true
FpsLabel.TextColor3 = Theme.TextMuted
FpsLabel.Font = Theme.FontCode
FpsLabel.TextSize = 11
FpsLabel.TextXAlignment = Enum.TextXAlignment.Left
FpsLabel.Parent = StatsContainer

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 85, 1, 0)
PingLabel.Position = UDim2.new(0, 75, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = 'PING: <font color="#A837FF">20ms</font>'
PingLabel.RichText = true
PingLabel.TextColor3 = Theme.TextMuted
PingLabel.Font = Theme.FontCode
PingLabel.TextSize = 11
PingLabel.TextXAlignment = Enum.TextXAlignment.Left
PingLabel.Parent = StatsContainer

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 75, 1, 0)
VersionLabel.Position = UDim2.new(0, 160, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = 'VER: <font color="#E12DD7">v2.5</font>'
VersionLabel.RichText = true
VersionLabel.TextColor3 = Theme.TextMuted
VersionLabel.Font = Theme.FontCode
VersionLabel.TextSize = 11
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.Parent = StatsContainer

-- Update Stats Loop
task.spawn(function()
    local frameCount = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 0.5 then
            local fps = math.floor(frameCount / (now - lastTime))
            FpsLabel.Text = string.format('FPS: <font color="#FF28BE">%d</font>', fps)
            frameCount = 0
            lastTime = now
            pcall(function()
                local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
                PingLabel.Text = string.format('PING: <font color="#A837FF">%dms</font>', ping)
            end)
        end
    end)
end)

-- Top Close / Minimize Controls
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.InnerCard
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.Font = Theme.FontBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 5)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Danger, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.InnerCard, TextColor3 = Theme.TextMuted}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Draggable Header
local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- =============================================================================
-- SIDEBAR (TABS NAVIGATION)
-- =============================================================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -68)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Name = "Divider"
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = Theme.CardBorder
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

local TabsList = Instance.new("ScrollingFrame")
TabsList.Name = "TabsList"
TabsList.Size = UDim2.new(1, -12, 1, -16)
TabsList.Position = UDim2.new(0, 6, 0, 8)
TabsList.BackgroundTransparency = 1
TabsList.ScrollBarThickness = 0
TabsList.CanvasSize = UDim2.new(0, 0, 0, 0)
TabsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabsList.Parent = Sidebar

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 5)
TabsLayout.Parent = TabsList

-- Content Viewport Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -160, 1, -68)
ContentContainer.Position = UDim2.new(0, 160, 0, 44)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- =============================================================================
-- FOOTER BAR
-- =============================================================================
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, 0, 0, 24)
Footer.Position = UDim2.new(0, 0, 1, -24)
Footer.BackgroundColor3 = Theme.Sidebar
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame

local FooterCorner = Instance.new("UICorner")
FooterCorner.CornerRadius = UDim.new(0, 8)
FooterCorner.Parent = Footer

local FooterTopLine = Instance.new("Frame")
FooterTopLine.Name = "Line"
FooterTopLine.Size = UDim2.new(1, 0, 0, 1)
FooterTopLine.Position = UDim2.new(0, 0, 0, 0)
FooterTopLine.BackgroundColor3 = Theme.CardBorder
FooterTopLine.BorderSizePixel = 0
FooterTopLine.Parent = Footer

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Name = "FooterLabel"
FooterLabel.Size = UDim2.new(1, -20, 1, 0)
FooterLabel.Position = UDim2.new(0, 10, 0, 0)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Theme.FontCode
FooterLabel.Text = "Trips Stealer v2.5"
FooterLabel.TextColor3 = Theme.TextDark
FooterLabel.TextSize = 11
FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
FooterLabel.Parent = Footer

-- =============================================================================
-- UI LIBRARY & COMPONENT BUILDERS
-- =============================================================================
local Library = {
    Tabs = {},
    CurrentTab = nil
}

function Library:CreateTab(name, iconId)
    local Tab = {
        Name = name,
        Page = nil,
        Button = nil,
        LeftColumn = nil,
        RightColumn = nil
    }
    
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = name .. "_Tab"
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = Theme.CardBg
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = ""
    TabBtn.AutoButtonColor = false
    TabBtn.Parent = TabsList
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabBtn
    
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Thickness = 1.2
    TabStroke.Color = Color3.fromRGB(255, 255, 255)
    TabStroke.Transparency = 1
    TabStroke.Parent = TabBtn
    
    local TabStrokeGradient = Instance.new("UIGradient")
    TabStrokeGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentPink),
        ColorSequenceKeypoint.new(1, Theme.AccentPurple)
    })
    TabStrokeGradient.Parent = TabStroke

    local TabGradient = Instance.new("UIGradient")
    TabGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentPink),
        ColorSequenceKeypoint.new(1, Theme.AccentPurple)
    })
    TabGradient.Parent = TabBtn
    
    local TabIcon = Instance.new("ImageLabel")
    TabIcon.Name = "Icon"
    TabIcon.Size = UDim2.new(0, 16, 0, 16)
    TabIcon.Position = UDim2.new(0, 10, 0.5, -8)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = iconId or "rbxassetid://10709791437"
    TabIcon.ImageColor3 = Theme.TextMuted
    TabIcon.Parent = TabBtn
    
    local TabTitle = Instance.new("TextLabel")
    TabTitle.Name = "Title"
    TabTitle.Size = UDim2.new(1, -34, 1, 0)
    TabTitle.Position = UDim2.new(0, 34, 0, 0)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Font = Theme.FontMedium
    TabTitle.Text = name
    TabTitle.TextColor3 = Theme.TextMuted
    TabTitle.TextSize = 12
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.Parent = TabBtn
    
    Tab.Button = TabBtn
    
    -- Page
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "_Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.AccentDark
    Page.Visible = false
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Parent = ContentContainer
    
    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingLeft = UDim.new(0, 10)
    PagePadding.PaddingRight = UDim.new(0, 10)
    PagePadding.PaddingBottom = UDim.new(0, 10)
    PagePadding.Parent = Page
    
    local Columns = Instance.new("Frame")
    Columns.Name = "Columns"
    Columns.Size = UDim2.new(1, 0, 0, 0)
    Columns.BackgroundTransparency = 1
    Columns.AutomaticSize = Enum.AutomaticSize.Y
    Columns.Parent = Page
    
    local LeftCol = Instance.new("Frame")
    LeftCol.Name = "LeftColumn"
    LeftCol.Size = UDim2.new(0.5, -5, 0, 0)
    LeftCol.Position = UDim2.new(0, 0, 0, 0)
    LeftCol.BackgroundTransparency = 1
    LeftCol.AutomaticSize = Enum.AutomaticSize.Y
    LeftCol.Parent = Columns
    
    local LeftLayout = Instance.new("UIListLayout")
    LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    LeftLayout.Padding = UDim.new(0, 8)
    LeftLayout.Parent = LeftCol
    
    local RightCol = Instance.new("Frame")
    RightCol.Name = "RightColumn"
    RightCol.Size = UDim2.new(0.5, -5, 0, 0)
    RightCol.Position = UDim2.new(0.5, 5, 0, 0)
    RightCol.BackgroundTransparency = 1
    RightCol.AutomaticSize = Enum.AutomaticSize.Y
    RightCol.Parent = Columns
    
    local RightLayout = Instance.new("UIListLayout")
    RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightLayout.Padding = UDim.new(0, 8)
    RightLayout.Parent = RightCol
    
    Tab.Page = Page
    Tab.LeftColumn = LeftCol
    Tab.RightColumn = RightCol
    
    local function Select()
        for _, otherTab in pairs(Library.Tabs) do
            otherTab.Page.Visible = false
            TweenService:Create(otherTab.Button, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
            if otherTab.Button:FindFirstChildWhichIsA("UIStroke") then
                TweenService:Create(otherTab.Button:FindFirstChildWhichIsA("UIStroke"), TweenInfo.new(0.18), {Transparency = 1}):Play()
            end
            TweenService:Create(otherTab.Button.Title, TweenInfo.new(0.18), {TextColor3 = Theme.TextMuted}):Play()
            TweenService:Create(otherTab.Button.Icon, TweenInfo.new(0.18), {ImageColor3 = Theme.TextMuted}):Play()
        end
        Page.Visible = true
        Library.CurrentTab = Tab
        TweenService:Create(TabBtn, TweenInfo.new(0.18), {BackgroundTransparency = 0.82, BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(TabStroke, TweenInfo.new(0.18), {Transparency = 0.35}):Play()
        TweenService:Create(TabTitle, TweenInfo.new(0.18), {TextColor3 = Theme.AccentPink}):Play()
        TweenService:Create(TabIcon, TweenInfo.new(0.18), {ImageColor3 = Theme.AccentPink}):Play()
    end
    
    TabBtn.MouseButton1Click:Connect(Select)
    
    if #Library.Tabs == 0 then
        Select()
    end
    
    table.insert(Library.Tabs, Tab)
    
    -- Section / Card Creator
    function Tab:CreateSection(title, iconId, side)
        local targetCol = (side == "Right" or side == 2) and RightCol or LeftCol
        local Section = {}
        
        local Card = Instance.new("Frame")
        Card.Name = title .. "_Card"
        Card.Size = UDim2.new(1, 0, 0, 0)
        Card.BackgroundColor3 = Theme.CardBg
        Card.BorderSizePixel = 0
        Card.AutomaticSize = Enum.AutomaticSize.Y
        Card.Parent = targetCol
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 6)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Theme.CardBorder
        CardStroke.Thickness = 1
        CardStroke.Parent = Card
        
        -- Header
        local Header = Instance.new("Frame")
        Header.Name = "Header"
        Header.Size = UDim2.new(1, 0, 0, 32)
        Header.BackgroundTransparency = 1
        Header.Parent = Card
        
        local HeaderIcon = Instance.new("ImageLabel")
        HeaderIcon.Name = "Icon"
        HeaderIcon.Size = UDim2.new(0, 16, 0, 16)
        HeaderIcon.Position = UDim2.new(0, 10, 0.5, -8)
        HeaderIcon.BackgroundTransparency = 1
        HeaderIcon.Image = iconId or "rbxassetid://10709791437"
        HeaderIcon.ImageColor3 = Theme.Accent
        HeaderIcon.Parent = Header
        
        local HeaderTitle = Instance.new("TextLabel")
        HeaderTitle.Name = "Title"
        HeaderTitle.Size = UDim2.new(1, -56, 1, 0)
        HeaderTitle.Position = UDim2.new(0, 32, 0, 0)
        HeaderTitle.BackgroundTransparency = 1
        HeaderTitle.Font = Theme.FontBold
        HeaderTitle.Text = title
        HeaderTitle.TextColor3 = Theme.Text
        HeaderTitle.TextSize = 12
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
        HeaderTitle.Parent = Header
        
        local CollapseIcon = Instance.new("ImageLabel")
        CollapseIcon.Name = "CollapseIcon"
        CollapseIcon.Size = UDim2.new(0, 14, 0, 14)
        CollapseIcon.Position = UDim2.new(1, -22, 0.5, -7)
        CollapseIcon.BackgroundTransparency = 1
        CollapseIcon.Image = "rbxassetid://10709790948"
        CollapseIcon.ImageColor3 = Theme.TextDark
        CollapseIcon.Parent = Header
        
        -- Items Container
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.Position = UDim2.new(0, 0, 0, 32)
        Container.BackgroundTransparency = 1
        Container.AutomaticSize = Enum.AutomaticSize.Y
        Container.Parent = Card
        
        local ContainerPadding = Instance.new("UIPadding")
        ContainerPadding.PaddingTop = UDim.new(0, 2)
        ContainerPadding.PaddingLeft = UDim.new(0, 8)
        ContainerPadding.PaddingRight = UDim.new(0, 8)
        ContainerPadding.PaddingBottom = UDim.new(0, 8)
        ContainerPadding.Parent = Container
        
        local ContainerLayout = Instance.new("UIListLayout")
        ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContainerLayout.Padding = UDim.new(0, 6)
        ContainerLayout.Parent = Container
        
        local collapsed = false
        local HeaderBtn = Instance.new("TextButton")
        HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Text = ""
        HeaderBtn.Parent = Header
        HeaderBtn.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            Container.Visible = not collapsed
            TweenService:Create(CollapseIcon, TweenInfo.new(0.2), {
                Rotation = collapsed and -90 or 0
            }):Play()
        end)
        
        -- Create Button
        function Section:CreateButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Name = text .. "_Button"
            Btn.Size = UDim2.new(1, 0, 0, 28)
            Btn.BackgroundColor3 = Theme.InnerCard
            Btn.BorderSizePixel = 0
            Btn.Font = Theme.FontMedium
            Btn.Text = text
            Btn.TextColor3 = Theme.Text
            Btn.TextSize = 11
            Btn.AutoButtonColor = false
            Btn.Parent = Container
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = Btn
            
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Theme.CardBorder
            BtnStroke.Thickness = 1
            BtnStroke.Parent = Btn
            
            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(34, 40, 48), TextColor3 = Theme.Accent}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.InnerCard, TextColor3 = Theme.Text}):Play()
            end)
            Btn.MouseButton1Click:Connect(function()
                pcall(callback or function() end)
            end)
            return Btn
        end
        
        -- Create Toggle
        function Section:CreateToggle(label, defaultState, callback)
            local state = defaultState or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = label .. "_Toggle"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = Container
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -45, 1, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Font = Theme.FontRegular
            ToggleLabel.Text = label
            ToggleLabel.TextColor3 = Theme.Text
            ToggleLabel.TextSize = 11
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local Switch = Instance.new("TextButton")
            Switch.Name = "Switch"
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -36, 0.5, -9)
            Switch.BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
            Switch.Text = ""
            Switch.AutoButtonColor = false
            Switch.Parent = ToggleFrame
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch
            
            local Circle = Instance.new("Frame")
            Circle.Name = "Circle"
            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Circle.BackgroundColor3 = Theme.ToggleSlider
            Circle.BorderSizePixel = 0
            Circle.Parent = Switch
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = Circle
            
            local function Update()
                local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local targetColor = state and Theme.Accent or Theme.ToggleOff
                TweenService:Create(Circle, TweenInfo.new(0.18), {Position = targetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
                pcall(callback or function() end, state)
            end
            
            Switch.MouseButton1Click:Connect(function()
                state = not state
                Update()
            end)
            
            return {
                Set = function(_, val)
                    state = val
                    Update()
                end,
                GetValue = function() return state end
            }
        end
        
        -- Create Slider
        function Section:CreateSlider(label, min, max, defaultVal, callback)
            local val = defaultVal or min
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = label .. "_Slider"
            SliderFrame.Size = UDim2.new(1, 0, 0, 38)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = Container
            
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, -60, 0, 16)
            Label.BackgroundTransparency = 1
            Label.Font = Theme.FontRegular
            Label.Text = label
            Label.TextColor3 = Theme.Text
            Label.TextSize = 11
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Name = "ValueLabel"
            ValueLabel.Size = UDim2.new(0, 60, 0, 16)
            ValueLabel.Position = UDim2.new(1, -60, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Theme.FontCode
            ValueLabel.Text = string.format("%.1f", val)
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.TextSize = 11
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local Bar = Instance.new("TextButton")
            Bar.Name = "Bar"
            Bar.Size = UDim2.new(1, 0, 0, 12)
            Bar.Position = UDim2.new(0, 0, 0, 20)
            Bar.BackgroundColor3 = Theme.SliderBg
            Bar.Text = ""
            Bar.AutoButtonColor = false
            Bar.Parent = SliderFrame
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(0, 3)
            BarCorner.Parent = Bar
            
            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            local initialPercent = math.clamp((val - min) / (max - min), 0, 1)
            Fill.Size = UDim2.new(initialPercent, 0, 1, 0)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Bar
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 3)
            FillCorner.Parent = Fill
            
            local sliding = false
            local function UpdateSlide(input)
                local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                val = math.floor((min + (max - min) * percent) * 10) / 10
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                ValueLabel.Text = string.format("%.1f", val)
                pcall(callback or function() end, val)
            end
            
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateSlide(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlide(input)
                end
            end)
            
            return {
                Set = function(_, v)
                    val = math.clamp(v, min, max)
                    local percent = (val - min) / (max - min)
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    ValueLabel.Text = string.format("%.1f", val)
                    pcall(callback or function() end, val)
                end,
                GetValue = function() return val end
            }
        end
        
        -- Create Dropdown with Proper ZIndex Layering & Opaque Overlay
        function Section:CreateDropdown(label, options, defaultSelected, callback)
            local selected = defaultSelected or options[1] or ""
            local open = false
            local hasLabel = (label and label ~= "")
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = (hasLabel and label or "Dropdown") .. "_Dropdown"
            DropdownFrame.Size = UDim2.new(1, 0, 0, hasLabel and 48 or 26)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.ClipsDescendants = false
            DropdownFrame.ZIndex = 1
            DropdownFrame.Parent = Container
            
            if hasLabel then
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Name = "Label"
                DropdownLabel.Size = UDim2.new(1, 0, 0, 16)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Font = Theme.FontRegular
                DropdownLabel.Text = label
                DropdownLabel.TextColor3 = Theme.Text
                DropdownLabel.TextSize = 11
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.ZIndex = 1
                DropdownLabel.Parent = DropdownFrame
            end
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Name = "Selector"
            DropBtn.Size = UDim2.new(1, 0, 0, 26)
            DropBtn.Position = UDim2.new(0, 0, 0, hasLabel and 18 or 0)
            DropBtn.BackgroundColor3 = Theme.InnerCard
            DropBtn.BorderSizePixel = 0
            DropBtn.Font = Theme.FontRegular
            DropBtn.Text = ""
            DropBtn.AutoButtonColor = false
            DropBtn.ZIndex = 2
            DropBtn.Parent = DropdownFrame
            
            local DropBtnCorner = Instance.new("UICorner")
            DropBtnCorner.CornerRadius = UDim.new(0, 4)
            DropBtnCorner.Parent = DropBtn
            
            local DropBtnStroke = Instance.new("UIStroke")
            DropBtnStroke.Color = Theme.CardBorder
            DropBtnStroke.Thickness = 1
            DropBtnStroke.Parent = DropBtn
            
            local SelectedText = Instance.new("TextLabel")
            SelectedText.Name = "SelectedText"
            SelectedText.Size = UDim2.new(1, -30, 1, 0)
            SelectedText.Position = UDim2.new(0, 8, 0, 0)
            SelectedText.BackgroundTransparency = 1
            SelectedText.Font = Theme.FontCode
            SelectedText.Text = selected
            SelectedText.TextColor3 = Theme.Text
            SelectedText.TextSize = 11
            SelectedText.TextXAlignment = Enum.TextXAlignment.Left
            SelectedText.ZIndex = 3
            SelectedText.Parent = DropBtn
            
            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Name = "Arrow"
            ArrowIcon.Size = UDim2.new(0, 14, 0, 14)
            ArrowIcon.Position = UDim2.new(1, -20, 0.5, -7)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = "rbxassetid://10709790948"
            ArrowIcon.ImageColor3 = Theme.TextMuted
            ArrowIcon.ZIndex = 3
            ArrowIcon.Parent = DropBtn
            
            local OptionsHolder = Instance.new("ScrollingFrame")
            OptionsHolder.Name = "OptionsHolder"
            OptionsHolder.Size = UDim2.new(1, 0, 0, 130)
            OptionsHolder.Position = UDim2.new(0, 0, 1, 4)
            OptionsHolder.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
            OptionsHolder.BackgroundTransparency = 0
            OptionsHolder.BorderSizePixel = 0
            OptionsHolder.ScrollBarThickness = 3
            OptionsHolder.ScrollBarImageColor3 = Theme.AccentDark
            OptionsHolder.Visible = false
            OptionsHolder.ZIndex = 150
            OptionsHolder.ClipsDescendants = true
            OptionsHolder.Parent = DropBtn
            
            local OptionsCorner = Instance.new("UICorner")
            OptionsCorner.CornerRadius = UDim.new(0, 4)
            OptionsCorner.Parent = OptionsHolder
            
            local OptionsStroke = Instance.new("UIStroke")
            OptionsStroke.Color = Theme.CardBorder
            OptionsStroke.Thickness = 1.2
            OptionsStroke.ZIndex = 150
            OptionsStroke.Parent = OptionsHolder
            
            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Padding = UDim.new(0, 1)
            OptionsLayout.Parent = OptionsHolder
            
            local function CloseDropdown()
                open = false
                OptionsHolder.Visible = false
                ArrowIcon.Rotation = 0
                DropdownFrame.ZIndex = 1
                Card.ZIndex = 1
                Container.ZIndex = 1
                if targetCol then targetCol.ZIndex = 1 end
                if Library.ActiveDropdownClose == CloseDropdown then
                    Library.ActiveDropdownClose = nil
                end
            end
            
            local function OpenDropdown()
                if Library.ActiveDropdownClose and Library.ActiveDropdownClose ~= CloseDropdown then
                    Library.ActiveDropdownClose()
                end
                open = true
                DropdownFrame.ZIndex = 120
                Card.ZIndex = 50
                Container.ZIndex = 50
                if targetCol then targetCol.ZIndex = 50 end
                OptionsHolder.Visible = true
                ArrowIcon.Rotation = 180
                Library.ActiveDropdownClose = CloseDropdown
            end
            
            local function RefreshOptions()
                for _, child in pairs(OptionsHolder:GetChildren()) do
                    if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
                end
                
                OptionsHolder.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
                
                for _, opt in ipairs(options) do
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Name = opt
                    ItemBtn.Size = UDim2.new(1, 0, 0, 24)
                    ItemBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
                    ItemBtn.BackgroundTransparency = 0
                    ItemBtn.BorderSizePixel = 0
                    ItemBtn.Font = Theme.FontCode
                    ItemBtn.Text = "  " .. tostring(opt)
                    ItemBtn.TextColor3 = (opt == selected) and Theme.Accent or Theme.Text
                    ItemBtn.TextSize = 11
                    ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                    ItemBtn.AutoButtonColor = false
                    ItemBtn.ZIndex = 151
                    ItemBtn.Parent = OptionsHolder
                    
                    ItemBtn.MouseEnter:Connect(function()
                        ItemBtn.BackgroundColor3 = Color3.fromRGB(34, 40, 48)
                    end)
                    ItemBtn.MouseLeave:Connect(function()
                        ItemBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 32)
                    end)
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        SelectedText.Text = selected
                        CloseDropdown()
                        pcall(callback or function() end, selected)
                    end)
                end
            end
            RefreshOptions()
            
            DropBtn.MouseButton1Click:Connect(function()
                if open then
                    CloseDropdown()
                else
                    OpenDropdown()
                end
            end)
            
            return {
                Set = function(_, opt)
                    selected = opt
                    SelectedText.Text = opt
                    pcall(callback or function() end, opt)
                end,
                SetOptions = function(_, newOptions)
                    options = newOptions
                    RefreshOptions()
                end,
                GetValue = function() return selected end,
                Close = CloseDropdown
            }
        end
        
        -- Create Text Input
        function Section:CreateTextInput(label, placeholder, defaultVal, callback)
            local InputFrame = Instance.new("Frame")
            InputFrame.Name = label .. "_Input"
            InputFrame.Size = UDim2.new(1, 0, 0, 48)
            InputFrame.BackgroundTransparency = 1
            InputFrame.Parent = Container
            
            local InputLabel = Instance.new("TextLabel")
            InputLabel.Name = "Label"
            InputLabel.Size = UDim2.new(1, 0, 0, 16)
            InputLabel.BackgroundTransparency = 1
            InputLabel.Font = Theme.FontRegular
            InputLabel.Text = label
            InputLabel.TextColor3 = Theme.Text
            InputLabel.TextSize = 11
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            InputLabel.Parent = InputFrame
            
            local Box = Instance.new("TextBox")
            Box.Name = "TextBox"
            Box.Size = UDim2.new(1, 0, 0, 26)
            Box.Position = UDim2.new(0, 0, 0, 18)
            Box.BackgroundColor3 = Theme.InnerCard
            Box.BorderSizePixel = 0
            Box.Font = Theme.FontCode
            Box.Text = defaultVal or ""
            Box.PlaceholderText = placeholder or "Enter value..."
            Box.PlaceholderColor3 = Theme.TextDark
            Box.TextColor3 = Theme.Text
            Box.TextSize = 11
            Box.ClearTextOnFocus = false
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.Parent = InputFrame
            
            local BoxPadding = Instance.new("UIPadding")
            BoxPadding.PaddingLeft = UDim.new(0, 8)
            BoxPadding.PaddingRight = UDim.new(0, 8)
            BoxPadding.Parent = Box
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = Box
            
            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Color = Theme.CardBorder
            BoxStroke.Thickness = 1
            BoxStroke.Parent = Box
            
            Box.FocusLost:Connect(function()
                pcall(callback or function() end, Box.Text)
            end)
            
            return {
                Set = function(_, t)
                    Box.Text = t
                    pcall(callback or function() end, t)
                end,
                GetValue = function() return Box.Text end
            }
        end
        
        return Section
    end
    
    return Tab
end

-- =============================================================================
-- GAME DEFINITIONS & DATA
-- =============================================================================
local AreaOrder = {
    "Forest",         -- 1
    "Lake",           -- 2
    "Desert",         -- 3
    "Jungle",         -- 4
    "Snow",           -- 5
    "Volcano",        -- 6
    "Abyss Ocean",    -- 7
    "Prehistoric",    -- 8
    "Cosmic",         -- 9
    "Cherry Blossom", -- 10
    "Titan Temple",   -- 11
    "Light Dark",     -- 12
    "Angels & Demons" -- 13
}

local AllAreas = {
    "All", "Light Dark", "Titan Temple", "Cherry Blossom", "Cosmic", "Prehistoric", "Abyss Ocean",
    "Volcano", "Snow", "Jungle", "Desert", "Lake", "Forest", "Angels & Demons"
}

local AllRarities = {
    "All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Cosmic",
    "Secret", "Eternal", "Divine"
}

local AllMutations = {
    "All", "None", "Bloodmoon", "Candy", "Celestial", "Diamond", "Frozen",
    "Golden", "Magma", "Plasma", "Rainbow", "Shiny", "Silver", "Void"
}

local AllRifts = {
    "All", "Angels & Demons", "Cosmic", "Titan", "Volcano", "Nightmare", "Hard", "Normal"
}

-- =============================================================================
-- AUTOMATION STATE & REFS
-- =============================================================================
local AutoStealSelected = false
local AutoStealOnPickup = false
local AutoDropHeld = false
local SelectedArea = "All"
local SelectedRarity = "All"
local SelectedMutation = "All"
local SelectedRift = "All"
local SelectedPriority = "Highest KG First"
local MoveSpeedVal = 120
local SuperSpeedActive = false
local CustomSafeZone = nil

local BatKillAura = false
local AutoEquipBat = false
local AuraRange = 12.0
local AttackDelay = 0.1
local AntiGuardHit = false
local AntiTrap = false
local AutoEnterBossArena = false
local AutoAttackCrystalTowers = false
local AutoTeleportBossShop = false

local AutoEquipBestPet = false
local AutoTreadmillUpgrade = false
local AutoBaseUpgrade = false

local EggESPEnabled = false
local PlayerESPEnabled = false
local BiomeESPEnabled = false

-- =============================================================================
-- UTILITY FUNCTIONS FOR AUTO-STEAL
-- =============================================================================
local function GetSafeZonePos()
    if CustomSafeZone then
        if typeof(CustomSafeZone) == "CFrame" then
            return CustomSafeZone.Position
        elseif typeof(CustomSafeZone) == "Vector3" then
            return CustomSafeZone
        end
    end

    local startArea = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("StartArea")
    if startArea then
        if startArea:IsA("BasePart") then return startArea.Position end
        if startArea:IsA("Model") and startArea.PrimaryPart then return startArea.PrimaryPart.Position end
        local p = startArea:FindFirstChildWhichIsA("BasePart", true)
        if p then return p.Position end
    end

    local spawnTarget = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Build") and workspace.__OBJECTS.Build:FindFirstChild("MainMap") and workspace.__OBJECTS.Build.MainMap:FindFirstChild("SpawnTarget")
    if spawnTarget then
        if spawnTarget:IsA("BasePart") then return spawnTarget.Position end
        local p = spawnTarget:FindFirstChildWhichIsA("BasePart", true)
        if p then return p.Position end
    end

    local spawnLoc = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawnLoc then return spawnLoc.Position end

    return Vector3.new(526.2, 70.6, -354.2)
end

local function IsHoldingEgg()
    local char = LocalPlayer.Character
    if not char then return false end

    if char:GetAttribute("HoldingEgg") == true or char:GetAttribute("CarryingEgg") == true or char:GetAttribute("IsCarryingEgg") == true then
        return true
    end

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") or (item:IsA("Model") and not item:IsA("Accessory")) then
            local iName = string.lower(item.Name)
            local itemType = tostring(item:GetAttribute("ItemType") or "")
            local isIgnored = string.find(iName, "pet") or string.find(iName, "bat") or string.find(iName, "trap") or string.find(iName, "slap") or string.find(iName, "sword") or (itemType == "AssetPet")
            if not isIgnored and (string.find(iName, "egg") or item:GetAttribute("Egg") == true or itemType == "AssetEgg") then
                return true
            end
        end
    end

    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local dropGui = pGui:FindFirstChild("DropHeldEgg")
        if dropGui and dropGui.Enabled then return true end

        local carryGui = pGui:FindFirstChild("EggCarrying") or pGui:FindFirstChild("EggCarried") or pGui:FindFirstChild("CarryEgg")
        if carryGui and carryGui.Enabled then return true end
    end

    if LocalPlayer:GetAttribute("HoldingEgg") == true or LocalPlayer:GetAttribute("CarryingEgg") == true then
        return true
    end

    return false
end

-- Area & Biome Position Resolution
local function IsAngelDemonName(str)
    if not str then return false end
    local s = string.lower(string.gsub(tostring(str), "[%s&_]+", ""))
    return string.find(s, "angel") ~= nil 
        or string.find(s, "demon") ~= nil 
        or string.find(s, "light") ~= nil 
        or string.find(s, "dark") ~= nil
        or string.find(s, "heaven") ~= nil
        or string.find(s, "hell") ~= nil
end

local BiomeCoords = {
    ["angels&demons"] = Vector3.new(0, 75, -1200),
    ["angelsanddemons"] = Vector3.new(0, 75, -1200),
    ["angelsdemons"] = Vector3.new(0, 75, -1200),
    ["angel"] = Vector3.new(0, 75, -1200),
    ["angels"] = Vector3.new(0, 75, -1200),
    ["demon"] = Vector3.new(0, 75, -1200),
    ["demons"] = Vector3.new(0, 75, -1200),
    ["lightdark"] = Vector3.new(0, 75, -1200),
    ["light&dark"] = Vector3.new(0, 75, -1200),
    ["lightanddark"] = Vector3.new(0, 75, -1200),
    ["light_dark"] = Vector3.new(0, 75, -1200),
    ["light"] = Vector3.new(0, 75, -1200),
    ["dark"] = Vector3.new(0, 75, -1200),
    ["heaven&hell"] = Vector3.new(0, 75, -1200),
    ["heaven"] = Vector3.new(0, 75, -1200),
    ["hell"] = Vector3.new(0, 75, -1200),
    titantemple = Vector3.new(280, 70, -850),
    volcano = Vector3.new(-650, 75, -500),
    cosmic = Vector3.new(600, 75, 450),
    cherryblossom = Vector3.new(-350, 70, 600),
    prehistoric = Vector3.new(-100, 70, -900),
    abyssocean = Vector3.new(850, 65, -150),
    snow = Vector3.new(-750, 70, 200),
    jungle = Vector3.new(250, 70, 750),
    desert = Vector3.new(-450, 70, -250),
    lake = Vector3.new(150, 65, -300),
    forest = Vector3.new(450, 70, -100)
}

local areaCenterCache = {}
local function GetAreaCenter(areaName)
    if not areaName or areaName == "All" or areaName == "---" or areaName == "" then return nil end
    if areaCenterCache[areaName] then return areaCenterCache[areaName] end

    local cleanTarget = string.lower(string.gsub(areaName, "[%s&]+", ""))
    local rawClean = string.lower(string.gsub(areaName, "%s+", ""))
    local alias = (rawClean == "valcano") and "volcano" or ((rawClean == "volcano") and "valcano" or rawClean)
    local isAngelDemon = IsAngelDemonName(areaName)

    -- 1. Direct check for Angels & Demons / Light Dark / Angels / Demons Nests & Centers
    if isAngelDemon then
        local guardAreas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
        if guardAreas then
            for _, gArea in pairs(guardAreas:GetChildren()) do
                if IsAngelDemonName(gArea.Name) then
                    local nests = gArea:FindFirstChild("Nests")
                    if nests then
                        local nestPart = nests:FindFirstChildWhichIsA("BasePart", true)
                        if nestPart then
                            areaCenterCache[areaName] = nestPart.Position
                            return nestPart.Position
                        end
                    end
                    local center = gArea:FindFirstChild("CENTER") or gArea:FindFirstChild("Center") or gArea:FindFirstChild("ClosestExitPoint") or gArea:FindFirstChildWhichIsA("BasePart", true)
                    if center then
                        areaCenterCache[areaName] = center.Position
                        return center.Position
                    end
                end
            end
        end

        local areas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas")
        if areas then
            for _, area in pairs(areas:GetChildren()) do
                if IsAngelDemonName(area.Name) then
                    local center = area:FindFirstChild("CENTER") or area:FindFirstChild("Center") or area:FindFirstChild("ClosestExitPoint") or area:FindFirstChildWhichIsA("BasePart", true)
                    if center then
                        areaCenterCache[areaName] = center.Position
                        return center.Position
                    end
                end
            end
        end

        local eggSlots = workspace:FindFirstChild("AreaEggSlotsClient")
        if eggSlots then
            for _, slot in pairs(eggSlots:GetChildren()) do
                if IsAngelDemonName(slot.Name) then
                    local part = slot:IsA("BasePart") and slot or slot:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        areaCenterCache[areaName] = part.Position
                        return part.Position
                    end
                end
            end
        end

        local defaultAD = Vector3.new(0, 75, -1200)
        areaCenterCache[areaName] = defaultAD
        return defaultAD
    end

    -- 2. Check workspace.__OBJECTS.Areas.GuardAreas general
    local guardAreas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
    if guardAreas then
        for _, area in pairs(guardAreas:GetChildren()) do
            local cleanArea = string.lower(string.gsub(area.Name, "[%s&]+", ""))
            local rawArea = string.lower(string.gsub(area.Name, "%s+", ""))
            if cleanArea == cleanTarget or rawArea == rawClean or cleanArea == alias or string.find(cleanArea, cleanTarget) or string.find(cleanTarget, cleanArea) or (area:GetAttribute("AreaId") and string.lower(string.gsub(tostring(area:GetAttribute("AreaId")), "[%s&]+", "")) == cleanTarget) then
                local center = area:FindFirstChild("CENTER") or area:FindFirstChild("Center") or area:FindFirstChild("ClosestExitPoint") or area:FindFirstChildWhichIsA("BasePart", true)
                if center then
                    areaCenterCache[areaName] = center.Position
                    return center.Position
                end
            end
        end
    end

    -- 3. Check workspace.__OBJECTS.Areas general
    local areas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas")
    if areas then
        for _, area in pairs(areas:GetChildren()) do
            local cleanArea = string.lower(string.gsub(area.Name, "[%s&]+", ""))
            local rawArea = string.lower(string.gsub(area.Name, "%s+", ""))
            if cleanArea == cleanTarget or rawArea == rawClean or cleanArea == alias or string.find(cleanArea, cleanTarget) then
                local center = area:FindFirstChild("CENTER") or area:FindFirstChild("Center") or area:FindFirstChild("ClosestExitPoint") or area:FindFirstChildWhichIsA("BasePart", true)
                if center then
                    areaCenterCache[areaName] = center.Position
                    return center.Position
                end
            end
        end
    end

    -- 4. Check AreaEggSlotsClient for slots in that area
    local eggSlots = workspace:FindFirstChild("AreaEggSlotsClient")
    if eggSlots then
        for _, slot in pairs(eggSlots:GetChildren()) do
            local sName = string.lower(string.gsub(slot.Name, "[%s&]+", ""))
            if string.find(sName, cleanTarget) or string.find(sName, alias) then
                local part = slot:IsA("BasePart") and slot or slot:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    areaCenterCache[areaName] = part.Position
                    return part.Position
                end
            end
        end
    end

    -- 5. Fallback: Check all root workspace models
    for _, obj in pairs(workspace:GetChildren()) do
        local cleanObj = string.lower(string.gsub(obj.Name, "[%s&]+", ""))
        if cleanObj == cleanTarget or cleanObj == alias or string.find(cleanObj, cleanTarget) then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
            if part then
                areaCenterCache[areaName] = part.Position
                return part.Position
            end
        end
    end

    -- 6. Hardcoded coordinates fallback
    if BiomeCoords[cleanTarget] then
        areaCenterCache[areaName] = BiomeCoords[cleanTarget]
        return BiomeCoords[cleanTarget]
    end
    if BiomeCoords[rawClean] then
        areaCenterCache[areaName] = BiomeCoords[rawClean]
        return BiomeCoords[rawClean]
    end
    if BiomeCoords[alias] then
        areaCenterCache[areaName] = BiomeCoords[alias]
        return BiomeCoords[alias]
    end

    return nil
end

local function IsEggInArea(eggPos, targetArea)
    if not targetArea or targetArea == "All" or targetArea == "---" or targetArea == "" then
        return true
    end
    if not eggPos then return false end

    local isAngelDemon = IsAngelDemonName(targetArea)
    if isAngelDemon then
        -- 1. Check fixed Angels & Demons location (0, 75, -1200)
        if (eggPos - Vector3.new(0, 75, -1200)).Magnitude <= 300 then
            return true
        end

        -- 2. Check dynamic GuardAreas (Light Dark / Angels / Demons)
        local guardAreas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
        if guardAreas then
            for _, gArea in pairs(guardAreas:GetChildren()) do
                if IsAngelDemonName(gArea.Name) then
                    local nests = gArea:FindFirstChild("Nests")
                    if nests then
                        local nPart = nests:FindFirstChildWhichIsA("BasePart", true)
                        if nPart and (eggPos - nPart.Position).Magnitude <= 300 then
                            return true
                        end
                    end
                    local center = gArea:FindFirstChild("CENTER") or gArea:FindFirstChild("Center") or gArea:FindFirstChildWhichIsA("BasePart", true)
                    if center and (eggPos - center.Position).Magnitude <= 300 then
                        return true
                    end
                end
            end
        end

        -- 3. Check AreaEggSlotsClient for Angel / Demon slots
        local eggSlots = workspace:FindFirstChild("AreaEggSlotsClient")
        if eggSlots then
            for _, slot in pairs(eggSlots:GetChildren()) do
                if IsAngelDemonName(slot.Name) then
                    local part = slot:IsA("BasePart") and slot or slot:FindFirstChildWhichIsA("BasePart", true)
                    if part and (eggPos - part.Position).Magnitude <= 80 then
                        return true
                    end
                end
            end
        end

        return false
    end

    local center = GetAreaCenter(targetArea)
    if center then
        return (eggPos - center).Magnitude <= 240
    end
    return true
end

-- Precise Egg Candidate Finder (Strict Rarity & Biome Matching)
local RarityTiers = {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Cosmic",
    [8] = "Secret",
    [9] = "Eternal",
    [10] = "Divine"
}

local KnownDivinePets = { "god", "divine", "zenith", "archangel", "overlord", "seraphim", "infinite" }
local KnownEternalPets = { "eternal", "angel", "celestial", "lunar", "solar", "valkyrie", "radiant", "holy" }
local KnownSecretPets = {
    "void dragon", "el maja", "mosasaurus", "balrog", "eternal lunar", "krakenoid",
    "oni tiger", "gorilla king", "archdemon", "kitsune", "dreadscale", "nightflame",
    "mecha dreadscale", "baby aurora", "aurora dragon", "secret", "demon", "nightmare", "darkness", "shadow"
}
local KnownCosmicPets = {
    "cosmic dragon", "cosmic gecko", "cosmic gorilla", "cosmic skeleton", "cosmic", "galaxy", "alien", "nebula", "star"
}
local KnownMythicPets = {
    "shadow dragon", "leviathan", "royal sphinx", "king mammoth", "whale shark",
    "demon imp", "kraken", "phoenix", "lava dragon", "strawberry elephant", "mythic", "titan", "sakura", "cherry"
}
local KnownLegendaryPets = {
    "golden", "dragon", "shark", "mammoth", "sphinx", "ocean", "prehistoric", "trex", "dino", "legendary"
}
local KnownEpicPets = {
    "volcano", "valcano", "lava", "magma", "jungle", "tiger", "panther", "gorilla", "epic"
}
local KnownRarePets = {
    "snow", "arctic", "penguin", "polar bear", "frost", "ice", "rare"
}
local KnownUncommonPets = {
    "desert", "camel", "scorpion", "sand", "cactus", "uncommon"
}

local BiomeRarities = {
    { Pos = Vector3.new(0, 75, -1200), Rarity = "Divine", Radius = 400 },
    { Pos = Vector3.new(600, 75, 450), Rarity = "Cosmic", Radius = 320 },
    { Pos = Vector3.new(-350, 70, 600), Rarity = "Mythic", Radius = 320 },
    { Pos = Vector3.new(280, 70, -850), Rarity = "Mythic", Radius = 320 },
    { Pos = Vector3.new(850, 65, -150), Rarity = "Legendary", Radius = 320 },
    { Pos = Vector3.new(-100, 70, -900), Rarity = "Legendary", Radius = 320 },
    { Pos = Vector3.new(-650, 75, -500), Rarity = "Epic", Radius = 320 },
    { Pos = Vector3.new(250, 70, 750), Rarity = "Epic", Radius = 320 },
    { Pos = Vector3.new(-750, 70, 200), Rarity = "Rare", Radius = 320 },
    { Pos = Vector3.new(150, 65, -300), Rarity = "Rare", Radius = 320 },
    { Pos = Vector3.new(-450, 70, -250), Rarity = "Uncommon", Radius = 320 },
    { Pos = Vector3.new(450, 70, -100), Rarity = "Common", Radius = 320 }
}

local function ParseVal(val)
    if val == nil then return nil end
    if typeof(val) == "number" then
        if val >= 1 and val <= 10 then
            return RarityTiers[val]
        end
        return nil
    end
    local s = tostring(val)
    if s == "" then return nil end
    local sLower = string.lower(s)

    -- 1. Direct Rarity & Tier Keywords (Strict Priority)
    if string.find(sLower, "divine") or string.find(sLower, "tenth") or string.find(sLower, "area10") or string.find(sLower, "area_10") or string.find(sLower, "area 10") or string.find(sLower, "tier10") or string.find(sLower, "tier_10") or string.find(sLower, "tier 10") or string.find(sLower, "godly") or string.find(sLower, "zenith") then
        return "Divine"
    end
    if string.find(sLower, "eternal") or string.find(sLower, "ninth") or string.find(sLower, "area9") or string.find(sLower, "area_9") or string.find(sLower, "area 9") or string.find(sLower, "tier9") or string.find(sLower, "tier_9") or string.find(sLower, "tier 9") or string.find(sLower, "heaven") or string.find(sLower, "angel") or string.find(sLower, "celestial") then
        return "Eternal"
    end
    if string.find(sLower, "secret") or string.find(sLower, "eighth") or string.find(sLower, "area8") or string.find(sLower, "area_8") or string.find(sLower, "area 8") or string.find(sLower, "tier8") or string.find(sLower, "tier_8") or string.find(sLower, "tier 8") or string.find(sLower, "demon") or string.find(sLower, "underworld") or string.find(sLower, "nightmare") then
        return "Secret"
    end
    if string.find(sLower, "cosmic") or string.find(sLower, "seventh") or string.find(sLower, "area7") or string.find(sLower, "area_7") or string.find(sLower, "area 7") or string.find(sLower, "tier7") or string.find(sLower, "tier_7") or string.find(sLower, "tier 7") or string.find(sLower, "galaxy") or string.find(sLower, "space") or string.find(sLower, "nebula") then
        return "Cosmic"
    end
    if string.find(sLower, "mythic") or string.find(sLower, "sixth") or string.find(sLower, "area6") or string.find(sLower, "area_6") or string.find(sLower, "area 6") or string.find(sLower, "tier6") or string.find(sLower, "tier_6") or string.find(sLower, "tier 6") or string.find(sLower, "cherryblossom") or string.find(sLower, "cherry") or string.find(sLower, "sakura") or string.find(sLower, "titantemple") or string.find(sLower, "titan") or string.find(sLower, "fantasy") then
        return "Mythic"
    end
    if string.find(sLower, "legendary") or string.find(sLower, "fifth") or string.find(sLower, "area5") or string.find(sLower, "area_5") or string.find(sLower, "area 5") or string.find(sLower, "tier5") or string.find(sLower, "tier_5") or string.find(sLower, "tier 5") or string.find(sLower, "abyssocean") or string.find(sLower, "abyss") or string.find(sLower, "ocean") or string.find(sLower, "prehistoric") or string.find(sLower, "dino") then
        return "Legendary"
    end
    if string.find(sLower, "epic") or string.find(sLower, "fourth") or string.find(sLower, "area4") or string.find(sLower, "area_4") or string.find(sLower, "area 4") or string.find(sLower, "tier4") or string.find(sLower, "tier_4") or string.find(sLower, "tier 4") or string.find(sLower, "volcano") or string.find(sLower, "valcano") or string.find(sLower, "lava") or string.find(sLower, "magma") or string.find(sLower, "jungle") then
        return "Epic"
    end
    if string.find(sLower, "uncommon") or string.find(sLower, "second") or string.find(sLower, "area2") or string.find(sLower, "area_2") or string.find(sLower, "area 2") or string.find(sLower, "tier2") or string.find(sLower, "tier_2") or string.find(sLower, "tier 2") or string.find(sLower, "desert") or string.find(sLower, "beach") or string.find(sLower, "sand") or string.find(sLower, "oasis") then
        return "Uncommon"
    end
    if string.find(sLower, "rare") or string.find(sLower, "third") or string.find(sLower, "area3") or string.find(sLower, "area_3") or string.find(sLower, "area 3") or string.find(sLower, "tier3") or string.find(sLower, "tier_3") or string.find(sLower, "tier 3") or string.find(sLower, "snow") or string.find(sLower, "ice") or string.find(sLower, "winter") or string.find(sLower, "arctic") or string.find(sLower, "lake") then
        return "Rare"
    end
    if string.find(sLower, "common") or string.find(sLower, "first") or string.find(sLower, "area1") or string.find(sLower, "area_1") or string.find(sLower, "area 1") or string.find(sLower, "tier1") or string.find(sLower, "tier_1") or string.find(sLower, "tier 1") or string.find(sLower, "forest") or string.find(sLower, "grass") or string.find(sLower, "spawn") or string.find(sLower, "starter") or string.find(sLower, "plains") then
        return "Common"
    end

    -- 2. Number extraction from names like "Area_4", "Egg-6", "Tier3", "Spot_2"
    local num = string.match(sLower, "area[ _%-]*(%d+)") or string.match(sLower, "tier[ _%-]*(%d+)") or string.match(sLower, "egg[ _%-]*(%d+)") or string.match(sLower, "slot[ _%-]*(%d+)") or string.match(sLower, "spot[ _%-]*(%d+)") or string.match(sLower, "^(%d+)")
    if num then
        local n = tonumber(num)
        if n and n >= 1 and n <= 10 then
            return RarityTiers[n]
        end
    end

    return nil
end

local function GetEggRarity(model, slot)
    if not model then return "Common" end

    local attrKeys = {"Rarity", "EggRarity", "Tier", "EggTier", "Area", "AreaIndex", "AreaNumber", "AreaId", "EggType", "AssetRarity", "Quality", "RarityName", "PetRarity", "RarityTier", "EggName", "PetName", "Id", "EggId", "Biome", "Zone"}

    -- 1. Direct Attributes on Model
    for _, attrName in ipairs(attrKeys) do
        local parsed = ParseVal(model:GetAttribute(attrName))
        if parsed then return parsed end
    end

    -- 2. ValueBase instances inside Model
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("ValueBase") or child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") then
            local parsed = ParseVal(child.Value) or ParseVal(child.Name)
            if parsed then return parsed end
        end
    end

    -- 3. Slot Attributes, Values & Slot Name
    if slot and slot ~= model then
        for _, attrName in ipairs(attrKeys) do
            local parsed = ParseVal(slot:GetAttribute(attrName))
            if parsed then return parsed end
        end
        for _, child in ipairs(slot:GetChildren()) do
            if child:IsA("ValueBase") or child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") then
                local parsed = ParseVal(child.Value) or ParseVal(child.Name)
                if parsed then return parsed end
            end
        end
        local parsedSlot = ParseVal(slot.Name)
        if parsedSlot then return parsedSlot end
    end

    -- 4. Check Ancestors (Parent, Grandparent, Area folders)
    local curr = model.Parent
    for _ = 1, 4 do
        if curr and curr ~= workspace then
            for _, attrName in ipairs(attrKeys) do
                local parsed = ParseVal(curr:GetAttribute(attrName))
                if parsed then return parsed end
            end
            local parsedParent = ParseVal(curr.Name)
            if parsedParent then return parsedParent end
            curr = curr.Parent
        else
            break
        end
    end

    -- 5. Check ProximityPrompt text & attributes
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true) or (slot and slot:FindFirstChildWhichIsA("ProximityPrompt", true))
    if prompt then
        for _, attrName in ipairs(attrKeys) do
            local parsed = ParseVal(prompt:GetAttribute(attrName))
            if parsed then return parsed end
        end
        local pText = tostring(prompt.ActionText) .. " " .. tostring(prompt.ObjectText) .. " " .. tostring(prompt.Name)
        local parsed = ParseVal(pText)
        if parsed then return parsed end
    end

    -- 6. Check Pet / Model Name against Known Pet lists
    local mName = string.lower(model.Name)
    for _, p in ipairs(KnownDivinePets) do if string.find(mName, p) then return "Divine" end end
    for _, p in ipairs(KnownEternalPets) do if string.find(mName, p) then return "Eternal" end end
    for _, p in ipairs(KnownSecretPets) do if string.find(mName, p) then return "Secret" end end
    for _, p in ipairs(KnownCosmicPets) do if string.find(mName, p) then return "Cosmic" end end
    for _, p in ipairs(KnownMythicPets) do if string.find(mName, p) then return "Mythic" end end
    for _, p in ipairs(KnownLegendaryPets) do if string.find(mName, p) then return "Legendary" end end
    for _, p in ipairs(KnownEpicPets) do if string.find(mName, p) then return "Epic" end end
    for _, p in ipairs(KnownRarePets) do if string.find(mName, p) then return "Rare" end end
    for _, p in ipairs(KnownUncommonPets) do if string.find(mName, p) then return "Uncommon" end end

    -- 7. Check Model Name itself
    local parsed = ParseVal(model.Name)
    if parsed then return parsed end

    -- 8. Check Descendant Part/Mesh/Texture/Decal Names
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
            local parsedText = ParseVal(desc.Text)
            if parsedText then return parsedText end
        end
        local parsedDesc = ParseVal(desc.Name)
        if parsedDesc then return parsedDesc end
    end

    -- 9. Check Physical 3D Position against Biomes & Area Centers (Guaranteed Fallback)
    local eggPos = nil
    if model:IsA("BasePart") then
        eggPos = model.Position
    else
        local p = model:FindFirstChild("HitBox") or model:FindFirstChild("Hitbox") or model:FindFirstChild("Part_Union") or model:FindFirstChildWhichIsA("BasePart", true) or (slot and (slot:IsA("BasePart") and slot or slot:FindFirstChildWhichIsA("BasePart", true)))
        if p then eggPos = p.Position end
    end

    if eggPos then
        local closestRarity = nil
        local closestDist = math.huge

        for _, biome in ipairs(BiomeRarities) do
            local d = (eggPos - biome.Pos).Magnitude
            if d < biome.Radius and d < closestDist then
                closestDist = d
                closestRarity = biome.Rarity
            end
        end

        if closestRarity then
            return closestRarity
        end
    end

    return "Common"
end

local function IsEggParasite(eggModel, slot)
    if not eggModel then return false end
    
    -- 1. Check direct attributes
    if eggModel:GetAttribute("Parasite") or eggModel:GetAttribute("IsParasite") or eggModel:GetAttribute("ParasiteEgg") or eggModel:GetAttribute("Infected") then
        return true
    end
    if slot and (slot:GetAttribute("Parasite") or slot:GetAttribute("IsParasite") or slot:GetAttribute("ParasiteEgg") or slot:GetAttribute("Infected")) then
        return true
    end

    -- 2. Check model name / slot name
    local eName = string.lower(eggModel.Name)
    local sName = slot and string.lower(slot.Name) or ""
    if string.find(eName, "parasite") or string.find(eName, "monster") or string.find(eName, "infected") or string.find(sName, "parasite") or string.find(sName, "monster") or string.find(sName, "infected") then
        return true
    end

    return false
end

-- =============================================================================
-- EGG STATE CLIENT MODULE BINDING (FASTEST RECORD SCANNING)
-- =============================================================================
local ClientFolder = ReplicatedStorage:FindFirstChild("Client")
local EggStateModule = nil
local function GetEggStateModule()
    if EggStateModule then return EggStateModule end
    pcall(function()
        if not ClientFolder then
            ClientFolder = ReplicatedStorage:FindFirstChild("Client")
        end
        if ClientFolder and ClientFolder:FindFirstChild("EggState") then
            EggStateModule = require(ClientFolder.EggState)
        end
    end)
    return EggStateModule
end

local function GetProximityPromptForEgg(eggPos)
    if not eggPos then return nil end
    local closetprompt = nil
    local closetdist = math.huge

    pcall(function()
        local CarryAreaEggs = (workspace.QueryDescendants and workspace:QueryDescendants("#CarryAreaEgg")) or CollectionService:GetTagged("CarryAreaEgg")
        if CarryAreaEggs then
            for _, prompt in pairs(CarryAreaEggs) do
                local actualPrompt = prompt:IsA("ProximityPrompt") and prompt or prompt:FindFirstChildWhichIsA("ProximityPrompt", true)
                local p = actualPrompt and actualPrompt.Parent
                if p and p:IsA("BasePart") then
                    local dist = (eggPos - p.Position).Magnitude
                    if dist < closetdist then
                        closetdist = dist
                        closetprompt = actualPrompt
                    end
                end
            end
        end
    end)

    if not closetprompt or closetdist > 25 then
        for prompt in pairs(cachedPrompts) do
            if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                local dist = (eggPos - prompt.Parent.Position).Magnitude
                if dist < closetdist then
                    closetdist = dist
                    closetprompt = prompt
                end
            end
        end
    end

    return closetprompt
end

local function FindBestEgg()
    local char = LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not hrp then return nil end

    -- 1. PRIMARY ENGINE: Read directly from game EggState records (100% accurate, instantaneous)
    local eggState = GetEggStateModule()
    if eggState and eggState.ReadFieldEggs then
        local s, fieldEggs = pcall(function() return eggState.ReadFieldEggs() end)
        if s and fieldEggs and fieldEggs.Records then
            local bestEgg = nil
            local bestScore = -1
            local closestDist = math.huge

            for key, data in pairs(fieldEggs.Records) do
                local areaId = tostring(data.AreaId or (data.Area and data.Area.Id) or "")
                local boundsCF = data.BoundsCFrame or data.CFrame
                local eggPos = boundsCF and boundsCF.Position

                if eggPos then
                    local matchArea = true
                    if SelectedArea and SelectedArea ~= "All" and SelectedArea ~= "---" then
                        local selClean = string.lower(string.gsub(SelectedArea, "[%s&]+", ""))
                        local areaClean = string.lower(string.gsub(areaId, "[%s&]+", ""))
                        matchArea = (areaClean == selClean) or string.find(areaClean, selClean) or string.find(selClean, areaClean)
                    end

                    local matchRarity = true
                    local eggRarity = tostring(data.Rarity or data.EggRarity or data.Type or "")
                    if SelectedRarity and SelectedRarity ~= "All" and SelectedRarity ~= "---" then
                        local targetRarity = string.lower(SelectedRarity)
                        local rClean = string.lower(eggRarity)
                        matchRarity = (rClean == targetRarity) or string.find(rClean, targetRarity) or string.find(targetRarity, rClean)
                    end

                    local matchParasite = true
                    local isParasite = data.IsParasite or data.Parasite or false
                    if SelectedPriority == "Parasite Eggs Only" or SelectedPriority == "Only Parasite Eggs" then
                        matchParasite = isParasite
                    end

                    if matchArea and matchRarity and matchParasite then
                        local dist = (hrp.Position - eggPos).Magnitude
                        local areaIdx = table.find(AreaOrder, areaId) or 0
                        local weight = tonumber(data.Scale or data.Weight or data.AssetScale or 1) or 1

                        if SelectedArea and SelectedArea ~= "All" and SelectedArea ~= "---" then
                            if dist < closestDist then
                                closestDist = dist
                                bestEgg = { Pos = eggPos, BoundsCFrame = boundsCF, Data = data, AreaId = areaId, Weight = weight }
                            end
                        elseif SelectedPriority == "Highest KG First" then
                            if weight > bestScore or (weight == bestScore and dist < closestDist) then
                                bestScore = weight
                                closestDist = dist
                                bestEgg = { Pos = eggPos, BoundsCFrame = boundsCF, Data = data, AreaId = areaId, Weight = weight }
                            end
                        elseif SelectedPriority == "Lowest KG First" then
                            if bestScore == -1 or weight < bestScore or (weight == bestScore and dist < closestDist) then
                                bestScore = weight
                                closestDist = dist
                                bestEgg = { Pos = eggPos, BoundsCFrame = boundsCF, Data = data, AreaId = areaId, Weight = weight }
                            end
                        else
                            if areaIdx > bestScore or (areaIdx == bestScore and dist < closestDist) then
                                bestScore = areaIdx
                                closestDist = dist
                                bestEgg = { Pos = eggPos, BoundsCFrame = boundsCF, Data = data, AreaId = areaId, Weight = weight }
                            end
                        end
                    end
                end
            end

            if bestEgg then
                local prompt = GetProximityPromptForEgg(bestEgg.Pos)
                local part = (prompt and prompt.Parent and prompt.Parent:IsA("BasePart") and prompt.Parent)
                if not part then
                    part = { Position = bestEgg.Pos, CFrame = bestEgg.BoundsCFrame }
                end
                return part, prompt and prompt:FindFirstAncestorOfClass("Model"), prompt and prompt.Parent, bestEgg
            end
        end
    end

    -- 2. SECONDARY FALLBACK: Scan physical workspace instances if EggState is not loaded
    local eggSlots = workspace:FindFirstChild("AreaEggSlotsClient")
    local candidates = {}

    local function CheckEgg(eggModel, slot)
        if not eggModel or eggModel == char or eggModel:IsDescendantOf(char) then return end
        local eName = string.lower(eggModel.Name)
        if not (string.find(eName, "egg") or eggModel:GetAttribute("Egg") or eggModel:FindFirstChild("Egg") or (slot and string.find(string.lower(slot.Name), "egg"))) then return end

        local hitPart = eggModel:FindFirstChild("HitBox") or eggModel:FindFirstChild("Hitbox") or eggModel:FindFirstChild("Part_Union") or eggModel:FindFirstChild("Handle") or (eggModel:IsA("BasePart") and eggModel) or eggModel:FindFirstChildWhichIsA("BasePart", true)
        if not hitPart then return end

        local dist = (hrp.Position - hitPart.Position).Magnitude
        if dist < 1.5 then return end

        -- 1. Area / Biome Filter
        if SelectedArea and SelectedArea ~= "All" and SelectedArea ~= "---" then
            if not IsEggInArea(hitPart.Position, SelectedArea) then
                return
            end
        end

        -- 2. Strict Rarity Filter
        if SelectedRarity and SelectedRarity ~= "All" and SelectedRarity ~= "---" then
            local targetRarity = string.lower(SelectedRarity)
            local eggRarity = string.lower(GetEggRarity(eggModel, slot))

            if eggRarity ~= targetRarity and not string.find(eggRarity, targetRarity) and not string.find(targetRarity, eggRarity) then
                return
            end
        end

        -- 3. Parasite Egg Only Filter
        local isParasite = IsEggParasite(eggModel, slot)
        if SelectedPriority == "Parasite Eggs Only" or SelectedPriority == "Only Parasite Eggs" then
            if not isParasite then
                return
            end
        end

        local scale = tonumber(eggModel:GetAttribute("Scale") or eggModel:GetAttribute("AssetScale") or 1)
        table.insert(candidates, {
            Part = hitPart,
            Model = eggModel,
            Slot = slot,
            Dist = dist,
            Weight = scale,
            IsParasite = isParasite
        })
    end

    if eggSlots then
        for _, slot in pairs(eggSlots:GetChildren()) do
            for _, egg in pairs(slot:GetChildren()) do
                CheckEgg(egg, slot)
            end
            if slot:IsA("Model") and (string.find(string.lower(slot.Name), "egg") or slot:GetAttribute("Rarity")) then
                CheckEgg(slot, slot)
            end
        end
    end

    -- Check GuardAreas
    local guardAreas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
    if guardAreas then
        for _, gArea in pairs(guardAreas:GetChildren()) do
            local nests = gArea:FindFirstChild("Nests")
            if nests then
                for _, nest in pairs(nests:GetChildren()) do
                    CheckEgg(nest, nest)
                    for _, egg in pairs(nest:GetChildren()) do
                        CheckEgg(egg, nest)
                        for _, sub in pairs(egg:GetChildren()) do
                            CheckEgg(sub, nest)
                        end
                    end
                end
            end
            for _, child in pairs(gArea:GetChildren()) do
                if child.Name ~= "Nests" then
                    CheckEgg(child, gArea)
                    for _, sub in pairs(child:GetChildren()) do
                        CheckEgg(sub, child)
                    end
                end
            end
        end
    end

    -- Also check workspace event, witch, and special eggs
    for _, obj in pairs(workspace:GetChildren()) do
        local oName = string.lower(obj.Name)
        if string.find(oName, "witch") or string.find(oName, "event") or string.find(oName, "parasite") or string.find(oName, "monster") or string.find(oName, "special") or (string.find(oName, "egg") and obj:IsA("Model")) then
            if obj ~= char and not obj:IsDescendantOf(char) then
                CheckEgg(obj, obj)
                for _, child in pairs(obj:GetChildren()) do
                    CheckEgg(child, obj)
                end
            end
        end
    end

    if #candidates == 0 then return nil end

    -- Priority sorting
    if SelectedRarity and SelectedRarity ~= "All" and SelectedRarity ~= "---" then
        table.sort(candidates, function(a, b) return a.Dist < b.Dist end)
    elseif SelectedPriority == "Highest KG First" then
        table.sort(candidates, function(a, b) return a.Weight > b.Weight end)
    elseif SelectedPriority == "Lowest KG First" then
        table.sort(candidates, function(a, b) return a.Weight < b.Weight end)
    elseif SelectedPriority == "Parasite Eggs Only" or SelectedPriority == "Only Parasite Eggs" then
        table.sort(candidates, function(a, b) return a.Dist < b.Dist end)
    else
        table.sort(candidates, function(a, b) return a.Dist < b.Dist end)
    end

    return candidates[1].Part, candidates[1].Model, candidates[1].Slot
end

-- =============================================================================
-- INSTANT PROXIMITY PROMPT & AUTO-E PICKUP ENGINE (ZERO-LAG EVENT DRIVEN)
-- =============================================================================
local ProximityPromptService = game:GetService("ProximityPromptService")
local cachedPrompts = {}
local AutoRegrabEgg = false
local InstantPickup = false

local function EnforceInstantPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        if InstantPickup or AutoStealSelected or AutoRegrabEgg or AutoStealOnPickup then
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
            prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 35)
            prompt.ClickablePrompt = true
        end
        prompt.Enabled = true
        cachedPrompts[prompt] = true
    end
end

-- Non-blocking initial scan (defers to background)
task.defer(function()
    local eggSlots = workspace:FindFirstChild("AreaEggSlotsClient")
    if eggSlots then
        for _, desc in ipairs(eggSlots:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                EnforceInstantPrompt(desc)
            end
        end
    end
    local objects = workspace:FindFirstChild("__OBJECTS")
    if objects then
        for _, desc in ipairs(objects:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                EnforceInstantPrompt(desc)
            end
        end
    end
end)

-- Event listeners for new/removed prompts (0 CPU overhead)
workspace.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        EnforceInstantPrompt(desc)
    end
end)

workspace.DescendantRemoving:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        cachedPrompts[desc] = nil
    end
end)

local currentTargetEggModel = nil

local function DoesPromptMatchTarget(prompt)
    if AutoRegrabEgg then return true end
    if not AutoStealSelected then return false end

    -- 1. If targeting a specific egg resolved by FindBestEgg
    if currentTargetEggModel and (prompt:IsDescendantOf(currentTargetEggModel) or prompt.Parent == currentTargetEggModel) then
        return true
    end

    -- 2. Strict Rarity Validation (e.g. Secret eggs)
    if SelectedRarity and SelectedRarity ~= "All" and SelectedRarity ~= "---" then
        local targetRarity = string.lower(SelectedRarity)
        local pModel = prompt:FindFirstAncestorOfClass("Model")
        if pModel then
            local r = string.lower(GetEggRarity(pModel, pModel.Parent))
            if r == targetRarity or string.find(r, targetRarity) or string.find(targetRarity, r) then
                return true
            end
        end
        return false -- STRICT REJECT: Do not pickup wrong rarity egg!
    end

    -- 3. Strict Parasite Validation
    if SelectedPriority == "Parasite Eggs Only" or SelectedPriority == "Only Parasite Eggs" then
        local pModel = prompt:FindFirstAncestorOfClass("Model")
        if pModel then
            if IsEggParasite(pModel, pModel.Parent) then
                return true
            end
        end
        return false
    end

    return true
end

-- Dropped Egg Locator (Fast native spatial query without workspace hierarchy scanning)
local function FindDroppedEggNearPlayer(maxRadius)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local radius = maxRadius or 32
    local closestDist = radius
    local bestPart = nil
    local bestModel = nil
    local bestSlot = nil

    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = {char}

    local parts = workspace:GetPartBoundsInRadius(hrp.Position, radius, overlapParams)
    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model ~= char and not model:IsDescendantOf(char) then
            local mName = string.lower(model.Name)
            if string.find(mName, "egg") or model:GetAttribute("Egg") or model:FindFirstChild("Egg") then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist <= closestDist then
                    closestDist = dist
                    bestPart = part
                    bestModel = model
                    bestSlot = model.Parent
                end
            end
        end
    end

    return bestPart, bestModel, bestSlot, closestDist
end

-- Trigger Instant Egg Pickup on any target egg
local function TriggerInstantEggPickup(eggPart, eggModel, eggSlot, eggData)
    if not eggPart and not eggData then return end
    local char = LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not hrp then return end

    local eggPos = (eggPart and eggPart.Position) or (eggData and eggData.Pos)

    -- 1. Targeted ProximityPrompt from EggState / CarryAreaEgg Tag Query
    if eggPos then
        local eggPrompt = GetProximityPromptForEgg(eggPos)
        if eggPrompt then
            EnforceInstantPrompt(eggPrompt)
            if fireproximityprompt then
                fireproximityprompt(eggPrompt, 0)
            end
            pcall(function()
                eggPrompt:InputHoldBegin()
                task.wait(0.005)
                eggPrompt:InputHoldEnd()
            end)
        end
    end

    -- 2. Proximity Prompts & Click Detectors on Model
    if eggModel and typeof(eggModel) == "Instance" then
        for _, prompt in pairs(eggModel:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                EnforceInstantPrompt(prompt)
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                end
                pcall(function()
                    prompt:InputHoldBegin()
                    task.wait(0.005)
                    prompt:InputHoldEnd()
                end)
            elseif prompt:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(prompt)
            end
        end
    end

    -- 3. Physical Touch Interest
    if firetouchinterest and eggPart and typeof(eggPart) == "Instance" and eggPart:IsA("BasePart") then
        firetouchinterest(hrp, eggPart, 0)
        task.wait(0.005)
        firetouchinterest(hrp, eggPart, 1)
    end

    -- 4. Remote Pickups
    local carryRemote = GetRemote("RF/EggWorld/AskFieldEggCarry") or GetRemote("RF/EggWorld/AskFieldEggPickup") or GetRemote("RE/EggWorld/PickupEgg")
    if carryRemote then
        pcall(function()
            if eggSlot and typeof(eggSlot) == "Instance" then
                carryRemote:InvokeServer(eggSlot.Name)
            elseif eggModel and typeof(eggModel) == "Instance" then
                carryRemote:InvokeServer(eggModel.Name)
            end
        end)
    end
end

-- Auto-Trigger prompt when Auto Steal OR Guard Regrab is active
pcall(function()
    ProximityPromptService.PromptShown:Connect(function(prompt)
        EnforceInstantPrompt(prompt)
        if (AutoStealSelected and DoesPromptMatchTarget(prompt)) or AutoRegrabEgg then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and prompt.Parent then
                local pPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart", true)
                if pPart and (hrp.Position - pPart.Position).Magnitude <= 35 then
                    if fireproximityprompt then
                        fireproximityprompt(prompt, 0)
                    end
                    pcall(function()
                        prompt:InputHoldBegin()
                        task.wait(0.005)
                        prompt:InputHoldEnd()
                    end)
                end
            end
        end
    end)
end)

-- Dedicated High-Speed Instant Auto-Regrab Engine (Runs every 0.015s)
task.spawn(function()
    local wasHolding = false
    while true do
        task.wait(0.015)
        local isHolding = IsHoldingEgg()

        -- If AutoRegrabEgg toggle is ON or we were holding an egg and suddenly dropped it (guard hit):
        if AutoRegrabEgg or (wasHolding and not isHolding) then
            if not isHolding then
                local eggPart, eggModel, eggSlot, dist = FindDroppedEggNearPlayer(32)
                if eggPart and dist <= 32 then
                    TriggerInstantEggPickup(eggPart, eggModel, eggSlot)
                end
            end
        end

        wasHolding = isHolding
    end
end)

-- Ultra-lightweight background Auto-Pickup Loop
task.spawn(function()
    while true do
        task.wait(0.03)
        if AutoStealSelected or AutoRegrabEgg then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for prompt, _ in pairs(cachedPrompts) do
                    if prompt and prompt.Parent and prompt.Enabled and DoesPromptMatchTarget(prompt) then
                        local pPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart", true)
                        if pPart then
                            local dist = (hrp.Position - pPart.Position).Magnitude
                            if dist <= 32 then
                                if fireproximityprompt then
                                    fireproximityprompt(prompt, 0)
                                end
                                pcall(function()
                                    prompt:InputHoldBegin()
                                    task.wait(0.005)
                                    prompt:InputHoldEnd()
                                end)
                            end
                        end
                    elseif prompt and not prompt.Enabled then
                        cachedPrompts[prompt] = nil
                    end
                end
            end)
        end
    end
end)

-- =============================================================================
-- ULTRA SPEED BYPASS & HOOK ENGINE (ANTI-CHEAT NEUTRALIZER)
-- =============================================================================
local ManualSpeed = 16
local currentTargetPos = nil
local stuckCheckPos = nil
local stuckCounter = 0
local lastNoEggNotify = 0
local speedActive = false

local speedBypass = {
    RunService = game:GetService("RunService"),
    Players = game:GetService("Players")
}

speedBypass.collectgarbage = function()
    local s, r = pcall(function(...)
        return getgc()
    end)
    if s and r then
        return r    
    end
    return {}
end

speedBypass.safehook = function(f, c)
    local s, r = pcall(function(...)
        if newlclosure then
            return hookfunction(f, newlclosure(c))
        else
            return hookfunction(f, c)
        end
    end)
    if s and r then
        return r    
    end
    return nil
end

function speedBypass:findfunction(nups, linedefined)
    local s, r = pcall(function(...)
        for _, f in next, self.collectgarbage() do
            if typeof(f) == 'function' and islclosure(f) then
                local upvs = debug.getupvalues(f)
                local line = debug.info(f, "l")

                if upvs and #upvs == nups and line == linedefined then
                    if nups == 10 then
                        local t = debug.getupvalue(f, 3)
                        if typeof(t) == "table" and rawget(t, "Humanoid") then
                            return f
                        end
                    else
                        return f
                    end
                end
            end
        end

        return nil
    end)

    if s and r then
        return r
    end

    return nil
end

local isBypassHooked = false
function speedBypass:initbypass()
    if isBypassHooked then return end
    self.LocalPlayer = self.Players.LocalPlayer or LocalPlayer

    if not getgc or not hookfunction or not islclosure then
        return
    end

    pcall(function()
        local func3 = self:findfunction(19, 634)
        if not func3 then return end

        local v7 = debug.getupvalue(func3, 2)
        if not v7 then return end

        local hookedfunc3; hookedfunc3 = self.safehook(v7, function(p1, p2)
            if p2 and typeof(p2) == "table" then
                setmetatable(p2, {})
            end
            return hookedfunc3(p1, p2)
        end)
        isBypassHooked = true
    end)
end

-- Initialize Speed Bypass Hook
pcall(function() speedBypass:initbypass() end)

local function getCurrentHumanoid()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

local function stopSpeedModifications()
    speedActive = false
    currentTargetPos = nil

    local character = LocalPlayer.Character
    if character then
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = SuperSpeedActive and 500 or (ManualSpeed or 16)
            hum.JumpPower = 50
            hum.AutoRotate = true
            hum.PlatformStand = false
            hum.Sit = false
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end)
        end
    end
end

local function startSpeedModifications(humanoid)
    pcall(function() speedBypass:initbypass() end)
    local hum = humanoid or getCurrentHumanoid()
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        end)
    end
end

local function activateBypass()
    pcall(function() speedBypass:initbypass() end)
    local hum = getCurrentHumanoid()
    if hum then
        startSpeedModifications(hum)
    end
end

-- Global Heartbeat Speed Engine (Pure Natural Walking Animations at 500 Speed)
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end

    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local desiredSpeed = (speedActive and 500) or (SuperSpeedActive and 500) or (ManualSpeed or 16)
    if hum.WalkSpeed ~= desiredSpeed then
        hum.WalkSpeed = desiredSpeed
    end

    if currentTargetPos and speedActive then
        hum:MoveTo(currentTargetPos)
    end
end)

-- Global Jump Engine: Multi-Input (Space, Mobile Button, Controller & JumpRequest)
local lastJumpTick = 0

local function PerformJump()
    local now = tick()
    if now - lastJumpTick < 0.22 then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
    if hum and hrp and hum.Health > 0 then
        lastJumpTick = now
        hum.Jump = true
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        local jPower = 50
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, jPower, hrp.AssemblyLinearVelocity.Z)
    end
end

pcall(function()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA) then
            PerformJump()
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        PerformJump()
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.35)
    activateBypass()
end)

getgenv().SAE = {
    setSpeed = function(speed)
        ManualSpeed = speed
    end,
    setWalkSpeed = function(walkSpeed)
        ManualSpeed = walkSpeed
    end,
    getBypassedHum = function()
        return getCurrentHumanoid()
    end,
    rebypass = function()
        activateBypass()
    end
}

-- =============================================================================
-- CORE AUTO-STEAL RUNNER ENGINE (SMOOTH, LAG-FREE, ZERO-JITTER)
-- =============================================================================
-- =============================================================================
-- CORE AUTO-STEAL RUNNER ENGINE (HIGH-SPEED GOTO INTERPOLATION & GRABBER)
-- =============================================================================
local function GoToTarget(pos, isApproachingEgg)
    pcall(function(...)
        local dist = math.huge
        local targetPos = (pos and pos.BoundsCFrame and pos.BoundsCFrame.Position) or (pos and pos.Position) or pos
        if not targetPos then return end

        local startTime = tick()
        repeat
            if not AutoStealSelected and not AutoStealOnPickup then break end
            
            -- If we are approaching an egg and pick it up at any millisecond, immediately abort approach and return
            if isApproachingEgg and IsHoldingEgg() then break end
            
            -- If returning to safe zone in OnPickup mode and egg is claimed or dropped, stop immediately
            if not isApproachingEgg and AutoStealOnPickup and not IsHoldingEgg() then break end

            local dt = task.wait(0.01)
            local char = LocalPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
            if not hrp or not char then break end

            local start = hrp.Position
            dist = (targetPos - start).Magnitude
            if dist <= 5 then break end

            local half = start + (targetPos - start).Unit * dt * 430
            char:MoveTo(half)
        until dist <= 5 or (tick() - startTime > 15)
    end)
end

local function GetEggProximityPrompt(egg)
    local eggPos = (egg and egg.BoundsCFrame and egg.BoundsCFrame.Position) or (egg and egg.Pos) or (egg and egg.Position)
    if not eggPos then return nil end
    local s, r = pcall(function(...)
        local CarryAreaEggs = (workspace.QueryDescendants and workspace:QueryDescendants("#CarryAreaEgg")) or CollectionService:GetTagged("CarryAreaEgg")
        local closetprompt = nil
        local closetdist = math.huge
        if CarryAreaEggs then
            for key, prompt in next, CarryAreaEggs do
                local p = prompt:IsA("ProximityPrompt") and prompt.Parent or (prompt:FindFirstChildWhichIsA("ProximityPrompt", true) and prompt:FindFirstChildWhichIsA("ProximityPrompt", true).Parent)
                if p and p:IsA("BasePart") then
                    local dist = (eggPos - p.Position).Magnitude
                    if dist < closetdist then
                        closetdist = dist
                        closetprompt = prompt:IsA("ProximityPrompt") and prompt or prompt:FindFirstChildWhichIsA("ProximityPrompt", true)
                    end
                end
            end
        end
        return closetprompt
    end)
    if s and r and r ~= nil then
        return r
    end
    return GetProximityPromptForEgg(eggPos)
end

task.spawn(function()
    while true do
        if AutoStealSelected then
            pcall(function(...)
                local eggPart, eggModel, eggSlot, eggData = FindBestEgg()
                local targetEgg = eggData or (eggPart and { BoundsCFrame = CFrame.new(eggPart.Position), Position = eggPart.Position })

                local safePos = CustomSafeZone and CustomSafeZone.Position or Vector3.new(514, 71, -368)
                local safeTarget = { BoundsCFrame = CFrame.new(safePos) }

                if targetEgg and AutoStealSelected then
                    -- 1. Deliver already held egg first if player already has an egg
                    if IsHoldingEgg() then
                        if not speedActive then
                            speedActive = true
                            activateBypass()
                        end
                        GoToTarget(safeTarget, false)
                        task.wait(0.05)
                    end

                    -- 2. Go to Target Egg (passes isApproachingEgg = true so it breaks the exact millisecond an egg is grabbed)
                    if not IsHoldingEgg() and AutoStealSelected then
                        GoToTarget(targetEgg, true)
                    end

                    -- 3. Grab Egg immediately
                    if not IsHoldingEgg() and AutoStealSelected then
                        local p = GetEggProximityPrompt(targetEgg)
                        if p and fireproximityprompt then
                            fireproximityprompt(p, 0)
                            pcall(function()
                                p:InputHoldBegin()
                                task.wait(0.01)
                                p:InputHoldEnd()
                            end)
                        end

                        -- Fast wait loop: proceeds the millisecond the egg enters hands (0 delay)
                        local grabStart = tick()
                        repeat
                            task.wait(0.01)
                        until IsHoldingEgg() or (tick() - grabStart > 0.35)

                        if not IsHoldingEgg() and p and fireproximityprompt then
                            fireproximityprompt(p, 0)
                        end
                    end

                    -- 4. Instantly Return to Safe Zone with Egg
                    if IsHoldingEgg() and AutoStealSelected then
                        if not speedActive then
                            speedActive = true
                            activateBypass()
                        end
                        GoToTarget(safeTarget, false)

                        -- Safe zone auto-claim trigger
                        local char = LocalPlayer.Character
                        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
                        if hrp and firetouchinterest then
                            local startArea = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("StartArea")
                            if startArea then
                                local touchPart = startArea:IsA("BasePart") and startArea or startArea:FindFirstChildWhichIsA("BasePart", true)
                                if touchPart then
                                    firetouchinterest(hrp, touchPart, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, touchPart, 1)
                                end
                            end
                        end
                    end
                else
                    GoToTarget(safeTarget, false)
                    task.wait(0.2)
                end
            end)
            task.wait(0.01)
        else
            task.wait(0.25)
        end
    end
end)

-- Auto Steal (On Pickup) Dedicated Runner (Auto-Activates on Pickup -> Deactivates on Claim)
task.spawn(function()
    while true do
        task.wait(0.01)
        if AutoStealOnPickup then
            pcall(function(...)
                local isHolding = IsHoldingEgg()
                local safePos = CustomSafeZone and CustomSafeZone.Position or Vector3.new(514, 71, -368)
                local safeTarget = { BoundsCFrame = CFrame.new(safePos) }

                if isHolding then
                    -- EGG IN HAND: Auto activate 500 speed & sprint immediately to safe zone
                    if not speedActive then
                        speedActive = true
                        activateBypass()
                    end

                    -- Drive player directly to safe zone
                    GoToTarget(safeTarget, false)

                    local char = LocalPlayer.Character
                    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
                    if hrp then
                        local distToSafe = (hrp.Position - safePos).Magnitude
                        if distToSafe <= 25 and firetouchinterest then
                            local startArea = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("StartArea")
                            if startArea then
                                local touchPart = startArea:IsA("BasePart") and startArea or startArea:FindFirstChildWhichIsA("BasePart", true)
                                if touchPart then
                                    firetouchinterest(hrp, touchPart, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, touchPart, 1)
                                end
                            end
                        end
                    end
                else
                    -- NO EGG IN HAND / CLAIMED: Immediately deactivate speed script & restore normal speed
                    if speedActive or currentTargetPos then
                        speedActive = false
                        currentTargetPos = nil
                        stopSpeedModifications()
                    end
                end
            end)
        end
    end
end)

-- =============================================================================
-- COMBAT & DEFENSE ENGINE
-- =============================================================================
-- Bat Kill Aura (High Accuracy Server Seed Engine)
local ToolGameplayGuard = nil
pcall(function()
    local clientFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Client")
    if clientFolder and clientFolder:FindFirstChild("ToolGameplayGuard") then
        ToolGameplayGuard = require(clientFolder.ToolGameplayGuard)
    end
end)

local function CreateBatSeed()
    local s, r = pcall(function()
        return ("%*:%*:%*"):format(LocalPlayer.UserId, 100, (math.floor(workspace:GetServerTimeNow() * 1000)))
    end)
    if s and r then
        return r
    end
    return tostring(LocalPlayer.UserId) .. ":100:" .. tostring(math.floor(workspace:GetServerTimeNow() * 1000))
end

local function GetClosestAuraTarget(maxDist)
    local target = nil
    local closestDist = maxDist or (AuraRange or 16.5)

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local tChar = p.Character
            local tHum = tChar:FindFirstChildOfClass("Humanoid")
            local tHrp = tChar.HumanoidRootPart
            if tHum and tHum.Health > 0 then
                local dist = (hrp.Position - tHrp.Position).Magnitude
                if dist <= closestDist then
                    closestDist = dist
                    target = p
                end
            end
        end
    end
    return target
end

local function CanUseBatTool()
    local char = LocalPlayer.Character
    if not char then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    if ToolGameplayGuard and ToolGameplayGuard.IsLocalInsideArena then
        local isInside = true
        pcall(function()
            if not ToolGameplayGuard.IsLocalInsideArena() then
                isInside = false
            end
        end)
        if not isInside then return false end
    end

    if workspace:GetAttribute("Event_MonsterEvent") then
        if hrp.Position.Z > -268 then
            return true
        end
        return false
    end

    return true
end

task.spawn(function()
    while true do
        task.wait(AttackDelay or 0.1)
        if BatKillAura then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                if AutoEquipBat then
                    local bat = LocalPlayer.Backpack:FindFirstChild("Bat") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                    if bat and not char:FindFirstChild(bat.Name) then
                        bat.Parent = char
                    end
                end

                local target = GetClosestAuraTarget(AuraRange or 16.5)
                if target and CanUseBatTool() then
                    local batTrigger = GetRemote("RE/BatSwing/Trigger")
                    local seed = CreateBatSeed()
                    if batTrigger then
                        pcall(function()
                            batTrigger:FireServer(target, seed)
                        end)
                    end

                    local equippedTool = char:FindFirstChildWhichIsA("Tool")
                    if equippedTool then
                        equippedTool:Activate()
                    end
                end
            end)
        end
    end
end)

-- Anti-Guard Hit / Anti-Knockback
task.spawn(function()
    while true do
        task.wait(0.5)
        if AntiGuardHit then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("TouchTransmitter") then
                            part:Destroy()
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Enter Boss Arena / Rift Portal Loop (workspace.BossArenaTeleport)
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoEnterBossArena then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                local bossPortal = workspace:FindFirstChild("BossArenaTeleport") or workspace:FindFirstChild("BossArenaTeleport", true)
                if bossPortal then
                    local portalPart = (bossPortal:IsA("BasePart") and bossPortal) or bossPortal:FindFirstChildWhichIsA("BasePart", true) or (bossPortal:IsA("Model") and bossPortal.PrimaryPart)
                    if portalPart then
                        local dist = (hrp.Position - portalPart.Position).Magnitude

                        -- 1. Sprint towards portal using bypassed humanoid speed engine
                        if dist > 6 then
                            currentTargetPos = portalPart.Position
                            if not speedActive then
                                speedActive = true
                                local bypassHum = clonedHumanoid
                                if not bypassHum or bypassHum.Parent ~= char then
                                    bypassHum = createBypassedHumanoid() or hum
                                end
                                if bypassHum then
                                    startSpeedModifications(bypassHum)
                                end
                            end
                            hum:MoveTo(portalPart.Position)
                        else
                            currentTargetPos = nil
                            speedActive = false
                        end

                        -- 2. Physical Touch & Proximity Prompt Entry
                        if dist <= 25 then
                            if firetouchinterest then
                                firetouchinterest(hrp, portalPart, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, portalPart, 1)
                            end

                            for _, prompt in pairs(bossPortal:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") then
                                    prompt.HoldDuration = 0
                                    prompt.RequiresLineOfSight = false
                                    prompt.MaxActivationDistance = 50
                                    if fireproximityprompt then
                                        fireproximityprompt(prompt, 0)
                                    end
                                    pcall(function()
                                        prompt:InputHoldBegin()
                                        task.wait(0.01)
                                        prompt:InputHoldEnd()
                                    end)
                                elseif prompt:IsA("ClickDetector") and fireclickdetector then
                                    fireclickdetector(prompt)
                                end
                            end

                            -- 3. Check for any Boss / Rift enter remotes
                            local enterRemote = GetRemote("RF/Boss/Enter") or GetRemote("RF/Rift/Enter") or GetRemote("RE/BossArena/Enter") or GetRemote("RF/BossArenaTeleport/Enter") or GetRemote("RE/Rift/Enter")
                            if enterRemote then
                                if enterRemote:IsA("RemoteFunction") then
                                    enterRemote:InvokeServer()
                                else
                                    enterRemote:FireServer()
                                end
                            end
                        end
                    end
                else
                    if not AutoStealSelected and not AutoStealOnPickup and not AutoAttackCrystalTowers then
                        currentTargetPos = nil
                        if speedActive then
                            stopSpeedModifications()
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Attack Crystal Towers Loop (workspace.BossArena.CrystalTowers)
task.spawn(function()
    while true do
        task.wait(0.08)
        if AutoAttackCrystalTowers then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hrp or not hum or hum.Health <= 0 then return end

                -- Auto equip bat if in backpack
                local bat = LocalPlayer.Backpack:FindFirstChild("Bat") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                if bat and not char:FindFirstChild(bat.Name) then
                    bat.Parent = char
                end

                -- Find closest active Crystal Tower
                local bossArena = workspace:FindFirstChild("BossArena") or workspace:FindFirstChild("BossArena", true)
                local towersFolder = bossArena and (bossArena:FindFirstChild("CrystalTowers") or bossArena:FindFirstChild("Crystal_Towers") or bossArena:FindFirstChild("Towers"))
                if not towersFolder then
                    towersFolder = workspace:FindFirstChild("CrystalTowers", true)
                end

                local targetTowerPart = nil
                local targetTowerModel = nil
                local closestDist = math.huge

                if towersFolder then
                    for _, tower in pairs(towersFolder:GetChildren()) do
                        local tPart = (tower:IsA("BasePart") and tower) or tower:FindFirstChildWhichIsA("BasePart", true) or (tower:IsA("Model") and tower.PrimaryPart)
                        if tPart then
                            local hp = tower:GetAttribute("Health") or tower:GetAttribute("HP")
                            local isDestroyed = (hp and tonumber(hp) <= 0) or (tower:GetAttribute("Destroyed") == true)
                            if not isDestroyed then
                                local dist = (hrp.Position - tPart.Position).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    targetTowerPart = tPart
                                    targetTowerModel = tower
                                end
                            end
                        end
                    end
                end

                if targetTowerPart then
                    -- 1. Sprint towards tower using bypassed humanoid velocity propulsion
                    if closestDist > 10 then
                        currentTargetPos = targetTowerPart.Position
                        if not speedActive then
                            speedActive = true
                            local bypassHum = clonedHumanoid
                            if not bypassHum or bypassHum.Parent ~= char then
                                bypassHum = createBypassedHumanoid() or hum
                            end
                            if bypassHum then
                                startSpeedModifications(bypassHum)
                            end
                        end
                        hum:MoveTo(targetTowerPart.Position)
                    else
                        currentTargetPos = nil
                        speedActive = false
                    end

                    -- 2. Attack Tower with Bat & Remote Trigger
                    if closestDist <= 28 then
                        local batTrigger = GetRemote("RE/BatSwing/Trigger")
                        local seed = CreateBatSeed()
                        if batTrigger then
                            pcall(function()
                                batTrigger:FireServer(targetTowerModel or targetTowerPart, seed)
                            end)
                        end

                        local equippedTool = char:FindFirstChildWhichIsA("Tool")
                        if equippedTool then
                            equippedTool:Activate()
                        end

                        if firetouchinterest then
                            firetouchinterest(hrp, targetTowerPart, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, targetTowerPart, 1)
                        end

                        for _, prompt in pairs((targetTowerModel or targetTowerPart):GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                prompt.HoldDuration = 0
                                if fireproximityprompt then fireproximityprompt(prompt, 0) end
                                pcall(function() prompt:InputHoldBegin() task.wait(0.01) prompt:InputHoldEnd() end)
                            elseif prompt:IsA("ClickDetector") and fireclickdetector then
                                fireclickdetector(prompt)
                            end
                        end
                    end
                else
                    if not AutoStealSelected and not AutoStealOnPickup and not AutoEnterBossArena then
                        currentTargetPos = nil
                        if speedActive then
                            stopSpeedModifications()
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Keep BossShop at Safe Zone Loop (workspace.BossArena.BossShopStand)
local function TeleportBossShopToSafeZone()
    local shop = (workspace:FindFirstChild("BossArena") and workspace.BossArena:FindFirstChild("BossShopStand")) or workspace:FindFirstChild("BossShopStand", true)
    if shop then
        local safePos = GetSafeZonePos()
        local targetCFrame = CFrame.new(safePos + Vector3.new(6, 2, 6))
        pcall(function()
            if shop:IsA("Model") then
                shop:PivotTo(targetCFrame)
            elseif shop:IsA("BasePart") then
                shop.CFrame = targetCFrame
            end
            for _, part in pairs(shop:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end
        end)
        return true
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(1.0)
        if AutoTeleportBossShop then
            pcall(function()
                TeleportBossShopToSafeZone()
            end)
        end
    end
end)

-- =============================================================================
-- AUTOMATION REPEAT LOOPS
-- =============================================================================
local WalkableTreadmill = false
local AutoCollectAwayEarnings = false

local function TriggerAwayEarningsCollection()
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))

        -- 1. Remote Invocations
        local awayRemote = GetRemote("RF/AwayEarnings/AskCollect") or GetRemote("RF/OfflineEarnings/AskCollect")
        if awayRemote and awayRemote:IsA("RemoteFunction") then
            awayRemote:InvokeServer()
        end

        -- 2. Touch Interest Simulation
        if hrp and firetouchinterest then
            local part_1 = workspace:FindFirstChild("MonsterChestSpawn", true)
            if part_1 then
                local tPart = part_1:IsA("BasePart") and part_1 or part_1:FindFirstChildWhichIsA("BasePart", true)
                if tPart then
                    firetouchinterest(hrp, tPart, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, tPart, 1)
                end
            end
            local toUpdate = workspace:FindFirstChild("ToUpdate", true)
            local part_2 = (toUpdate and toUpdate:FindFirstChild("PetArea")) or workspace:FindFirstChild("PetArea", true)
            if part_2 then
                local tPart2 = part_2:IsA("BasePart") and part_2 or part_2:FindFirstChildWhichIsA("BasePart", true)
                if tPart2 then
                    firetouchinterest(hrp, tPart2, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, tPart2, 1)
                end
            end
        end

        -- 3. Proximity Prompt / Click Trigger
        local smartPart = workspace:FindFirstChild("SmartPromptPart", true)
        if smartPart then
            local prompt_1 = smartPart:IsA("ProximityPrompt") and smartPart or smartPart:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt_1 then
                prompt_1.HoldDuration = 0
                if fireproximityprompt then fireproximityprompt(prompt_1, 0) end
                pcall(function() prompt_1:InputHoldBegin() task.wait(0.01) prompt_1:InputHoldEnd() end)
            end
            local cd_1 = smartPart:FindFirstChildWhichIsA("ClickDetector", true)
            if cd_1 and fireclickdetector then
                fireclickdetector(cd_1)
            end
        end
    end)
end

local function IsNearAnyWildEgg(hrp)
    if not hrp or IsHoldingEgg() then return false end
    local pPos = hrp.Position

    if currentTargetPos and (pPos - currentTargetPos).Magnitude < 35 then
        return true
    end

    local eggSlots = workspace:FindFirstChild("AreaEggSlotsClient")
    if eggSlots then
        for _, slot in pairs(eggSlots:GetChildren()) do
            for _, egg in pairs(slot:GetChildren()) do
                local hitPart = egg:FindFirstChild("HitBox") or egg:FindFirstChild("Hitbox") or egg:FindFirstChild("Part_Union") or egg:FindFirstChildWhichIsA("BasePart", true)
                if hitPart and (pPos - hitPart.Position).Magnitude < 35 then
                    return true
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(0.6)
        pcall(function()
            if AutoEquipBestPet then
                local wearBest = GetRemote("RF/Haul/WearBest")
                if wearBest then wearBest:InvokeServer() end
            end
            if WalkableTreadmill or AutoTreadmillTrain then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local nearEgg = IsNearAnyWildEgg(hrp)

                local treadmill = GetRemote("RF/Treadmill/AskWearStill")
                if nearEgg then
                    -- Near a wild egg: Release treadmill state so server permits egg grab
                    if treadmill then
                        treadmill:InvokeServer(false)
                    end
                else
                    -- Free walking or carrying egg: Train treadmill speed
                    if treadmill then
                        treadmill:InvokeServer(true)
                    end
                    local treadmillTrain = GetRemote("RE/Treadmill/Train") or GetRemote("RF/Treadmill/Train")
                    if treadmillTrain then
                        if treadmillTrain:IsA("RemoteFunction") then
                            treadmillTrain:InvokeServer()
                        else
                            treadmillTrain:FireServer()
                        end
                    end
                end

                -- Ensure player is NEVER frozen or anchored by the treadmill
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.PlatformStand = false
                        hum.Sit = false
                    end
                    if hrp and hrp.Anchored then
                        hrp.Anchored = false
                    end

                    -- Clean up any treadmill welds or constraints
                    for _, child in pairs(char:GetChildren()) do
                        if child:IsA("Weld") or child:IsA("WeldConstraint") or child:IsA("AlignPosition") then
                            local cName = string.lower(child.Name)
                            if string.find(cName, "treadmill") or string.find(cName, "seat") or string.find(cName, "train") then
                                child:Destroy()
                            end
                        end
                    end
                end
            end
            if AutoTreadmillUpgrade then
                local tier = GetRemote("RF/Treadmill/AskTierRaise")
                if tier then tier:InvokeServer() end
            end
            if AutoBaseUpgrade then
                local base = GetRemote("RE/Homestead/AskBaseTierRaise")
                if base then base:FireServer() end
            end
            if AutoCollectAwayEarnings then
                TriggerAwayEarningsCollection()
            end
        end)
    end
end)

-- =============================================================================
-- ESP SYSTEM (EGGS & PLAYERS)
-- =============================================================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "TripsStealer_ESP"
ESPFolder.Parent = ScreenGui

local function ClearESP()
    for _, child in pairs(ESPFolder:GetChildren()) do
        child:Destroy()
    end
end

local RarityColors = {
    Common = Color3.fromRGB(220, 225, 235),
    Uncommon = Color3.fromRGB(85, 235, 95),
    Rare = Color3.fromRGB(45, 170, 255),
    Epic = Color3.fromRGB(195, 65, 255),
    Legendary = Color3.fromRGB(255, 195, 30),
    Mythic = Color3.fromRGB(255, 60, 95),
    Cosmic = Color3.fromRGB(0, 255, 240),
    Secret = Color3.fromRGB(255, 25, 150),
    Eternal = Color3.fromRGB(255, 245, 90),
    Divine = Color3.fromRGB(255, 255, 255)
}

local function GetEggInfo(eggModel, slot)
    local rarity = GetEggRarity(eggModel, slot)
    local isParasite = IsEggParasite(eggModel, slot)
    
    -- Clean Display Name: Always accurately display the assigned rarity + "Egg"
    local cleanName = tostring(rarity) .. " Egg"
    if isParasite then
        cleanName = "Parasite " .. cleanName
    end

    -- Mutation
    local mutation = eggModel:GetAttribute("Mutation") or eggModel:GetAttribute("AssetMutation") or (slot and (slot:GetAttribute("Mutation") or slot:GetAttribute("AssetMutation")))
    
    -- Weight / Scale (KG)
    local weightVal = eggModel:GetAttribute("Weight") or eggModel:GetAttribute("KG") or eggModel:GetAttribute("Scale") or eggModel:GetAttribute("AssetScale") or (slot and (slot:GetAttribute("Weight") or slot:GetAttribute("KG") or slot:GetAttribute("Scale")))
    local weightText = nil
    if weightVal then
        local num = tonumber(weightVal)
        if num then
            weightText = string.format("%.1f KG", num)
        else
            weightText = tostring(weightVal)
        end
    end

    return {
        Rarity = rarity,
        Name = cleanName,
        Mutation = mutation,
        Weight = weightText,
        IsParasite = isParasite
    }
end

local function ApplyEggESP(hitPart, eggModel, slot, hrp)
    if not hitPart or not hitPart:IsDescendantOf(workspace) then return end
    
    local dist = math.floor((hrp.Position - hitPart.Position).Magnitude)
    local info = GetEggInfo(eggModel, slot)
    local rarityColor = RarityColors[tostring(info.Rarity)] or Theme.Accent
    if info.IsParasite then
        rarityColor = Color3.fromRGB(175, 60, 255)
    end

    -- 1. Full Body Glowing Highlight on the Egg Model
    local targetAdornee = (eggModel and eggModel:IsA("Model")) and eggModel or hitPart
    local highlight = Instance.new("Highlight")
    highlight.Name = "EggHighlight"
    highlight.Adornee = targetAdornee
    highlight.FillColor = rarityColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = rarityColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ESPFolder

    -- 2. Floating Bold Text ESP (No background box/frame)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggESP"
    billboard.Adornee = hitPart
    billboard.Size = UDim2.new(0, 180, 0, 36)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.ClipsDescendants = false
    billboard.Parent = ESPFolder

    -- Line 1: Bold Rarity Text with Solid Stroke
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 18)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = tostring(info.Name)
    titleLabel.TextColor3 = rarityColor
    titleLabel.TextSize = 14
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Parent = billboard

    -- Line 2: Bold Distance / Mutation / Weight Subtext with Solid Stroke
    local subParts = {}
    if info.Mutation and tostring(info.Mutation) ~= "" and tostring(info.Mutation) ~= "None" then
        table.insert(subParts, "✨ " .. tostring(info.Mutation))
    end
    if info.Weight then
        table.insert(subParts, tostring(info.Weight))
    end
    table.insert(subParts, string.format("[%dm]", dist))

    local detailsLabel = Instance.new("TextLabel")
    detailsLabel.Name = "Details"
    detailsLabel.Size = UDim2.new(1, 0, 0, 14)
    detailsLabel.Position = UDim2.new(0, 0, 0, 18)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Font = Enum.Font.GothamBold
    detailsLabel.Text = table.concat(subParts, " • ")
    detailsLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
    detailsLabel.TextSize = 11
    detailsLabel.TextStrokeTransparency = 0
    detailsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    detailsLabel.Parent = billboard
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if EggESPEnabled or PlayerESPEnabled then
            pcall(function()
                ClearESP()
                local char = LocalPlayer.Character
                local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
                if not hrp then return end

                local processedModels = {}

                -- 1. Egg ESP Discovery Engine
                if EggESPEnabled then
                    local function CheckAndRenderEgg(eggModel, slot)
                        if not eggModel or eggModel == char or eggModel:IsDescendantOf(char) then return end
                        if processedModels[eggModel] then return end

                        local eName = string.lower(eggModel.Name)
                        local isEgg = string.find(eName, "egg") or eggModel:GetAttribute("Egg") or eggModel:FindFirstChild("Egg") or (slot and string.find(string.lower(slot.Name), "egg")) or eggModel:GetAttribute("Rarity")
                        if not isEgg then return end

                        local hitPart = eggModel:FindFirstChild("HitBox") or eggModel:FindFirstChild("Hitbox") or eggModel:FindFirstChild("Part_Union") or eggModel:FindFirstChild("Handle") or (eggModel:IsA("BasePart") and eggModel) or eggModel:FindFirstChildWhichIsA("BasePart", true)
                        if hitPart then
                            processedModels[eggModel] = true
                            ApplyEggESP(hitPart, eggModel, slot, hrp)
                        end
                    end

                    -- Scan AreaEggSlotsClient
                    local eggSlots = workspace:FindFirstChild("AreaEggSlotsClient")
                    if eggSlots then
                        for _, slot in pairs(eggSlots:GetChildren()) do
                            for _, egg in pairs(slot:GetChildren()) do
                                CheckAndRenderEgg(egg, slot)
                            end
                            if slot:IsA("Model") and (string.find(string.lower(slot.Name), "egg") or slot:GetAttribute("Rarity")) then
                                CheckAndRenderEgg(slot, slot)
                            end
                        end
                    end

                    -- Scan GuardAreas and Nests
                    local guardAreas = workspace:FindFirstChild("__OBJECTS") and workspace.__OBJECTS:FindFirstChild("Areas") and workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
                    if guardAreas then
                        for _, gArea in pairs(guardAreas:GetChildren()) do
                            local nests = gArea:FindFirstChild("Nests")
                            if nests then
                                for _, nest in pairs(nests:GetChildren()) do
                                    CheckAndRenderEgg(nest, nest)
                                    for _, egg in pairs(nest:GetChildren()) do
                                        CheckAndRenderEgg(egg, nest)
                                    end
                                end
                            end
                            for _, child in pairs(gArea:GetChildren()) do
                                if child.Name ~= "Nests" then
                                    CheckAndRenderEgg(child, gArea)
                                end
                            end
                        end
                    end

                    -- Scan Dropped & Event Eggs in Workspace
                    for _, obj in pairs(workspace:GetChildren()) do
                        local oName = string.lower(obj.Name)
                        if string.find(oName, "egg") or string.find(oName, "witch") or string.find(oName, "parasite") or string.find(oName, "monster") then
                            if obj:IsA("Model") or obj:IsA("BasePart") then
                                CheckAndRenderEgg(obj, obj)
                            end
                        end
                    end
                end

                -- 2. Player ESP
                if PlayerESPEnabled then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local pHrp = p.Character.HumanoidRootPart
                            local dist = math.floor((hrp.Position - pHrp.Position).Magnitude)

                            -- Highlight enemy player character
                            local pHighlight = Instance.new("Highlight")
                            pHighlight.Name = "PlayerHighlight"
                            pHighlight.Adornee = p.Character
                            pHighlight.FillColor = Theme.Danger
                            pHighlight.FillTransparency = 0.65
                            pHighlight.OutlineColor = Theme.Danger
                            pHighlight.OutlineTransparency = 0.2
                            pHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            pHighlight.Parent = ESPFolder

                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "PlayerESP"
                            billboard.Adornee = pHrp
                            billboard.Size = UDim2.new(0, 120, 0, 30)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = ESPFolder

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Font = Theme.FontBold
                            txt.Text = string.format("%s\n[%dm]", p.DisplayName, dist)
                            txt.TextColor3 = Theme.Danger
                            txt.TextSize = 10
                            txt.TextStrokeTransparency = 0.3
                            txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            txt.Parent = billboard
                        end
                    end
                end
            end)
        else
            ClearESP()
        end
    end
end)

-- =============================================================================
-- POPULATE TABS AND SECTIONS
-- =============================================================================
local MainTab = Library:CreateTab("Steal Eggs", "rbxassetid://10709790387")
local CombatTab = Library:CreateTab("Combat", "rbxassetid://10734950309")
local AutoTab = Library:CreateTab("Automation", "rbxassetid://10734950020")
local PlayerTab = Library:CreateTab("Player", "rbxassetid://10747373176")
local VisualsTab = Library:CreateTab("Visuals", "rbxassetid://10723346959")
local SettingsTab = Library:CreateTab("Settings", "rbxassetid://10734950309")

-- -----------------------------------------------------------------------------
-- 1. STEAL EGGS TAB
-- -----------------------------------------------------------------------------
local TargetCard = MainTab:CreateSection("Target Filters", "rbxassetid://10709790387", "Left")
TargetCard:CreateDropdown("Area / Biome", AllAreas, "All", function(val)
    SelectedArea = val
    if val ~= "All" and val ~= "---" then
        SendNotification("Target Area", "Targeting: " .. val)
    else
        SendNotification("Target Area", "Targeting all biomes.")
    end
end)
TargetCard:CreateDropdown("Egg Rarity", AllRarities, "All", function(val)
    SelectedRarity = val
    if val ~= "All" and val ~= "---" then
        SendNotification("Target Rarity", "Filter set to: " .. val .. " (Will hunt " .. val .. " eggs first!)")
    else
        SendNotification("Target Rarity", "Targeting all egg rarities.")
    end
end)
TargetCard:CreateDropdown("Target Priority", {"Highest KG First", "Lowest KG First", "Closest Distance", "Parasite Eggs Only"}, "Highest KG First", function(val)
    SelectedPriority = val
    SendNotification("Target Priority", "Priority set to: " .. val)
end)

local AutoStealCard = MainTab:CreateSection("Auto Steal Execution", "rbxassetid://10723415903", "Right")
AutoStealCard:CreateToggle("Instant Pickup", false, function(state)
    InstantPickup = state
    if state then
        pcall(function()
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    desc.HoldDuration = 0
                    desc.RequiresLineOfSight = false
                    desc.MaxActivationDistance = math.max(desc.MaxActivationDistance, 35)
                    desc.ClickablePrompt = true
                end
            end
        end)
        SendNotification("Instant Pickup", "Active! Single tap [E] to instantly pick up any egg without holding.", 3.5)
    else
        SendNotification("Instant Pickup", "Disabled.")
    end
end)
AutoStealCard:CreateToggle("Auto Steal (Selected Filters)", false, function(state)
    AutoStealSelected = state
    lastNoEggNotify = 0 -- reset so user is notified immediately if none are available
    if state then
        pcall(function(...)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Lutosys/opensrc/refs/heads/main/stealaeggspeedbypass.lua"))()
        end)
        activateBypass()
        local rText = (SelectedRarity and SelectedRarity ~= "All" and SelectedRarity ~= "---") and tostring(SelectedRarity) or "any"
        local aText = (SelectedArea and SelectedArea ~= "All" and SelectedArea ~= "---") and tostring(SelectedArea) or "All Biomes"
        SendNotification("Auto Steal Started", string.format("Targeting: %s eggs in %s (Speed 500 Active)", rText, aText), 3.5)
    else
        currentTargetPos = nil
        currentTargetEggModel = nil
        cachedTargetEggPart = nil
        cachedTargetEggModel = nil
        cachedTargetEggSlot = nil
        cachedTargetEggData = nil
        speedActive = false
        stopSpeedModifications()
        local hum = getCurrentHumanoid()
        if hum then
            hum.WalkSpeed = ManualSpeed or 16
        end
        SendNotification("Auto Steal", "Auto Steal Stopped. Normal speed restored.")
    end
end)
AutoStealCard:CreateToggle("Auto Steal (On Pickup)", false, function(state)
    AutoStealOnPickup = state
    if state then
        SendNotification("Auto Steal (On Pickup)", "Ready! Pick up any egg to auto-sprint to Safe Zone at 500 speed.")
    else
        stopSpeedModifications()
        SendNotification("Auto Steal (On Pickup)", "Deactivated. Normal speed restored.")
    end
end)
AutoStealCard:CreateToggle("Auto Drop Held Egg", false, function(state)
    AutoDropHeld = state
    if state then
        local dropRemote = GetRemote("RF/EggWorld/AskFieldEggDrop")
        if dropRemote then dropRemote:InvokeServer() end
    end
end)
AutoStealCard:CreateButton("Set Current Position as Safe Zone", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        CustomSafeZone = hrp.CFrame
        SendNotification("Safe Zone Set", "Current position saved as return destination!")
    end
end)
AutoStealCard:CreateButton("Reset Safe Zone to Game Default", function()
    CustomSafeZone = nil
    SendNotification("Safe Zone Reset", "Default game spawn restored.")
end)

-- -----------------------------------------------------------------------------
-- 2. COMBAT & DEFENSE TAB
-- -----------------------------------------------------------------------------
local BatCard = CombatTab:CreateSection("Bat Kill Aura", "rbxassetid://10734950309", "Left")
BatCard:CreateToggle("Bat Kill Aura", false, function(state)
    BatKillAura = state
end)
BatCard:CreateToggle("Auto Equip Bat", false, function(state)
    AutoEquipBat = state
end)
BatCard:CreateSlider("Aura Range", 5.0, 30.0, 12.0, function(val)
    AuraRange = val
end)
BatCard:CreateSlider("Attack Delay", 0.05, 1.0, 0.1, function(val)
    AttackDelay = val
end)

local DefenseCard = CombatTab:CreateSection("Guard Protection", "rbxassetid://10747373176", "Right")
DefenseCard:CreateToggle("⚡ Instant Auto-Regrab Egg (Guard Hit)", false, function(state)
    AutoRegrabEgg = state
    SendNotification("Auto Re-Grab Egg", state and "Active! Instantly re-picks up dropped eggs on guard hit." or "Disabled.")
end)
DefenseCard:CreateToggle("Anti-Guard Hit / Knockback", false, function(state)
    AntiGuardHit = state
    SendNotification("Anti-Guard", state and "Bypassing guard knockback & damage!" or "Disabled.")
end)
DefenseCard:CreateToggle("Anti-Trap Disabler", false, function(state)
    AntiTrap = state
    if state then
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if string.find(string.lower(obj.Name), "trap") and obj:IsA("BasePart") then
                    obj.CanTouch = false
                end
            end
        end)
    end
end)

local RiftCard = CombatTab:CreateSection("RIFT", "rbxassetid://10723415903", "Left")
RiftCard:CreateToggle("⚡ Auto Run & Enter Portal (BossArenaTeleport)", false, function(state)
    AutoEnterBossArena = state
    if state then
        SendNotification("Boss Arena Portal", "Active! Auto-sprinting at high speed & entering workspace.BossArenaTeleport whenever it spawns.", 4.0)
    else
        if not AutoStealSelected and not AutoStealOnPickup and not AutoAttackCrystalTowers then
            currentTargetPos = nil
            stopSpeedModifications()
        end
        SendNotification("Boss Arena Portal", "Disabled.")
    end
end)
local CrystalTowersToggle
CrystalTowersToggle = RiftCard:CreateToggle("⚔️ Auto Attack Crystal Towers", false, function(state)
    if state then
        AutoAttackCrystalTowers = false
        ShowCenterModal("Crystal Towers (Beta)", "This option is in beta testing the dev is still working on it.\n\nThank you for using my scripts by the way :) much love!", 4.5)
        task.defer(function()
            if CrystalTowersToggle and CrystalTowersToggle.Set then
                CrystalTowersToggle:Set(false)
            end
        end)
    else
        AutoAttackCrystalTowers = false
        if not AutoStealSelected and not AutoStealOnPickup and not AutoEnterBossArena then
            currentTargetPos = nil
            stopSpeedModifications()
        end
    end
end)

-- -----------------------------------------------------------------------------
-- 3. AUTOMATION & UPGRADES TAB
-- -----------------------------------------------------------------------------
local BlockTreadmillEntryActive = false
local treadmillBarrierFolder = Instance.new("Folder")
treadmillBarrierFolder.Name = "Trips_TreadmillWalkBarriers"
treadmillBarrierFolder.Parent = workspace

local function ClearTreadmillBarriers()
    pcall(function()
        for _, child in pairs(treadmillBarrierFolder:GetChildren()) do
            child:Destroy()
        end
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "Trips_TreadmillWalkBarrier" then
                obj:Destroy()
            end
        end
    end)
end

local function SetTreadmillEntryBlocked(blocked)
    pcall(function()
        local clientTreadmills = workspace:FindFirstChild("__ClientTreadmillRenders")
        if clientTreadmills then
            for _, obj in pairs(clientTreadmills:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CanTouch = not blocked
                elseif obj:IsA("ProximityPrompt") then
                    obj.Enabled = not blocked
                end
            end
        end

        for _, rName in ipairs({"TreadmillRender_7", "TreadmillRender_1", "TreadmillRender_2", "TreadmillRender_3", "TreadmillRender_4", "TreadmillRender_5", "TreadmillRender_6", "TreadmillRender_8", "TreadmillRender_9"}) do
            local found = workspace:FindFirstChild(rName, true)
            if found then
                for _, obj in pairs(found:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.CanTouch = not blocked
                    elseif obj:IsA("ProximityPrompt") then
                        obj.Enabled = not blocked
                    end
                end
                if found:IsA("BasePart") then
                    found.CanTouch = not blocked
                end
            end
        end

        if blocked then
            local function EnsureBarrier(obj)
                if not obj then return end
                local cf, size
                if obj:IsA("Model") then
                    cf, size = obj:GetBoundingBox()
                elseif obj:IsA("BasePart") then
                    cf, size = obj.CFrame, obj.Size
                end
                if cf and size and size.Magnitude > 1 then
                    for _, b in pairs(treadmillBarrierFolder:GetChildren()) do
                        if (b.Position - cf.Position).Magnitude < 4 then
                            return
                        end
                    end
                    local barrier = Instance.new("Part")
                    barrier.Name = "Trips_TreadmillWalkBarrier"
                    barrier.Anchored = true
                    barrier.CanCollide = true
                    barrier.CanTouch = false
                    barrier.CanQuery = true
                    barrier.Transparency = 1
                    barrier.Material = Enum.Material.SmoothPlastic
                    barrier.Size = Vector3.new(math.max(size.X + 2, 10), math.max(size.Y + 8, 12), math.max(size.Z + 2, 10))
                    barrier.CFrame = cf + Vector3.new(0, math.max(size.Y, 4) / 2, 0)
                    barrier.Parent = treadmillBarrierFolder
                end
            end

            if clientTreadmills then
                for _, child in pairs(clientTreadmills:GetChildren()) do
                    EnsureBarrier(child)
                end
            end
            for _, rName in ipairs({"TreadmillRender_7", "TreadmillRender_1", "TreadmillRender_2", "TreadmillRender_3", "TreadmillRender_4", "TreadmillRender_5", "TreadmillRender_6", "TreadmillRender_8", "TreadmillRender_9"}) do
                local found = workspace:FindFirstChild(rName, true)
                if found then EnsureBarrier(found) end
            end
        else
            ClearTreadmillBarriers()
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(1.0)
        if BlockTreadmillEntryActive then
            SetTreadmillEntryBlocked(true)
        end
    end
end)

local UpgradesCard = AutoTab:CreateSection("Player & Base Upgrades", "rbxassetid://10747373176", "Left")
UpgradesCard:CreateToggle("🧱 Invisible Box Barrier (Block Treadmill)", false, function(state)
    BlockTreadmillEntryActive = state
    SetTreadmillEntryBlocked(state)
    SendNotification("Treadmill Barrier", state and "Invisible barrier box active! Blocks you from walking on the treadmill." or "Invisible barrier removed! You can now walk on the treadmill.")
end)
UpgradesCard:CreateToggle("Auto Equip Best Pet", false, function(state)
    AutoEquipBestPet = state
end)
UpgradesCard:CreateToggle("Auto Treadmill Upgrade", false, function(state)
    AutoTreadmillUpgrade = state
end)
UpgradesCard:CreateToggle("Auto Base Upgrade", false, function(state)
    AutoBaseUpgrade = state
end)

local HatchCard = AutoTab:CreateSection("Egg Lifecycle", "rbxassetid://10709790387", "Right")
HatchCard:CreateButton("Auto Place Held Egg", function()
    ShowCenterModal("Egg Lifecycle (Beta)", "These options are in beta testing the dev is still working on them.\n\nThank you for using my scripts by the way :) much love!", 4.5)
end)
HatchCard:CreateButton("Auto Hatch Ready Eggs", function()
    ShowCenterModal("Egg Lifecycle (Beta)", "These options are in beta testing the dev is still working on them.\n\nThank you for using my scripts by the way :) much love!", 4.5)
end)
HatchCard:CreateButton("Auto Sell All Eligible Pets", function()
    ShowCenterModal("Egg Lifecycle (Beta)", "These options are in beta testing the dev is still working on them.\n\nThank you for using my scripts by the way :) much love!", 4.5)
end)

local function HookGuiCloseButtons(targetGui)
    if not targetGui then return end
    local main = targetGui:FindFirstChild("Main") or targetGui:FindFirstChildWhichIsA("Frame", true)

    local function BindButton(btn)
        if not (btn:IsA("GuiButton") or btn:IsA("TextButton") or btn:IsA("ImageButton")) then return end
        if btn:GetAttribute("TripsCloseHooked") then return end

        local bName = string.lower(btn.Name)
        local bText = (btn:IsA("TextButton") and string.lower(btn.Text)) or ""

        local isClose = string.find(bName, "close") or string.find(bName, "exit") or string.find(bName, "cancel") or bName == "x"
            or bText == "x" or bText == "✕" or bText == "✖" or string.find(bText, "close")

        -- Also check for top-right red close button
        if not isClose and (btn.Position.X.Scale > 0.6 or btn.Position.X.Offset > 150) and (btn.Position.Y.Scale < 0.35) then
            if btn.BackgroundColor3.R > 0.5 and btn.BackgroundColor3.G < 0.4 then
                isClose = true
            end
        end

        if isClose then
            btn:SetAttribute("TripsCloseHooked", true)
            local function CloseShop()
                targetGui.Enabled = false
                if main then main.Visible = false end
                for _, child in pairs(targetGui:GetChildren()) do
                    if child:IsA("Frame") or child:IsA("CanvasGroup") then
                        child.Visible = false
                    end
                end
            end

            btn.MouseButton1Click:Connect(CloseShop)
            pcall(function()
                if btn.Activated then
                    btn.Activated:Connect(CloseShop)
                end
            end)
        end
    end

    for _, desc in pairs(targetGui:GetDescendants()) do
        BindButton(desc)
    end
    targetGui.DescendantAdded:Connect(function(desc)
        task.wait(0.05)
        BindButton(desc)
    end)
end

-- Continuously ensure Shop close buttons are hooked
task.spawn(function()
    while true do
        task.wait(1.0)
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local bossShop = pGui:FindFirstChild("BossShop")
            if bossShop then HookGuiCloseButtons(bossShop) end
            local trailShop = pGui:FindFirstChild("TrailShop") or pGui:FindFirstChild("TrailsShop")
            if trailShop then HookGuiCloseButtons(trailShop) end
            local sellPrompt = pGui:FindFirstChild("SellPrompt") or pGui:FindFirstChild("SellGui") or pGui:FindFirstChild("SellUI")
            if sellPrompt then HookGuiCloseButtons(sellPrompt) end
            local riftShop = pGui:FindFirstChild("RiftTradeIn") or pGui:FindFirstChild("RiftShop")
            if riftShop then HookGuiCloseButtons(riftShop) end
            local petFuse = pGui:FindFirstChild("PetFuse") or pGui:FindFirstChild("FuseGui") or pGui:FindFirstChild("FusePrompt")
            if petFuse then HookGuiCloseButtons(petFuse) end
        end
    end
end)

local ShopsCard = AutoTab:CreateSection("Shops", "rbxassetid://10734950309", "Left")
ShopsCard:CreateButton("Boss Shop", function()
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if not pGui then
            SendNotification("Boss Shop", "PlayerGui not found.", 3.5)
            return
        end
        local bossShop = pGui:FindFirstChild("BossShop")
        if bossShop then
            HookGuiCloseButtons(bossShop)
            bossShop.Enabled = true
            local main = bossShop:FindFirstChild("Main") or bossShop:FindFirstChildWhichIsA("Frame", true)
            if main then
                main.Visible = true
            end
            for _, child in pairs(bossShop:GetChildren()) do
                if child:IsA("Frame") or child:IsA("CanvasGroup") then
                    child.Visible = true
                end
            end
            SendNotification("Boss Shop", "Opened Boss Shop! (Click [X] to close and uncheck Enabled)", 3.5)
        else
            SendNotification("Boss Shop", "BossShop GUI not found in PlayerGui.", 3.5)
        end
    end)
end)

ShopsCard:CreateButton("Trails Shop", function()
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if not pGui then
            SendNotification("Trails Shop", "PlayerGui not found.", 3.5)
            return
        end
        local trailShop = pGui:FindFirstChild("TrailShop") or pGui:FindFirstChild("TrailsShop")
        if trailShop then
            HookGuiCloseButtons(trailShop)
            trailShop.Enabled = true
            local main = trailShop:FindFirstChild("Main") or trailShop:FindFirstChildWhichIsA("Frame", true)
            if main then
                main.Visible = true
            end
            for _, child in pairs(trailShop:GetChildren()) do
                if child:IsA("Frame") or child:IsA("CanvasGroup") then
                    child.Visible = true
                end
            end
            SendNotification("Trails Shop", "Opened Trails Shop! (Click [X] to close and uncheck Enabled)", 3.5)
        else
            SendNotification("Trails Shop", "TrailShop GUI not found in PlayerGui.", 3.5)
        end
    end)
end)

ShopsCard:CreateButton("Sell GUI", function()
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if not pGui then
            SendNotification("Sell GUI", "PlayerGui not found.", 3.5)
            return
        end
        local sellPrompt = pGui:FindFirstChild("SellPrompt") or pGui:FindFirstChild("SellGui") or pGui:FindFirstChild("SellUI")
        if sellPrompt then
            HookGuiCloseButtons(sellPrompt)
            sellPrompt.Enabled = true
            local main = sellPrompt:FindFirstChild("Main") or sellPrompt:FindFirstChildWhichIsA("Frame", true)
            if main then
                main.Visible = true
            end
            for _, child in pairs(sellPrompt:GetChildren()) do
                if child:IsA("Frame") or child:IsA("CanvasGroup") then
                    child.Visible = true
                end
            end
            SendNotification("Sell GUI", "Opened Sell GUI! (Click [X] to close and uncheck Enabled)", 3.5)
        else
            SendNotification("Sell GUI", "SellPrompt GUI not found in PlayerGui.", 3.5)
        end
    end)
end)

ShopsCard:CreateButton("The Rift (Trade In)", function()
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if not pGui then
            SendNotification("The Rift", "PlayerGui not found.", 3.5)
            return
        end
        local riftShop = pGui:FindFirstChild("RiftTradeIn") or pGui:FindFirstChild("RiftShop")
        if riftShop then
            HookGuiCloseButtons(riftShop)
            riftShop.Enabled = true
            local main = riftShop:FindFirstChild("Main") or riftShop:FindFirstChildWhichIsA("Frame", true)
            if main then
                main.Visible = true
            end
            for _, child in pairs(riftShop:GetChildren()) do
                if child:IsA("Frame") or child:IsA("CanvasGroup") then
                    child.Visible = true
                end
            end
            SendNotification("The Rift", "Opened Rift Trade In! (Click [X] to close and uncheck Enabled)", 3.5)
        else
            SendNotification("The Rift", "RiftTradeIn GUI not found in PlayerGui.", 3.5)
        end
    end)
end)

ShopsCard:CreateButton("Pet Fuse", function()
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 3)
        if not pGui then
            SendNotification("Pet Fuse", "PlayerGui not found.", 3.5)
            return
        end
        local petFuse = pGui:FindFirstChild("PetFuse") or pGui:FindFirstChild("FuseGui") or pGui:FindFirstChild("FusePrompt")
        if petFuse then
            HookGuiCloseButtons(petFuse)
            petFuse.Enabled = true
            local main = petFuse:FindFirstChild("Main") or petFuse:FindFirstChildWhichIsA("Frame", true)
            if main then
                main.Visible = true
            end
            for _, child in pairs(petFuse:GetChildren()) do
                if child:IsA("Frame") or child:IsA("CanvasGroup") then
                    child.Visible = true
                end
            end
            SendNotification("Pet Fuse", "Opened Pet Fuse! (Click [X] to close and uncheck Enabled)", 3.5)
        else
            SendNotification("Pet Fuse", "PetFuse GUI not found in PlayerGui.", 3.5)
        end
    end)
end)

-- -----------------------------------------------------------------------------
-- 4. PLAYER & PHYSICS TAB
-- -----------------------------------------------------------------------------
local PhysCard = PlayerTab:CreateSection("Movement", "rbxassetid://10747373176", "Left")
PhysCard:CreateToggle("⚡ Super Speed (500 Speed)", false, function(state)
    SuperSpeedActive = state
    local hum = getCurrentHumanoid()
    if hum and not speedActive then
        hum.WalkSpeed = state and 500 or (ManualSpeed or 16)
    end
    SendNotification("Super Speed", state and "Active! Movement speed set to 500." or "Disabled. Normal speed restored.")
end)
PhysCard:CreateSlider("Player Speed", 16, 100, 16, function(val)
    ManualSpeed = tonumber(val) or 16
    local hum = getCurrentHumanoid()
    if hum and not speedActive and not SuperSpeedActive then
        hum.WalkSpeed = ManualSpeed
    end
end)
PhysCard:CreateToggle("Infinite Jump", false, function(state)
    if state then
        _G.InfJumpConn = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if _G.InfJumpConn then _G.InfJumpConn:Disconnect() end
    end
end)
PhysCard:CreateToggle("Noclip", false, function(state)
    _G.NoclipActive = state
    if state then
        _G.NoclipConn = RunService.Stepped:Connect(function()
            if _G.NoclipActive and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if _G.NoclipConn then _G.NoclipConn:Disconnect() end
    end
end)



-- -----------------------------------------------------------------------------
-- 6. VISUALS / ESP TAB
-- -----------------------------------------------------------------------------
local VisualSection = VisualsTab:CreateSection("ESP Visuals", "rbxassetid://10723346959", "Left")
local EggESPToggle
EggESPToggle = VisualSection:CreateToggle("Egg ESP (Rarity Color-Coded)", false, function(state)
    if state then
        EggESPEnabled = false
        ShowCenterModal("Egg ESP (Beta)", "This option is in beta testing the dev is still working on it.\n\nThank you for using my scripts by the way :) much love!", 4.5)
        task.defer(function()
            if EggESPToggle and EggESPToggle.Set then
                EggESPToggle:Set(false)
            end
        end)
    else
        EggESPEnabled = false
        if not PlayerESPEnabled then
            ClearESP()
        end
    end
end)
VisualSection:CreateToggle("Player ESP (Track Enemies)", false, function(state)
    PlayerESPEnabled = state
    if not state and not EggESPEnabled then
        ClearESP()
    end
end)

local ThemeSection = VisualsTab:CreateSection("GUI Appearance", "rbxassetid://10723346959", "Right")
ThemeSection:CreateDropdown("Theme", {"Dust Particles", "Matrix Rain (Green 0/1)", "Dark Mint", "Cyberpunk Neon", "Midnight Blue", "Crimson Blood", "Solar Gold"}, "Dust Particles", function(val)
    if val == "Dust Particles" then
        SetMatrixRain(false)
        SetDustParticles(true, Theme.Accent)
        SendNotification("Theme", "Theme set to: Dust Particles (Animated dust active!)")
    elseif val == "Matrix Rain (Green 0/1)" then
        SetDustParticles(false)
        SetMatrixRain(true)
        SendNotification("Theme", "Theme set to: Matrix Rain (Falling green 0 and 1 code active!)")
    elseif val == "Dark Mint" then
        SetDustParticles(false)
        SetMatrixRain(false)
        SendNotification("Theme", "Theme set to: Dark Mint (Clean background)")
    elseif val == "Cyberpunk Neon" then
        SetMatrixRain(false)
        SetDustParticles(true, Color3.fromRGB(190, 110, 255))
        SendNotification("Theme", "Theme set to: Cyberpunk Neon")
    elseif val == "Midnight Blue" then
        SetMatrixRain(false)
        SetDustParticles(true, Color3.fromRGB(90, 180, 255))
        SendNotification("Theme", "Theme set to: Midnight Blue")
    elseif val == "Crimson Blood" then
        SetMatrixRain(false)
        SetDustParticles(true, Color3.fromRGB(255, 80, 80))
        SendNotification("Theme", "Theme set to: Crimson Blood")
    elseif val == "Solar Gold" then
        SetMatrixRain(false)
        SetDustParticles(true, Color3.fromRGB(255, 215, 80))
        SendNotification("Theme", "Theme set to: Solar Gold")
    end
end)
ThemeSection:CreateToggle("Trips Menus", true, function(state)
    SetTripsWatermark(state)
    SendNotification("Trips Menus", state and "Enabled Trips Menus background!" or "Disabled Trips Menus background.")
end)
ThemeSection:CreateToggle("✨ Background Dust Particles", true, function(state)
    SetDustParticles(state)
    SendNotification("Dust Particles", state and "Enabled background dust particles!" or "Disabled dust particles.")
end)
ThemeSection:CreateToggle("💻 Matrix Rain (Green 0/1)", false, function(state)
    SetMatrixRain(state)
    SendNotification("Matrix Rain", state and "Enabled falling green 0/1 code!" or "Disabled Matrix rain.")
end)

-- -----------------------------------------------------------------------------
-- 7. SETTINGS TAB
-- -----------------------------------------------------------------------------
local SettingsSection = SettingsTab:CreateSection("Script & Controls", "rbxassetid://10734950309", "Left")
local AntiAFKEnabled = false
local AntiAFKConn = nil

SettingsSection:CreateToggle("Anti-AFK (Prevent 20min Idle Kick)", false, function(state)
    AntiAFKEnabled = state
    if state then
        local VirtualUser = game:GetService("VirtualUser")
        AntiAFKConn = LocalPlayer.Idled:Connect(function()
            if AntiAFKEnabled then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end)
            end
        end)
        SendNotification("Anti-AFK", "Enabled! Prevents 20-minute idle disconnect.")
    else
        if AntiAFKConn then
            AntiAFKConn:Disconnect()
            AntiAFKConn = nil
        end
        SendNotification("Anti-AFK", "Disabled.")
    end
end)
SettingsSection:CreateButton("🔄 Rejoin Current Server", function()
    local TeleportService = game:GetService("TeleportService")
    SendNotification("Rejoining", "Connecting back to the server...", 3)
    task.wait(0.4)
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end)
SettingsSection:CreateButton("🌐 Server Hop (Find New Server)", function()
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    SendNotification("Server Hop", "Searching for an active public server...", 3)
    task.spawn(function()
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local success, result = pcall(function()
            local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100", tostring(placeId))
            local response = game:HttpGet(url)
            return HttpService:JSONDecode(response)
        end)
        if success and result and result.data then
            local serverCandidates = {}
            for _, s in ipairs(result.data) do
                if s.id ~= currentJobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.playing > 0 then
                    table.insert(serverCandidates, s.id)
                end
            end
            if #serverCandidates > 0 then
                local chosenId = serverCandidates[math.random(1, #serverCandidates)]
                TeleportService:TeleportToPlaceInstance(placeId, chosenId, LocalPlayer)
                return
            end
        end
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
end)
SettingsSection:CreateButton("Copy Discord Invite Link", function()
    if setclipboard then
        setclipboard("https://discord.gg/8Ekmx3aFb2")
        SendNotification("Copied", "Discord link copied to clipboard!")
    end
end)
SettingsSection:CreateButton("Unload Trips Stealer", function()
    AutoStealSelected = false
    AutoStealOnPickup = false
    InstantPickup = false
    stopSpeedModifications()
    currentTargetPos = nil
    EggESPEnabled = false
    PlayerESPEnabled = false
    ClearESP()
    if _G.InfJumpConn then _G.InfJumpConn:Disconnect() end
    if _G.NoclipConn then _G.NoclipConn:Disconnect() end
    if AntiAFKConn then AntiAFKConn:Disconnect() end
    SetTreadmillEntryBlocked(false)
    ScreenGui:Destroy()
    SendNotification("Unloaded", "Trips Stealer has been completely removed.")
end)

-- Toggle Keybinds (RightControl / Insert / V)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Welcome Notification
SendNotification("Trips Stealer", "Loaded successfully! Tap [T] badge or press RightControl.", 4.5)
print("[Trips Stealer] Initialized successfully with all game remotes and features!")

return Library

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === Load Rayfield ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Player Tools",
    LoadingTitle = "God Mode & Speed",
    LoadingSubtitle = "Rayfield UI",
    KeySystem = false,
})
local Tab = Window:CreateTab("Player", 4483362458)

-- Variabel
local noDamage = false
local connections = {}
local walkSpeedValue = 16 -- default speed Roblox

-- Fungsi aktifkan no damage
local function enableNoDamage(char)
    local humanoid = char:WaitForChild("Humanoid")

    humanoid.Health = humanoid.MaxHealth
    connections[humanoid] = humanoid.HealthChanged:Connect(function(hp)
        if noDamage and hp < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)

    -- set walkspeed awal sesuai slider
    humanoid.WalkSpeed = walkSpeedValue
end

-- Fungsi matikan no damage
local function disableNoDamage(char)
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and connections[humanoid] then
        connections[humanoid]:Disconnect()
        connections[humanoid] = nil
    end
end

-- Toggle No Damage
Tab:CreateToggle({
    Name = "Aktifkan No Damage",
    CurrentValue = false,
    Callback = function(Value)
        noDamage = Value
        local char = player.Character
        if noDamage and char then
            enableNoDamage(char)
        elseif not noDamage and char then
            disableNoDamage(char)
        end
    end,
})

-- Slider WalkSpeed
Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200}, -- default 16, max 200
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Callback = function(Value)
        walkSpeedValue = Value
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = walkSpeedValue
        end
    end,
})

-- Pastikan saat respawn ikut
player.CharacterAdded:Connect(function(char)
    if noDamage then
        enableNoDamage(char)
    end
    -- terapkan walkSpeed
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = walkSpeedValue
end)

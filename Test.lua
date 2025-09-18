local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === State ===
local hrp, hum
local godMode = false
local ff

-- === Helper ===
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    return char
end

-- Lock HP function
local function lockHealth()
    if hum then
        hum.MaxHealth = math.huge
        hum.Health = hum.MaxHealth
    end
end

-- Enable God
local function enableGod()
    local char = getChar()
    lockHealth()

    -- ForceField invisible
    if not ff or not ff.Parent then
        ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = char
    end

    -- Patch TakeDamage agar tidak berfungsi
    hum.TakeDamage = function() end

    -- Listener untuk Health
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if godMode and hum.Health < hum.MaxHealth then
            lockHealth()
        end
    end)
end

-- Loop setiap frame
RunService.Heartbeat:Connect(function()
    if godMode then
        if not hum then getChar() end
        if hum then lockHealth() end
    end
end)

-- === Example Toggle ===
-- Misal kamu pakai UI Rayfield toggle, callback-nya cukup set godMode = true/false

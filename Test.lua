local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
local walkSpeedValue = 16 -- default Roblox

-- Fungsi aktifkan no damage full
local function enableNoDamage(char)
    local humanoid = char:WaitForChild("Humanoid")

    -- Cegah state yang bisa bikin mati
    for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state == Enum.HumanoidStateType.Dead 
        or state == Enum.HumanoidStateType.FallingDown then
            humanoid:SetStateEnabled(state, false)
        end
    end

    -- Loop per frame: lock health & walkspeed
    RunService.Heartbeat:Connect(function()
        if noDamage and humanoid and humanoid.Parent then
            humanoid.Health = humanoid.MaxHealth
            humanoid.WalkSpeed = walkSpeedValue
        end
    end)
end

-- Toggle No Damage
Tab:CreateToggle({
    Name = "Aktifkan No Damage (God Mode)",
    CurrentValue = false,
    Callback = function(Value)
        noDamage = Value
        local char = player.Character
        if noDamage and char then
            enableNoDamage(char)
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

-- Terapkan saat respawn
player.CharacterAdded:Connect(function(char)
    if noDamage then
        enableNoDamage(char)
    end
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.WalkSpeed = walkSpeedValue
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Main Debug Menu",
    LoadingTitle = "Debug Tools",
    LoadingSubtitle = "Absolute GodMode + Tools",
    KeySystem = false,
})
local Tab = Window:CreateTab("Main", 4483362458)

-- === State ===
local hrp, hum
local godMode = false
local magnetOn = false
local magnetRange = 1000
local walkSpeed = 16
local jumpPower = 50

-- === Helper ===
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    return char
end

local function getGoldFolder()
    local lego = workspace:FindFirstChild("LEGO%")
    if lego then
        return lego:FindFirstChild("GoldStuds")
    end
end

-- === ABSOLUTE GOD MODE (Fix Anti-Freeze) ===
RunService.Heartbeat:Connect(function()
    local char = getChar()
    if godMode and hum then
        hum.Health = hum.MaxHealth -- selalu full
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    end
end)

-- === Magnet Collect ===
RunService.Heartbeat:Connect(function()
    if not magnetOn then return end
    hrp = hrp or getChar():WaitForChild("HumanoidRootPart")
    local goldFolder = getGoldFolder()
    if not (hrp and goldFolder) then return end

    for _, model in pairs(goldFolder:GetChildren()) do
        local hitbox = model:FindFirstChild("HitBox")
        if hitbox and hitbox:IsA("BasePart") then
            local dist = (hitbox.Position - hrp.Position).Magnitude
            if dist <= magnetRange then
                hitbox.CFrame = hrp.CFrame + Vector3.new(0, -2, 0)
            end
        end
    end
end)

-- === Speed & Jump ===
RunService.Heartbeat:Connect(function()
    local char = getChar()
    if hum then
        hum.WalkSpeed = walkSpeed
        hum.JumpPower = jumpPower
    end
end)

-- === UI ===
Tab:CreateToggle({
    Name = "Absolute GodMode",
    CurrentValue = false,
    Callback = function(v)
        godMode = v
    end
})

Tab:CreateToggle({
    Name = "Magnet Collect ON/OFF",
    CurrentValue = false,
    Callback = function(v)
        magnetOn = v
    end
})

Tab:CreateSlider({
    Name = "Magnet Range",
    Range = {100, 2000},
    Increment = 50,
    Suffix = "stud",
    CurrentValue = magnetRange,
    Callback = function(val)
        magnetRange = val
    end
})

Tab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 5,
    Suffix = "spd",
    CurrentValue = walkSpeed,
    Callback = function(val)
        walkSpeed = val
    end
})

Tab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 10,
    Suffix = "jmp",
    CurrentValue = jumpPower,
    Callback = function(val)
        jumpPower = val
    end
})

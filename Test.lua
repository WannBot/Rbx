local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Coin Debug",
    LoadingTitle = "Magnet + Teleport + x2 Coin",
    LoadingSubtitle = "Client Side",
    KeySystem = false,
})
local Tab = Window:CreateTab("Coins", 4483362458)

-- === State ===
local hrp, hum
local magnetOn = false
local magnetRange = 1000
local teleOn = false
local tpConn
local tpDelay = 0.15
local multiplier = 2 -- X2 coin

-- === Helper ===
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    return char:WaitForChild("HumanoidRootPart")
end

local function getGoldFolder()
    local lego = workspace:FindFirstChild("LEGO%")
    if lego then
        return lego:FindFirstChild("GoldStuds")
    end
end

-- === X2 Coin Client Side (visual only) ===
task.spawn(function()
    local stats = player:WaitForChild("leaderstats")
    local coins = stats:WaitForChild("Coins")
    coins:GetPropertyChangedSignal("Value"):Connect(function()
        if coins.Value > 0 then
            coins.Value = coins.Value * multiplier
        end
    end)
end)

-- === Magnet Collect ===
RunService.Heartbeat:Connect(function()
    if not magnetOn then return end
    hrp = hrp or getHRP()
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

-- === Teleport Collect Long Range ===
local function startTeleportLoop()
    hrp = getHRP()
    local goldFolder = getGoldFolder()
    if not (hrp and goldFolder) then return end

    tpConn = RunService.Heartbeat:Connect(function()
        if not teleOn then return end
        for _, model in pairs(goldFolder:GetChildren()) do
            local hitbox = model:FindFirstChild("HitBox")
            if hitbox and hitbox:IsA("BasePart") then
                hrp.CFrame = hitbox.CFrame + Vector3.new(0, 3, 0)
                task.wait(tpDelay) -- jeda antar teleport
            end
        end
    end)
end

local function stopTeleportLoop()
    if tpConn then tpConn:Disconnect() tpConn = nil end
end

-- === UI Control ===
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

Tab:CreateToggle({
    Name = "Teleport Collect ON/OFF",
    CurrentValue = false,
    Callback = function(v)
        teleOn = v
        if teleOn then
            startTeleportLoop()
        else
            stopTeleportLoop()
        end
    end
})

Tab:CreateSlider({
    Name = "Teleport Delay",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "sec",
    CurrentValue = tpDelay,
    Callback = function(val)
        tpDelay = val
    end
})

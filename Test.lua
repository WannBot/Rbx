local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Magnet Collect",
    LoadingTitle = "Auto Collect",
    LoadingSubtitle = "GoldStuds HitBox",
    KeySystem = false,
})
local Tab = Window:CreateTab("Magnet", 4483362458)

-- === State ===
local magnetOn = false
local magnetRange = 1000
local hrp, goldFolder

-- Cari HRP
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Path coin folder
local function getGoldFolder()
    local lego = workspace:FindFirstChild("LEGO%")
    if lego then
        return lego:FindFirstChild("GoldStuds")
    end
end

-- Tarik item ke player
local function pull(part, hrp)
    if part and part:IsA("BasePart") and hrp then
        part.CFrame = hrp.CFrame + Vector3.new(0, -2, 0)
    end
end

-- Loop magnet
RunService.Heartbeat:Connect(function()
    if not magnetOn then return end
    hrp = hrp or getHRP()
    goldFolder = goldFolder or getGoldFolder()
    if not (hrp and goldFolder) then return end

    for _, model in pairs(goldFolder:GetChildren()) do
        local hitbox = model:FindFirstChild("HitBox")
        if hitbox and hitbox:IsA("BasePart") then
            local dist = (hitbox.Position - hrp.Position).Magnitude
            if dist <= magnetRange then
                pull(hitbox, hrp)
            end
        end
    end
end)

-- === UI Control ===
Tab:CreateToggle({
    Name = "Magnet ON/OFF",
    CurrentValue = false,
    Callback = function(v)
        magnetOn = v
        hrp = nil -- refresh
        goldFolder = nil
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

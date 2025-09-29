local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Load Rayfield ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Debug Menu",
    LoadingTitle = "Init",
    LoadingSubtitle = "GodMode Rayfield",
    KeySystem = false,
})
local Tab = Window:CreateTab("Main", 4483362458)

-- === State ===
local godMode = false
local hum, hrp
local ff

-- === Helper ===
local function bindChar()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    -- invisible forcefield
    if not ff or not ff.Parent then
        ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = char
    end

    -- lock health awal
    hum.MaxHealth = math.huge
    hum.Health = hum.MaxHealth
end

-- === GodMode loop ===
RunService.Heartbeat:Connect(function()
    if godMode and hum then
        -- kunci darah full
        hum.MaxHealth = math.huge
        hum.Health = hum.MaxHealth

        -- cegah state berbahaya
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    end
end)

-- === UI Toggle ===
Tab:CreateToggle({
    Name = "GodMode (ForceField + MaxHealth)",
    CurrentValue = false,
    Callback = function(v)
        godMode = v
        if godMode then
            bindChar()
        else
            if ff then
                ff:Destroy()
                ff = nil
            end
        end
    end
})

-- rebind saat respawn
player.CharacterAdded:Connect(function()
    if godMode then
        task.wait(0.1)
        bindChar()
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Legend Mode God",
    LoadingTitle = "Absolute GodMode",
    LoadingSubtitle = "For 1% HP Mode",
    KeySystem = false,
})

local Tab = Window:CreateTab("GodMode", 4483362458)

-- State
local godOn = false
local hbConn, hcConn

local function protect(char)
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    -- Pastikan darah & MaxHealth di-boost
    hum.MaxHealth = 1e9
    hum.Health = hum.MaxHealth

    -- Disable state berbahaya
    for _, st in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
        if st == Enum.HumanoidStateType.Dead
        or st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.PlatformStanding
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.Swimming then
            hum:SetStateEnabled(st, false)
        end
    end

    -- Signal lock: kalau Health berubah, langsung pulihkan
    if hcConn then hcConn:Disconnect() end
    hcConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if godOn and hum.Health < hum.MaxHealth then
            hum.MaxHealth = 1e9
            hum.Health = hum.MaxHealth
        end
    end)

    -- Heartbeat brute force
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if godOn and hum and hum.Parent then
            if hum.Health < hum.MaxHealth then
                hum.MaxHealth = 1e9
                hum.Health = hum.MaxHealth
            end
        end
        -- anti break joints (jika server coba hancurkan karakter)
        if not char:FindFirstChild("HumanoidRootPart") then
            local newRoot = Instance.new("Part")
            newRoot.Name = "HumanoidRootPart"
            newRoot.Size = Vector3.new(2,2,1)
            newRoot.Anchored = false
            newRoot.CanCollide = true
            newRoot.CFrame = CFrame.new(0,50,0)
            newRoot.Parent = char
            hum.RootPart = newRoot
        end
    end)
end

local function unprotect()
    if hbConn then hbConn:Disconnect() end
    if hcConn then hcConn:Disconnect() end
    hbConn, hcConn = nil, nil
end

-- UI Toggle
Tab:CreateToggle({
    Name = "Legend GodMode (1% HP Safe)",
    CurrentValue = false,
    Callback = function(v)
        godOn = v
        local char = player.Character
        if char then
            if godOn then protect(char) else unprotect() end
        end
    end,
})

-- Respawn handler
player.CharacterAdded:Connect(function(char)
    if godOn then protect(char) end
end)

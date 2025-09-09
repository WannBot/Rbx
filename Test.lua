local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Absolute GodMode",
    LoadingTitle = "100% Anti Damage",
    LoadingSubtitle = "No Death • No Health Drop",
    KeySystem = false,
})

local Tab = Window:CreateTab("Player", 4483362458)

-- Variabel
local godMode = false
local currentFF
local hbConn, hcConn

-- Fungsi proteksi
local function protect(char)
    local hum = char:WaitForChild("Humanoid")

    -- Pastikan darah sangat besar dari awal
    hum.MaxHealth = math.huge
    hum.Health = hum.MaxHealth

    -- ForceField invisible
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = char
    currentFF = ff

    -- Disable state yg bisa bikin mati/jatuh
    for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state == Enum.HumanoidStateType.Dead 
        or state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.PlatformStanding
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.Swimming then
            hum:SetStateEnabled(state, false)
        end
    end

    -- Lock Health (tidak boleh turun)
    if hcConn then hcConn:Disconnect() end
    hcConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if godMode and hum and hum.Parent and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)

    -- Backup lock di Heartbeat
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if godMode and hum and hum.Parent then
            if hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end)
end

-- Fungsi stop proteksi
local function unprotect()
    if hbConn then hbConn:Disconnect() end
    if hcConn then hcConn:Disconnect() end
    hbConn, hcConn = nil, nil
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    currentFF = nil
end

-- Toggle di UI
Tab:CreateToggle({
    Name = "Absolute GodMode (100% Anti Damage)",
    CurrentValue = false,
    Callback = function(v)
        godMode = v
        local char = player.Character
        if char then
            if godMode then protect(char) else unprotect() end
        end
    end,
})

-- Respawn handler
player.CharacterAdded:Connect(function(char)
    if godMode then protect(char) end
end)

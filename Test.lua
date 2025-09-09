local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Strong Forcefield",
    LoadingTitle = "God Mode",
    LoadingSubtitle = "Anti Air & Anti Fall",
    KeySystem = false,
})

local Tab = Window:CreateTab("Player", 4483362458)

-- Variabel
local ffOn = false
local hbConn
local currentFF

-- Ambil karakter
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    return char, hum
end

-- Aktifkan proteksi
local function protect(char)
    local hum = char:WaitForChild("Humanoid")

    -- Forcefield invisible
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = char
    currentFF = ff

    -- Loop per frame: lock health & cegah fall death
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if ffOn and hum and hum.Parent then
            -- Kunci darah penuh
            hum.Health = hum.MaxHealth

            -- Disable state jatuh/mati
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

            -- Prevent drowning/terrain damage
            if hum:GetState() == Enum.HumanoidStateType.Swimming and hum.Health < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end
    end)
end

-- Matikan proteksi
local function unprotect()
    if hbConn then hbConn:Disconnect() end
    hbConn = nil
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    currentFF = nil
end

-- Toggle di UI
Tab:CreateToggle({
    Name = "Strong Forcefield (Anti Damage Besar)",
    CurrentValue = false,
    Callback = function(v)
        ffOn = v
        local char = player.Character
        if char then
            if ffOn then protect(char) else unprotect() end
        end
    end,
})

-- Respawn handler
player.CharacterAdded:Connect(function(char)
    if ffOn then protect(char) end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Main Features",
    LoadingTitle = "Forcefield Strong",
    LoadingSubtitle = "Anti Damage • Anti Fall",
    KeySystem = false,
})
local Tab = Window:CreateTab("Player", 4483362458)

-- Variabel
local ffOn = false
local hbConn

-- Fungsi aktifkan proteksi
local function protect(char)
    local hum = char:WaitForChild("Humanoid")

    -- bikin ForceField invisible
    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = char

    -- per frame: kunci health + cegah jatuh
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if ffOn and hum and hum.Parent then
            hum.Health = hum.MaxHealth
            -- cegah state jatuh/mati
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end)
end

local function unprotect()
    if hbConn then hbConn:Disconnect() end
    hbConn = nil
end

-- === UI Toggle ===
Tab:CreateToggle({
    Name = "Strong Forcefield (No Damage)",
    CurrentValue = false,
    Callback = function(v)
        ffOn = v
        local char = player.Character
        if char then
            if ffOn then
                protect(char)
            else
                unprotect()
            end
        end
    end,
})

-- Respawn handler
player.CharacterAdded:Connect(function(char)
    if ffOn then protect(char) end
end)

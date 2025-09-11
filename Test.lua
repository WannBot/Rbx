local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Anti-Fall Extreme",
    LoadingTitle = "Air-Brake + Soft Landing",
    LoadingSubtitle = "No Mid-Air Jump",
    KeySystem = false,
})
local Tab = Window:CreateTab("Anti-Fall", 4483362458)

-- ==== Parameters ====
local antiFallOn = true
local maxFallSpeed = 65        -- batas kecepatan jatuh
local groundBrakeDist = 12     -- jarak tanah untuk mulai rem
local brakeMultiplier = 1.25   -- kekuatan “parasut”

-- ==== UI ====
Tab:CreateToggle({
    Name = "Aktifkan Anti-Fall Extreme",
    CurrentValue = true,
    Callback = function(v) antiFallOn = v end
})
Tab:CreateSlider({
    Name = "Max Fall Speed (stud/s)",
    Range = {30, 150}, Increment = 1,
    CurrentValue = maxFallSpeed,
    Callback = function(v) maxFallSpeed = v end
})
Tab:CreateSlider({
    Name = "Rem Jarak Tanah (stud)",
    Range = {6, 30}, Increment = 1,
    CurrentValue = groundBrakeDist,
    Callback = function(v) groundBrakeDist = v end
})
Tab:CreateSlider({
    Name = "Kekuatan Parasut",
    Range = {1, 2}, Increment = 0.05,
    CurrentValue = brakeMultiplier,
    Callback = function(v) brakeMultiplier = v end
})

-- ==== State ====
local hbConn, vf, att

local function setupForce(hrp)
    if not att then
        att = Instance.new("Attachment")
        att.Name = "AF_Att"
        att.Parent = hrp
    end
    if not vf then
        vf = Instance.new("VectorForce")
        vf.Name = "AF_VectorForce"
        vf.Attachment0 = att
        vf.RelativeTo = Enum.ActuatorRelativeTo.World
        vf.Force = Vector3.zero
        vf.Parent = hrp
    end
end

local function enableAntiFall(char)
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    setupForce(hrp)

    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if not antiFallOn or not hum.Parent then
            if vf then vf.Force = Vector3.zero end
            return
        end

        local mass = hrp.AssemblyMass
        local g = Workspace.Gravity
        local vel = hrp.AssemblyLinearVelocity
        local vy = vel.Y

        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local ray = Workspace:Raycast(hrp.Position, Vector3.new(0, -groundBrakeDist, 0), params)
        local nearGround = ray ~= nil

        local forceY = 0

        -- Parasut saat jatuh cepat
        if vy < -maxFallSpeed then
            forceY = mass * g * brakeMultiplier
        end

        -- Soft landing saat dekat tanah
        if nearGround and vy < -maxFallSpeed/2 then
            -- clamp velocity agar nggak “nyungsep”
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.max(vy, -10), vel.Z)
            forceY = math.max(forceY, mass * g * (brakeMultiplier + 0.3))
        end

        -- Terapkan gaya
        if vf then
            vf.Force = Vector3.new(0, forceY, 0)
        end
    end)
end

local function disableAntiFall()
    if hbConn then hbConn:Disconnect() hbConn = nil end
    if vf then vf.Force = Vector3.zero end
end

-- Respawn handler
player.CharacterAdded:Connect(function(char)
    if antiFallOn then enableAntiFall(char) else disableAntiFall() end
end)
if player.Character then
    if antiFallOn then enableAntiFall(player.Character) end
end

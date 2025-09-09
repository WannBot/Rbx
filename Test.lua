-- Jalankan sebagai LocalScript / executor (untuk project-mu sendiri)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Anti-Fall Extreme",
    LoadingTitle = "Air-Brake + Soft Landing",
    LoadingSubtitle = "No Visual FF",
    KeySystem = false,
})
local Tab = Window:CreateTab("Anti-Fall", 4483362458)

-- ==== Parameters (bisa diubah dari UI) ====
local antiFallOn = true
local maxFallSpeed = 65        -- batas kecepatan jatuh (stud/s). Turunkan kalau masih sakit.
local groundBrakeDist = 12     -- mulai rem keras jika tanah < 12 stud di bawah
local brakeMultiplier = 1.25   -- kekuatan “parasut” relatif terhadap gravitasi (>=1)
local ffOn = true              -- guard opsional
local lockHealth = true        -- jaga darah tetap penuh

-- ==== UI ====
Tab:CreateToggle({
    Name = "Aktifkan Anti-Fall Extreme",
    CurrentValue = true,
    Callback = function(v) antiFallOn = v end
})
Tab:CreateSlider({
    Name = "Max Fall Speed (stud/s)",
    Range = {30, 150}, Increment = 1, Suffix = "vY",
    CurrentValue = maxFallSpeed,
    Callback = function(v) maxFallSpeed = v end
})
Tab:CreateSlider({
    Name = "Rem Jarak Tanah (stud)",
    Range = {6, 30}, Increment = 1, Suffix = "stud",
    CurrentValue = groundBrakeDist,
    Callback = function(v) groundBrakeDist = v end
})
Tab:CreateSlider({
    Name = "Kekuatan Parasut",
    Range = {1, 2}, Increment = 0.05, Suffix = "x g",
    CurrentValue = brakeMultiplier,
    Callback = function(v) brakeMultiplier = v end
})
Tab:CreateToggle({
    Name = "ForceField (Invisible)",
    CurrentValue = ffOn,
    Callback = function(v) ffOn = v end
})
Tab:CreateToggle({
    Name = "Lock Health (opsional)",
    CurrentValue = lockHealth,
    Callback = function(v) lockHealth = v end
})

-- ==== Helpers ====
local currentFF, vf, att    -- ForceField, VectorForce, Attachment
local hbConn, hcConn

local function setupAttachments(hrp)
    if att and att.Parent ~= hrp then att:Destroy(); att = nil end
    if vf and vf.Parent ~= hrp then vf:Destroy(); vf = nil end
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
        vf.Force = Vector3.new()
        vf.Enabled = true
        vf.Parent = hrp
    end
end

local function setFF(char, on)
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    if on then
        local ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = char
        currentFF = ff
    else
        currentFF = nil
    end
end

local function enableAntiFall(char)
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    -- jaga darah penuh dulu (kalau spawn lemah)
    hum.MaxHealth = math.max(hum.MaxHealth, 1e8)
    hum.Health = hum.MaxHealth

    -- opsional proteksi ringan
    setFF(char, ffOn)

    -- siapkan gaya pengurang jatuh
    setupAttachments(hrp)

    -- lock health bila diinginkan (cegah drop 1%)
    if hcConn then hcConn:Disconnect() end
    hcConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if lockHealth and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)

    -- loop kontrol jatuh
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function(dt)
        if not antiFallOn or not hum.Parent then
            if vf then vf.Force = Vector3.new() end
            return
        end

        -- jaga darah (opsional)
        if lockHealth and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end

        -- info fisika
        local mass = hrp.AssemblyMass
        local g = Workspace.Gravity
        local vel = hrp.AssemblyLinearVelocity
        local vy = vel.Y

        -- Ray ke bawah: deteksi tanah untuk soft landing
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Blacklist
        local hit = Workspace:Raycast(hrp.Position, Vector3.new(0, -groundBrakeDist, 0), params)
        local nearGround = hit ~= nil

        local forceY = 0

        -- 1) Parasut saat jatuh cepat
        if vy < -maxFallSpeed then
            -- gaya ke atas untuk mengimbangi g + sedikit ekstra (brakeMultiplier)
            forceY = mass * g * brakeMultiplier
        end

        -- 2) Soft landing saat dekat tanah dan masih turun
        if nearGround and vy < -10 then
            -- rem kuat + kecilkan kecepatan vertikal
            forceY = math.max(forceY, mass * g * (brakeMultiplier + 0.35))
            -- potong kecepatan vertikal supaya aman
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.max(vy, -10), vel.Z)
            hum:ChangeState(Enum.HumanoidStateType.Jumping) -- “sentuh” lompat kecil supaya tidak ragdoll
        end

        -- terapkan gaya
        if vf then
            if forceY > 0 then
                vf.Force = Vector3.new(0, forceY, 0)
            else
                vf.Force = Vector3.new()
            end
        end

        -- anti kill-plane (jaga-jaga)
        local killY = Workspace.FallenPartsDestroyHeight
        if killY == 0 then killY = -1000 end
        if hrp.Position.Y < killY + 25 then
            hrp.CFrame = CFrame.new(hrp.Position.X, killY + 80, hrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            if lockHealth then hum.Health = hum.MaxHealth end
        end
    end)
end

local function disableAntiFall()
    if hbConn then hbConn:Disconnect() hbConn = nil end
    if hcConn then hcConn:Disconnect() hcConn = nil end
    if vf then vf.Force = Vector3.new() end
end

-- handle respawn
player.CharacterAdded:Connect(function(char)
    if antiFallOn then enableAntiFall(char) else disableAntiFall() end
end)
if player.Character then
    if antiFallOn then enableAntiFall(player.Character) end
end

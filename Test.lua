local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Absolute GodMode+",
    LoadingTitle = "100% Anti Terrain & Fall",
    LoadingSubtitle = "No Visual FF",
    KeySystem = false,
})
local Tab = Window:CreateTab("Player", 4483362458)

-- ====== State ======
local godOn = false
local currentFF
local hbConn, hcConn

-- ==== Utils ====
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hum, hrp
end

-- Anti-killplane helper
local function getKillPlaneBuffer()
    -- default kill-plane sering -500 / -1000; kalau tak diketahui, pakai -1000
    local y = workspace.FallenPartsDestroyHeight
    if y == 0 then y = -1000 end
    return y + 50 -- zona aman = 50 stud di atas kill-plane
end

-- ==== Proteksi utama ====
local function enableGod(char)
    local hum, hrp
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    -- 1) Perbesar MaxHealth lebih dulu (mengatasi spawn darah rendah)
    hum.HealthDisplayDistance = 0
    hum.BreakJointsOnDeath = false
    hum.RequiresNeck = false
    hum.MaxHealth = 1e9
    hum.Health = hum.MaxHealth

    -- 2) ForceField tak terlihat
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = char
    currentFF = ff

    -- 3) Matikan state berbahaya
    for _, st in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
        if st == Enum.HumanoidStateType.Dead
        or st == Enum.HumanoidStateType.FallingDown
        or st == Enum.HumanoidStateType.PlatformStanding
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.Swimming then
            hum:SetStateEnabled(st, false)
        end
    end

    -- 4) Kunci Health: cegah drop 1% pun
    if hcConn then hcConn:Disconnect() end
    hcConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if godOn and hum and hum.Parent and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)

    -- 5) Heartbeat: anti-terrain, anti-fall, anti-killplane
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if not (godOn and hum and hum.Parent and hrp and hrp.Parent) then return end

        -- Pastikan penuh
        if hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end

        -- Anti kill-plane
        local safeY = getKillPlaneBuffer()
        if hrp.Position.Y < safeY then
            hrp.CFrame = CFrame.new(hrp.Position.X, safeY + 10, hrp.Position.Z)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        -- Anti-terrain air: cek material di bawah kaki
        local matBelow = workspace.Terrain:ReadVoxels(
            Region3.new(hrp.Position - Vector3.new(2,6,2), hrp.Position + Vector3.new(2,2,2)),
            4
        )
        -- Atau yang ringan: GetMaterialAt (sekali titik)
        local mat = workspace.Terrain:GetMaterialAt(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
        if mat == Enum.Material.Water then
            -- naikkan karakter dari air + nol-kan kecepatan jatuh
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)
            local v = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            -- jaga darah full
            hum.Health = hum.MaxHealth
        end

        -- Anti-fall: jika akan “mendarat keras”, hambat kecepatan vertikal sebelum menyentuh tanah
        local v = hrp.AssemblyLinearVelocity
        local verticalSpeed = v.Y
        if verticalSpeed < -80 then
            -- ada tanah dekat di bawah?
            local ray = workspace:Raycast(hrp.Position, Vector3.new(0, -12, 0), RaycastParams.new())
            if ray then
                -- rem jatuh + lompat sedikit
                hrp.AssemblyLinearVelocity = Vector3.new(v.X, -10, v.Z)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hum.Health = hum.MaxHealth
            end
        end
    end)
end

local function disableGod()
    if hbConn then hbConn:Disconnect() end
    if hcConn then hcConn:Disconnect() end
    hbConn, hcConn = nil, nil
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    currentFF = nil
end

-- === UI Toggle ===
Tab:CreateToggle({
    Name = "Absolute GodMode+ (100% Anti Terrain/Fall)",
    CurrentValue = false,
    Callback = function(on)
        godOn = on
        local char = player.Character
        if char then
            if godOn then enableGod(char) else disableGod() end
        end
    end
})

-- Terapkan saat respawn
player.CharacterAdded:Connect(function(char)
    if godOn then enableGod(char) end
end)

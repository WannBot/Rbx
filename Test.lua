-- LocalScript / executor (gunakan di proyek milikmu sendiri)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Debug Tools",
    LoadingTitle = "Safe Utilities",
    LoadingSubtitle = "Forcefield • Invis • Speed • Jump • Noclip • Fly",
    KeySystem = false,
})
local Tab = Window:CreateTab("Player", 4483362458)
Tab:CreateSection("Toggles & Sliders")

-- === State ===
local walkSpeedVal, jumpPowerVal = 16, 50
local ffOn, invisOn, noclipOn, flyOn = false, false, false, false
local flySpeed = 75
local currentFF
local hbConn, noclipConn, flyConn
local savedAlpha = {}

local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hum, hrp
end

local function applyMovement(hum)
    hum.WalkSpeed = walkSpeedVal
    hum.UseJumpPower = true
    hum.JumpPower = jumpPowerVal
end

-- Forcefield
local function setFF(char, on)
    if on then
        if currentFF and currentFF.Parent then currentFF:Destroy() end
        currentFF = Instance.new("ForceField")
        currentFF.Visible = true
        currentFF.Parent = char
    else
        if currentFF and currentFF.Parent then currentFF:Destroy() end
        currentFF = nil
    end
end

-- Invisible (local only)
local function setInvisibleLocal(char, on)
    for k in pairs(savedAlpha) do savedAlpha[k] = nil end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            if on then
                savedAlpha[d] = d.LocalTransparencyModifier
                d.LocalTransparencyModifier = 1
            else
                d.LocalTransparencyModifier = savedAlpha[d] or 0
            end
        elseif d:IsA("Decal") or d:IsA("Texture") then
            if on then
                savedAlpha[d] = d.Transparency
                d.Transparency = 1
            else
                d.Transparency = savedAlpha[d] or 0
            end
        end
    end
end

-- Noclip (hanya karakter sendiri)
local function setNoclip(char, on)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Fly (aman untuk debug)
local flyKeys = {W=false,S=false,A=false,D=false,Space=false,Ctrl=false}
local function setFly(on)
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    flyOn = on
    if not on then return end
    flyConn = RunService.Heartbeat:Connect(function(dt)
        local char, hum, hrp = getChar()
        local dir = Vector3.zero
        if flyKeys.W then dir += hrp.CFrame.LookVector end
        if flyKeys.S then dir -= hrp.CFrame.LookVector end
        if flyKeys.A then dir -= hrp.CFrame.RightVector end
        if flyKeys.D then dir += hrp.CFrame.RightVector end
        if flyKeys.Space then dir += Vector3.new(0,1,0) end
        if flyKeys.Ctrl then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = dir.Unit * flySpeed
        else
            -- perlambat saat tidak input
            hrp.AssemblyLinearVelocity *= 0.9
        end
        hum.PlatformStand = true -- biar tubuh “melayang”
    end)
end

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.W then flyKeys.W = true end
    if i.KeyCode == Enum.KeyCode.S then flyKeys.S = true end
    if i.KeyCode == Enum.KeyCode.A then flyKeys.A = true end
    if i.KeyCode == Enum.KeyCode.D then flyKeys.D = true end
    if i.KeyCode == Enum.KeyCode.Space then flyKeys.Space = true end
    if i.KeyCode == Enum.KeyCode.LeftControl or i.KeyCode == Enum.KeyCode.RightControl then flyKeys.Ctrl = true end
end)
UserInputService.InputEnded:Connect(function(i, gp)
    if i.KeyCode == Enum.KeyCode.W then flyKeys.W = false end
    if i.KeyCode == Enum.KeyCode.S then flyKeys.S = false end
    if i.KeyCode == Enum.KeyCode.A then flyKeys.A = false end
    if i.KeyCode == Enum.KeyCode.D then flyKeys.D = false end
    if i.KeyCode == Enum.KeyCode.Space then flyKeys.Space = false end
    if i.KeyCode == Enum.KeyCode.LeftControl or i.KeyCode == Enum.KeyCode.RightControl then flyKeys.Ctrl = false end
end)

-- Self Impulse (debug dorong diri)
local function selfImpulse()
    local _, _, hrp = getChar()
    local look = hrp.CFrame.LookVector
    hrp.AssemblyLinearVelocity = look * 60 + Vector3.new(0, 35, 0)
end

-- Heartbeat reapply (jaga nilai saat game mengubah)
local function bindHeartbeat(hum)
    if hbConn then hbConn:Disconnect(); hbConn = nil end
    hbConn = RunService.Heartbeat:Connect(function()
        if hum and hum.Parent then
            if hum.WalkSpeed ~= walkSpeedVal then hum.WalkSpeed = walkSpeedVal end
            if hum.UseJumpPower ~= true or hum.JumpPower ~= jumpPowerVal then
                hum.UseJumpPower = true
                hum.JumpPower = jumpPowerVal
            end
        end
    end)
end

-- UI Controls
Tab:CreateToggle({
    Name = "Forcefield",
    CurrentValue = false,
    Callback = function(v)
        ffOn = v
        local char = player.Character
        if char then setFF(char, ffOn) end
    end
})

Tab:CreateToggle({
    Name = "Invisible (Local)",
    CurrentValue = false,
    Callback = function(v)
        invisOn = v
        local char = player.Character
        if char then setInvisibleLocal(char, invisOn) end
    end
})

Tab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        noclipOn = v
        local char = player.Character
        if char then setNoclip(char, noclipOn) end
    end
})

Tab:CreateToggle({
    Name = "Fly Mode (WASD/Space/Ctrl)",
    CurrentValue = false,
    Callback = function(v)
        setFly(v)
    end
})

Tab:CreateSlider({
    Name = "Fly Speed",
    Range = {25, 200},
    Increment = 5,
    Suffix = "spd",
    CurrentValue = 75,
    Callback = function(val)
        flySpeed = val
    end
})

Tab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "spd",
    CurrentValue = 16,
    Callback = function(val)
        walkSpeedVal = val
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = walkSpeedVal end
        end
    end
})

Tab:CreateSlider({
    Name = "JumpPower",
    Range = {25, 250},
    Increment = 1,
    Suffix = "jp",
    CurrentValue = 50,
    Callback = function(val)
        jumpPowerVal = val
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.UseJumpPower = true hum.JumpPower = jumpPowerVal end
        end
    end
})

Tab:CreateButton({
    Name = "Self Impulse (Dorong Diri)",
    Callback = function()
        selfImpulse()
    end
})

-- Character lifecycle
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    applyMovement(hum)
    bindHeartbeat(hum)
    setFF(char, ffOn)
    setInvisibleLocal(char, invisOn)
    setNoclip(char, noclipOn)
    if flyOn then setFly(true) end
end)
if player.Character then
    local hum = player.Character:WaitForChild("Humanoid")
    applyMovement(hum)
    bindHeartbeat(hum)
end

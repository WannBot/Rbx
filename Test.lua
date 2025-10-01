-- Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Player
local Player = Players.LocalPlayer
local function getChar()
    local c = Player.Character or Player.CharacterAdded:Wait()
    return c, c:WaitForChild("HumanoidRootPart"), c:WaitForChild("Humanoid")
end
local char, rootPart, hum = getChar()

-- Fly state
local Flying = false
local currentCF = rootPart.CFrame
local hbConn
local speed = 2

-- get camera basis (horizontal)
local function getCameraBasis()
    local camCF = Camera.CFrame
    local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
    return forward, right
end

-- toggle fly
local function toggleFly(on)
    Flying = on
    if Flying then
        hum.PlatformStand = true
        if hbConn then hbConn:Disconnect() end
        hbConn = RunService.Heartbeat:Connect(function()
            if not Flying then return end

            local add = Vector3.new(0, 0, 0)

            -- PC controls
            if UIS:IsKeyDown(Enum.KeyCode.W) then add += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then add -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then add += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then add -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.E) then add += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then add -= Vector3.new(0, 1, 0) end

            -- Mobile joystick via hum.MoveDirection
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                local forward, right = getCameraBasis()
                add += forward * md.Z + right * md.X
            end

            -- reset velocities
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero

            currentCF += add * speed
            rootPart.CFrame = CFrame.lookAt(
                currentCF.Position,
                currentCF.Position + (Camera.CFrame.LookVector * 2)
            )
        end)
    else
        if hbConn then hbConn:Disconnect() hbConn = nil end
        hum.PlatformStand = false
    end
end

-- Load Fluent
local ok, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)
if not ok or not Fluent then
    warn("Gagal load Fluent UI library")
    -- fallback UI minimal
    local sg = Instance.new("ScreenGui", game.CoreGui)
    local btn = Instance.new("TextButton", sg)
    btn.Size = UDim2.new(0, 200, 0, 50)
    btn.Position = UDim2.new(0.5, -100, 0.2, 0)
    btn.Text = "Fly: OFF"
    btn.MouseButton1Click:Connect(function()
        Flying = not Flying
        toggleFly(Flying)
        btn.Text = Flying and "Fly: ON" or "Fly: OFF"
    end)
    return
end

-- Create Fluent UI
local Window = Fluent:CreateWindow({
    Title = "Fly UI",
    SubTitle = "Fluent",
    Theme = "Dark",
    Width = 300,
    Height = 150,
})

local Tab = Window:AddTab("Main")

Tab:AddToggle("FlyToggle", { Title = "Enable Fly", Default = false }, function(v)
    toggleFly(v)
end)

Tab:AddSlider("FlySpeed", {
    Title = "Speed",
    Description = "Fly speed multiplier",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 1,
}, function(val)
    speed = val
end)

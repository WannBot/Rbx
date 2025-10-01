--// Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

--// Player
local Player = Players.LocalPlayer
local function getChar()
    local c = Player.Character or Player.CharacterAdded:Wait()
    return c, c:WaitForChild("HumanoidRootPart"), c:WaitForChild("Humanoid")
end
local char, rootPart, hum = getChar()

--// State
local Flying = false
local currentCF = rootPart.CFrame
local hbConn
local speed = 2

-- fungsi ambil basis kamera (hanya yaw)
local function getCameraBasis()
    local camCF = Camera.CFrame
    local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
    return forward, right
end

-- toggle fly
local function toggleFly(state)
    Flying = state
    if Flying then
        hum.PlatformStand = true
        if hbConn then hbConn:Disconnect() end
        hbConn = RunService.Heartbeat:Connect(function()
            if not Flying then return end

            local add = Vector3.new(0,0,0)

            -- PC keyboard
            if UIS:IsKeyDown(Enum.KeyCode.W) then add += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then add -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then add += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then add -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.E) then add += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then add -= Vector3.new(0,1,0) end

            -- Mobile joystick (Thumbstick Dinamis)
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local forward, right = getCameraBasis()
                local input = Vector3.new(moveDir.X, 0, moveDir.Z)
                add += (forward * input.Z) + (right * input.X)
            end

            -- apply
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

--// === Fluent UI ===
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/source.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fly Control",
    SubTitle = "Fluent UI",
    TabWidth = 120,
    Size = UDim2.fromOffset(430, 300),
    Acrylic = true, -- blur background
    Theme = "Dark"
})

local Tab = Window:AddTab({ Title = "Main", Icon = "airplane" })

-- Toggle Fly
Tab:AddToggle("FlyToggle", { Title = "Enable Fly", Default = false }, function(state)
    toggleFly(state)
end)

-- Slider Speed
Tab:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust movement speed",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 1,
}, function(val)
    speed = val
end)

-- Notification Example
Fluent:Notify({
    Title = "Fly Script",
    Content = "Loaded with Fluent UI",
    Duration = 5
})

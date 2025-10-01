--// Load FluentPlus
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua", true))()

--// Window
local Window = Fluent:CreateWindow({
    Title = "Fly Control",
    SubTitle = "FluentPlus UI",
    Theme = "Dark",
    Size = UDim2.fromOffset(450, 300),
})

local Tab = Window:AddTab({ Title = "Main", Icon = "airplane" })

--// Fly Logic
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local char, root, hum

local function bindChar()
    char = Player.Character or Player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end
bindChar()
Player.CharacterAdded:Connect(bindChar)

local Flying, hbConn = false, nil
local currentCF = root.CFrame
local speed = 2

local function getCameraBasis()
    local camCF = Camera.CFrame
    local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
    local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
    return forward, right
end

local function toggleFly(state)
    Flying = state
    if Flying then
        hum.PlatformStand = true
        if hbConn then hbConn:Disconnect() end
        hbConn = RunService.Heartbeat:Connect(function()
            if not Flying then return end

            local add = Vector3.new()

            -- PC keys
            if UIS:IsKeyDown(Enum.KeyCode.W) then add += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then add -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then add += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then add -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.E) then add += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then add -= Vector3.new(0,1,0) end

            -- Mobile analog (thumbstick dinamis)
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                local f, r = getCameraBasis()
                add += f * md.Z + r * md.X
            end

            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero

            currentCF += add * speed
            root.CFrame = CFrame.lookAt(currentCF.Position, currentCF.Position + (Camera.CFrame.LookVector * 2))
        end)
    else
        if hbConn then hbConn:Disconnect() hbConn = nil end
        hum.PlatformStand = false
    end
end

--// UI Controls
Tab:AddToggle("FlyToggle", { Title = "Enable Fly", Default = false }, function(v)
    toggleFly(v)
end)

Tab:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 1,
}, function(val)
    speed = val
end)

Fluent:Notify({
    Title = "Fly Script",
    Content = "FluentPlus UI Loaded ✅",
    Duration = 5
})

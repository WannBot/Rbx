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

--// Fly toggle
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

            -- Mobile joystick (Thumbstick Dinamis default)
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- ambil basis kamera (horizontal only)
                local camCF = Camera.CFrame
                local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
                add += (forward * moveDir.Z) + (right * moveDir.X)
            end

            -- apply fly
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

--// === UI sederhana ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local Toggle = Instance.new("TextButton", Frame)
local SpeedBtn = Instance.new("TextButton", Frame)

ScreenGui.ResetOnSpawn = false
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(0.5, -110, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 10)
Toggle.Text = "Fly: OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextSize = 20

local flyOn = false
Toggle.MouseButton1Click:Connect(function()
    flyOn = not flyOn
    Toggle.Text = flyOn and "Fly: ON" or "Fly: OFF"
    toggleFly(flyOn)
end)

-- Speed cycle button
SpeedBtn.Size = UDim2.new(1, -20, 0, 40)
SpeedBtn.Position = UDim2.new(0, 10, 0, 60)
SpeedBtn.Text = "Speed: x"..speed
SpeedBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.SourceSansBold
SpeedBtn.TextSize = 18

SpeedBtn.MouseButton1Click:Connect(function()
    speed = speed + 1
    if speed > 5 then speed = 1 end
    SpeedBtn.Text = "Speed: x"..speed
end)

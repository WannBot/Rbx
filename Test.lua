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

--// Fly state
local Flying = false
local currentCF = rootPart.CFrame
local hbConn

--// Fly toggle
local function toggleFly(state)
	Flying = state
	if Flying then
		hum.PlatformStand = true
		if hbConn then hbConn:Disconnect() end
		hbConn = RunService.Heartbeat:Connect(function()
			if not Flying then return end

			local add = Vector3.new(0,0,0)

			-- PC Keyboard
			if UIS:IsKeyDown(Enum.KeyCode.W) then add += Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then add -= Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then add += Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then add -= Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.E) then add += Camera.CFrame.UpVector end
			if UIS:IsKeyDown(Enum.KeyCode.Q) then add -= Camera.CFrame.UpVector end

			-- Mobile Joystick (MoveDirection)
			local moveDir = hum.MoveDirection
			if moveDir.Magnitude > 0 then
				-- arah joystick relatif kamera
				local camRelative = Camera.CFrame:VectorToWorldSpace(moveDir)
				add += camRelative
			end

			-- Apply movement
			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero

			currentCF += add
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

--// === Minimal UI ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local Toggle = Instance.new("TextButton", Frame)

ScreenGui.ResetOnSpawn = false
Frame.Size = UDim2.new(0, 200, 0, 80)
Frame.Position = UDim2.new(0.5, -100, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true

Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0.5, -20)
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

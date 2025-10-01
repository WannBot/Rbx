--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

--// Player
local Player = Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local Root = Char:WaitForChild("HumanoidRootPart")

--// Fly state
local Flying = false
local FlySpeed = 50
local BodyVelocity
local HBConn

--// Toggle Fly
local function toggleFly(state)
	Flying = state
	if Flying then
		if not BodyVelocity then
			BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Velocity = Vector3.new(0,0,0)
			BodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
			BodyVelocity.P = 10000
			BodyVelocity.Parent = Root
		end

		if HBConn then HBConn:Disconnect() end
		HBConn = RunService.Heartbeat:Connect(function()
			if not Flying then return end

			local moveDir = Vector3.new(0,0,0)

			-- PC Keyboard
			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.E) then moveDir += Camera.CFrame.UpVector end
			if UIS:IsKeyDown(Enum.KeyCode.Q) then moveDir -= Camera.CFrame.UpVector end

			-- Mobile Joystick
			if Hum.MoveDirection.Magnitude > 0 then
				local camRelative = Camera.CFrame:VectorToWorldSpace(Hum.MoveDirection)
				moveDir += camRelative
			end

			if moveDir.Magnitude > 0 then
				BodyVelocity.Velocity = moveDir.Unit * FlySpeed
			else
				BodyVelocity.Velocity = Vector3.zero
			end
		end)
	else
		if HBConn then HBConn:Disconnect() HBConn = nil end
		if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
	end
end

--// === Minimal UI (Button On/Off) ===
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
local Toggle = Instance.new("TextButton", Frame)

ScreenGui.ResetOnSpawn = false
Frame.Size = UDim2.new(0, 200, 0, 80)
Frame.Position = UDim2.new(0.5, -100, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true

Toggle.Size = UDim2.new(1, -20, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0.5, -20)
Toggle.Text = "Fly: OFF"
Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
Toggle.TextColor3 = Color3.fromRGB(255,255,255)
Toggle.Font = Enum.Font.SourceSansBold
Toggle.TextSize = 20

local flyOn = false
Toggle.MouseButton1Click:Connect(function()
	flyOn = not flyOn
	Toggle.Text = flyOn and "Fly: ON" or "Fly: OFF"
	toggleFly(flyOn)
end)

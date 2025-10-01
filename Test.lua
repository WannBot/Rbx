--// Services
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

--// Player
local Player = Players.LocalPlayer
local char = Player.Character or Player.CharacterAdded:Wait()
local rootPart: BasePart = char:WaitForChild("HumanoidRootPart")
local hum: Humanoid = char:WaitForChild("Humanoid")

--// Fly state
local Flying = false
local currentCF = rootPart.CFrame

--// Fly toggle function
local function toggleFly(state)
	Flying = state
	
	if Flying then
		hum.PlatformStand = true
		RunService.Heartbeat:Connect(function()
			if not Flying then return end

			local add = Vector3.new(0,0,0)

			if UIS:IsKeyDown(Enum.KeyCode.W) then add += Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then add -= Camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then add += Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then add -= Camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.E) then add += Camera.CFrame.UpVector end
			if UIS:IsKeyDown(Enum.KeyCode.Q) then add -= Camera.CFrame.UpVector end

			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero

			currentCF += add
			rootPart.CFrame = CFrame.lookAt(
				currentCF.Position,
				currentCF.Position + (Camera.CFrame.LookVector * 2)
			)
		end)
	else
		hum.PlatformStand = false
	end
end

--// === UI: Union Library ===
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/UnionFairy/UILibs/main/UnionLibrary.lua"))()

local Window = Library:CreateWindow("Delta UI")
local Tab = Window:CreateTab("Fly Tool")

Tab:CreateToggle("Fly Mode", function(val)
	toggleFly(val)
end)

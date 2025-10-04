-- // LocalScript: Tap To Walk with Dot Path Visualization
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

--=== STATE ===--
local activePath = nil
local pathDots = {}
local moving = false

--=== VISUAL ===--
local function clearDots()
	for _, d in ipairs(pathDots) do
		if d and d.Parent then d:Destroy() end
	end
	pathDots = {}
end

local function showPath(waypoints)
	clearDots()
	for _, wp in ipairs(waypoints) do
		local dot = Instance.new("Part")
		dot.Shape = Enum.PartType.Ball
		dot.Anchored = true
		dot.CanCollide = false
		dot.Material = Enum.Material.Neon
		dot.Color = Color3.fromRGB(0, 255, 0)
		dot.Size = Vector3.new(0.4, 0.4, 0.4)
		dot.Position = wp.Position + Vector3.new(0, 0.2, 0)
		dot.Parent = workspace
		table.insert(pathDots, dot)
	end
end

--=== PATHFINDING ===--
local function moveToPoint(position)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true
	})
	path:ComputeAsync(hrp.Position, position)

	if path.Status == Enum.PathStatus.Success then
		activePath = path
		showPath(path:GetWaypoints())

		moving = true
		for _, waypoint in ipairs(path:GetWaypoints()) do
			if not moving then break end
			hum:MoveTo(waypoint.Position)
			hum.MoveToFinished:Wait()
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	else
		warn("Gagal menghitung jalur ke lokasi tersebut.")
	end
	moving = false
end

--=== INPUT ===--
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local mouse = player:GetMouse()
		local targetPos = mouse.Hit and mouse.Hit.p
		if targetPos then
			moveToPoint(targetPos)
		end
	end
end)

--=== UI (RAYFIELD) ===--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Path Visualizer",
	LoadingTitle = "Tap to Walk",
	LoadingSubtitle = "Path Dot Visual",
	KeySystem = false
})

local Tab = Window:CreateTab("Path Control", 4483362458)
Tab:CreateButton({
	Name = "🧹 Clear Path Dots",
	Callback = clearDots
})
Tab:CreateToggle({
	Name = "⏹ Stop Movement",
	CurrentValue = false,
	Callback = function(state)
		moving = not state
	end
})

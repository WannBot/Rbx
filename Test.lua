local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- GUI Toggle
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0,180,0,40)
Button.Position = UDim2.new(0.05,0,0.8,0)
Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Text = "Auto Walk: OFF"
Button.Parent = ScreenGui

-- Status
local autoWalk = false
local currentIndex = 1

-- >>> Daftar koordinat tujuan <<<
local daftarTujuan = {
	Vector3.new(-32, 406, 637),
	Vector3.new(-24, 422, 637),
	Vector3.new(-15, 440, 638),
	Vector3.new(-16, 445, 625),
	Vector3.new(-16, 449, 610),
	Vector3.new(-16, 452, 603),
}

-- Parameter agen
local PATH_PARAMS = {
	AgentRadius = 2,
	AgentHeight = 5,
	AgentCanJump = true,
	AgentMaxSlope = 45,
}

-- Hitung path
local function computePath(fromPos, toPos)
	local path = PathfindingService:CreatePath(PATH_PARAMS)
	path:ComputeAsync(fromPos, toPos)
	return path
end

-- Ikuti path
local function followPath(path)
	if path.Status ~= Enum.PathStatus.Success then
		return false
	end

	local waypoints = path:GetWaypoints()
	for _, wp in ipairs(waypoints) do
		if not autoWalk then break end

		if wp.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		elseif wp.Action == Enum.PathWaypointAction.Custom then
			-- >>> Ini lewat PathfindingLink <<<
			print("Melewati PathfindingLink ke:", wp.Position)
			-- Bisa pakai teleport, atau climbing manual
			humanoid:MoveTo(wp.Position)
			-- contoh: lompat supaya naik
			humanoid.Jump = true
		end

		humanoid:MoveTo(wp.Position)
		humanoid.MoveToFinished:Wait()
	end
	return true
end

-- Toggle
Button.MouseButton1Click:Connect(function()
	autoWalk = not autoWalk
	if autoWalk then
		Button.Text = "Auto Walk: ON"
		currentIndex = 1
	else
		Button.Text = "Auto Walk: OFF"
	end
end)

-- Loop
task.spawn(function()
	while task.wait(0.5) do
		if autoWalk and daftarTujuan[currentIndex] then
			local path = computePath(root.Position, daftarTujuan[currentIndex])
			local ok = followPath(path)
			if ok then
				currentIndex += 1
				if currentIndex > #daftarTujuan then
					autoWalk = false
					Button.Text = "Auto Walk: OFF"
				end
			else
				task.wait(0.5)
			end
		end
	end
end)

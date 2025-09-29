-- Auto Walk ke Banyak Koordinat (Pathfinding + Toggle)
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0,160,0,40)
Button.Position = UDim2.new(0.05,0,0.8,0)
Button.BackgroundColor3 = Color3.fromRGB(40,40,40)
Button.TextColor3 = Color3.fromRGB(255,255,255)
Button.Text = "Auto Walk: OFF"
Button.Parent = ScreenGui

-- Status
local autoWalk = false
local currentIndex = 1

-- >>> Daftar koordinat tujuan (edit sesuai map kamu) <<<
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
	AgentMaxSlope = 45, -- bisa naik tangga/permukaan miring
}

-- Hitung path
local function computePath(fromPos, toPos)
	local path = PathfindingService:CreatePath(PATH_PARAMS)
	path:ComputeAsync(fromPos, toPos)
	return path
end

-- Jalan mengikuti path
local function followPath(path)
	if path.Status ~= Enum.PathStatus.Success then
		return false
	end
	local waypoints = path:GetWaypoints()
	for _, wp in ipairs(waypoints) do
		if not autoWalk then break end
		if wp.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
		humanoid:MoveTo(wp.Position)
		local reached = humanoid.MoveToFinished:Wait()
		if not reached then
			return false
		end
	end
	return true
end

-- Toggle tombol
Button.MouseButton1Click:Connect(function()
	autoWalk = not autoWalk
	if autoWalk then
		Button.Text = "Auto Walk: ON"
		currentIndex = 1
	else
		Button.Text = "Auto Walk: OFF"
	end
end)

-- Loop jalan berurutan
task.spawn(function()
	while task.wait(0.5) do
		if autoWalk and daftarTujuan[currentIndex] then
			local path = computePath(root.Position, daftarTujuan[currentIndex])
			local ok = followPath(path)
			if ok then
				currentIndex += 1 -- lanjut ke titik berikutnya
				if currentIndex > #daftarTujuan then
					autoWalk = false
					Button.Text = "Auto Walk: OFF"
				end
			else
				task.wait(0.5) -- coba lagi kalau gagal
			end
		end
	end
end)

-- ✅ AUTO WALK RECORDER (Save ke Folder AutoWalk)
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local player = PlayerService.LocalPlayer
if not player then player = PlayerService.PlayerAdded:Wait() end
player:WaitForChild("PlayerGui")

-- Pastikan folder save ada
local folderPath = "AutoWalk"
if not isfolder(folderPath) then makefolder(folderPath) end

-- GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "AutoWalkUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 240, 0, 230)
frame.Position = UDim2.new(0.5, -120, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
frame.Active = true
frame.Draggable = true

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(60, 120, 255)

local title = Instance.new("TextLabel", header)
title.Text = "Auto Walk Recorder"
title.Size = UDim2.new(1, -90, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Tombol header
local btnMin = Instance.new("TextButton", header)
btnMin.Text, btnMin.Size, btnMin.Position = "–", UDim2.new(0,25,0,25), UDim2.new(1,-75,0,2)
btnMin.BackgroundColor3 = Color3.fromRGB(255,220,90)

local btnFull = Instance.new("TextButton", header)
btnFull.Text, btnFull.Size, btnFull.Position = "□", UDim2.new(0,25,0,25), UDim2.new(1,-50,0,2)
btnFull.BackgroundColor3 = Color3.fromRGB(90,220,255)

local btnClose = Instance.new("TextButton", header)
btnClose.Text, btnClose.Size, btnClose.Position = "×", UDim2.new(0,25,0,25), UDim2.new(1,-25,0,2)
btnClose.BackgroundColor3 = Color3.fromRGB(255,100,100)

local status = Instance.new("TextLabel", frame)
status.Text = "Status: Idle"
status.Size = UDim2.new(1,0,0,25)
status.Position = UDim2.new(0,0,0,30)
status.TextColor3 = Color3.fromRGB(0,0,0)
status.BackgroundColor3 = Color3.fromRGB(255,255,255)
status.TextScaled = true

-- Tombol utama
local btnRecord = Instance.new("TextButton", frame)
btnRecord.Text = "Start Record"
btnRecord.Size = UDim2.new(0,110,0,30)
btnRecord.Position = UDim2.new(0,10,0,65)
btnRecord.BackgroundColor3 = Color3.fromRGB(255,80,80)
btnRecord.TextScaled = true

local btnStopRecord = Instance.new("TextButton", frame)
btnStopRecord.Text = "Stop Record"
btnStopRecord.Size = UDim2.new(0,110,0,30)
btnStopRecord.Position = UDim2.new(0,120,0,65)
btnStopRecord.BackgroundColor3 = Color3.fromRGB(255,170,60)
btnStopRecord.TextScaled = true

local btnPlay = Instance.new("TextButton", frame)
btnPlay.Text = "Play Replay"
btnPlay.Size = UDim2.new(0,110,0,30)
btnPlay.Position = UDim2.new(0,10,0,100)
btnPlay.BackgroundColor3 = Color3.fromRGB(60,200,100)
btnPlay.TextScaled = true

local btnStopPlay = Instance.new("TextButton", frame)
btnStopPlay.Text = "Stop Replay"
btnStopPlay.Size = UDim2.new(0,110,0,30)
btnStopPlay.Position = UDim2.new(0,120,0,100)
btnStopPlay.BackgroundColor3 = Color3.fromRGB(255,100,100)
btnStopPlay.TextScaled = true

-- Scroll area daftar save
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0,10,0,140)
scroll.Size = UDim2.new(1,-20,0,80)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 8
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,5)

-- Variabel utama
local recording, playing = false, false
local pathData, currentSaveIndex = {}, 0
local hum, root = nil, nil

-- Init character
local function bindChar()
	local char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- Record
btnRecord.MouseButton1Click:Connect(function()
	if recording then return end
	recording = true
	pathData = {}
	status.Text = "Status: Recording..."
	task.spawn(function()
		while recording and root do
			table.insert(pathData, {X=root.Position.X,Y=root.Position.Y,Z=root.Position.Z})
			RunService.Heartbeat:Wait()
		end
	end)
end)

-- Stop record + save otomatis
btnStopRecord.MouseButton1Click:Connect(function()
	if not recording then return end
	recording = false
	status.Text = "Saving..."
	currentSaveIndex += 1
	local fileName = string.format("%s/Path_%d.json", folderPath, currentSaveIndex)
	writefile(fileName, HttpService:JSONEncode(pathData))
	status.Text = "✅ Saved: Path_"..currentSaveIndex..".json"

	local btn = Instance.new("TextButton", scroll)
	btn.Text = "Path_"..currentSaveIndex
	btn.Size = UDim2.new(1,-10,0,25)
	btn.BackgroundColor3 = Color3.fromRGB(200,220,255)
	btn.TextScaled = true

	local play = Instance.new("TextButton", btn)
	play.Text = "▶"
	play.Size = UDim2.new(0,25,1,0)
	play.Position = UDim2.new(1,-50,0,0)
	play.BackgroundColor3 = Color3.fromRGB(120,255,150)
	play.TextScaled = true

	local del = Instance.new("TextButton", btn)
	del.Text = "✖"
	del.Size = UDim2.new(0,25,1,0)
	del.Position = UDim2.new(1,-25,0,0)
	del.BackgroundColor3 = Color3.fromRGB(255,120,120)
	del.TextScaled = true

	scroll.CanvasSize = UDim2.new(0,0,0,#scroll:GetChildren()*30)

	play.MouseButton1Click:Connect(function()
		if playing then return end
		local data = HttpService:JSONDecode(readfile(fileName))
		if not data then return end
		playing = true
		status.Text = "Status: Playing " .. btn.Text
		for _,pos in ipairs(data) do
			if not playing then break end
			root.CFrame = CFrame.new(Vector3.new(pos.X,pos.Y,pos.Z))
			RunService.Heartbeat:Wait()
		end
		status.Text = "Status: Idle"
		playing = false
	end)

	del.MouseButton1Click:Connect(function()
		if isfile(fileName) then delfile(fileName) end
		btn:Destroy()
		status.Text = "🗑 Deleted " .. fileName
	end)
end)

-- Stop play
btnStopPlay.MouseButton1Click:Connect(function()
	if playing then
		playing = false
		status.Text = "⏹ Stopped Replay"
	end
end)

-- Tombol header
btnMin.MouseButton1Click:Connect(function()
	frame.Visible = false
	local restore = Instance.new("TextButton", screenGui)
	restore.Text = "Open AutoWalk"
	restore.Size = UDim2.new(0,140,0,30)
	restore.Position = UDim2.new(0.5,-70,0.9,0)
	restore.BackgroundColor3 = Color3.fromRGB(100,180,255)
	restore.TextScaled = true
	restore.MouseButton1Click:Connect(function()
		frame.Visible = true
		restore:Destroy()
	end)
end)

local full = false
btnFull.MouseButton1Click:Connect(function()
	if not full then
		frame:TweenSize(UDim2.new(0,400,0,400),"Out","Sine",0.3,true)
	else
		frame:TweenSize(UDim2.new(0,240,0,230),"Out","Sine",0.3,true)
	end
	full = not full
end)

btnClose.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Auto Walk Recorder GUI dengan Save/Load (untuk project pribadi)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Data
local recordedPath = {}
local recording = false
local playback = false
local speedMultiplier = 1.0

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,260,0,170)
Frame.Position = UDim2.new(0.05,0,0.7,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Active = true
Frame.Draggable = true -- bisa di-drag
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "Auto Walk Recorder"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.fromRGB(45,45,45)
Title.Parent = Frame

-- Tombol
local recordBtn = Instance.new("TextButton")
recordBtn.Text = "Start Record"
recordBtn.Size = UDim2.new(0.5,-5,0,30)
recordBtn.Position = UDim2.new(0,5,0,40)
recordBtn.Parent = Frame

local playBtn = Instance.new("TextButton")
playBtn.Text = "Play"
playBtn.Size = UDim2.new(0.5,-5,0,30)
playBtn.Position = UDim2.new(0.5,5,0,40)
playBtn.Parent = Frame

local saveBtn = Instance.new("TextButton")
saveBtn.Text = "Save"
saveBtn.Size = UDim2.new(0.5,-5,0,30)
saveBtn.Position = UDim2.new(0,5,0,80)
saveBtn.Parent = Frame

local loadBtn = Instance.new("TextButton")
loadBtn.Text = "Load"
loadBtn.Size = UDim2.new(0.5,-5,0,30)
loadBtn.Position = UDim2.new(0.5,5,0,80)
loadBtn.Parent = Frame

local speedBox = Instance.new("TextBox")
speedBox.Text = "1.0"
speedBox.PlaceholderText = "Speed"
speedBox.Size = UDim2.new(0.5,-5,0,30)
speedBox.Position = UDim2.new(0,5,0,120)
speedBox.Parent = Frame

local clearBtn = Instance.new("TextButton")
clearBtn.Text = "Clear"
clearBtn.Size = UDim2.new(0.5,-5,0,30)
clearBtn.Position = UDim2.new(0.5,5,0,120)
clearBtn.Parent = Frame

-- Minimize
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "-"
minimizeBtn.Size = UDim2.new(0,30,0,30)
minimizeBtn.Position = UDim2.new(1,-35,0,0)
minimizeBtn.Parent = Frame

-- State
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in ipairs(Frame:GetChildren()) do
        if child ~= Title and child ~= minimizeBtn then
            child.Visible = not minimized
        end
    end
    Frame.Size = minimized and UDim2.new(0,260,0,30) or UDim2.new(0,260,0,170)
end)

-- Record
local function startRecord()
    recordedPath = {}
    recording = true
    recordBtn.Text = "Stop Record"
end

local function stopRecord()
    recording = false
    recordBtn.Text = "Start Record"
    print("Saved "..#recordedPath.." points")
end

-- Playback
local function playPath()
    if #recordedPath == 0 then return end
    playback = true
    for _, pos in ipairs(recordedPath) do
        if not playback then break end
        humanoid:MoveTo(pos)
        humanoid.MoveToFinished:Wait()
    end
    playback = false
end

-- Save/Load (versi dalam game → pakai Instance Value)
local function savePath()
    local storage = Instance.new("Folder")
    storage.Name = "SavedPath"
    storage.Parent = game.ReplicatedStorage

    for i,pos in ipairs(recordedPath) do
        local val = Instance.new("Vector3Value")
        val.Name = "Point"..i
        val.Value = pos
        val.Parent = storage
    end
    print("Path saved to ReplicatedStorage")
end

local function loadPath()
    local storage = game.ReplicatedStorage:FindFirstChild("SavedPath")
    if storage then
        recordedPath = {}
        for _,v in ipairs(storage:GetChildren()) do
            table.insert(recordedPath, v.Value)
        end
        print("Loaded "..#recordedPath.." points")
    end
end

-- Tombol handler
recordBtn.MouseButton1Click:Connect(function()
    if not recording then startRecord() else stopRecord() end
end)

playBtn.MouseButton1Click:Connect(function()
    if not playback then
        speedMultiplier = tonumber(speedBox.Text) or 1.0
        humanoid.WalkSpeed = 16 * speedMultiplier
        playPath()
        humanoid.WalkSpeed = 16
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    recordedPath = {}
    print("Cleared path")
end)

saveBtn.MouseButton1Click:Connect(savePath)
loadBtn.MouseButton1Click:Connect(loadPath)

-- Rekam posisi tiap detik
task.spawn(function()
    while true do
        task.wait(1)
        if recording and root then
            table.insert(recordedPath, root.Position)
        end
    end
end)

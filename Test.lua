-- Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Update kalau respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    root = char:WaitForChild("HumanoidRootPart")
end)

-- Data
local recording = false
local recordedPath = {}
local speedMultiplier = 1.0

-- Fungsi playback
local function playPath(path)
    if not humanoid or #path == 0 then return end
    humanoid.WalkSpeed = 16 * speedMultiplier
    for _,pos in ipairs(path) do
        humanoid:MoveTo(pos)
        humanoid.MoveToFinished:Wait()
    end
    humanoid.WalkSpeed = 16
end

-- UI
local Window = Rayfield:CreateWindow({Name="Auto Walk Test"})
local MainTab = Window:CreateTab("Main")

MainTab:CreateButton({
    Name="Start / Stop Record",
    Callback=function()
        recording = not recording
        if recording then
            recordedPath = {}
            Rayfield:Notify({Title="Recording", Content="Mulai merekam...", Duration=3})
        else
            Rayfield:Notify({Title="Stopped", Content="Rekaman selesai ("..#recordedPath.." titik)", Duration=3})
        end
    end
})

MainTab:CreateButton({
    Name="Play Record",
    Callback=function() playPath(recordedPath) end
})

MainTab:CreateSlider({
    Name="Speed",
    Range={0.5,3},
    Increment=0.1,
    Suffix="x",
    CurrentValue=1,
    Callback=function(v) speedMultiplier=v end
})

-- Loop record posisi
task.spawn(function()
    while true do
        task.wait(0.5)
        if recording and root then
            table.insert(recordedPath, root.Position)
        end
    end
end)

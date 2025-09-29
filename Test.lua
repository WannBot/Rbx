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

    -- Rebind listener jump setiap respawn
    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping then
            if recording and root then
                table.insert(recordedPath, {pos=root.Position, jump=true})
            end
        end
    end)
end)

-- Data
local recording = false
local recordedPath = {}
local speedMultiplier = 1.0

-- Playback
local function playPath(path)
    if not humanoid or #path == 0 then return end
    humanoid.WalkSpeed = 16 * speedMultiplier
    for _,step in ipairs(path) do
        if step.jump then
            humanoid.Jump = true
        end
        humanoid:MoveTo(step.pos)
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
            Rayfield:Notify({Title="Stopped", Content="Rekaman selesai ("..#recordedPath.." step)", Duration=3})
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

-- Loop record posisi normal (jalan)
task.spawn(function()
    while true do
        task.wait(0.5)
        if recording and root then
            table.insert(recordedPath, {pos=root.Position, jump=false})
        end
    end
end)

-- Listener jump untuk pertama kali load karakter
humanoid.StateChanged:Connect(function(_, newState)
    if newState == Enum.HumanoidStateType.Jumping then
        if recording and root then
            table.insert(recordedPath, {pos=root.Position, jump=true})
        end
    end
end)

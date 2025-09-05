local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Auto Walk Natural",
    LoadingTitle = "Auto Walker",
    LoadingSubtitle = "Rayfield UI",
    KeySystem = false,
})
local Tab = Window:CreateTab("Auto Walk", 4483362458)

-- Variabel
local autoWalk = false
local delayTime = 1
local currentIndex = 1

-- 10 koordinat
local checkpoints = {
    Vector3.new(-862, 125, 661),
    Vector3.new(-533, 231, 261),
    Vector3.new(-636, 315, 16),
    Vector3.new(-752, 412, 65),
    Vector3.new(-567, 417, 124),
    Vector3.new(-657, 488, 383),
    Vector3.new(-369, 703, 596),
    Vector3.new(-588, 679, 399),
    Vector3.new(-288, 873, 83),
    Vector3.new(-855, 124, 902),
}

-- UI Toggle
Tab:CreateToggle({
    Name = "Auto Walk ke 10 Titik",
    CurrentValue = false,
    Callback = function(Value)
        autoWalk = Value
        print("Auto Walk:", autoWalk)
    end,
})

-- Slider Delay antar checkpoint
Tab:CreateSlider({
    Name = "Delay antar Checkpoint",
    Range = {1, 30},
    Increment = 1,
    Suffix = "detik",
    CurrentValue = 1,
    Callback = function(Value)
        delayTime = Value
    end,
})

-- Fungsi jalan natural
local function walkTo(targetPos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    -- jalan sampai dekat target
    while autoWalk and (hrp.Position - targetPos).Magnitude > 5 do
        local direction = (targetPos - hrp.Position).Unit
        humanoid:Move(Vector3.new(direction.X, 0, direction.Z), false)
        RunService.Heartbeat:Wait()
    end

    -- berhenti setelah sampai
    humanoid:Move(Vector3.new(0, 0, 0), false)
end

-- Loop jalan berurutan
task.spawn(function()
    while task.wait() do
        if autoWalk then
            walkTo(checkpoints[currentIndex])
            print("Sampai di titik", currentIndex)

            task.wait(delayTime)

            currentIndex += 1
            if currentIndex > #checkpoints then
                currentIndex = 1
            end
        end
    end
end)

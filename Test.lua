local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Load Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Auto Walk System",
    LoadingTitle = "Path Bot",
    LoadingSubtitle = "Rayfield UI",
    KeySystem = false,
})

local Tab = Window:CreateTab("Auto Walk", 4483362458)

-- Variabel
local autoWalk = false
local delayTime = 1

-- UI Toggle
Tab:CreateToggle({
    Name = "Auto Walk",
    CurrentValue = false,
    Callback = function(Value)
        autoWalk = Value
        print("Auto Walk:", autoWalk)
    end,
})

-- UI Slider untuk Delay
Tab:CreateSlider({
    Name = "Delay antar Node",
    Range = {0, 10},
    Increment = 1,
    Suffix = "detik",
    CurrentValue = 1,
    Callback = function(Value)
        delayTime = Value
    end,
})

-- Ambil karakter & humanoid
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    return humanoid, root
end

-- Daftar node jalur
local route = {
    workspace.Icebergs.Basecamp["10"].Union,
    workspace.ObstaclesLocal["20"].Side_Rails,
    workspace.ObstaclesLocal["30"].Ladder.Side_Rails,
    workspace.ObstaclesLocal["30"].Ladder.Ice.Icicle_Big,
    workspace.ObstaclesLocal["40"].Side_Rails,
    workspace.Ladder.Side_Rails,
    workspace.ObstaclesLocal["50"].Iceberg1,
}

-- Fungsi jalan
local function walkTo(part)
    local humanoid, root = getChar()
    humanoid:MoveTo(part.Position)

    while autoWalk and (root.Position - part.Position).Magnitude > 6 do
        task.wait(0.1)

        -- Auto Jump jika perlu
        if math.abs(root.Position.Y - part.Position.Y) > 5 then
            humanoid.Jump = true
        elseif tostring(part.Name):lower():find("ladder")
            or tostring(part.Name):lower():find("rail")
            or tostring(part.Name):lower():find("ice") then
            humanoid.Jump = true
        end
    end
end

-- Loop utama
task.spawn(function()
    while task.wait() do
        if autoWalk then
            for i, node in ipairs(route) do
                if not autoWalk then break end
                print("Menuju:", node:GetFullName())
                walkTo(node)
                task.wait(delayTime)
            end
        end
    end
end)

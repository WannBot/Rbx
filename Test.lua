local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === Rayfield UI ===
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

Tab:CreateToggle({
    Name = "Auto Walk",
    CurrentValue = false,
    Callback = function(Value)
        autoWalk = Value
    end,
})

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
    return humanoid
end

-- Daftar node (HARUS BasePart)
local route = {
    workspace.Icebergs.Basecamp["10"].Union,
    workspace.ObstaclesLocal["20"].Side_Rails,
    workspace.ObstaclesLocal["30"].Ladder.Side_Rails,
    workspace.ObstaclesLocal["30"].Ladder.Ice.Icicle_Big,
    workspace.ObstaclesLocal["40"].Side_Rails,
    workspace.Ladder.Side_Rails,
    workspace.ObstaclesLocal["50"].Iceberg1,
}

-- Fungsi jalan ke node
local function walkTo(part)
    local humanoid = getChar()
    if not part or not part:IsA("BasePart") then
        warn("Node bukan BasePart:", part and part.Name or "nil")
        return
    end

    humanoid:MoveTo(part.Position)
    humanoid.MoveToFinished:Wait()

    -- Auto jump kalau object berpotensi rintangan
    local lowerName = part.Name:lower()
    if lowerName:find("ladder") or lowerName:find("rail") or lowerName:find("ice") then
        humanoid.Jump = true
    end
end

-- Loop jalan
task.spawn(function()
    while task.wait() do
        if autoWalk then
            for i, node in ipairs(route) do
                if not autoWalk then break end
                print("Menuju ke:", node:GetFullName())
                walkTo(node)
                task.wait(delayTime)
            end
        end
    end
end)

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

-- === Load Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Auto Walk Checkpoints",
    LoadingTitle = "Auto Walker",
    LoadingSubtitle = "Rayfield UI",
    KeySystem = false,
})

local Tab = Window:CreateTab("Auto Walk", 4483362458)

-- === Variabel ===
local autoWalk = false
local delayTime = 3

-- Daftar koordinat checkpoints
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

-- === UI Controls ===
Tab:CreateToggle({
    Name = "Auto Walk",
    CurrentValue = false,
    Callback = function(Value)
        autoWalk = Value
        print("Auto Walk:", autoWalk)
    end,
})

Tab:CreateSlider({
    Name = "Delay antar Checkpoint",
    Range = {1, 30},
    Increment = 1,
    Suffix = "detik",
    CurrentValue = 3,
    Callback = function(Value)
        delayTime = Value
    end,
})

-- === Fungsi jalan dengan Pathfinding ===
local function walkTo(targetPos)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45,
    })

    path:ComputeAsync(root.Position, targetPos)

    if path.Status == Enum.PathStatus.Complete then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not autoWalk then return end -- stop kalau toggle off
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
        end
    else
        warn("Path gagal, teleport fallback:", targetPos)
        root.CFrame = CFrame.new(targetPos)
    end
end

-- === Loop jalan ke semua checkpoint ===
task.spawn(function()
    while task.wait() do
        if autoWalk then
            for i, pos in ipairs(checkpoints) do
                if not autoWalk then break end
                print("Menuju checkpoint", i)
                walkTo(pos)
                task.wait(delayTime)
            end
        end
    end
end)

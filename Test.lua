-- Script ini bisa ditaruh di StarterPlayerScripts (untuk Player)
-- atau di NPC model (untuk Bot test)

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

-- target checkpoint (contoh koordinat Vector3)
local checkpoint = Vector3.new(-862, 125, 661)

-- fungsi untuk membuat path dan jalan
local function walkTo(targetPos)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")

    -- buat path
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
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()

            -- kalau waypoint butuh lompat
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
        end
        print("Sampai di checkpoint")
    else
        warn("Path gagal dihitung!")
    end
end

-- panggil fungsi
walkTo(checkpoint)

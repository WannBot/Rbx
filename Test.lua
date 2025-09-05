-- Auto walk sederhana ke satu target (gunakan executor)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- titik tujuan (ubah ke koordinat checkpointmu)
local target = Vector3.new(-862, 125, 661)

local function autoWalk(targetPos)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    -- jalan terus ke arah target
    RunService.Heartbeat:Connect(function()
        if (hrp.Position - targetPos).Magnitude > 5 then
            local dir = (targetPos - hrp.Position).Unit
            humanoid:Move(Vector3.new(dir.X, 0, dir.Z), false)
        else
            humanoid:Move(Vector3.new(0,0,0), false)
            print("Sampai di target")
        end
    end)
end

autoWalk(target)

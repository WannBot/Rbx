local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- daftar target koordinat
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

local delayTime = 3 -- jeda antar titik (detik)

-- fungsi auto jalan
local function walkTo(targetPos)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    humanoid:MoveTo(targetPos)
    humanoid.MoveToFinished:Wait()
end

-- loop jalan ke semua titik
while true do
    for i, pos in ipairs(checkpoints) do
        walkTo(pos)
        print("Sampai di titik", i)
        task.wait(delayTime)
    end
end

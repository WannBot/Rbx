local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ambil humanoid
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- daftar route dari path yang kamu kasih
local route = {
    workspace.Icebergs.Basecamp["10"].Union,
    workspace.ObstaclesLocal["20"].Side_Rails,
    workspace.ObstaclesLocal["30"].Ladder.Side_Rails,
    workspace.ObstaclesLocal["30"].Ladder.Ice.Icicle_Big,
    workspace.ObstaclesLocal["40"].Side_Rails,
    workspace.Ladder.Side_Rails,
    workspace.ObstaclesLocal["50"].Iceberg1,
}

local delayTime = 1 -- jeda antar node

-- fungsi jalan ke satu node
local function walkTo(part)
    local humanoid = getHumanoid()
    if not part or not part:IsA("BasePart") then
        warn("Node bukan BasePart:", part and part.Name or "nil")
        return
    end

    humanoid:MoveTo(part.Position)
    humanoid.MoveToFinished:Wait()

    -- auto jump kalau nama object menunjukkan rintangan
    local lowerName = part.Name:lower()
    if lowerName:find("ladder") or lowerName:find("rail") or lowerName:find("ice") then
        humanoid.Jump = true
    end
end

-- loop jalur
while true do
    for i, node in ipairs(route) do
        walkTo(node)
        print("Sampai di:", node:GetFullName())
        task.wait(delayTime)
    end
end

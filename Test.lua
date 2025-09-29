local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Real Recorder",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record & Replay Real",
    KeySystem = false,
})
local Tab = Window:CreateTab("Path Tool", 4483362458)

-- === State ===
local hrp, hum
local recording = false
local playing = false
local pathData = {}
local recordConn, jumpConn
local startTime

-- === Helper ===
local function bindChar()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- === Record Path ===
local function startRecord()
    if recording then return end
    recording = true
    pathData = {}
    startTime = tick()
    print("[RealRecord] Start recording...")

    recordConn = RunService.Heartbeat:Connect(function()
        if recording and hrp then
            table.insert(pathData, {
                t = tick() - startTime,
                pos = {hrp.Position.X, hrp.Position.Y, hrp.Position.Z},
                vel = hum.MoveDirection.Magnitude, -- cek jalan / diam
                type = "move"
            })
        end
    end)

    jumpConn = hum.StateChanged:Connect(function(_, new)
        if recording and new == Enum.HumanoidStateType.Jumping then
            table.insert(pathData, {
                t = tick() - startTime,
                pos = {hrp.Position.X, hrp.Position.Y, hrp.Position.Z},
                vel = 0,
                type = "jump"
            })
        end
    end)
end

local function stopRecord()
    if not recording then return end
    recording = false
    if recordConn then recordConn:Disconnect() recordConn = nil end
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    print("[RealRecord] Stop. Frames:", #pathData)
end

-- === Play Path (Replay real gerakan) ===
local function playPath()
    if #pathData == 0 then
        warn("[RealRecord] Tidak ada data record!")
        return
    end
    if playing then return end
    playing = true
    print("[RealRecord] Playing... steps:", #pathData)

    task.spawn(function()
        local playStart = tick()
        local i = 1
        while playing and i <= #pathData do
            local step = pathData[i]
            local elapsed = tick() - playStart

            if elapsed >= step.t then
                if step.type == "move" then
                    -- gerakkan dengan MoveTo (biar natural)
                    local target = Vector3.new(step.pos[1], step.pos[2], step.pos[3])
                    hum:MoveTo(target)
                elseif step.type == "jump" then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                i = i + 1
            else
                task.wait(0.01)
            end
        end
        playing = false
        print("[RealRecord] Done.")
    end)
end

local function stopPlay()
    playing = false
    hum:Move(Vector3.new(0,0,0))
    print("[RealRecord] Play stopped.")
end

-- === UI ===
Tab:CreateButton({
    Name = "Start Record",
    Callback = startRecord
})

Tab:CreateButton({
    Name = "Stop Record",
    Callback = stopRecord
})

Tab:CreateButton({
    Name = "Play Last Record",
    Callback = playPath
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

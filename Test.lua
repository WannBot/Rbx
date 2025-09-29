local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Path Recorder & Player",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record & Replay (Natural Walk)",
    KeySystem = false,
})
local Tab = Window:CreateTab("Path Tool", 4483362458)

-- === State ===
local hrp, hum
local recording = false
local playing = false
local pathData = {}
local jumpConn, recordConn

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
    print("[PathTool] Recording started...")

    recordConn = RunService.Heartbeat:Connect(function()
        if recording and hrp then
            table.insert(pathData, {
                t = tick(),
                pos = {hrp.Position.X, hrp.Position.Y, hrp.Position.Z},
                type = "move"
            })
        end
    end)

    jumpConn = hum.StateChanged:Connect(function(_, new)
        if recording and new == Enum.HumanoidStateType.Jumping then
            table.insert(pathData, {
                t = tick(),
                pos = {hrp.Position.X, hrp.Position.Y, hrp.Position.Z},
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

    print("[PathTool] Recording stopped. Steps:", #pathData)
end

-- === Play Path (jalan asli) ===
local function playPath()
    if #pathData == 0 then
        warn("[PathTool] Belum ada data record. Rekam dulu sebelum play!")
        return
    end
    if playing then return end
    playing = true
    print("[PathTool] Playing recorded path (jalan asli)... Steps:", #pathData)

    task.spawn(function()
        for _, step in ipairs(pathData) do
            if not playing then break end
            if hrp and hum then
                if step.type == "move" then
                    local target = Vector3.new(step.pos[1], step.pos[2], step.pos[3])
                    hum:MoveTo(target)
                    hum.MoveToFinished:Wait() -- tunggu sampai nyampe
                elseif step.type == "jump" then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
        playing = false
        print("[PathTool] Done playing path.")
    end)
end

local function stopPlay()
    playing = false
    hum:Move(Vector3.new(0,0,0)) -- stop gerak
    print("[PathTool] Play stopped.")
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
    Name = "Play Last Record (Jalan Asli)",
    Callback = playPath
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

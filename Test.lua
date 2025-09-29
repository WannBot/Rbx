local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Smooth Path Recorder",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record & Replay Natural Run",
    KeySystem = false,
})
local Tab = Window:CreateTab("Path Tool", 4483362458)

-- === State ===
local hrp, hum
local recording = false
local playing = false
local pathData = {}
local recordConn, jumpConn
local lastTick = 0
local lastPos = nil
local minDist = 5 -- simpan titik tiap >= 5 studs

-- === Helper ===
local function bindChar()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- === Record (optimized, no spam) ===
local function startRecord()
    if recording then return end
    recording = true
    pathData = {}
    lastTick = tick()
    lastPos = hrp and hrp.Position or nil
    print("[PathTool] Recording started...")

    recordConn = RunService.Heartbeat:Connect(function()
        if recording and hrp then
            local now = tick()
            local delta = now - lastTick
            local pos = hrp.Position
            if not lastPos or (pos - lastPos).Magnitude >= minDist then
                lastTick = now
                lastPos = pos
                table.insert(pathData, {
                    delay = delta,
                    pos = {pos.X, pos.Y, pos.Z},
                    type = "move"
                })
            end
        end
    end)

    jumpConn = hum.StateChanged:Connect(function(_, new)
        if recording and new == Enum.HumanoidStateType.Jumping then
            local now = tick()
            local delta = now - lastTick
            lastTick = now
            table.insert(pathData, {
                delay = delta,
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

-- === Play Path (smooth natural run) ===
local function playPath()
    if #pathData == 0 then
        warn("[PathTool] Belum ada data record!")
        return
    end
    if playing then return end
    playing = true
    print("[PathTool] Playing path (smooth)... Steps:", #pathData)

    task.spawn(function()
        for _, step in ipairs(pathData) do
            if not playing then break end
            task.wait(step.delay) -- ikut jeda rekaman
            if hrp and hum then
                if step.type == "move" then
                    hum:MoveTo(Vector3.new(step.pos[1], step.pos[2], step.pos[3]))
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
    if hum then hum:Move(Vector3.new(0,0,0)) end
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
    Name = "Play Last Record (Smooth Run)",
    Callback = playPath
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

Tab:CreateSlider({
    Name = "Min Distance Save",
    Range = {1, 15},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 5,
    Callback = function(v)
        minDist = v
        print("[PathTool] minDist diubah ke", v)
    end
})

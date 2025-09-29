local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Real Path Recorder",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record & Replay (Speed Control)",
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
local playSpeed = 1 -- default 1x speed

-- === Helper ===
local function bindChar()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- === Record (pakai timing asli) ===
local function startRecord()
    if recording then return end
    recording = true
    pathData = {}
    lastTick = tick()
    print("[PathTool] Recording started (real timing)...")

    recordConn = RunService.Heartbeat:Connect(function()
        if recording and hrp then
            local now = tick()
            local delta = now - lastTick
            lastTick = now

            table.insert(pathData, {
                delay = delta,
                pos = {hrp.Position.X, hrp.Position.Y, hrp.Position.Z},
                type = "move"
            })
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

-- === Play Path (pakai timing asli + speed slider) ===
local function playPath()
    if #pathData == 0 then
        warn("[PathTool] Belum ada data record!")
        return
    end
    if playing then return end
    playing = true
    print("[PathTool] Playing path... Steps:", #pathData, " Speed:", playSpeed, "x")

    task.spawn(function()
        for i, step in ipairs(pathData) do
            if not playing then break end
            task.wait(step.delay / playSpeed) -- kontrol kecepatan
            if hrp and hum then
                if step.type == "move" then
                    -- arahkan avatar ke posisi step berikut
                    local target = Vector3.new(step.pos[1], step.pos[2], step.pos[3])
                    local dir = (target - hrp.Position).Unit
                    hum:Move(dir)
                elseif step.type == "jump" then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
        playing = false
        hum:Move(Vector3.zero) -- berhenti setelah selesai
        print("[PathTool] Done playing.")
    end)
end

local function stopPlay()
    playing = false
    if hum then hum:Move(Vector3.zero) end
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
    Name = "Play Last Record (Real Timing)",
    Callback = playPath
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

Tab:CreateSlider({
    Name = "Playback Speed",
    Range = {0.5, 3}, -- bisa set 0.5x sampai 3x
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Callback = function(v)
        playSpeed = v
        print("[PathTool] Playback speed diubah ke", v, "x")
    end
})

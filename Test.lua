local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Path Recorder",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record Run + Jump",
    KeySystem = false,
})
local Tab = Window:CreateTab("Recorder", 4483362458)

-- === State ===
local hrp, hum
local recording = false
local pathData = {}
local jumpConn

-- Helper: bind character
local function bindChar()
    local char = player.Character or player.CharacterAdded:Wait()
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

-- Start recording
local function startRecord()
    if recording then return end
    recording = true
    pathData = {}
    print("[Recorder] Start recording...")

    -- record posisi tiap frame
    RunService.Heartbeat:Connect(function()
        if recording and hrp then
            table.insert(pathData, {
                t = tick(),
                pos = {hrp.Position.X, hrp.Position.Y, hrp.Position.Z},
                type = "move"
            })
        end
    end)

    -- record event jump
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

-- Stop recording
local function stopRecord()
    if not recording then return end
    recording = false
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    print("[Recorder] Recording stopped. Steps:", #pathData)
end

-- Save to file
local function saveRecord()
    if #pathData == 0 then
        warn("[Recorder] No data to save")
        return
    end
    local json = HttpService:JSONEncode(pathData)
    local filename = "PathRecord_"..os.time()..".json"

    if writefile then
        writefile(filename, json)
        print("[Recorder] Saved to", filename)
    else
        warn("[Recorder] Executor tidak mendukung writefile()")
    end
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
    Name = "Save to File",
    Callback = saveRecord
})

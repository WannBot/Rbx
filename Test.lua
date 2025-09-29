local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Path Recorder & Player",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record & Replay",
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

local function saveRecord()
    if #pathData == 0 then
        warn("[PathTool] Tidak ada data untuk disimpan")
        return
    end
    local json = HttpService:JSONEncode(pathData)
    local filename = "PathRecord_"..os.time()..".json"

    if writefile then
        writefile(filename, json)
        print("[PathTool] Saved to", filename)
    else
        warn("[PathTool] Executor tidak mendukung writefile()")
    end
end

-- === Play Path (langsung data terakhir) ===
local function playPath()
    if #pathData == 0 then
        warn("[PathTool] Belum ada data record. Rekam dulu sebelum play!")
        return
    end
    if playing then return end
    playing = true
    print("[PathTool] Playing recorded path... Steps:", #pathData)

    task.spawn(function()
        for _, step in ipairs(pathData) do
            if not playing then break end
            if hrp and hum then
                if step.type == "move" then
                    hrp.CFrame = CFrame.new(Vector3.new(step.pos[1], step.pos[2], step.pos[3]))
                elseif step.type == "jump" then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            task.wait(0.1)
        end
        playing = false
        print("[PathTool] Done playing path.")
    end)
end

local function stopPlay()
    playing = false
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
    Name = "Save to File",
    Callback = saveRecord
})

Tab:CreateButton({
    Name = "Play Last Record",
    Callback = playPath
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Path Recorder & Player",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record + Smooth Play",
    KeySystem = false,
})
local Tab = Window:CreateTab("Path Tool", 4483362458)

-- === State ===
local hrp, hum
local recording = false
local playing = false
local pathData = {}
local jumpConn, recordConn
local minDist = 5 -- default jarak antar titik

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

-- === Path Simplifier ===
local function simplifyPath(data, minDist)
    local simple = {}
    local lastPos = nil
    for _, step in ipairs(data) do
        if step.type == "move" then
            local pos = Vector3.new(step.pos[1], step.pos[2], step.pos[3])
            if not lastPos or (pos - lastPos).Magnitude > minDist then
                table.insert(simple, step)
                lastPos = pos
            end
        else
            table.insert(simple, step) -- simpan jump
        end
    end
    return simple
end

-- === Play Path (jalan asli) ===
local function playPath()
    if #pathData == 0 then
        warn("[PathTool] Belum ada data record. Rekam dulu sebelum play!")
        return
    end
    if playing then return end
    playing = true
    print("[PathTool] Playing path... (steps:", #pathData, ")")

    local data = simplifyPath(pathData, minDist)

    task.spawn(function()
        for _, step in ipairs(data) do
            if not playing then break end
            if hrp and hum then
                if step.type == "move" then
                    local target = Vector3.new(step.pos[1], step.pos[2], step.pos[3])
                    hum:MoveTo(target)
                    repeat
                        task.wait(0.05)
                    until not playing or (hrp.Position - target).Magnitude < 2
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
    Name = "Save to File",
    Callback = saveRecord
})

Tab:CreateButton({
    Name = "Play Last Record (Smooth Walk)",
    Callback = playPath
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

Tab:CreateSlider({
    Name = "Min Distance (Smoothness)",
    Range = {1, 15},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 5,
    Callback = function(v)
        minDist = v
        print("[PathTool] minDist diubah ke", v)
    end
})

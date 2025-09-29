local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Path Recorder & Player",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record & Replay Run + Jump",
    KeySystem = false,
})
local Tab = Window:CreateTab("Path Tool", 4483362458)

-- === State ===
local hrp, hum
local recording = false
local playing = false
local pathData = {}
local jumpConn

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
    print("[PathTool] Start recording...")

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

    -- record jump
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

-- === Play Path ===
local function loadPath(filename)
    if not readfile then
        warn("[PathTool] Executor tidak mendukung readfile()")
        return nil
    end
    if not isfile(filename) then
        warn("[PathTool] File tidak ditemukan:", filename)
        return nil
    end
    local content = readfile(filename)
    local data = HttpService:JSONDecode(content)
    return data
end

local function playPath(filename)
    local data = loadPath(filename)
    if not data then return end
    if playing then return end
    playing = true
    print("[PathTool] Playing path:", filename, "steps:", #data)

    task.spawn(function()
        for _, step in ipairs(data) do
            if not playing then break end
            if hrp and hum then
                if step.type == "move" then
                    hrp.CFrame = CFrame.new(Vector3.new(step.pos[1], step.pos[2], step.pos[3]))
                elseif step.type == "jump" then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
            task.wait(0.1) -- delay antar step
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

Tab:CreateInput({
    Name = "Play Path (Masukkan nama file)",
    PlaceholderText = "contoh: PathRecord_123456.json",
    RemoveTextAfterFocusLost = false,
    Callback = function(filename)
        playPath(filename)
    end
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

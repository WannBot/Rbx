local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Path Recorder & Player",
    LoadingTitle = "Init",
    LoadingSubtitle = "Record & Replay Smooth",
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

-- === Play Path (Smooth / lerp) ===
local function playPath()
    if #pathData == 0 then
        warn("[PathTool] Belum ada data record. Rekam dulu sebelum play!")
        return
    end
    if playing then return end
    playing = true
    print("[PathTool] Playing recorded path (smooth)... Steps:", #pathData)

    task.spawn(function()
        for i, step in ipairs(pathData) do
            if not playing then break end
            if hrp and hum then
                if step.type == "move" then
                    local targetPos = Vector3.new(step.pos[1], step.pos[2], step.pos[3])
                    local distance = (hrp.Position - targetPos).Magnitude
                    local speed = hum.WalkSpeed > 0 and hum.WalkSpeed or 16
                    local travelTime = distance / speed

                    local tween = TweenService:Create(
                        hrp,
                        TweenInfo.new(travelTime, Enum.EasingStyle.Linear),
                        {CFrame = CFrame.new(targetPos)}
                    )
                    tween:Play()
                    tween.Completed:Wait()
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
    Name = "Play Last Record (Smooth)",
    Callback = playPath
})

Tab:CreateButton({
    Name = "Stop Play",
    Callback = stopPlay
})

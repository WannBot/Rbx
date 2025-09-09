local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Main Features",
    LoadingTitle = "Forcefield Strong",
    LoadingSubtitle = "Anti Damage • Anti Fall • Command",
    KeySystem = false,
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local CommandTab = Window:CreateTab("Command", 4483362458)

-- Variabel
local ffOn = false
local hbConn
local currentFF

-- ==== Forcefield Protect ====
local function protect(char)
    local hum = char:WaitForChild("Humanoid")

    -- bikin ForceField invisible
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = char
    currentFF = ff

    -- per frame: kunci health + cegah jatuh
    if hbConn then hbConn:Disconnect() end
    hbConn = RunService.Heartbeat:Connect(function()
        if ffOn and hum and hum.Parent then
            hum.Health = hum.MaxHealth
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end)
end

local function unprotect()
    if hbConn then hbConn:Disconnect() end
    hbConn = nil
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    currentFF = nil
end

-- === UI Toggle di Tab Player ===
PlayerTab:CreateToggle({
    Name = "Strong Forcefield (No Damage)",
    CurrentValue = false,
    Callback = function(v)
        ffOn = v
        local char = player.Character
        if char then
            if ffOn then protect(char) else unprotect() end
        end
    end,
})

-- Respawn handler
player.CharacterAdded:Connect(function(char)
    if ffOn then protect(char) end
end)

-- ==== Command System ====
local function getCharHum()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hum, hrp
end

local function findPlayerByNameFragment(fragment)
    fragment = tostring(fragment):lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        local uname = plr.Name:lower()
        if uname:sub(1, #fragment) == fragment or uname:find(fragment, 1, true) then
            return plr
        end
    end
    return nil
end

local function gotoPlayer(user)
    local target = findPlayerByNameFragment(user)
    if not target or not target.Character then
        warn("[GOTO] Player tidak ditemukan: " .. user)
        return
    end
    local _, _, myHrp = getCharHum()
    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
    if tHrp then
        myHrp.CFrame = tHrp.CFrame + Vector3.new(0,3,0)
        print("[GOTO] Teleport ke " .. target.Name)
    end
end

-- === Command Input UI ===
CommandTab:CreateInput({
    Name = "Command Box",
    PlaceholderText = "Contoh: .goto username",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if text:sub(1,1) ~= "." then
            warn("Command harus diawali dengan '.'")
            return
        end

        local args = {}
        for token in text:gmatch("%S+") do table.insert(args, token) end
        local cmd = (args[1] or ""):sub(2):lower()

        if cmd == "goto" and args[2] then
            gotoPlayer(args[2])
        elseif cmd == "ff" then
            ffOn = not ffOn
            local char = player.Character
            if char then
                if ffOn then protect(char) else unprotect() end
            end
            print("[FF] " .. (ffOn and "ON" or "OFF"))
        elseif cmd == "help" then
            print("Commands: .goto <username> | .ff (toggle) | .help")
        else
            warn("Command tidak dikenal: " .. cmd)
        end
    end,
})

-- Sumber awal: Strong Forcefield (invisible) + anti-fall/terrain
-- Ditambah: Command system prefix "." dan perintah .goto <username>

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- === UI (opsional, tetap dari script kamu; bisa dipertahankan jika perlu) ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Main Features",
    LoadingTitle = "Forcefield Strong",
    LoadingSubtitle = "Anti Damage • Anti Fall",
    KeySystem = false,
})
local Tab = Window:CreateTab("Player", 4483362458)

-- === State ===
local ffOn = false
local hbConn -- Heartbeat connection untuk Health-lock
local currentFF

-- === Utils ===
local function sysMsg(text, color)
    -- kirim pesan ke chat lokal biar jelas status command
    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = tostring(text),
            Color = color or Color3.fromRGB(0,255,0),
            Font = Enum.Font.SourceSansBold,
            TextSize = 18
        })
    end)
    print(text)
end

local function getCharHum()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hum, hrp
end

-- === Proteksi: ForceField (invisible) + Health lock + block Dead/FallingDown ===
local function protect(char)
    local hum = char:WaitForChild("Humanoid")

    -- ForceField tak terlihat
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = char
    currentFF = ff

    -- Lock health & cegah state jatuh/mati
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

-- === UI toggle FF ===
Tab:CreateToggle({
    Name = "Strong Forcefield (No Damage)",
    CurrentValue = false,
    Callback = function(v)
        ffOn = v
        local char = player.Character
        if char then
            if ffOn then
                protect(char)
                sysMsg("[FF] ON (invisible, anti-damage besar)")
            else
                unprotect()
                sysMsg("[FF] OFF", Color3.fromRGB(255,200,0))
            end
        end
    end,
})

-- Respawn handler: tetap aktif sesuai status terakhir
player.CharacterAdded:Connect(function(char)
    if ffOn then protect(char) end
end)

-- =========================================================
-- =============== COMMAND SYSTEM (prefix ".") ==============
-- =========================================================
local PREFIX = "."

-- cari pemain by username (partial, case-insensitive)
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

-- teleport ke player target (spawn di atas/di belakang sedikit agar tidak stuck)
local function gotoPlayer(targetName)
    local target = findPlayerByNameFragment(targetName)
    if not target or not target.Character then
        sysMsg(("[GOTO] Player '%s' tidak ditemukan / belum spawn."):format(targetName), Color3.fromRGB(255,80,80))
        return
    end

    local _, _, myHrp = getCharHum()
    local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not tHrp then
        sysMsg("[GOTO] Target tidak punya HumanoidRootPart.", Color3.fromRGB(255,80,80))
        return
    end

    -- offset sedikit agar tidak clip
    local offset = (tHrp.CFrame.LookVector * -2) + Vector3.new(0, 3, 0)
    myHrp.CFrame = tHrp.CFrame + offset

    sysMsg(("[GOTO] Teleport ke %s"):format(target.Name))
end

-- handler chat lokal
local function onChatted(msg)
    if type(msg) ~= "string" then return end
    if msg:sub(1,1) ~= PREFIX then return end

    -- parse
    local args = {}
    for token in msg:gmatch("%S+") do
        table.insert(args, token)
    end
    local cmd = (args[1] or ""):sub(2):lower()

    if cmd == "goto" then
        local user = args[2]
        if not user then
            sysMsg("Usage: .goto <username>", Color3.fromRGB(255,200,0))
            return
        end
        gotoPlayer(user)

    elseif cmd == "ff" then
        -- .ff on / .ff off / .ff (toggle)
        local opt = (args[2] or ""):lower()
        if opt == "on" then
            ffOn = true
        elseif opt == "off" then
            ffOn = false
        else
            ffOn = not ffOn
        end
        local char = player.Character
        if char then
            if ffOn then protect(char) else unprotect() end
        end
        sysMsg("[FF] " .. (ffOn and "ON" or "OFF"))

    elseif cmd == "help" then
        sysMsg("Commands: .goto <username> | .ff [on/off] | .help", Color3.fromRGB(200,200,255))

    else
        sysMsg(("Command tidak dikenal: %s"):format(cmd), Color3.fromRGB(255,80,80))
    end
end

-- koneksi chat lokal
player.Chatted:Connect(onChatted)

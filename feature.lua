-- // Rayfield UI + Login Key (Role & Whitelist)
-- // Main Fiture: NoClip, Speed, + NEW: Carry, GodMode, ESP, Aimbot
-- // Teleporter (tanpa keybinds)
-- // Tidak ada Tab Commands

-----------------------------
-- KONFIG POSISI TELEPORT (optional, tetap ada)
-----------------------------
local OFFSET_Y = 3
local POINTS = {
    Vector3.new(388, 310, -185),    -- 1
    Vector3.new(99, 412, 615),      -- 2
    Vector3.new(10, 601, 998),      -- 3
    Vector3.new(871, 865, 583),     -- 4
    Vector3.new(1622, 1080, 157),   -- 5
    Vector3.new(2969, 1528, 708),   -- 6
    Vector3.new(1803, 1982, 2169), 
}
local DEFAULT_DELAY = 2

-----------------------------
-- GITHUB SOURCE (opsional KEYS.json)
-----------------------------
local HttpService = game:GetService("HttpService")
local BASE = "https://raw.githubusercontent.com/WannBot/Rbx/refs/heads/main/"

local function fetchKeysFromGit()
    local ok, raw = pcall(function()
        return game:HttpGet(BASE .. "KEYS.json")
    end)
    if not ok then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok2 and type(data)=="table" then return data end
    return nil
end

-----------------------------
-- KEY & ROLE (fallback lokal)
-----------------------------
local KEYS = {
    ["ADMIN1"] = { role = "ADMIN", allow = "any" },
    ["VIP1"]   = { role = "VIP",   allow = {9179746755, 87654321} },
    ["USER1"]  = { role = "USER",  allow = "any" },
}
local PERMISSIONS = {
    ADMIN = { noclip = true,  speed = true,  teleport = true, carry=true, god=true, esp=true, aimbot=true },
    VIP   = { noclip = false, speed = true,  teleport = true, carry=true, god=true, esp=true, aimbot=true },
    USER  = { noclip = false, speed = false, teleport = true, carry=true, god=true, esp=true, aimbot=true },
}

-----------------------------
-- SERVICES & VARS
-----------------------------
local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer
local Camera  = workspace.CurrentCamera

local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil

-----------------------------
-- HELPERS
-----------------------------
local function norm(s)
    s = tostring(s or "")
    return s:gsub("^%s+",""):gsub("%s+$","")
end
local function getCharHum()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end
local function clampDelay(x)
    if type(x)~="number" or x<=0 then return DEFAULT_DELAY end
    if x<0.1 then x=0.1 end
    if x>30 then x=30 end
    return x
end
local function getPlayerByNamePartial(txt)
    txt = tostring(txt or ""):lower()
    if txt=="" then return nil end
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Name:lower():find(txt,1,true) then return pl end
    end
    return nil
end

-----------------------------
-- TELEPORT
-----------------------------
-----------------------------
-- TELEPORT (dengan Auto Respawn di akhir loop)
-----------------------------
-----------------------------
-- TELEPORT (mulai dari titik terakhir, respawn 2s di akhir)
-----------------------------
local lastTpIndex = 0

local function teleportTo(i)
    if i < 1 or i > #POINTS then return end
    local _, _, hrp = getCharHum()
    hrp.CFrame = CFrame.new(POINTS[i] + Vector3.new(0, OFFSET_Y, 0))
    lastTpIndex = i
end

local function respawnNow()
    local ok = pcall(function()
        Players.LocalPlayer:LoadCharacter()
    end)
    if not ok then
        local _, hum = getCharHum()
        if hum then hum.Health = 0 end
    end
    Players.LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
end

local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil

-- hitung start index (kalau belum ada lastTpIndex, ambil 1)
local function computeStartIndex()
    if lastTpIndex >= 1 and lastTpIndex <= #POINTS then
        local nxt = lastTpIndex + 1
        if nxt > #POINTS then nxt = 1 end
        return nxt
    else
        return 1
    end
end

local function startLoop()
    if autoLoop then return end
    autoLoop = true
    loopThread = coroutine.create(function()
        local i = computeStartIndex()
        while autoLoop do
            teleportTo(i)

            if i < #POINTS then
                -- titik biasa → pakai delay TP normal
                local t0 = os.clock()
                while autoLoop and (os.clock() - t0) < currentDelay do
                    task.wait(0.05)
                end
            else
                -- TITIK TERAKHIR → tunggu 2 detik, respawn, lalu reset & jeda 5 detik
                local t0 = os.clock()
                while autoLoop and (os.clock() - t0) < 2 do
                    task.wait(0.05)
                end
                if not autoLoop then break end
                respawnNow()
                lastTpIndex = 0   -- reset index
                -- jeda 5 detik setelah respawn
                local t1 = os.clock()
                while autoLoop and (os.clock() - t1) < 5 do
                    task.wait(0.1)
                end
            end

            -- next index (wrap ke awal kalau habis)
            i = i + 1
            if i > #POINTS then i = 1 end
        end
    end)
    coroutine.resume(loopThread)
end

-----------------------------
-- RAYFIELD
-----------------------------
local function newWindow()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "WS",
        Icon = 0,
        LoadingTitle = "Rayfield Interface Suite",
        LoadingSubtitle = "UI",
        Theme = "Default",
        ToggleUIKeybind = "K",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "Teleporter7",
            FileName = "Config"
        },
        KeySystem = false,
    })
    return Rayfield, Window
end

-----------------------------
-- BUILD FEATURE TABS
-----------------------------
local function buildFeatureTabs(Window, Rayfield, role)
    local perms = PERMISSIONS[role] or { noclip=false, speed=false, teleport=true, carry=false, god=false, esp=false, aimbot=false }

    -- ========== Tab: Main Fiture ==========
    local TabMain = Window:CreateTab("Main Fiture", "layout-grid")

    -- NoClip
    if perms.noclip then
        local noclip=false
        local noclipConn
        local function setNoClip(state)
            if state then
                if noclip then return end
                noclip = true
                noclipConn = RS.Stepped:Connect(function()
                    local char = player.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide=false end
                    end
                end)
            else
                if not noclip then return end
                noclip=false
                if noclipConn then noclipConn:Disconnect() noclipConn=nil end
            end
        end
        TabMain:CreateSection("No Clip")
        TabMain:CreateToggle({
            Name = "Aktifkan No Clip",
            CurrentValue = false,
            Flag = "NoClipToggle",
            Callback = function(on) setNoClip(on) end,
        })
    else
        TabMain:CreateSection("No Clip")
        TabMain:CreateParagraph({ Title="Tidak tersedia", Content="Role: "..tostring(role) })
    end

    -- Speed
    if perms.speed then
        local function setRunSpeed(v)
            local _,hum = getCharHum()
            hum.WalkSpeed = math.clamp(tonumber(v) or 16, 1, 200)
        end
        TabMain:CreateSection("Speed Run")
        TabMain:CreateSlider({
            Name="WalkSpeed", Range={16,200}, Increment=1, CurrentValue=16,
            Flag="RunSpeed", Callback=function(val) setRunSpeed(val) end,
        })
        TabMain:CreateButton({ Name="Reset WalkSpeed (16)", Callback=function() setRunSpeed(16) end })
    else
        TabMain:CreateSection("Speed Run")
        TabMain:CreateParagraph({ Title="Tidak tersedia", Content="Role: "..tostring(role) })
    end

    -- Carry / Gendong Player (local)
    if perms.carry then
        TabMain:CreateSection("Carry / Gendong Player")
        local carryName = ""
        local carryOn   = false
        local carryConn = nil
        local offsetCF  = CFrame.new(0,0,-2) -- di depan pemain

        TabMain:CreateInput({
            Name="Target Username (partial)",
            PlaceholderText="contoh: budi",
            RemoveTextAfterFocusLost=false,
            Callback=function(t) carryName = tostring(t or "") end,
        })
        local function setCarry(state)
            if state then
                if carryOn then return end
                local target = getPlayerByNamePartial(carryName)
                if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
                    return
                end
                carryOn = true
                carryConn = RS.RenderStepped:Connect(function()
                    if not carryOn then return end
                    local _,_,myHRP = getCharHum()
                    local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                    if myHRP and tHRP then
                        tHRP.CFrame = myHRP.CFrame * offsetCF
                    end
                end)
            else
                if not carryOn then return end
                carryOn=false
                if carryConn then carryConn:Disconnect() carryConn=nil end
            end
        end
        TabMain:CreateToggle({
            Name="Aktifkan Carry",
            CurrentValue=false,
            Flag="CarryToggle",
            Callback=function(on) setCarry(on) end,
        })
    end

    -- God Mode (Auto-Heal)
    if perms.god then
        TabMain:CreateSection("God Mode (Auto-Heal)")
        local godOn=false
        local godConn=nil
        local function setGod(state)
            if state then
                if godOn then return end
                godOn=true
                godConn = RS.Heartbeat:Connect(function()
                    local _, hum = getCharHum()
                    if hum and hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                end)
            else
                if not godOn then return end
                godOn=false
                if godConn then godConn:Disconnect() godConn=nil end
            end
        end
        TabMain:CreateToggle({
            Name="Aktifkan God Mode",
            CurrentValue=false,
            Flag="GodToggle",
            Callback=function(on) setGod(on) end,
        })
    end

    -- ESP (BillboardGui) tanpa Drawing API
    if perms.esp then
        TabMain:CreateSection("ESP (Nama + Jarak)")
        local espOn=false
        local espFolder = Instance.new("Folder")
        espFolder.Name = "WS_ESPFolder"
        espFolder.Parent = game.CoreGui

        local function createESP(plr)
            if plr==player then return end
            if not plr.Character then return end
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if hrp:FindFirstChild("WS_ESP") then return end

            local billboard = Instance.new("BillboardGui")
            billboard.Name = "WS_ESP"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = hrp

            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1,0,1,0)
            label.TextColor3 = Color3.new(1,1,1)
            label.TextStrokeTransparency = 0.3
            label.Font = Enum.Font.SourceSansBold
            label.TextScaled = true
            label.Text = plr.Name
            label.Parent = billboard

            -- update jarak
            local conn
            conn = RS.RenderStepped:Connect(function()
                if not billboard or not billboard.Parent or not plr.Character then
                    if conn then conn:Disconnect() end
                    return
                end
                local myHRP = (player.Character and player.Character:FindFirstChild("HumanoidRootPart"))
                local tHRP  = (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart"))
                if myHRP and tHRP then
                    local dist = (myHRP.Position - tHRP.Position).Magnitude
                    label.Text = string.format("%s (%.0f)", plr.Name, dist)
                end
            end)
        end
        local function removeESP(plr)
            if plr and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local b = hrp:FindFirstChild("WS_ESP")
                    if b then b:Destroy() end
                end
            end
        end
        local function setESP(state)
            if state then
                if espOn then return end
                espOn=true
                for _,pl in ipairs(Players:GetPlayers()) do
                    if pl~=player then createESP(pl) end
                end
                espFolder.Parent = game.CoreGui
                -- hook events
                espFolder.ChildAdded:Connect(function() end) -- placeholder
                -- on new player / respawn
                local conPA, conCH
                conPA = Players.PlayerAdded:Connect(function(pl) task.wait(1) createESP(pl) end)
                conCH = Players.PlayerRemoving:Connect(function(pl) removeESP(pl) end)
                -- simpan di atribut folder biar bisa diputus manual
                espFolder:SetAttribute("PA", conPA)
                espFolder:SetAttribute("CH", conCH)
            else
                if not espOn then return end
                espOn=false
                -- bersihkan semua
                for _,pl in ipairs(Players:GetPlayers()) do removeESP(pl) end
                -- putus event
                local pa = espFolder:GetAttribute("PA")
                local ch = espFolder:GetAttribute("CH")
                if typeof(pa)=="RBXScriptConnection" then pa:Disconnect() end
                if typeof(ch)=="RBXScriptConnection" then ch:Disconnect() end
                espFolder.Parent = nil
            end
        end
        TabMain:CreateToggle({
            Name="Aktifkan ESP",
            CurrentValue=false,
            Flag="ESPToggle",
            Callback=function(on) setESP(on) end,
        })
    end

    -- Aimbot (kamera lock target)
    if perms.aimbot then
        TabMain:CreateSection("Aimbot (Camera Lock)")
        local aimOn=false
        local aimConn=nil
        local maxDist = 1500
        local teamCheck = false

        local function isEnemy(pl)
            if not teamCheck then return true end
            local lpTeam = player.Team
            return (pl.Team ~= lpTeam)
        end
        local function getClosestTarget()
            local myChar = player.Character
            local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return nil end

            local closest, best = nil, 1e9
            for _,pl in ipairs(Players:GetPlayers()) do
                if pl ~= player and isEnemy(pl) and pl.Character then
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local dist = (myHRP.Position - hrp.Position).Magnitude
                        if dist < best and dist <= maxDist then
                            best = dist
                            closest = hrp
                        end
                    end
                end
            end
            return closest
        end
        local function setAimbot(state)
            if state then
                if aimOn then return end
                aimOn=true
                aimConn = RS.RenderStepped:Connect(function()
                    if not aimOn then return end
                    local targetHRP = getClosestTarget()
                    local _,_,myHRP = getCharHum()
                    if targetHRP and myHRP then
                        local look = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
                        Camera.CFrame = look
                    end
                end)
            else
                if not aimOn then return end
                aimOn=false
                if aimConn then aimConn:Disconnect() aimConn=nil end
            end
        end
        TabMain:CreateToggle({
            Name="Aktifkan Aimbot",
            CurrentValue=false,
            Flag="AimbotToggle",
            Callback=function(on) setAimbot(on) end,
        })
        TabMain:CreateSlider({
            Name="Jarak Maks Target",
            Range={100, 3000},
            Increment=50, CurrentValue=maxDist, Flag="AimbotRange",
            Callback=function(v) maxDist = tonumber(v) or maxDist end,
        })
        TabMain:CreateToggle({
            Name="Team Check",
            CurrentValue=false,
            Flag="AimbotTeamCheck",
            Callback=function(on) teamCheck = on end,
        })
    end

    -- ========== Tab: Teleporter (tanpa keybinds, TANPA Tab Commands) ==========
    if perms.teleport then
        local Tab = Window:CreateTab("Teleporter", "map-pin")

        Tab:CreateSection("Manual Teleport")
        for i=1,#POINTS do
            Tab:CreateButton({
                Name=("TP %d"):format(i),
                Callback=function() teleportTo(i) end,
            })
        end

        Tab:CreateSection("Auto Loop")
        Tab:CreateToggle({
            Name="Aktifkan Auto Loop",
            CurrentValue=false,
            Flag="AutoLoop",
            Callback=function(on) if on then startLoop() else stopLoop() end end,
        })
        Tab:CreateSlider({
            Name="Delay Teleport (detik)",
            Range={0.1,30}, Increment=0.1, Suffix="s",
            CurrentValue=DEFAULT_DELAY, Flag="DelayTP",
            Callback=function(val) currentDelay = clampDelay(val) end,
        })
    else
        local Tab = Window:CreateTab("Teleporter", "map-pin")
        Tab:CreateParagraph({ Title="Tidak tersedia", Content="Fitur Teleporter nonaktif untuk role: "..tostring(role) })
    end

    -- Info
    local TabInfo = Window:CreateTab("Info", "info")
    local p = PERMISSIONS[role] or {}
    TabInfo:CreateParagraph({ Title="Role Aktif", Content=tostring(role) })
    TabInfo:CreateParagraph({ Title="Permissions", Content =
        ("noclip=%s, speed=%s, teleport=%s, carry=%s, god=%s, esp=%s, aimbot=%s")
        :format(tostring(p.noclip), tostring(p.speed), tostring(p.teleport), tostring(p.carry), tostring(p.god), tostring(p.esp), tostring(p.aimbot)) })

    Rayfield:LoadConfiguration()
end

-----------------------------
-- LOGIN + REBUILD UI
-----------------------------
local function validateKey(inputKey)
    local entry = KEYS[norm(inputKey)]
    if not entry then return false, "KEY salah." end
    local allow = entry.allow
    if allow=="any" then return true, entry.role end
    local uid = Players.LocalPlayer.UserId
    if typeof(allow)=="table" then
        for _,x in ipairs(allow) do if x==uid then return true, entry.role end end
        return false, "KEY bukan untuk akun ini."
    end
    return false, "Whitelist tidak valid."
end

local Rayfield1, Window1 = newWindow()
local TabLogin = Window1:CreateTab("Login", "lock")
TabLogin:CreateSection("Masukkan KEY untuk melanjutkan")
local typedKey=""

TabLogin:CreateInput({
    Name="Key", PlaceholderText="Masukkan KEY di sini", RemoveTextAfterFocusLost=false,
    Callback=function(text) typedKey = tostring(text or "") end,
})
TabLogin:CreateButton({
    Name="Login",
    Callback=function()
        local remote = fetchKeysFromGit()
        if remote and type(remote)=="table" then KEYS = remote end

        if typedKey=="" then
            Rayfield1:Notify({ Title="Login Gagal", Content="KEY masih kosong.", Duration=3, Image="alert-triangle" })
            return
        end
        local ok, roleOrMsg = validateKey(typedKey)
        if not ok then
            Rayfield1:Notify({ Title="Login Gagal", Content=tostring(roleOrMsg), Duration=3, Image="x" })
            return
        end
        local role = roleOrMsg or "USER"
        Rayfield1:Notify({ Title="Login Berhasil", Content="Role: "..tostring(role), Duration=3, Image="check" })

        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _,gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and tostring(gui.Name):lower():find("rayfield") then
                    gui:Destroy()
                end
            end
        end
        local Rayfield2, Window2 = newWindow()
        buildFeatureTabs(Window2, Rayfield2, role)
        Rayfield2:Notify({ Title="Siap", Content="Fitur diaktifkan sesuai role.", Duration=3, Image="info" })
    end,
})

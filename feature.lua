-- features.lua — Login (role+whitelist) + Main Fiture (NoClip, Speed, Fling, WalkFling, Invisible Username)
-- Dua tab teleport di file terpisah: teleport_tab1.lua & teleport_tab2.lua
-- Tidak ada Fly. Tidak ada Keybinds TP. Tidak ada Tab Commands.

-----------------------------
-- GITHUB SOURCE
-----------------------------
local HttpService = game:GetService("HttpService")
-- Ganti ini kalau struktur repo/branch/path berbeda (akhiri dengan '/'):
local BASE = "https://raw.githubusercontent.com/WannBot/Rbx/refs/heads/main/"

local function fetch(url)
    local ok, data = pcall(function() return game:HttpGet(url) end)
    if ok then return data end
    warn("[features] fetch fail:", data)
    return nil
end

local function fetchJSON(url)
    local raw = fetch(url)
    if not raw then return nil end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok and type(decoded) == "table" then return decoded end
    warn("[features] json decode fail for:", url)
    return nil
end

-----------------------------
-- KEY & ROLE CONFIG (fallback lokal)
-----------------------------
-- Jika KEYS.json gagal diambil, pakai tabel lokal ini.
-- KEYS: key -> { role="ADMIN|VIP|USER", allow="any"|{UserIds...} }
local KEYS = {
    ["ADMIN1"] = { role = "ADMIN", allow = {9179746755} },
    ["VIP1"]   = { role = "VIP",   allow = {9179746755, 87654321} },
    ["USER1"]  = { role = "USER",  allow = "any" },
}

-- Izin fitur per role (ubah sesuka hati)
local PERMISSIONS = {
    ADMIN = { noclip = true,  speed = true,  teleport = true, fling = true,  walkfling = true,  invisUser = true },
    VIP   = { noclip = false, speed = true,  teleport = true, fling = true,  walkfling = true,  invisUser = true },
    USER  = { noclip = false, speed = false, teleport = true, fling = false, walkfling = false, invisUser = true },
}

-----------------------------
-- SERVICES & VAR
-----------------------------
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local player  = Players.LocalPlayer

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

-----------------------------
-- RAYFIELD HELPERS
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
-- MAIN FEATURE TABS
-----------------------------
local function buildFeatureTabs(Window, Rayfield, role)
    local perms = PERMISSIONS[role] or { noclip=false, speed=false, teleport=true, fling=false, walkfling=false, invisUser=true }

    -- ===== Tab: Main Fiture =====
    local TabMain = Window:CreateTab("Main Fiture", "layout-grid")

    -- NoClip
    if perms.noclip then
        local noclip, noclipConn = false, nil
        local function setNoClip(state)
            if state then
                if noclip then return end
                noclip = true
                noclipConn = RS.Stepped:Connect(function()
                    local char = player.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end)
            else
                if not noclip then return end
                noclip = false
                if noclipConn then noclipConn:Disconnect() noclipConn = nil end
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
        TabMain:CreateParagraph({ Title = "Tidak tersedia", Content = "Role: "..tostring(role) })
    end

    -- Speed (WalkSpeed)
    if perms.speed then
        local function setRunSpeed(v)
            local _, hum = getCharHum()
            hum.WalkSpeed = math.clamp(tonumber(v) or 16, 1, 200)
        end
        TabMain:CreateSection("Speed Run")
        TabMain:CreateSlider({
            Name = "WalkSpeed",
            Range = {16, 200},
            Increment = 1,
            CurrentValue = 16,
            Flag = "RunSpeed",
            Callback = function(val) setRunSpeed(val) end,
        })
        TabMain:CreateButton({
            Name = "Reset WalkSpeed (16)",
            Callback = function() setRunSpeed(16) end,
        })
    else
        TabMain:CreateSection("Speed Run")
        TabMain:CreateParagraph({ Title = "Tidak tersedia", Content = "Role: "..tostring(role) })
    end

    -- Fling (spin)
    if perms.fling then
        TabMain:CreateSection("Fling")
        local flingEnabled, flange, savedVel, connFling = false, 2000, nil, nil
        local function setFling(state)
            local _,_,hrp = getCharHum()
            if state then
                if flingEnabled then return end
                flingEnabled = true
                savedVel = hrp.AssemblyAngularVelocity
                connFling = RS.Heartbeat:Connect(function()
                    if not flingEnabled then return end
                    local _,_,r = getCharHum()
                    r.AssemblyAngularVelocity = Vector3.new(flange, flange, flange)
                end)
            else
                if not flingEnabled then return end
                flingEnabled = false
                if connFling then connFling:Disconnect() connFling = nil end
                local _,_,r = getCharHum()
                if savedVel then r.AssemblyAngularVelocity = savedVel end
            end
        end
        TabMain:CreateToggle({
            Name = "Aktifkan Fling (spin)",
            CurrentValue = false,
            Flag = "FlingToggle",
            Callback = function(on) setFling(on) end,
        })
        TabMain:CreateSlider({
            Name = "Kekuatan Spin",
            Range = {500, 5000},
            Increment = 50,
            CurrentValue = 2000,
            Flag = "FlingSpin",
            Callback = function(val) flange = tonumber(val) or flange end,
        })
    end

    -- WalkFling
    if perms.walkfling then
        TabMain:CreateSection("WalkFling")
        local wfEnabled, wfPower, connWF = false, 250, nil
        local function setWalkFling(state)
            if state then
                if wfEnabled then return end
                wfEnabled = true
                connWF = RS.RenderStepped:Connect(function()
                    if not wfEnabled then return end
                    local _, hum, hrp = getCharHum()
                    local dir = hum.MoveDirection
                    if dir.Magnitude > 0 then
                        hrp.AssemblyLinearVelocity = dir.Unit * wfPower
                    end
                end)
            else
                if not wfEnabled then return end
                wfEnabled = false
                if connWF then connWF:Disconnect() connWF = nil end
            end
        end
        TabMain:CreateToggle({
            Name = "Aktifkan WalkFling",
            CurrentValue = false,
            Flag = "WalkFlingToggle",
            Callback = function(on) setWalkFling(on) end,
        })
        TabMain:CreateSlider({
            Name = "Kekuatan Dorong",
            Range = {50, 1000},
            Increment = 10,
            CurrentValue = 250,
            Flag = "WalkFlingPower",
            Callback = function(val) wfPower = tonumber(val) or wfPower end,
        })
    end

    -- Invisible Username (local)
    if perms.invisUser then
        TabMain:CreateSection("Invisible Username (Local)")
        local targetName = ""
        local function setInvisibleForUsername(name, invisible)
            name = tostring(name or "")
            local plr = Players:FindFirstChild(name)
            if not plr or not plr.Character then return end
            for _, obj in ipairs(plr.Character:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.LocalTransparencyModifier = invisible and 1 or 0
                elseif obj:IsA("Decal") then
                    obj.Transparency = invisible and 1 or 0
                end
            end
        end
        TabMain:CreateInput({
            Name = "Username target",
            PlaceholderText = "misal: PlayerName",
            RemoveTextAfterFocusLost = false,
            Callback = function(text) targetName = tostring(text or "") end,
        })
        TabMain:CreateButton({
            Name = "Jadikan Invisible",
            Callback = function() if targetName ~= "" then setInvisibleForUsername(targetName, true) end end,
        })
        TabMain:CreateButton({
            Name = "Kembalikan (Visible)",
            Callback = function() if targetName ~= "" then setInvisibleForUsername(targetName, false) end end,
        })
    end

    -- ===== Dua Tab Teleport eksternal =====
    if perms.teleport then
        -- Tab 1
        local src1 = fetch(BASE .. "teleport_tab1.lua")
        if src1 then
            local ok1, builder1 = pcall(loadstring, src1)
            if ok1 and type(builder1) == "function" then
                builder1({ Window = Window, getCharHum = getCharHum })
            else
                warn("[features] teleport_tab1.lua load error:", tostring(builder1))
            end
        else
            warn("[features] teleport_tab1.lua not found at BASE path.")
        end

        -- Tab 2
        local src2 = fetch(BASE .. "teleport_tab2.lua")
        if src2 then
            local ok2, builder2 = pcall(loadstring, src2)
            if ok2 and type(builder2) == "function" then
                builder2({ Window = Window, getCharHum = getCharHum })
            else
                warn("[features] teleport_tab2.lua load error:", tostring(builder2))
            end
        else
            warn("[features] teleport_tab2.lua not found at BASE path.")
        end
    end

    -- ===== Tab: Info =====
    local TabInfo = Window:CreateTab("Info", "info")
    local p = PERMISSIONS[role] or {}
    TabInfo:CreateParagraph({ Title = "Role Aktif", Content = tostring(role) })
    TabInfo:CreateParagraph({ Title = "Permissions", Content =
        ("noclip=%s, speed=%s, teleport=%s, fling=%s, walkfling=%s, invisUser=%s")
        :format(tostring(p.noclip), tostring(p.speed), tostring(p.teleport), tostring(p.fling), tostring(p.walkfling), tostring(p.invisUser)) })
end

-----------------------------
-- LOGIN + REBUILD UI
-----------------------------
local function validateKey(inputKey)
    local entry = KEYS[norm(inputKey)]
    if not entry then return false, "KEY salah." end
    local allow = entry.allow
    if allow == "any" then return true, entry.role end
    local uid = Players.LocalPlayer.UserId
    if typeof(allow) == "table" then
        for _,x in ipairs(allow) do if x == uid then return true, entry.role end end
        return false, "KEY bukan untuk akun ini."
    end
    return false, "Whitelist tidak valid."
end

-- Window 1: Tab Login saja
local Rayfield1, Window1 = newWindow()
local TabLogin = Window1:CreateTab("Login", "lock")
TabLogin:CreateSection("Masukkan KEY untuk melanjutkan")

local typedKey = ""
TabLogin:CreateInput({
    Name = "Key",
    PlaceholderText = "Masukkan KEY di sini",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) typedKey = tostring(text or "") end,
})

TabLogin:CreateButton({
    Name = "Login",
    Callback = function()
        local remote = fetchJSON(BASE .. "KEYS.json")
        if remote and type(remote) == "table" then KEYS = remote end

        if typedKey == "" then
            Rayfield1:Notify({ Title = "Login Gagal", Content = "KEY masih kosong.", Duration = 3, Image = "alert-triangle" })
            return
        end

        local ok, roleOrMsg = validateKey(typedKey)
        if not ok then
            Rayfield1:Notify({ Title = "Login Gagal", Content = tostring(roleOrMsg), Duration = 3, Image = "x" })
            return
        end
        local role = roleOrMsg or "USER"
        Rayfield1:Notify({ Title = "Login Berhasil", Content = "Role: "..tostring(role), Duration = 3, Image = "check" })

        -- hancurkan UI lama (tab Login)
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and tostring(gui.Name):lower():find("rayfield") then
                    gui:Destroy()
                end
            end
        end

        -- Window 2: Fitur
        local Rayfield2, Window2 = newWindow()
        buildFeatureTabs(Window2, Rayfield2, role)
        Rayfield2:Notify({ Title = "Siap", Content = "Fitur diaktifkan sesuai role.", Duration = 3, Image = "info" })
    end,
})

-- // Rayfield UI + Login Key (Role & Whitelist) + Main Fiture (NoClip, Speed) + Teleporter (7 pos)
-- // Gunakan di game sendiri / testing.

-----------------------------
-- KONFIGURASI POSISI
-----------------------------
local OFFSET_Y = 3
local POINTS = {
    -- GANTI koordinat sesuai map-mu:
    Vector3.new(388, 310, -185),    -- 1
    Vector3.new(99, 412, 615),      -- 2
    Vector3.new(10, 601, 998),      -- 3
    Vector3.new(871, 865, 583),     -- 4
    Vector3.new(1622, 1080, 157),   -- 5
    Vector3.new(2969, 1528, 708),   -- 6
    Vector3.new(1803, 1982, 2169),  -- 7
}
local DEFAULT_DELAY = 2 -- detik
local TOGGLE_KEY = "L"  -- toggle UI loop

-----------------------------
-- KEY & ROLE CONFIG
-----------------------------
-- KEYS: setiap key punya role dan whitelist UserId
--  - allow = "any"             -> bebas dipakai siapa saja
--  - allow = {9179746755, 456, ...}   -> hanya userId di daftar ini
local KEYS = {
    ["ADMIN1"] = { role = "ADMIN", allow = "any" },
    ["VIP1"]  = { role = "VIP",   allow = {9179746755, 87654321} },
    ["USER1"] = { role = "USER",  allow = "any" },
}

-- PERMISSIONS: atur fitur apa saja yang aktif untuk setiap role
-- Ubah true/false sesuai kebutuhanmu
local PERMISSIONS = {
    ADMIN = { noclip = true,  speed = true,  teleport = true },
    VIP   = { noclip = false, speed = true,  teleport = true },
    USER  = { noclip = false, speed = false, teleport = true },
}

-----------------------------
-- SERVICES & VAR
-----------------------------
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local player  = Players.LocalPlayer

local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil

-----------------------------
-- HELPERS
-----------------------------
local function norm(s) -- trim input
    s = tostring(s or "")
    return s:gsub("^%s+",""):gsub("%s+$","")
end

local function getCharHum()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local function clampDelay(x)
    if type(x) ~= "number" or x <= 0 then return DEFAULT_DELAY end
    if x < 0.1 then x = 0.1 end
    if x > 30 then x = 30 end
    return x
end

-----------------------------
-- TELEPORT
-----------------------------
local function teleportTo(i)
    if i < 1 or i > #POINTS then return end
    local _, _, hrp = getCharHum()
    hrp.CFrame = CFrame.new(POINTS[i] + Vector3.new(0, OFFSET_Y, 0))
end

local function startLoop()
    if autoLoop then return end
    autoLoop = true
    loopThread = coroutine.create(function()
        while autoLoop do
            for i = 1, #POINTS do
                if not autoLoop then break end
                teleportTo(i)
                task.wait(currentDelay)
            end
        end
    end)
    coroutine.resume(loopThread)
end

local function stopLoop()
    autoLoop = false
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

-- Bangun tab fitur utama sesuai role/permissions
local function buildFeatureTabs(Window, Rayfield, role)
    local perms = PERMISSIONS[role] or { noclip=false, speed=false, teleport=true }

    -- ===== Tab: Main Fiture (NoClip + Speed) =====
    local TabMain = Window:CreateTab("Main Fiture", "layout-grid")

    -- ==== NoClip (jika diizinkan) ====
    if perms.noclip then
        local noclip = false
        local noclipConn
        local function setNoClip(state)
            local char = player.Character
            if state then
                if noclip then return end
                noclip = true
                noclipConn = RS.Stepped:Connect(function()
                    char = player.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            else
                if not noclip then return end
                noclip = false
                if noclipConn then noclipConn:Disconnect() noclipConn = nil end
                -- biarkan Roblox yang restore collision saat respawn
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
        TabMain:CreateParagraph({ Title = "Tidak tersedia", Content = "Fitur ini tidak aktif untuk role: "..tostring(role) })
    end

    -- ==== Speed Run (WalkSpeed) (jika diizinkan) ====
    if perms.speed then
        local defaultWalkSpeed = 16
        local function setRunSpeed(v)
            local _, hum = getCharHum()
            hum.WalkSpeed = math.clamp(v, 1, 200)
        end

        TabMain:CreateSection("Speed Run")
        TabMain:CreateSlider({
            Name = "WalkSpeed",
            Range = {16, 200},
            Increment = 1,
            Suffix = "",
            CurrentValue = 16,
            Flag = "RunSpeed",
            Callback = function(val) setRunSpeed(tonumber(val) or 16) end,
        })
        TabMain:CreateButton({
            Name = "Reset WalkSpeed (16)",
            Callback = function() 
                local _, hum = getCharHum()
                hum.WalkSpeed = 16
            end,
        })
    else
        TabMain:CreateSection("Speed Run")
        TabMain:CreateParagraph({ Title = "Tidak tersedia", Content = "Fitur ini tidak aktif untuk role: "..tostring(role) })
    end

    -- ===== Tab: Teleporter (jika diizinkan) =====
    if perms.teleport then
        local Tab = Window:CreateTab("Teleporter", "map-pin")

        Tab:CreateSection("Manual Teleport")
        for i = 1, #POINTS do
            Tab:CreateButton({
                Name = ("TP %d"):format(i),
                Callback = function() teleportTo(i) end,
            })
        end

        Tab:CreateSection("Auto Loop")
        local ToggleLoop = Tab:CreateToggle({
            Name = "Aktifkan Auto Loop",
            CurrentValue = false,
            Flag = "AutoLoop",
            Callback = function(on) if on then startLoop() else stopLoop() end end,
        })
        Tab:CreateSlider({
            Name = "Delay Teleport (detik)",
            Range = {0.1, 30},
            Increment = 0.1,
            Suffix = "s",
            CurrentValue = DEFAULT_DELAY,
            Flag = "DelayTP",
            Callback = function(val) currentDelay = clampDelay(val) end,
        })

        Tab:CreateSection("Keybinds")
        for i = 1, #POINTS do
            Tab:CreateKeybind({
                Name = ("Keybind TP %d"):format(i),
                CurrentKeybind = tostring(i),
                HoldToInteract = false,
                Flag = ("BindTP"..i),
                Callback = function() teleportTo(i) end,
            })
        end
        Tab:CreateKeybind({
            Name = "Toggle Auto Loop",
            CurrentKeybind = TOGGLE_KEY,
            HoldToInteract = false,
            Flag = "BindLoop",
            Callback = function()
                local newState = not autoLoop
                ToggleLoop:Set(newState)
                if newState then startLoop() else stopLoop() end
            end,
        })

        Rayfield:Notify({
            Title = "Teleporter siap",
            Content = "Role: "..tostring(role),
            Duration = 3,
            Image = "map"
        })
    else
        local Tab = Window:CreateTab("Teleporter", "map-pin")
        Tab:CreateParagraph({ Title = "Tidak tersedia", Content = "Fitur Teleporter nonaktif untuk role: "..tostring(role) })
    end

    -- ===== Tab: Info =====
    local TabInfo = Window:CreateTab("Info", "info")
    local p = PERMISSIONS[role] or {}
    TabInfo:CreateParagraph({ Title = "Role Aktif", Content = tostring(role) })
    TabInfo:CreateParagraph({ Title = "Permissions", Content =
        ("noclip=%s, speed=%s, teleport=%s"):format(tostring(p.noclip), tostring(p.speed), tostring(p.teleport)) })

    Rayfield:LoadConfiguration()
end

-------------------------------------------------
-- LOGIN: Key Manual (Role + Whitelist + Rebuild UI)
-------------------------------------------------
local function validateKey(inputKey)
    local entry = KEYS[norm(inputKey)]
    if not entry then
        return false, "KEY salah.", nil
    end
    local allow = entry.allow
    if allow == "any" then
        return true, entry.role, entry
    end
    local uid = Players.LocalPlayer.UserId
    if typeof(allow) == "table" then
        for _,x in ipairs(allow) do if x == uid then return true, entry.role, entry end end
        return false, "KEY bukan untuk akun ini.", nil
    end
    return false, "Whitelist tidak valid.", nil
end

-- 1) Buat Window pertama: HANYA Tab Login
local Rayfield, Window = newWindow()
local TabLogin = Window:CreateTab("Login", "lock")
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
        if typedKey == "" then
            Rayfield:Notify({ Title = "Login Gagal", Content = "KEY masih kosong.", Duration = 3, Image = "alert-triangle" })
            return
        end

        local ok, roleOrMsg = validateKey(typedKey)
        if not ok then
            Rayfield:Notify({ Title = "Login Gagal", Content = tostring(roleOrMsg), Duration = 3, Image = "x" })
            return
        end
        local role = roleOrMsg or "USER"

        Rayfield:Notify({ Title = "Login Berhasil", Content = "Role: "..tostring(role), Duration = 3, Image = "check" })

        -- 2) Hancurkan seluruh Rayfield UI lama (yang berisi Tab Login)
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in ipairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and tostring(gui.Name):lower():find("rayfield") then
                    gui:Destroy()
                end
            end
        end

        -- 3) Buat Window BARU tanpa Tab Login, lalu bangun fitur sesuai role
        local Rayfield2, Window2 = newWindow()
        buildFeatureTabs(Window2, Rayfield2, role)
        Rayfield2:Notify({ Title = "Siap", Content = "Fitur diaktifkan sesuai role.", Duration = 3, Image = "info" })
    end,
})

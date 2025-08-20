--[[
Client-only TEST Gate — KEY per Roblox UserId (NO duration) + Rayfield Teleporter + Original Script
- This is for quick local testing without Studio/server. Not secure for release.
- Verifies: KEY must match the mapping for Players.LocalPlayer.UserId.
- After KEY valid, shows Rayfield UI (teleporter 7 points) and then runs your original script.
]]]

-- ==== CONFIG: KEY PER USERID (EDIT THIS) ====
-- Example:
-- KEYS_PER_ID[12345678] = "susu"
-- Replace with your own UserId -> KEY pairs.
local KEYS_PER_ID = {{
    -- [PUT_YOUR_USERID_HERE] = "SUSU",
    -- Example test entry (remove it later):
    [0] = "TEST-KEY", -- 0 won't match any real user; just a placeholder
}}

-- ==== TELEPORT CONFIG ====
local OFFSET_Y = 3
local POINTS = {{
    Vector3.new(100, 10, 50),
    Vector3.new(150, 12, -30),
    Vector3.new(80,  9, 100),
    Vector3.new(-40, 15, 75),
    Vector3.new(0,   25, 0),
    Vector3.new(220, 8, -120),
    Vector3.new(-100, 18, 40),
}}
local DEFAULT_DELAY   = 2
local TOGGLE_LOOP_KEY = "L"

-- ==== SERVICES & VAR ====
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer

local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil
local verified     = false

local function log(...)
    pcall(function()
        if rconsoleprint then
            rconsoleprint("[Teleporter] "..table.concat({{...}}," ").."\n")
        else
            warn("[Teleporter]", ...)
        end
    end)
end

-- ==== TELEPORT CORE ====
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(i)
    if not verified then return end
    if i < 1 or i > #POINTS then return end
    local hrp = getHRP()
    if not hrp then return end
    hrp.CFrame = CFrame.new(POINTS[i] + Vector3.new(0, OFFSET_Y, 0))
end

local function clampDelay(x)
    if type(x) ~= "number" or x <= 0 then return DEFAULT_DELAY end
    if x < 0.1 then x = 0.1 end
    if x > 30 then x = 30 end
    return x
end

local function startLoop()
    if not verified then return end
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

-- ==== SIMPLE KEY PROMPT UI ====
local function showKeyPrompt(onSubmit)
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeyGateLocal"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 190)
    frame.Position = UDim2.new(0.5, -180, 0.5, -95)
    frame.BackgroundTransparency = 0.1
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Text = "Masukkan KEY"
    title.Parent = frame

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, -20, 0, 20)
    hint.Position = UDim2.new(0, 10, 0, 38)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 12
    hint.TextColor3 = Color3.fromRGB(200,200,200)
    hint.Text = "KEY per UserId (client-only, test)"
    hint.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 34)
    box.Position = UDim2.new(0, 10, 0, 68)
    box.ClearTextOnFocus = false
    box.PlaceholderText = "KEY di sini"
    box.Text = ""
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.BackgroundTransparency = 0.05
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -20, 0, 20)
    msg.Position = UDim2.new(0, 10, 0, 108)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 12
    msg.TextColor3 = Color3.fromRGB(255,120,120)
    msg.Text = ""
    msg.Parent = frame

    local submit = Instance.new("TextButton")
    submit.Size = UDim2.new(1, -20, 0, 34)
    submit.Position = UDim2.new(0, 10, 0, 136)
    submit.Text = "Verifikasi (Lokal)"
    submit.Font = Enum.Font.GothamMedium
    submit.TextSize = 14
    submit.AutoButtonColor = true
    submit.Parent = frame
    Instance.new("UICorner", submit).CornerRadius = UDim.new(0, 8)

    submit.Activated:Connect(function()
        local key = tostring(box.Text or ""):gsub("^%s+",""):gsub("%s+$","")
        if key == "" then
            msg.Text = "KEY kosong."
            return
        end
        onSubmit(key, function(ok, text)
            if ok then
                gui:Destroy()
            else
                msg.Text = text or "KEY salah."
            end
        end)
    end)
end

-- Client-side verify (TEST ONLY, per UserId)
local function verifyKeyLocal(inputKey)
    local uid = player.UserId
    local expected = KEYS_PER_ID[uid]
    if not expected then
        return false, ("UserId %d belum didaftarkan."):format(uid)
    end
    if tostring(expected) ~= tostring(inputKey) then
        return false, "KEY tidak cocok untuk UserId ini."
    end
    verified = true
    return true, "OK"
end

-- ==== RAYFIELD UI AFTER VERIFIED ====
local function buildRayfieldUI()
    local ok, Rayfield = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    if not ok or not Rayfield then
        log("Gagal memuat Rayfield. Pastikan HttpGet diperbolehkan oleh executor.")
        return
    end

    local Window = Rayfield:CreateWindow({
        Name = "Teleporter 7 Pos",
        Icon = 0,
        LoadingTitle = "Rayfield",
        LoadingSubtitle = "Teleporter",
        Theme = "Default",
        ToggleUIKeybind = "K",
        ConfigurationSaving = { Enabled = true, FolderName = "Teleporter7Local", FileName = "Config" },
        KeySystem = false,
    })

    local Tab = Window:CreateTab("Teleporter", "map-pin")

    Tab:CreateSection("Manual Teleport")
    for i = 1, #POINTS do
        Tab:CreateButton({
            Name = ("TP %d"):format(i),
            Callback = function()
                teleportTo(i)
            end,
        })
    end

    Tab:CreateSection("Auto Loop")
    local ToggleLoop = Tab:CreateToggle({
        Name = "Aktifkan Auto Loop",
        CurrentValue = false,
        Flag = "AutoLoop",
        Callback = function(on)
            if on then startLoop() else stopLoop() end
        end,
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
            Flag = ("BindTP%d"):format(i),
            Callback = function()
                teleportTo(i)
            end,
        })
    end

    Tab:CreateKeybind({
        Name = "Toggle Auto Loop",
        CurrentKeybind = TOGGLE_LOOP_KEY,
        HoldToInteract = false,
        Flag = "BindLoop",
        Callback = function()
            if autoLoop then
                stopLoop()
                ToggleLoop:Set(false)
            else
                ToggleLoop:Set(true)
                startLoop()
            end
        end,
    })

    Rayfield:Notify({ Title = "Siap", Content = "KEY valid. Gunakan tombol TP/Loop/Delay.", Duration = 5, Image = "rocket" })
end

-- ==== RUN: prompt key -> build UI -> run original ====
local function run()
    local function onSubmit(key, uiCb)
        local ok, message = verifyKeyLocal(key)
        uiCb(ok, message)
        if ok then
            task.defer(buildRayfieldUI)
            -- Execute the original script AFTER verification:
            local original_src = [===[
__ORIGINAL__
]===]
            local ok2, chunk = pcall(loadstring, original_src)
            if ok2 and type(chunk) == "function" then
                local ok3, err = pcall(chunk)
                if not ok3 then
                    log("Error running original script:", tostring(err))
                end
            else
                log("Error compiling original script:", tostring(chunk))
            end
        end
    end
    showKeyPrompt(onSubmit)
end

-- Inject original code placeholder now
do
    local original = [===[
-- // Teleporter 7 Pos + Rayfield UI
-- // Gunakan di game sendiri / testing. Jangan dipakai untuk eksploit di game orang lain.

-----------------------------
-- KONFIGURASI POSISI
-----------------------------
local OFFSET_Y = 3
local POINTS = {
    -- GANTI koordinat sesuai map-mu:
    Vector3.new(388, 310, -185),    -- 1
    Vector3.new(99, 412, 615),   -- 2
    Vector3.new(10, 601, 998),    -- 3
    Vector3.new(871, 865, 583),    -- 4
    Vector3.new(1622, 1080, 157),     -- 5
    Vector3.new(2969, 1528, 708),   -- 6
    Vector3.new(1803, 1982, 2169),   -- 7
    Vector3.new(516, 14, -994),   -- Basecamp
}
local DEFAULT_DELAY = 2 -- detik
local TOGGLE_KEY = "L"  -- toggle UI & loop keybind di bawah

-----------------------------
-- SERVICES & VAR
-----------------------------
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer

local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil

-----------------------------
-- CORE TELEPORT
-----------------------------
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(i)
    if i < 1 or i > #POINTS then return end
    local hrp = getHRP()
    if not hrp then return end
    hrp.CFrame = CFrame.new(POINTS[i] + Vector3.new(0, OFFSET_Y, 0))
end

local function clampDelay(x)
    if type(x) ~= "number" or x <= 0 then return DEFAULT_DELAY end
    if x < 0.1 then x = 0.1 end
    if x > 30 then x = 30 end
    return x
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
-- RAYFIELD UI
-----------------------------
-- Load library (sesuai docs)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Buat jendela
local Window = Rayfield:CreateWindow({
    Name = "WS",
    Icon = 0,
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "Teleporter",
    ShowText = "Teleporter",
    Theme = "Default",
    ToggleUIKeybind = "K", -- toggle visibilitas UI Rayfield
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Teleporter7",
        FileName = "Config"
    },
    KeySystem = false, -- kita pakai key manual/serverside di versi sebelumnya; matikan di Rayfield
})

-- Tab utama
local Tab = Window:CreateTab("Teleporter", "map-pin")

-- Bagian Manual
Tab:CreateSection("Manual Teleport")

for i = 1, #POINTS do
    Tab:CreateButton({
        Name = ("TP %d"):format(i),
        Callback = function()
            teleportTo(i)
        end,
    })
end

-- Bagian Auto Loop
Tab:CreateSection("Auto Loop")

-- Toggle Auto Loop
local ToggleLoop = Tab:CreateToggle({
    Name = "Aktifkan Auto Loop",
    CurrentValue = false,
    Flag = "AutoLoop",
    Callback = function(on)
        if on then startLoop() else stopLoop() end
    end,
})

-- Slider Delay (0.1s - 30s)
local DelaySlider = Tab:CreateSlider({
    Name = "Delay Teleport (detik)",
    Range = {0.1, 30},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = DEFAULT_DELAY,
    Flag = "DelayTP",
    Callback = function(val)
        currentDelay = clampDelay(val)
    end,
})

-- Notifikasi siap
Rayfield:Notify({
    Title = "Teleporter siap",
    Content = "Selamat menggunakan script",
    Duration = 3,
    Image = "Fire"
})

-- Binds (angka 1..7 untuk TP, L untuk toggle loop)
Tab:CreateSection("Keybinds")

for i = 1, #POINTS do
    Tab:CreateKeybind({
        Name = ("Keybind TP %d"):format(i),
        CurrentKeybind = tostring(i), -- "1".."7"
        HoldToInteract = false,
        Flag = ("BindTP%d"):format(i),
        Callback = function()
            teleportTo(i)
        end,
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

-- (opsional) load & simpan konfigurasi Rayfield
Rayfield:LoadConfiguration() -- sesuai petunjuk config saving

]===]
    run = assert(loadstring((string.dump(run)):gsub("__ORIGINAL__", original)))
end

run()

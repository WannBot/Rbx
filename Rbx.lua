--[[
 Client-only KEY Gate (TEST ONLY) + Rayfield Teleporter 7 Pos
 - Tanpa Studio, tanpa server. Semuanya lokal di client.
 - Untuk uji coba game kamu sendiri. Jangan dipakai untuk rilis publik.
]]

-- ==== KONFIGURASI KEY (TEST LOKAL) ====
-- Kamu bisa menambah/mengedit key di sini.
-- durationSeconds: durasi aktif dari momen aktivasi (0 = tanpa durasi)
-- lifetimeUntil:   batas waktu absolut (Unix epoch / os.time()) (0 = tanpa lifetime)
local KEYS = {
    ["TEST-30S"]  = { durationSeconds = 30,  lifetimeUntil = 0 },          -- aktif 30 detik
    ["TEST-5MIN"] = { durationSeconds = 300, lifetimeUntil = 0 },          -- aktif 5 menit
    ["TEST-LIFE"] = { durationSeconds = 0,   lifetimeUntil = 2000000000 }, -- hanya lifetime (contoh: 2033+)
}

-- ==== TELEPORT KONFIG ====
local OFFSET_Y = 3
local POINTS = {
    Vector3.new(100, 10, 50),    -- 1
    Vector3.new(150, 12, -30),   -- 2
    Vector3.new(80,  9, 100),    -- 3
    Vector3.new(-40, 15, 75),    -- 4
    Vector3.new(0,   25, 0),     -- 5
    Vector3.new(220, 8, -120),   -- 6
    Vector3.new(-100, 18, 40),   -- 7
}
local DEFAULT_DELAY   = 2
local TOGGLE_LOOP_KEY = "L" -- keybind untuk toggle loop

-- ==== SERVICES & VAR ====
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer

local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil
local expiresAt    = 0   -- timestamp kadaluwarsa (client-side)
local verified     = false

-- ==== HELPER WAKTU ====
local function minNonZero(a, b)
    if a == 0 then return b end
    if b == 0 then return a end
    return math.min(a, b)
end

-- hitung kapan expired berdasarkan policy dan waktu aktivasi sekarang
local function computeExpiry(now, policy)
    local fromDuration = 0
    if policy.durationSeconds and policy.durationSeconds > 0 then
        fromDuration = now + policy.durationSeconds
    end
    local fromLifetime = tonumber(policy.lifetimeUntil or 0)
    return minNonZero(fromDuration, fromLifetime) -- 0 = tidak dibatasi
end

-- ==== CORE TELEPORT ====
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(i)
    if not verified then return end
    if expiresAt > 0 and os.time() >= expiresAt then return end
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
    if expiresAt > 0 and os.time() >= expiresAt then return end
    if autoLoop then return end
    autoLoop = true
    loopThread = coroutine.create(function()
        while autoLoop do
            for i = 1, #POINTS do
                if not autoLoop then break end
                if expiresAt > 0 and os.time() >= expiresAt then
                    autoLoop = false
                    break
                end
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

-- ==== UI PROMPT KEY SEDERHANA ====
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
    title.Text = "Masukkan KEY (TEST Lokal)"
    title.Parent = frame

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, -20, 0, 20)
    hint.Position = UDim2.new(0, 10, 0, 38)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 12
    hint.TextColor3 = Color3.fromRGB(200,200,200)
    hint.Text = "Contoh: TEST-30S / TEST-5MIN / TEST-LIFE (ubah di script)"
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
                msg.Text = text or "KEY tidak valid."
            end
        end)
    end)
end

-- Validasi KEY lokal (tanpa server)
local function verifyKeyLocal(inputKey)
    local policy = KEYS[inputKey]
    if not policy then
        return false, "KEY tidak terdaftar."
    end
    local now = os.time()
    if policy.lifetimeUntil and policy.lifetimeUntil > 0 and now >= policy.lifetimeUntil then
        return false, "KEY sudah melewati lifetime."
    end
    expiresAt = computeExpiry(now, policy) -- bisa 0 jika tanpa batas
    verified  = true
    return true, "OK (lokal)"
end

-- ==== RAYFIELD UI SETELAH VERIFIED ====
local function buildRayfieldUI()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "Teleporter 7 Pos (TEST Lokal)",
        Icon = 0,
        LoadingTitle = "Rayfield",
        LoadingSubtitle = "Teleporter",
        Theme = "Default",
        ToggleUIKeybind = "K",
        ConfigurationSaving = { Enabled = true, FolderName = "Teleporter7Local", FileName = "Config" },
        KeySystem = false,
    })

    local Tab = Window:CreateTab("Teleporter", "map-pin")

    -- Info masa aktif
    if expiresAt and expiresAt > 0 then
        local remain = math.max(0, expiresAt - os.time())
        Tab:CreateParagraph({ Title = "Masa Aktif KEY", Content = string.format("Sisa waktu: ~%d detik", remain) })
    else
        Tab:CreateParagraph({ Title = "Masa Aktif KEY", Content = "Tidak dibatasi (lokal)" })
    end

    Tab:CreateSection("Manual Teleport")
    for i = 1, #POINTS do
        Tab:CreateButton({
            Name = ("TP %d"):format(i),
            Callback = function()
                if expiresAt > 0 and os.time() >= expiresAt then
                    Rayfield:Notify({ Title = "KEY habis", Content = "Masa aktif KEY berakhir.", Duration = 5, Image = "alert-triangle" })
                    stopLoop()
                    return
                end
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
            if on then
                if expiresAt > 0 and os.time() >= expiresAt then
                    Rayfield:Notify({ Title = "KEY habis", Content = "Masa aktif KEY berakhir.", Duration = 5, Image = "alert-triangle" })
                    ToggleLoop:Set(false)
                    return
                end
                startLoop()
            else
                stopLoop()
            end
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
                if expiresAt > 0 and os.time() >= expiresAt then
                    stopLoop()
                    return
                end
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
                if expiresAt > 0 and os.time() >= expiresAt then
                    Rayfield:Notify({ Title = "KEY habis", Content = "Masa aktif KEY berakhir.", Duration = 5, Image = "alert-triangle" })
                    return
                end
                ToggleLoop:Set(true)
                startLoop()
            end
        end,
    })

    Rayfield:Notify({ Title = "Siap", Content = "KEY valid (lokal). Gunakan tombol TP/Loop/Delay.", Duration = 5, Image = "rocket" })

    -- Watchdog masa aktif
    task.spawn(function()
        while verified do
            task.wait(1)
            if expiresAt > 0 and os.time() >= expiresAt then
                stopLoop()
                Rayfield:Notify({ Title = "KEY habis", Content = "Masa aktif KEY berakhir.", Duration = 6, Image = "alert-triangle" })
                verified = false
                break
            end
        end
    end)
end

-- ==== ALUR: minta KEY lokal → bangun UI ====
local function run()
    -- Prompt key
    local done = false
    showKeyPrompt(function(inputKey, uiCb)
        local ok, message = verifyKeyLocal(inputKey)
        uiCb(ok, message)
        done = ok
        if ok then
            task.delay(0.1, buildRayfieldUI)
        end
    end)
end

run()

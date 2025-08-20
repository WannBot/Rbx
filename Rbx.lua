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

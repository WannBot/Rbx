--// Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Teleport",
    LoadingTitle = "Teleport System",
    LoadingSubtitle = "by Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TeleportCFG",
        FileName = "AutoTP"
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local MainSection = MainTab:CreateSection("Teleport Settings")

-- Variabel utama
local autoTP = false
local delayTime = 3 -- default

-- Toggle Auto Teleport
MainTab:CreateToggle({
    Name = "Auto Teleport",
    CurrentValue = false,
    Callback = function(Value)
        autoTP = Value
    end,
})

-- Slider delay
MainTab:CreateSlider({
    Name = "Delay Teleport (detik)",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 3,
    Suffix = "Detik",
    Callback = function(Value)
        delayTime = Value
    end,
})

-- Fungsi teleport
local function teleportTo(pos)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Fungsi tekan tombol UI
local function pressBasecampButton()
    local player = game.Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")

    -- cari tombol "Ke Basecamp"
    local button = gui:FindFirstChild("Ke Basecamp", true) -- true = recursive search
    if button and button:IsA("TextButton") then
        firesignal(button.MouseButton1Click) -- klik manual
    end
end

-- Loop auto teleport
task.spawn(function()
    while task.wait() do
        if autoTP then
            -- Teleport ke koordinat pertama
            teleportTo(Vector3.new(3055, 7878, 1034))
            task.wait(delayTime)

            -- Tekan tombol "Ke Basecamp"
            pressBasecampButton()
            task.wait(delayTime)
        end
    end
end)

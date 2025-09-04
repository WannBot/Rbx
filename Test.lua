-- LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === Load Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Teleport",
    LoadingTitle = "Teleport System",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TeleportCFG",
        FileName = "AutoTP10"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Teleport", 4483362458)
local Section = Tab:CreateSection("Pengaturan Auto Teleport")

-- === Variabel ===
local autoTP = false
local delayTime = 5 -- default delay (detik)
local currentIndex = 1 -- untuk simpan posisi terakhir

-- Toggle Auto Teleport
Tab:CreateToggle({
    Name = "Auto Teleport 10 Titik",
    CurrentValue = false,
    Callback = function(Value)
        autoTP = Value
        print("AutoTP:", autoTP)
    end,
})

-- Slider Delay
Tab:CreateSlider({
    Name = "Delay per Teleport",
    Range = {1, 60},
    Increment = 1,
    Suffix = "detik",
    CurrentValue = 5,
    Callback = function(Value)
        delayTime = Value
        print("Delay diubah ke:", delayTime, "detik")
    end,
})

-- === Daftar 10 koordinat ===
local coords = {
    Vector3.new(-862, 125, 661),  -- titik 1
    Vector3.new(-533, 231, 261),  -- titik 2
    Vector3.new(-636, 315, 16),   -- titik 3
    Vector3.new(-751, 411, 65),   -- titik 4
    Vector3.new(-567, 417, 124),  -- titik 5
    Vector3.new(-657, 487, 384),  -- titik 6
    Vector3.new(-369, 703, 596),  -- titik 7
    Vector3.new(-588, 679, 399),  -- titik 8
    Vector3.new(-288, 873, 83),   -- titik 9
    Vector3.new(-855, 124, 902),  -- titik 10
}

-- Fungsi Teleport
local function teleportTo(pos)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Loop Auto Teleport
task.spawn(function()
    while task.wait() do
        if autoTP then
            teleportTo(coords[currentIndex])
            print("Teleport ke titik", currentIndex)

            task.wait(delayTime)

            -- pindah ke titik berikutnya
            currentIndex = currentIndex + 1
            if currentIndex > #coords then
                currentIndex = 1 -- ulang dari awal kalau sudah titik terakhir
            end
        end
    end
end)

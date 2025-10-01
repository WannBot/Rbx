-- Contoh penggunaan UI-Library HoangNguyenk8 (UI only) — template

-- Load UI library (ganti URL ke raw file UI-Library yang benar)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/HoangNguyenk8/Scripts/main/UI-Library/YourUILibraryFile.lua", true))()

-- Buat window utama
local Window = Library:CreateWindow("My UI")

-- Tambah tab
local MainTab = Window:CreateTab("Main")

-- Contoh toggle
MainTab:CreateToggle("FlyToggle", {Text = "Enable Fly", Default = false}, function(state)
    print("Toggle:", state)
end)

-- Contoh slider
MainTab:CreateSlider("SpeedSlider", {
    Text = "Fly Speed",
    Default = 2,
    Min = 1,
    Max = 10,
    Precise = false
}, function(val)
    print("Speed:", val)
end)

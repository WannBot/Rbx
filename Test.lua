-- Load FluentPlus
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/release.lua", true))()

-- Buat Window utama
local Window = Fluent:CreateWindow({
    Title = "My Game UI",
    SubTitle = "FluentPlus Example",
    Theme = "Dark",          -- "Dark" / "Light"
    Size = UDim2.fromOffset(450, 300),
})

-- Tambah Tab
local MainTab = Window:AddTab({ Title = "Main", Icon = "home" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

-- Tambah elemen di Main Tab
MainTab:AddToggle("ExampleToggle", { Title = "Example Toggle", Default = false }, function(state)
    print("Toggle State:", state)
end)

MainTab:AddButton({
    Title = "Example Button",
    Description = "Click me!",
    Callback = function()
        print("Button clicked!")
    end
})

MainTab:AddSlider("ExampleSlider", {
    Title = "Example Slider",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1,
}, function(value)
    print("Slider Value:", value)
end)

-- Tambah elemen di Settings Tab
SettingsTab:AddParagraph("Info", "Ini contoh UI pakai FluentPlus. Semua elemen bisa kamu custom.")

-- Contoh notifikasi
Fluent:Notify({
    Title = "FluentPlus",
    Content = "UI berhasil dimuat ✅",
    Duration = 5
})

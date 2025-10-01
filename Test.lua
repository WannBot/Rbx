-- Load UI library dari WannBot
local ok, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/WannBot/Rbx/refs/heads/main/Library.lua", true))()
end)
if not ok or not Library then
    warn("Gagal load WannBot UI Library:", Library)
    -- fallback UI sederhana agar ada indikasi
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 40)
    lbl.Position = UDim2.new(0, 0, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = "UI Load Failed"
    lbl.TextColor3 = Color3.new(1,0,0)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 24
    return
end

-- Jika Library berhasil load:
-- Buat window dan test UI elemen
local Window = Library:CreateWindow({
    Title = "Test UI (WannBot)",
    SubTitle = "Basic UI",
})

-- Buat tab / halaman utama jika library mendukung
local Tab = Window:AddTab("Main")

-- Tambah Toggle (contoh)
Tab:AddToggle("TestToggle", {
    Title = "Enable Feature",
    Default = false
}, function(state)
    print("Toggle State:", state)
end)

-- Tambah Slider (contoh)
Tab:AddSlider("TestSlider", {
    Title = "Test Speed",
    Default = 5,
    Min = 1,
    Max = 20,
    Rounding = 1
}, function(val)
    print("Slider Value:", val)
end)

-- Tambah Button
Tab:AddButton({
    Title = "Click Me",
    Description = "Test Button",
    Callback = function()
        print("Button clicked!")
    end
})

-- Notify atau pesan
if Library.Notify then
    Library:Notify({
        Title = "UI Library",
        Content = "UI berhasil dimuat dari WannBot",
        Duration = 3
    })
end

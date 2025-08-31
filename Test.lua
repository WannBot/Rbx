-- LocalScript untuk debug developer
local RunService = game:GetService("RunService")
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window utama
local Window = Rayfield:CreateWindow({
    Name = "ESP Racun Dinamis",
    LoadingTitle = "Debug Poison Drinks",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ESP_CFG",
        FileName = "PoisonESP"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("ESP", 4483362458)
local Section = Tab:CreateSection("Pengaturan Racun")

-- daftar atribut racun (dinamis)
local PoisonAttrs = {
    "IsPoison" -- default
}

local billboards = {}

-- fungsi cek apakah part racun
local function isPoisonPart(part)
    for _, attr in ipairs(PoisonAttrs) do
        if part:GetAttribute(attr) == true then
            return true
        end
    end
    return false
end

-- buat Billboard
local function makeBillboard(adornee, text, color)
    local b = Instance.new("BillboardGui")
    b.Size = UDim2.new(0, 100, 0, 50)
    b.StudsOffset = Vector3.new(0, 3, 0)
    b.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = b

    b.Adornee = adornee
    b.Parent = adornee
    return b
end

-- pasang ESP
local function attachESP(part)
    if billboards[part] then return end

    if isPoisonPart(part) then
        billboards[part] = makeBillboard(part, "☠ RACUN ☠", Color3.fromRGB(255, 0, 0))
    else
        billboards[part] = makeBillboard(part, "AMAN", Color3.fromRGB(0, 255, 0))
    end
end

-- update label
local function refresh()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if not billboards[part] then
                attachESP(part)
            else
                local isPoison = isPoisonPart(part)
                local label = billboards[part]:FindFirstChildOfClass("TextLabel")
                if label then
                    if isPoison and label.Text ~= "☠ RACUN ☠" then
                        billboards[part]:Destroy()
                        billboards[part] = nil
                        attachESP(part)
                    elseif not isPoison and label.Text ~= "AMAN" then
                        billboards[part]:Destroy()
                        billboards[part] = nil
                        attachESP(part)
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(refresh)

-- === UI Rayfield ===
Tab:CreateParagraph({Title = "Atribut Racun Aktif", Content = table.concat(PoisonAttrs, ", ")})

Tab:CreateInput({
    Name = "Tambah Atribut Racun",
    PlaceholderText = "contoh: IsExpired",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if text ~= "" and not table.find(PoisonAttrs, text) then
            table.insert(PoisonAttrs, text)
            Rayfield:Notify({
                Title = "Atribut Ditambahkan",
                Content = text .. " sekarang dipakai untuk deteksi racun",
                Duration = 4
            })
        end
    end,
})

Tab:CreateInput({
    Name = "Hapus Atribut Racun",
    PlaceholderText = "contoh: IsExpired",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        for i, v in ipairs(PoisonAttrs) do
            if v == text then
                table.remove(PoisonAttrs, i)
                Rayfield:Notify({
                    Title = "Atribut Dihapus",
                    Content = text .. " dihapus dari daftar racun",
                    Duration = 4
                })
                break
            end
        end
    end,
})

Tab:CreateButton({
    Name = "Lihat Daftar Atribut",
    Callback = function()
        Rayfield:Notify({
            Title = "Atribut Racun Aktif",
            Content = table.concat(PoisonAttrs, ", "),
            Duration = 6
        })
    end,
})

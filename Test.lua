-- Services
local HttpService = game:GetService("HttpService")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Fungsi validasi key (pakai executor http_request/syn.request)
local function validateKey(key)
    local endpoint = "https://botresi.xyz/keygen/api/validate.php"
    local body = "key=" .. key
    local requestFunc = (http_request or request or syn and syn.request)
    if not requestFunc then return false, "executor_no_http" end

    local response = requestFunc({
        Url = endpoint,
        Method = "POST",
        Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
        Body = body
    })

    if not response or not response.Body then
        return false, "no_response"
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if not success then
        return false, "invalid_response"
    end

    if data.valid then
        return true, data
    else
        return false, data.reason or "invalid"
    end
end

-- Buat Window Awal (Login)
local Window = Rayfield:CreateWindow({
    Name = "Key Login",
    LoadingTitle = "Botresi Key",
    LoadingSubtitle = "Login menggunakan key",
    ConfigurationSaving = {Enabled = false}
})

-- Tab Auth
local AuthTab = Window:CreateTab("Auth", 0)
AuthTab:CreateSection("Login Key")

-- Input Key (dibuat lebih lebar)
local inputKey = AuthTab:CreateInput({
    Name = "Masukkan Key",
    PlaceholderText = "paste key di sini",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) end
})
inputKey.Input.Size = UDim2.new(0, 300, 0, 40) -- perlebar kolom input

-- Status Label
local statusLabel = AuthTab:CreateLabel("Status: idle")

-- Tombol Login
AuthTab:CreateButton({
    Name = "Login dengan Key",
    Callback = function()
        local key = inputKey.CurrentValue
        if not key or key == "" then
            statusLabel:Set("Status: Masukkan key terlebih dahulu")
            return
        end

        statusLabel:Set("Status: Memeriksa key...")
        local ok, res = validateKey(key)
        if ok then
            -- Hapus semua tab lama (Auth)
            for _, tab in pairs(Window.Tabs) do
                tab.TabFrame:Destroy()
            end

            -- Ubah Title Window & tambahkan Duration Key
            Window:SetTitle("Botresi Hub")
            local duration = tostring(res.duration or "Unknown")
            local durationLabel = Window:CreateLabel("Key Duration: " .. duration)
            durationLabel.Label.Position = UDim2.new(0.5, -100, 0, 10) -- tampil di tengah header
            durationLabel.Label.Size = UDim2.new(0, 200, 0, 20)
            durationLabel.Label.TextScaled = true

            -- Tab Main
            local MainTab = Window:CreateTab("Main", 4483362458)
            MainTab:CreateLabel("✔ Login sukses, fitur terbuka")

            -- Tab Settings
            local SettingsTab = Window:CreateTab("Settings", 4483362458)

            -- Theme Options
            local Themes = {
                ["Default"] = "Default",
                ["Amber Glow"] = "AmberGlow",
                ["Amethyst"] = "Amethyst",
                ["Bloom"] = "Bloom",
                ["Dark Blue"] = "DarkBlue",
                ["Green"] = "Green",
                ["Light"] = "Light",
                ["Ocean"] = "Ocean",
                ["Serenity"] = "Serenity"
            }

            SettingsTab:CreateDropdown({
                Name = "Theme",
                Options = {"Default","Amber Glow","Amethyst","Bloom","Dark Blue","Green","Light","Ocean","Serenity"},
                CurrentOption = "Default",
                Flag = "ThemeDropdown",
                Callback = function(option)
                    local themeId = Themes[option]
                    if themeId then
                        Window:ModifyTheme(themeId)
                        Rayfield:Notify({
                            Title = "Theme Changed",
                            Content = "Now using theme: " .. option,
                            Duration = 5,
                            Image = 4483362458
                        })
                    end
                end
            })

            -- Hide / Show / Check / Destroy UI
            SettingsTab:CreateButton({
                Name = "Hide UI",
                Callback = function()
                    Rayfield:SetVisibility(false)
                    Rayfield:Notify({Title="UI Hidden",Content="Rayfield interface hidden",Duration=3})
                end
            })

            SettingsTab:CreateButton({
                Name = "Show UI",
                Callback = function()
                    Rayfield:SetVisibility(true)
                    Rayfield:Notify({Title="UI Shown",Content="Rayfield interface visible",Duration=3})
                end
            })

            SettingsTab:CreateButton({
                Name = "Check UI Visible?",
                Callback = function()
                    local visible = Rayfield:IsVisible()
                    Rayfield:Notify({
                        Title = "UI Visibility",
                        Content = visible and "UI is visible" or "UI is hidden",
                        Duration = 3
                    })
                end
            })

            SettingsTab:CreateButton({
                Name = "Destroy UI",
                Callback = function() Rayfield:Destroy() end
            })

            -- Notify Sukses
            Rayfield:Notify({
                Title = "Login Sukses",
                Content = "Key valid! Durasi: " .. duration,
                Duration = 6,
                Image = 4483362458
            })
        else
            statusLabel:Set("Status: ❌ Key tidak valid (" .. tostring(res) .. ")")
            Rayfield:Notify({
                Title = "Login Gagal",
                Content = "Key salah atau expired",
                Duration = 5,
                Image = 4483362458
            })
        end
    end
})

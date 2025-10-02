-- // Services
local HttpService = game:GetService("HttpService")

-- // Load Rayfield (official)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // ===== HTTP validate (executor request) =====
local function validateKey(key)
    local endpoint = "https://botresi.xyz/keygen/api/validate.php" -- ganti sesuai API kamu
    local body = "key=" .. key

    local request = (http_request or request or syn and syn.request)
    if not request then
        return false, "executor_no_http"
    end

    local resp
    local ok, err = pcall(function()
        resp = request({
            Url = endpoint,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded",
            },
            Body = body
        })
    end)
    if not ok or not resp or not resp.Body then
        return false, "no_response"
    end

    local data
    local okDecode, errDecode = pcall(function()
        data = HttpService:JSONDecode(resp.Body)
    end)
    if not okDecode or type(data) ~= "table" then
        return false, "invalid_response"
    end

    if data.valid then
        return true, data
    else
        return false, data.reason or "invalid"
    end
end

-- // ====== Builder: Main UI (setelah login) ======
local function BuildMainUI(durationStr)
    -- Hancurkan UI lama, buat ulang window baru yang “bersih”
    Rayfield:Destroy()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "Botresi Hub",
        LoadingTitle = "Welcome",
        LoadingSubtitle = "Authenticated",
        Theme = "Default",
        ShowText = "Rayfield",
        ToggleUIKeybind = "K",
    })

    -- ==== Main Tab
    local MainTab = Window:CreateTab("Main", 4483362458)
    -- Label durasi key di paling atas konten Main tab
    MainTab:CreateLabel("🔑 Key Duration: " .. tostring(durationStr))
    MainTab:CreateLabel("✔ Login sukses, fitur terbuka")

    Rayfield:Notify({
        Title = "Login Sukses",
        Content = "Key valid! Durasi: " .. tostring(durationStr),
        Duration = 6,
        Image = 4483362458
    })

    -- ==== Settings Tab (Theme + Visibility Controls)
    local SettingsTab = Window:CreateTab("Settings", 4483362458)

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
                -- panggil API Rayfield ubah tema
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

    SettingsTab:CreateButton({
        Name = "Hide UI",
        Callback = function()
            Rayfield:SetVisibility(false)
            Rayfield:Notify({ Title="UI Hidden", Content="Rayfield hidden", Duration=3, Image=4483362458 })
        end
    })

    SettingsTab:CreateButton({
        Name = "Show UI",
        Callback = function()
            Rayfield:SetVisibility(true)
            Rayfield:Notify({ Title="UI Shown", Content="Rayfield visible", Duration=3, Image=4483362458 })
        end
    })

    SettingsTab:CreateButton({
        Name = "Check UI Visible?",
        Callback = function()
            local visible = Rayfield:IsVisible()
            Rayfield:Notify({
                Title = "UI Visibility",
                Content = visible and "UI is currently visible" or "UI is currently hidden",
                Duration = 3,
                Image = 4483362458
            })
        end
    })

    SettingsTab:CreateButton({
        Name = "Destroy UI",
        Callback = function() Rayfield:Destroy() end
    })
end

-- // ====== Builder: Auth UI (awal) ======
local function BuildAuthUI()
    local Window = Rayfield:CreateWindow({
        Name = "Key Login",
        LoadingTitle = "Botresi Key",
        LoadingSubtitle = "Login menggunakan key",
        ConfigurationSaving = { Enabled = false },
        Theme = "Default",
        ShowText = "Rayfield",
        ToggleUIKeybind = "K",
    })

    local AuthTab = Window:CreateTab("Auth", 0)
    AuthTab:CreateSection("Login Key")

    local inputValue = ""

    -- Input Key
    local inputKey = AuthTab:CreateInput({
        Name = "Masukkan Key",
        PlaceholderText = "paste key di sini",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            inputValue = text or ""
        end
    })

    -- Perlebar kolom input (aman pakai pcall jika struktur berubah)
    pcall(function()
        -- beberapa build Rayfield punya .Input/.TextBox; kita coba keduanya
        if inputKey and inputKey.Input then
            inputKey.Input.Size = UDim2.new(0, 320, 0, 40)
        elseif inputKey and inputKey.TextBox then
            inputKey.TextBox.Size = UDim2.new(0, 320, 0, 40)
        end
    end)

    local statusLabel = AuthTab:CreateLabel("Status: idle")

    -- Tombol Login
    AuthTab:CreateButton({
        Name = "Login dengan Key",
        Callback = function()
            if inputValue == "" then
                statusLabel:Set("Status: Masukkan key terlebih dahulu")
                return
            end

            statusLabel:Set("Status: Memeriksa key...")
            local ok, res = validateKey(inputValue)
            if ok then
                local duration = res.duration or res.expires_in or res.expires_in_seconds or "Unknown"
                -- Rebuild UI (relog) agar tab login hilang
                BuildMainUI(duration)
            else
                statusLabel:Set("Status: ❌ Key tidak valid (" .. tostring(res) .. ")")
                Rayfield:Notify({
                    Title = "Login Gagal",
                    Content = "Key salah/expired. ("..tostring(res)..")",
                    Duration = 5,
                    Image = 4483362458
                })
            end
        end
    })
end

-- // Start dari Auth UI
BuildAuthUI()

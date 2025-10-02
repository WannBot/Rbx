-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window Login
local Window = Rayfield:CreateWindow({
    Name = "Key Login",
    LoadingTitle = "Botresi Key",
    LoadingSubtitle = "Login menggunakan key",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Tab Auth
local AuthTab = Window:CreateTab("Auth", 0)
AuthTab:CreateSection("Login Key")

-- Input Key
local inputKey = AuthTab:CreateInput({
    Name = "Masukkan Key",
    PlaceholderText = "paste key di sini",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) end
})

-- Status Label
local statusLabel = AuthTab:CreateLabel("Status: idle")

-- Fungsi validasi key
local function validateKey(key)
    local endpoint = "https://botresi.xyz/keygen/api/validate.php"
    local body = "key=" .. key

    local requestFunc = (http_request or request or syn and syn.request)

    if not requestFunc then
        return false, "Executor tidak support HTTP request"
    end

    local response = requestFunc({
        Url = endpoint,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        },
        Body = body
    })

    if not response or not response.Body then
        return false, "no_response"
    end

    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response.Body)
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
            statusLabel:Set("Status: ✅ Key valid — " .. tostring(res.duration or ""))

            -- Unlock Tab baru setelah login sukses
            local MainTab = Window:CreateTab("Main", 4483362458)
            MainTab:CreateLabel("Selamat datang! Fitur aktif ✔")

            Rayfield:Notify({
                Title = "Login Sukses",
                Content = "Key valid! Fitur sudah terbuka",
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

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
    local endpoint = "https://botresi.xyz/keygen/api/validate.php" -- API kamu
    local body = "key=" .. HttpService:UrlEncode(key)
    local headers = { ["Content-Type"] = "application/x-www-form-urlencoded" }

    local ok, resp = pcall(function()
        return HttpService:PostAsync(endpoint, body, Enum.HttpContentType.ApplicationUrlEncoded, false, headers)
    end)

    if not ok then
        return false, "http_error: " .. tostring(resp)
    end

    local decodeOk, data = pcall(function()
        return HttpService:JSONDecode(resp) end)

    if not decodeOk then
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

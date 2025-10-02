local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Player = game:GetService("Players").LocalPlayer

-- 🔑 Validasi key ke API
local function validateKey(key)
    local requestFunc = (http_request or request or syn and syn.request)
    if not requestFunc then
        return false, "Executor tidak support http_request"
    end

    local response = requestFunc({
        Url = "https://botresi.xyz/keygen/api/validate.php",
        Method = "POST",
        Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
        Body = "key=" .. key
    })

    if not response or not response.Body then return false, "no_response" end

    local ok, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
    if not ok then return false, "invalid_response" end

    if data.valid then
        return true, data
    else
        return false, data.reason or "invalid"
    end
end

------------------------------------------------------
-- UI LOGIN
------------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Botresi Hub",
    LoadingTitle = "Key Login",
    LoadingSubtitle = "Gunakan key untuk masuk",
    Theme = "Default"
})

local AuthTab = Window:CreateTab("Auth 🔑", 0)
AuthTab:CreateSection("Login Key")

local inputKeyValue = ""
local KeyInput = AuthTab:CreateInput({
    Name = "Masukkan Key",
    PlaceholderText = "Paste key di sini",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        inputKeyValue = text
    end
})

local Status = AuthTab:CreateLabel("Status: idle")

AuthTab:CreateButton({
    Name = "Login",
    Callback = function()
        if inputKeyValue == "" then
            Status:Set("Status: Masukkan key dulu")
            return
        end

        Status:Set("Status: Memeriksa key...")
        local ok, res = validateKey(inputKeyValue)

        if ok then
            Status:Set("Status: Key valid ✔")

            -- 🔥 Hapus/disable Tab Auth
            AuthTab:Destroy()

            ------------------------------------------------------
            -- Tab Main
            ------------------------------------------------------
            local MainTab = Window:CreateTab("Main", 0)
            MainTab:CreateSection("Fitur Utama")
            MainTab:CreateLabel("Selamat Datang, " .. Player.Name)

            ------------------------------------------------------
            -- Tab Info
            ------------------------------------------------------
            local InfoTab = Window:CreateTab("Info ℹ️", 0)
            InfoTab:CreateSection("Key Information")

            -- Format expired date
            local expiredDate = res.expired_date or "Unknown"
            InfoTab:CreateLabel("Expired: " .. expiredDate)

        else
            Status:Set("Status: Key salah (" .. tostring(res) .. ")")
        end
    end
})

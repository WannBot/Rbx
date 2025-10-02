local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local HttpService = game:GetService("HttpService")
local Player = game:GetService("Players").LocalPlayer

-- 🔄 Format durasi key
local function formatDuration(seconds)
    local d = math.floor(seconds / 86400)
    local h = math.floor(seconds % 86400 / 3600)
    local m = math.floor(seconds % 3600 / 60)
    local s = math.floor(seconds % 60)
    return string.format("%dd %dh %dm %ds", d, h, m, s)
end

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
local LoginWindow = Rayfield:CreateWindow({
    Name = "Botresi Hub",
    LoadingTitle = "Key Login",
    LoadingSubtitle = "Gunakan key untuk masuk",
    Theme = "Default"
})

local Tab = LoginWindow:CreateTab("Auth 🔑", 0)
Tab:CreateSection("Login Key")

local inputKeyValue = ""
local KeyInput = Tab:CreateInput({
    Name = "Masukkan Key",
    PlaceholderText = "Paste key di sini",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        inputKeyValue = text
    end
})

local Status = Tab:CreateLabel("Status: idle")

Tab:CreateButton({
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

            task.wait(1)
            Rayfield:Destroy()
            task.wait(1)

            ------------------------------------------------------
            -- UI MAIN setelah login
            ------------------------------------------------------
            local MainWindow = Rayfield:CreateWindow({
                Name = "Botresi Hub",
                LoadingTitle = "Botresi Hub",
                LoadingSubtitle = "Selamat Datang",
                Theme = "Default"
            })

            local MainTab = MainWindow:CreateTab("Main", 0)
            MainTab:CreateSection("Fitur Utama")
            MainTab:CreateLabel("Selamat Datang, " .. Player.Name)

            -- ⏱ Durasi Key di header kanan
            task.wait(1)
            local topbar = game:GetService("CoreGui"):FindFirstChild("Rayfield"):FindFirstChild("Topbar", true)
            if topbar then
                local durationLabel = Instance.new("TextLabel")
                durationLabel.Name = "DurationLabel"
                durationLabel.Size = UDim2.new(0, 250, 1, 0)
                durationLabel.Position = UDim2.new(1, -260, 0, 0)
                durationLabel.BackgroundTransparency = 1
                durationLabel.TextColor3 = Color3.fromRGB(255,255,255)
                durationLabel.TextStrokeTransparency = 0.5
                durationLabel.Font = Enum.Font.GothamBold
                durationLabel.TextScaled = true
                durationLabel.TextXAlignment = Enum.TextXAlignment.Right
                durationLabel.Text = "Checking..."
                durationLabel.Parent = topbar

                local totalSeconds = res.expires_in or 3600

                task.spawn(function()
                    while totalSeconds > 0 and durationLabel.Parent do
                        durationLabel.Text = "Key Duration: " .. formatDuration(totalSeconds)
                        task.wait(1)
                        totalSeconds -= 1
                    end
                    if durationLabel.Parent then
                        durationLabel.Text = "Key Expired"
                        Player:Kick("Key Expired. Silakan login ulang.")
                    end
                end)
            end
        else
            Status:Set("Status: Key salah (" .. tostring(res) .. ")")
        end
    end
})

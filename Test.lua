local function loadRayfield()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end

local Rayfield = loadRayfield()
local HttpService = game:GetService("HttpService")
local Player = game:GetService("Players").LocalPlayer

-- ambil humanoid
local function getHumanoid()
    local char = Player.Character or Player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

-- validasi key API
local function validateKey(key)
    local requestFunc = (http_request or request or syn and syn.request)
    if not requestFunc then return false, "Executor tidak support http_request" end

    local response = requestFunc({
        Url = "https://botresi.xyz/keygen/api/validate.php",
        Method = "POST",
        Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
        Body = "key=" .. key
    })

    if not response or not response.Body then return false, "no_response" end
    local ok, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
    if not ok then return false, "invalid_response" end
    if data.valid then return true, data else return false, data.reason or "invalid" end
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

local AuthTab = LoginWindow:CreateTab("Auth 🔑", 0)
AuthTab:CreateSection("Login Key")

local inputKeyValue = ""
AuthTab:CreateInput({
    Name = "Masukkan Key",
    PlaceholderText = "Paste key di sini",
    RemoveTextAfterFocusLost = false,
    Callback = function(text) inputKeyValue = text end
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
            task.wait(1)

            Rayfield:Destroy()
            task.wait(1)
            Rayfield = loadRayfield()

            ------------------------------------------------------
            -- UI setelah login
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
            -- di dalam MainTab setelah login
local Humanoid = getHumanoid()
local GodModeEnabled = false
local heartbeatConn, healthConn = nil, nil

MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(state)
        GodModeEnabled = state
        if state then
            ------------------------------------------------------
            -- Aktifkan God Mode
            ------------------------------------------------------
            local char = Player.Character or Player.CharacterAdded:Wait()
            Humanoid = char:WaitForChild("Humanoid")

            -- Max Health
            Humanoid.MaxHealth = math.huge
            Humanoid.Health = Humanoid.MaxHealth

            -- ForceField (tidak terlihat)
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char

            -- Heartbeat check
            heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
                if Humanoid then
                    Humanoid.MaxHealth = math.huge
                    Humanoid.Health = Humanoid.MaxHealth
                    Humanoid.PlatformStand = false -- anti ragdoll jatuh
                end
            end)

            -- HealthChanged listener
            healthConn = Humanoid.HealthChanged:Connect(function()
                if Humanoid and GodModeEnabled then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)

            -- Tool damage / touched parts
            char.DescendantAdded:Connect(function(obj)
                if GodModeEnabled and obj:IsA("TouchTransmitter") then
                    local part = obj.Parent
                    if part and part:IsA("BasePart") then
                        part.CanTouch = false
                    end
                end
            end)

            -- Terrain anti water/lava/fire
            workspace.Terrain.ChildAdded:Connect(function(child)
                if GodModeEnabled and (child.Name:lower():find("lava") or child.Name:lower():find("fire") or child.Name:lower():find("water")) then
                    child:Destroy()
                end
            end)

        else
            ------------------------------------------------------
            -- Nonaktifkan God Mode
            ------------------------------------------------------
            if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end
            if healthConn then healthConn:Disconnect() healthConn = nil end

            local char = Player.Character
            if char then
                local ff = char:FindFirstChildOfClass("ForceField")
                if ff then ff:Destroy() end
                if Humanoid then
                    Humanoid.MaxHealth = 100
                    Humanoid.Health = 100
                end
            end
        end
    end
})

            ------------------------------------------------------
            -- 🔥 Fitur Speed (Dropdown berisi On/Off + Input)
            ------------------------------------------------------
            local Humanoid = getHumanoid()
            local speedEnabled = false
            local speedValue = 16

            local SpeedSection = MainTab:CreateSection("Speed")

            MainTab:CreateDropdown({
                Name = "Speed Mode",
                Options = {"Off", "On"},
                CurrentOption = {"Off"},
                Callback = function(option)
                    if option[1] == "On" then
                        speedEnabled = true
                        Humanoid.WalkSpeed = speedValue
                    else
                        speedEnabled = false
                        Humanoid.WalkSpeed = 16
                    end
                end
            })

            -- Input angka di bawah dropdown Speed
            MainTab:CreateInput({
                Name = "Atur Speed",
                PlaceholderText = tostring(speedValue),
                RemoveTextAfterFocusLost = false,
                Callback = function(text)
                    local num = tonumber(text)
                    if num then
                        speedValue = math.clamp(num, 16, 200)
                        if speedEnabled then
                            Humanoid.WalkSpeed = speedValue
                        end
                    end
                end
            })

        else
            Status:Set("Status: Key salah (" .. tostring(res) .. ")")
        end
    end
})

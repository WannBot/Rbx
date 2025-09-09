-- LocalScript / executor
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Strong Forcefield",
    LoadingTitle = "Damage Scaling (No Lock)",
    LoadingSubtitle = "Invisible FF • Anti-Fall",
    KeySystem = false,
})
local Tab = Window:CreateTab("Forcefield", 4483362458)

-- ===== State =====
local ffEnabled = false
local passThroughPercent = 0 -- 0..100 (0% = kebal)
local currentFF
local hcConn -- HealthChanged connection
local guarding = false -- anti re-entrancy saat kita set Health sendiri

-- ===== Util =====
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid")
end

local function makeInvisibleFF(char)
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = char
    currentFF = ff
end

local function removeFF()
    if currentFF and currentFF.Parent then currentFF:Destroy() end
    currentFF = nil
end

-- Disable fall-related death states
local function enableAntiFall(humanoid, on)
    -- FallingDown & Dead kita nonaktifkan agar jatuh tinggi tidak instant KO
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, not on and true or false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not on and true or false)
end

-- Hook HealthChanged untuk scaling damage
local function attachDamageScaler(humanoid)
    if hcConn then hcConn:Disconnect(); hcConn = nil end
    local lastHealth = humanoid.Health

    hcConn = humanoid.HealthChanged:Connect(function(newHP)
        if guarding then return end
        if not ffEnabled then
            lastHealth = newHP
            return
        end

        -- jika Health turun → terapkan damage scaling
        if newHP < lastHealth then
            local damage = lastHealth - newHP
            -- berapa persen damage yang DIIZINKAN masuk (0..100)
            local allowed = damage * (passThroughPercent / 100)
            local targetHP = math.max(0, lastHealth - allowed)

            if math.abs(targetHP - newHP) > 0.001 then
                guarding = true
                humanoid.Health = targetHP
                guarding = false
                lastHealth = targetHP
                return
            end
        end

        -- update baseline
        lastHealth = newHP
    end)
end

local function enableFF()
    local char, humanoid = getHumanoid()
    makeInvisibleFF(char)
    enableAntiFall(humanoid, true)       -- tetap anti-fall
    attachDamageScaler(humanoid)         -- pasang scaler damage
end

local function disableFF()
    removeFF()
    if hcConn then hcConn:Disconnect(); hcConn = nil end
    local char, humanoid = getHumanoid()
    enableAntiFall(humanoid, false)      -- kembalikan state default
end

-- ===== UI =====
Tab:CreateToggle({
    Name = "Enable Strong Forcefield",
    CurrentValue = false,
    Callback = function(v)
        ffEnabled = v
        if ffEnabled then enableFF() else disableFF() end
    end
})

Tab:CreateSlider({
    Name = "Damage Pass-Through %",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 0,
    Callback = function(val)
        passThroughPercent = val
        -- Tidak perlu reconnect; scaler langsung pakai nilai baru
    end
})

-- Respawn safety
player.CharacterAdded:Connect(function(_)
    if ffEnabled then
        -- beri sedikit waktu agar Humanoid siap
        task.defer(enableFF)
    end
end)

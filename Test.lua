local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Coin Debug Tools",
    LoadingTitle = "Extra Coin System",
    LoadingSubtitle = "Multiplier & Auto Increase",
    KeySystem = false,
})

local Tab = Window:CreateTab("Coins", 4483362458)

-- ==== State ====
local coinMultiplier = 1.0
local autoCoin = false
local coinFolder
local coinVal
local hbConn

-- cari folder leaderstats / coins
local function findCoin()
    if player:FindFirstChild("leaderstats") then
        local ls = player.leaderstats
        for _, v in pairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then
                if v.Name:lower():find("coin") or v.Name:lower():find("money") then
                    return v
                end
            end
        end
    end
    return nil
end

-- tambah koin manual
local function addCoins(amount)
    coinVal = coinVal or findCoin()
    if coinVal then
        coinVal.Value = coinVal.Value + math.floor(amount * coinMultiplier)
        print("[Coin Debug] +"..math.floor(amount * coinMultiplier).." (x"..coinMultiplier..")")
    else
        warn("[Coin Debug] Coin value tidak ditemukan!")
    end
end

-- UI: multiplier slider
Tab:CreateSlider({
    Name = "Coin Multiplier",
    Range = {1, 10},  -- 1x sampai 10x (100% - 1000%)
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Callback = function(val)
        coinMultiplier = val
    end
})

-- UI: button tambah 100 coin
Tab:CreateButton({
    Name = "Tambah 100 Coin (pakai multiplier)",
    Callback = function()
        addCoins(100)
    end
})

-- UI: auto increase toggle
Tab:CreateToggle({
    Name = "Auto Increase Coins",
    CurrentValue = false,
    Callback = function(v)
        autoCoin = v
        if hbConn then hbConn:Disconnect() hbConn = nil end
        if autoCoin then
            coinVal = findCoin()
            if not coinVal then warn("Coin tidak ditemukan!") return end
            hbConn = RunService.Heartbeat:Connect(function()
                addCoins(1) -- tiap frame nambah 1 * multiplier
            end)
        end
    end
})

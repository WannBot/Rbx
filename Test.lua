-- Auto Collect Fruits (Client-side only)
-- Rayfield UI: toggle per buah + slider lama hold + slider delay antar buah

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Daftar nama buah
local FRUIT_TYPES = {"Coconut", "Beanstalk", "Berry", "Sugar Apple"}

-- Status auto per buah
local autoState = {}
local holdTimes = {}   -- lama hold per buah
local delays    = {}   -- jeda antar buah per buah
for _,f in ipairs(FRUIT_TYPES) do
    autoState[f] = false
    holdTimes[f] = 3      -- default 3 detik
    delays[f]    = 1      -- default 1 detik
end

-- Cari buah sesuai jenis
local function getFruitsByType(fruitType)
    local list = {}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(fruitType)) then
            if obj:IsA("BasePart") then
                table.insert(list, obj)
            elseif obj:IsA("Model") and obj.PrimaryPart then
                table.insert(list, obj.PrimaryPart)
            end
        end
    end
    return list
end

-- Teleport ke posisi
local function teleportTo(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

-- Fungsi Auto Collect
local function autoCollect(fruitType)
    task.spawn(function()
        while autoState[fruitType] do
            local fruits = getFruitsByType(fruitType)
            for _,fruit in ipairs(fruits) do
                if not autoState[fruitType] then break end -- stop jika toggle dimatikan

                teleportTo(fruit.Position)
                task.wait(0.5)

                local prompt = fruit.Parent:FindFirstChildOfClass("ProximityPrompt") or fruit:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    -- hold sesuai slider
                    fireproximityprompt(prompt, 1) -- mulai hold
                    task.wait(holdTimes[fruitType])
                    fireproximityprompt(prompt, 0) -- lepas hold
                end

                -- jeda antar buah (bisa diatur slider)
                local t = delays[fruitType] or 1
                local timer = 0
                while autoState[fruitType] and timer < t do
                    task.wait(0.1)
                    timer += 0.1
                end
            end
            task.wait(1) -- jeda scan ulang
        end
    end)
end

-- ====== Rayfield UI ======
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "WS Auto Collect Fruits",
    Icon = 0,
    LoadingTitle = "Rayfield",
    LoadingSubtitle = "Fruit Tools",
    Theme = "Default",
    ToggleUIKeybind = "K",
    KeySystem = false,
})

local Tab = Window:CreateTab("Harvest", "leaf")

for _,fruit in ipairs(FRUIT_TYPES) do
    Tab:CreateToggle({
        Name = "Auto Collect "..fruit,
        CurrentValue = false,
        Flag = "Auto"..fruit,
        Callback = function(val)
            autoState[fruit] = val
            if val then
                autoCollect(fruit)
            end
        end
    })

    Tab:CreateSlider({
        Name = "Hold "..fruit.." (detik)",
        Range = {1, 5},
        Increment = 0.5,
        CurrentValue = holdTimes[fruit],
        Flag = "Hold"..fruit,
        Callback = function(val)
            holdTimes[fruit] = val
        end
    })

    Tab:CreateSlider({
        Name = "Delay "..fruit.." (detik)",
        Range = {0.5, 3},
        Increment = 0.1,
        CurrentValue = delays[fruit],
        Flag = "Delay"..fruit,
        Callback = function(val)
            delays[fruit] = val
        end
    })
end

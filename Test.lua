-- Auto Collect Fruits (Client-side only)
-- Gunakan dengan loader kamu (mis. loadstring)
-- Rayfield UI + toggle per buah

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Daftar nama buah yang mau dicari
local FRUIT_TYPES = {"Coconut", "Beanstalk", "Berry", "Sugar Apple"}

-- Auto state per buah
local autoState = {}
for _,f in ipairs(FRUIT_TYPES) do autoState[f] = false end

-- Ambil semua objek buah sesuai nama
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

-- Fungsi teleport ke posisi
local function teleportTo(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

-- Loop auto collect
RunService.Heartbeat:Connect(function()
    for fruitType,on in pairs(autoState) do
        if on then
            local fruits = getFruitsByType(fruitType)
            for _,fruit in ipairs(fruits) do
                teleportTo(fruit.Position)
                task.wait(0.5)
                -- kalau ada prompt
                local prompt = fruit.Parent:FindFirstChildOfClass("ProximityPrompt") or fruit:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
                task.wait(1)
            end
        end
    end
end)

-- ====== RAYFIELD UI ======
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
        end
    })
end

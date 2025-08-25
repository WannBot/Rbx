-- Auto Collect Fruits (Client-side only)
-- Cari ProximityPrompt "Collect", teleport ke Adornee/Parent, lalu hold (1–5 dtk).
-- UI: toggle per buah + slider Hold + slider Delay.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Jenis buah yang dicari (ubah sesuai game kamu)
local FRUIT_TYPES = {"Coconut", "Beanstalk", "Berry", "Sugar Apple"}
-- State per buah
local autoState, holdTimes, delays = {}, {}, {}
for _,f in ipairs(FRUIT_TYPES) do
    autoState[f] = false
    holdTimes[f] = 3    -- detik
    delays[f]    = 1    -- detik
end

-- ===== util =====
local function getChar()
    local c = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return c, c:WaitForChild("HumanoidRootPart")
end

local function tpNear(pos)
    local _,hrp = getChar()
    hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
end

local function strf(s) return string.lower(tostring(s or "")) end

-- Ambil semua ProximityPrompt yang “terkait” buahType
local function findPromptsForFruit(fruitType)
    local res, key = {}, strf(fruitType)
    for _,pp in ipairs(workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            local par = pp.Parent
            local match =
                strf(pp.ActionText):find("collect", 1, true)                -- tombol Collect
                and (
                    strf(pp.ObjectText):find(key, 1, true)                    -- ObjectText mengandung buah
                    or strf(par and par.Name):find(key, 1, true)              -- nama parent mengandung buah
                    or strf(par and par.Parent and par.Parent.Name):find(key, 1, true) -- nama model di atasnya
                )

            if match then table.insert(res, pp) end
        end
    end
    return res
end

-- Pos dunia untuk prompt (pakai Adornee jika ada)
local function promptWorldPos(pp)
    local adornee = pp.Adornee
    if adornee then
        if adornee:IsA("BasePart") then return adornee.Position end
        if adornee:IsA("Attachment") and adornee.Parent and adornee.Parent:IsA("BasePart") then
            return adornee.WorldPosition
        end
    end
    -- fallback: parent part
    local par = pp.Parent
    if par:IsA("BasePart") then return par.Position end
    if par:IsA("Attachment") and par.Parent and par.Parent:IsA("BasePart") then
        return par.WorldPosition
    end
    -- fallback terakhir: posisi player (biar gak error)
    local _,hrp = getChar()
    return hrp.Position
end

-- Cek jarak aktif
local function waitWithinActivation(pp, timeout)
    timeout = timeout or 3
    local t0 = os.clock()
    while os.clock() - t0 < timeout do
        local _,hrp = getChar()
        local p = promptWorldPos(pp)
        local dist = (hrp.Position - p).Magnitude
        if dist <= (pp.MaxActivationDistance + 0.25) then return true end
        -- geser sedikit mendekat
        hrp.CFrame = CFrame.new(p + Vector3.new(0, 2.5, 0))
        task.wait(0.05)
    end
    return false
end

-- Trigger prompt dengan hold t detik (pakai fireproximityprompt; fallback ke InputHoldBegin/End)
local function triggerPrompt(pp, holdSec)
    holdSec = math.max(0.1, tonumber(holdSec) or 1)
    -- beberapa executor pakai fireproximityprompt(prompt, pressTimes)
    local ok = pcall(function() fireproximityprompt(pp) end)
    if ok then
        -- jika engine sudah meng-handle holdDuration internal, kita tambahkan wait secukupnya
        task.wait(holdSec)
        return
    end
    -- fallback: gunakan API internal prompt (jika tersedia)
    if pp.InputHoldBegin and pp.InputHoldEnd then
        pcall(function() pp:InputHoldBegin() end)
        task.wait(holdSec)
        pcall(function() pp:InputHoldEnd() end)
    else
        -- fallback terakhir: coba panggil dua argumen (mulai/selesai)
        pcall(function() fireproximityprompt(pp, 1) end)
        task.wait(holdSec)
        pcall(function() fireproximityprompt(pp, 0) end)
    end
end

-- Loop per buah
local function autoCollectFruitLoop(fruitType)
    task.spawn(function()
        while autoState[fruitType] do
            local prompts = findPromptsForFruit(fruitType)

            -- urutkan dari yang terdekat biar efisien
            local _,hrp = getChar()
            table.sort(prompts, function(a,b)
                local pa = promptWorldPos(a); local pb = promptWorldPos(b)
                return (hrp.Position - pa).Magnitude < (hrp.Position - pb).Magnitude
            end)

            for _,pp in ipairs(prompts) do
                if not autoState[fruitType] then break end

                local targetPos = promptWorldPos(pp)
                tpNear(targetPos)
                if waitWithinActivation(pp, 3) then
                    triggerPrompt(pp, holdTimes[fruitType])
                end

                -- jeda antar buah; berhenti segera jika toggle dimatikan
                local delayT = math.max(0.1, delays[fruitType] or 1)
                local t0 = os.clock()
                while autoState[fruitType] and (os.clock() - t0) < delayT do task.wait(0.05) end
            end

            -- scan ulang tiap 1 detik bila masih ON
            local t0 = os.clock()
            while autoState[fruitType] and (os.clock() - t0) < 1 do task.wait(0.05) end
        end
    end)
end

-- ===== Rayfield UI =====
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
        Callback = function(on)
            autoState[fruit] = on
            if on then autoCollectFruitLoop(fruit) end
        end
    })
    Tab:CreateSlider({
        Name = "Hold "..fruit.." (detik)",
        Range = {1, 5},
        Increment = 0.5,
        CurrentValue = holdTimes[fruit],
        Flag = "Hold"..fruit,
        Callback = function(v) holdTimes[fruit] = tonumber(v) or holdTimes[fruit] end
    })
    Tab:CreateSlider({
        Name = "Delay "..fruit.." (detik)",
        Range = {0.1, 3},
        Increment = 0.1,
        CurrentValue = delays[fruit],
        Flag = "Delay"..fruit,
        Callback = function(v) delays[fruit] = tonumber(v) or delays[fruit] end
    })
end

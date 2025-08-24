-- WS Teleporter Only + Rayfield
-- Fitur: Auto-scan checkpoint, Manual TP, AutoLoop (delay), Respawn 3s di titik terakhir, Start dari titik terakhir/saat ini
-- Tidak ada fitur lain.

-- ===== Konfigurasi ringan =====
local OFFSET_Y      = 3        -- angkat sedikit saat teleport
local DEFAULT_DELAY = 2        -- detik (untuk jeda antar TP pada auto-loop)

-- ===== Services =====
local Players           = game:GetService("Players")
local RS                = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer       = Players.LocalPlayer

-- ===== Rayfield =====
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "WS Teleporter",
    Icon = 0,
    LoadingTitle = "Rayfield",
    LoadingSubtitle = "Teleporter Only",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "WS_TeleporterOnly",
        FileName = "Config"
    },
    KeySystem = false,
})

-- ===== Util =====
local function getCharHum()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local NAME_HINTS = {"checkpoint", "FINISH"}

local function getWorldPosFromInstance(inst)
    if inst:IsA("BasePart") then
        return inst.Position
    elseif inst:IsA("Model") then
        if inst.PrimaryPart then
            return inst.PrimaryPart.Position
        end
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok and typeof(cf) == "CFrame" then return cf.Position end
    end
    return nil
end

local function looksLikeCheckpoint(inst)
    local name = string.lower(inst.Name or "")
    for _,hint in ipairs(NAME_HINTS) do
        if string.find(name, hint, 1, true) then return true end
    end
    local okAttr = pcall(function() return inst:GetAttribute("Checkpoint") end)
    if okAttr and inst:GetAttribute("Checkpoint") == true then return true end
    local bv = inst:FindFirstChild("Checkpoint")
    if bv and (bv:IsA("BoolValue") or bv:IsA("NumberValue") or bv:IsA("IntValue")) then
        return (bv.Value == true) or (tonumber(bv.Value) ~= nil)
    end
    return false
end

local function readOrder(inst)
    local okAttr, ord = pcall(function() return inst:GetAttribute("Order") end)
    if okAttr and tonumber(ord) then return tonumber(ord) end
    local iv = inst:FindFirstChild("Order")
    if iv and (iv:IsA("NumberValue") or iv:IsA("IntValue")) and tonumber(iv.Value) then
        return tonumber(iv.Value)
    end
    return nil
end

local function orderByNearest(points, startPos)
    if #points <= 1 then return points end
    local used, route = {}, {}
    local best, idx = math.huge, 1
    for i,p in ipairs(points) do
        local d = (p - startPos).Magnitude
        if d < best then best, idx = d, i end
    end
    while #route < #points do
        table.insert(route, points[idx]); used[idx] = true
        local nd, ni = math.huge, nil
        for i,p in ipairs(points) do
            if not used[i] then
                local d = (p - route[#route]).Magnitude
                if d < nd then nd, ni = d, i end
            end
        end
        if not ni then break end
        idx = ni
    end
    return route
end

local function dedupePoints(vectors, minDist)
    minDist = minDist or 5
    local out = {}
    for _,v in ipairs(vectors) do
        local dup = false
        for _,o in ipairs(out) do
            if (o - v).Magnitude < minDist then dup = true; break end
        end
        if not dup then table.insert(out, v) end
    end
    return out
end

-- ===== Scan Checkpoints =====
local function scanCheckpoints()
    local found = {}

    -- Tag CollectionService 'Checkpoint'
    for _,inst in ipairs(CollectionService:GetTagged("Checkpoint")) do
        local pos = getWorldPosFromInstance(inst)
        if pos then table.insert(found, {pos=pos, inst=inst, order=readOrder(inst)}) end
    end

    -- Sweep workspace kandidat
    local function tryPush(inst)
        if looksLikeCheckpoint(inst) then
            local pos = getWorldPosFromInstance(inst)
            if pos then table.insert(found, {pos=pos, inst=inst, order=readOrder(inst)}) end
        end
    end
    for _,inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") or inst:IsA("Model") or inst:IsA("SpawnLocation") then
            tryPush(inst)
        end
    end

    if #found == 0 then
        warn("[Teleporter] Tidak menemukan checkpoint.")
        return {}
    end

    local withOrder, without = {}, {}
    for _,x in ipairs(found) do
        if x.order then table.insert(withOrder, x) else table.insert(without, x) end
    end

    local points = {}
    if #withOrder > 0 then
        table.sort(withOrder, function(a,b) return a.order < b.order end)
        for _,x in ipairs(withOrder) do table.insert(points, x.pos) end

        if #without > 0 then
            local rest = {}
            for _,x in ipairs(without) do table.insert(rest, x.pos) end
            local startPos =
                points[#points]
                or ((LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position) or Vector3.new())
            rest = orderByNearest(rest, startPos)
            for _,p in ipairs(rest) do table.insert(points, p) end
        end
    else
        local startPos =
            (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position)
            or Vector3.new()
        local tmp = {}
        for _,x in ipairs(found) do table.insert(tmp, x.pos) end
        points = orderByNearest(dedupePoints(tmp, 6), startPos)
    end

    points = dedupePoints(points, 6)
    return points
end

-- ===== Teleport logic =====
local AUTO_POINTS = scanCheckpoints()
if #AUTO_POINTS == 0 then
    -- fallback: tetap buat 1 titik di posisi sekarang agar UI tidak kosong
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp  = char:WaitForChild("HumanoidRootPart")
    AUTO_POINTS = { hrp.Position }
end

local lastTpIndex = 0
local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil

local function teleportTo(i)
    if i < 1 or i > #AUTO_POINTS then return end
    local _,_,hrp = getCharHum()
    hrp.CFrame = CFrame.new(AUTO_POINTS[i] + Vector3.new(0, OFFSET_Y, 0))
    lastTpIndex = i
end

local function respawnNow()
    local ok = pcall(function() LocalPlayer:LoadCharacter() end)
    if not ok then
        local _, hum = getCharHum()
        if hum then hum.Health = 0 end
    end
    LocalPlayer.CharacterAdded:Wait()
    task.wait(0.5)
end

local function computeStartIndex()
    if lastTpIndex >= 1 and lastTpIndex <= #AUTO_POINTS then
        local nxt = lastTpIndex + 1
        if nxt > #AUTO_POINTS then nxt = 1 end
        return nxt
    end
    local _,_,hrp = getCharHum()
    local best, idx = math.huge, 1
    for i,p in ipairs(AUTO_POINTS) do
        local d = (hrp.Position - p).Magnitude
        if d < best then best, idx = d, i end
    end
    return idx
end

local function startLoop()
    if autoLoop or #AUTO_POINTS == 0 then return end
    autoLoop = true
    loopThread = coroutine.create(function()
        local i = computeStartIndex()
        while autoLoop do
            teleportTo(i)

            if i < #AUTO_POINTS then
                local t, timer = currentDelay, 0
                while autoLoop and timer < t do task.wait(0.05); timer += 0.05 end
            else
                local timer = 0
                while autoLoop and timer < 3 do task.wait(0.05); timer += 0.05 end
                if not autoLoop then break end
                respawnNow()
            end

            i += 1
            if i > #AUTO_POINTS then i = 1 end
        end
    end)
    coroutine.resume(loopThread)
end

local function stopLoop()
    autoLoop = false
end

local function clampDelay(x)
    if type(x) ~= "number" or x <= 0 then return DEFAULT_DELAY end
    if x < 0.1 then x = 0.1 end
    if x > 30 then x = 30 end
    return x
end

-- ===== UI: Tab Teleporter =====
local Tab = Window:CreateTab("Teleporter (Auto)", "map-pin")

local countLabel = Tab:CreateParagraph({
    Title = "Checkpoint",
    Content = "Terdeteksi: "..tostring(#AUTO_POINTS)
})

Tab:CreateSection("Manual Teleport")
local function rebuildButtons()
    -- (Optional) bisa dibuat dinamis kalau mau refresh daftar tombol; untuk simple, kita buat sekali saja.
end
for i = 1, #AUTO_POINTS do
    Tab:CreateButton({
        Name = ("TP %d"):format(i),
        Callback = function() teleportTo(i) end,
    })
end

Tab:CreateSection("Auto Loop")
Tab:CreateToggle({
    Name = "Aktifkan Auto Loop",
    CurrentValue = false,
    Flag = "AutoLoop",
    Callback = function(on) if on then startLoop() else stopLoop() end end,
})
Tab:CreateSlider({
    Name = "Delay Teleport (detik)",
    Range = {0.1, 30},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = DEFAULT_DELAY,
    Flag = "DelayTP",
    Callback = function(val) currentDelay = clampDelay(val) end,
})

Tab:CreateSection("Utilitas")
Tab:CreateButton({
    Name = "Rescan Checkpoints",
    Callback = function()
        local pts = scanCheckpoints()
        if pts and #pts > 0 then
            AUTO_POINTS = pts
            lastTpIndex = 0
            countLabel:Set("Terdeteksi: "..tostring(#AUTO_POINTS))
            Rayfield:Notify({ Title="Teleporter", Content="Scan berhasil: "..#AUTO_POINTS.." titik.", Duration=3, Image="check" })
            -- (Catatan) Tombol TP dibuat saat init; kalau ingin ikut berganti jumlahnya,
            -- kamu bisa membangun ulang UI di sini (buat ulang Tab atau pakai Tab:CreateParagraph daftar).
        else
            Rayfield:Notify({ Title="Teleporter", Content="Tidak ada checkpoint baru.", Duration=3, Image="alert-triangle" })
        end
    end,
})

Rayfield:LoadConfiguration()

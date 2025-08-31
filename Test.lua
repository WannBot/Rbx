-- LocalScript di StarterPlayerScripts (khusus developer map sendiri)

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- >>> LOAD RAYFIELD <<<
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ESP Racun",
    LoadingTitle = "Debug Minuman Beracun",
    LoadingSubtitle = "by Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PoisonCFG",
        FileName = "ESP"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("ESP", 4483362458)
local Section = Tab:CreateSection("Pengaturan ESP")

-- === Variabel utama ===
local POISON_ATTR = "IsPoison"
local DRINK_TAG   = "Drink"
local POISON_TAG  = "PoisonDrink"

local espEnabled = true
local highlights = {}
local billboards = {}

-- === Fungsi ===
local function makeHighlight(adornee: Instance)
    local h = Instance.new("Highlight")
    h.Name = "PoisonHighlight"
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Color3.fromRGB(255, 0, 0)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.Adornee = adornee
    h.Parent = adornee
    return h
end

local function makeBillboard(adornee: Instance)
    local b = Instance.new("BillboardGui")
    b.Name = "PoisonESP"
    b.Size = UDim2.new(0, 100, 0, 50)
    b.StudsOffset = Vector3.new(0, 3, 0)
    b.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "☠ Racun ☠"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = b

    b.Adornee = adornee
    b.Parent = adornee
    return b
end

local function shouldMark(inst: Instance): boolean
    if CollectionService:HasTag(inst, POISON_TAG) then return true end
    if inst:GetAttribute(POISON_ATTR) == true then return true end
    return false
end

local function getAdornee(inst: Instance): Instance
    if inst:IsA("Model") then return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart") or inst end
    if inst:IsA("BasePart") and inst.Parent and inst.Parent:IsA("Model") then
        return inst.Parent
    end
    return inst
end

local function attach(inst: Instance)
    if not espEnabled or highlights[inst] then return end
    local adornee = getAdornee(inst)
    if not adornee then return end

    highlights[inst] = makeHighlight(adornee)
    billboards[inst] = makeBillboard(adornee)
end

local function detach(inst: Instance)
    if highlights[inst] then highlights[inst]:Destroy() end
    if billboards[inst] then billboards[inst]:Destroy() end
    highlights[inst] = nil
    billboards[inst] = nil
end

local function refresh()
    for inst, _ in pairs(highlights) do
        if not inst:IsDescendantOf(game) or not espEnabled or not shouldMark(inst) then
            detach(inst)
        end
    end
    if not espEnabled then return end

    for _, inst in ipairs(CollectionService:GetTagged(DRINK_TAG)) do
        if shouldMark(inst) then attach(inst) end
    end
    for _, inst in ipairs(CollectionService:GetTagged(POISON_TAG)) do
        attach(inst)
    end
end

-- === UI Toggle di Rayfield ===
Tab:CreateToggle({
    Name = "ESP Racun",
    CurrentValue = true,
    Callback = function(Value)
        espEnabled = Value
        refresh()
    end,
})

-- === Toggle lewat keyboard G ===
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        espEnabled = not espEnabled
        refresh()
        print("Poison ESP:", espEnabled)
    end
end)

-- === Setup awal ===
CollectionService:GetInstanceAddedSignal(DRINK_TAG):Connect(function(inst)
    inst:GetAttributeChangedSignal(POISON_ATTR):Connect(function()
        if shouldMark(inst) then attach(inst) else detach(inst) end
    end)
    if shouldMark(inst) then attach(inst) end
end)
CollectionService:GetInstanceAddedSignal(POISON_TAG):Connect(attach)

refresh()
RunService.Heartbeat:Connect(refresh)

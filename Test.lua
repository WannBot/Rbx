-- // LocalScript : Dot Trail Path Recorder + Saver
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

--=== STATE ===--
local hrp
local recording = false
local pathData = {}
local dots = {}
local lastPoint = tick()

--=== CHARACTER BIND ===--
local function bindChar()
	local char = player.Character or player.CharacterAdded:Wait()
	hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

--=== VISUAL ===--
local function createDot(position)
	local dot = Instance.new("Part")
	dot.Shape = Enum.PartType.Ball
	dot.Anchored = true
	dot.CanCollide = false
	dot.Material = Enum.Material.Neon
	dot.Color = Color3.fromRGB(0, 255, 0)
	dot.Size = Vector3.new(0.4, 0.4, 0.4)
	dot.Position = position
	dot.Parent = workspace
	table.insert(dots, dot)
end

local function clearDots()
	for _, d in ipairs(dots) do
		if d and d.Parent then d:Destroy() end
	end
	dots = {}
end

--=== RECORD ===--
local function startRecord()
	if recording then return end
	recording = true
	pathData = {}
	clearDots()
	print("[Dot Trail] Mulai merekam...")

	RunService.Heartbeat:Connect(function()
		if recording and hrp and (tick() - lastPoint) > 0.2 then
			table.insert(pathData, hrp.Position)
			createDot(hrp.Position)
			lastPoint = tick()
		end
	end)
end

local function stopRecord()
	recording = false
	print("[Dot Trail] Rekaman berhenti. Total titik:", #pathData)
end

--=== SAVE / LOAD ===--
local function savePath(name)
	if #pathData == 0 then
		warn("Belum ada jalur untuk disimpan.")
		return
	end
	local json = HttpService:JSONEncode(pathData)
	writefile(name .. ".json", json)
	print("[Dot Trail] Jalur disimpan sebagai:", name .. ".json")
end

local function loadPath(name)
	if not isfile(name .. ".json") then
		warn("File tidak ditemukan:", name)
		return
	end
	clearDots()
	local json = readfile(name .. ".json")
	local data = HttpService:JSONDecode(json)
	print("[Dot Trail] Memuat jalur:", name, "dengan", #data, "titik")
	for _, pos in ipairs(data) do
		createDot(Vector3.new(pos.X, pos.Y, pos.Z))
	end
end

--=== UI RAYFIELD ===--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Dot Trail Path Tool",
	LoadingTitle = "Initializing",
	LoadingSubtitle = "by ChatGPT",
	KeySystem = false,
})

local Tab = Window:CreateTab("Dot Trail", 4483362458)

Tab:CreateButton({
	Name = "▶️ Start Record",
	Callback = startRecord
})
Tab:CreateButton({
	Name = "⏹ Stop Record",
	Callback = stopRecord
})
Tab:CreateInput({
	Name = "💾 Save Jalur (masukkan nama)",
	PlaceholderText = "contoh: trail1",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		savePath(input)
	end
})
Tab:CreateInput({
	Name = "📂 Load Jalur (nama file)",
	PlaceholderText = "contoh: trail1",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		loadPath(input)
	end
})
Tab:CreateButton({
	Name = "🧹 Hapus Semua Titik",
	Callback = clearDots
})

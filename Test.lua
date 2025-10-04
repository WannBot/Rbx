-- // LocalScript: Manual Path Maker + Play/Stop + Double Tap Protection
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local hum, hrp

local function bindChar()
	local char = player.Character or player.CharacterAdded:Wait()
	hum = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
end
bindChar()
player.CharacterAdded:Connect(bindChar)

--=== STATE ===--
local pathPoints = {}
local dots = {}
local addingMode = false
local playing = false
local lastClickTime = 0

--=== VISUAL ===--
local function createDot(position)
	local dot = Instance.new("Part")
	dot.Shape = Enum.PartType.Ball
	dot.Anchored = true
	dot.CanCollide = false
	dot.Material = Enum.Material.Neon
	dot.Color = Color3.fromRGB(0, 255, 0)
	dot.Size = Vector3.new(0.4, 0.4, 0.4)
	dot.Position = position + Vector3.new(0, 0.2, 0)
	dot.Parent = workspace
	table.insert(dots, dot)
end

local function clearDots()
	for _, d in ipairs(dots) do
		if d and d.Parent then d:Destroy() end
	end
	dots = {}
end

local function redrawDots()
	clearDots()
	for _, pos in ipairs(pathPoints) do
		createDot(pos)
	end
end

--=== DOUBLE CLICK DETECTION ===--
UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not addingMode then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local now = tick()
		if now - lastClickTime < 0.3 then -- klik dua kali cepat
			local mouse = player:GetMouse()
			if mouse.Target then
				local pos = mouse.Hit.p
				table.insert(pathPoints, pos)
				createDot(pos)
				print("✅ Titik ditambahkan:", pos)
			end
		end
		lastClickTime = now
	end
end)

--=== SAVE / LOAD ===--
local function savePath(name)
	if #pathPoints == 0 then
		warn("Belum ada titik untuk disimpan.")
		return
	end
	local simple = {}
	for _, v in ipairs(pathPoints) do
		table.insert(simple, {X = v.X, Y = v.Y, Z = v.Z})
	end
	writefile(name .. ".json", HttpService:JSONEncode(simple))
	print("[PathMaker] Jalur disimpan:", name .. ".json")
end

local function loadPath(name)
	if not isfile(name .. ".json") then
		warn("File tidak ditemukan:", name)
		return
	end
	local data = HttpService:JSONDecode(readfile(name .. ".json"))
	pathPoints = {}
	for _, p in ipairs(data) do
		table.insert(pathPoints, Vector3.new(p.X, p.Y, p.Z))
	end
	print("[PathMaker] Jalur dimuat:", #pathPoints, "titik")
	redrawDots()
end

--=== PLAY PATH ===--
local function playPath()
	if playing or #pathPoints == 0 then return end
	print("[PathMaker] Mulai Play Path...")
	playing = true
	for _, pos in ipairs(pathPoints) do
		if not playing then break end
		hum:MoveTo(pos)
		hum.MoveToFinished:Wait()
	end
	playing = false
end

local function stopPath()
	if playing then
		playing = false
		hum:Move(Vector3.zero)
		print("[PathMaker] Play dihentikan.")
	end
end

local function undoLast()
	if #pathPoints > 0 then
		table.remove(pathPoints, #pathPoints)
		redrawDots()
		print("[PathMaker] Titik terakhir dihapus.")
	end
end

--=== UI RAYFIELD ===--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Manual Path Builder v2",
	LoadingTitle = "Path Builder",
	LoadingSubtitle = "Double Tap + Play Test",
	KeySystem = false
})

local Tab = Window:CreateTab("Path Editor", 4483362458)

Tab:CreateToggle({
	Name = "🟢 Mode Tambah Titik (Double Tap)",
	CurrentValue = false,
	Callback = function(state)
		addingMode = state
		print("Mode tambah titik:", state and "Aktif" or "Nonaktif")
	end
})
Tab:CreateButton({
	Name = "▶️ Play Path",
	Callback = playPath
})
Tab:CreateButton({
	Name = "⏹ Stop Path",
	Callback = stopPath
})
Tab:CreateButton({
	Name = "↩️ Undo Titik Terakhir",
	Callback = undoLast
})
Tab:CreateButton({
	Name = "🧹 Clear Semua Titik",
	Callback = function()
		pathPoints = {}
		clearDots()
	end
})
Tab:CreateInput({
	Name = "💾 Save Jalur",
	PlaceholderText = "contoh: path1",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		savePath(input)
	end
})
Tab:CreateInput({
	Name = "📂 Load Jalur",
	PlaceholderText = "contoh: path1",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		loadPath(input)
	end
})

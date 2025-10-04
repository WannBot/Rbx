-- // LocalScript: Manual Path Maker + Saver
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

--=== STATE ===--
local pathPoints = {}
local dots = {}

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
	pathPoints = {}
end

local function redrawDots()
	clearDots()
	for _, pos in ipairs(pathPoints) do
		createDot(pos)
	end
end

--=== INPUT CLICK ===--
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local mouse = player:GetMouse()
		if mouse.Target then
			local pos = mouse.Hit.p
			table.insert(pathPoints, pos)
			createDot(pos)
			print("Titik ditambahkan:", pos)
		end
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
	local json = HttpService:JSONEncode(simple)
	writefile(name .. ".json", json)
	print("[PathMaker] Jalur disimpan ke", name .. ".json")
end

local function loadPath(name)
	if not isfile(name .. ".json") then
		warn("File tidak ditemukan:", name)
		return
	end
	local json = readfile(name .. ".json")
	local data = HttpService:JSONDecode(json)
	pathPoints = {}
	for _, p in ipairs(data) do
		table.insert(pathPoints, Vector3.new(p.X, p.Y, p.Z))
	end
	print("[PathMaker] Jalur dimuat, total titik:", #pathPoints)
	redrawDots()
end

local function undoLast()
	if #pathPoints > 0 then
		table.remove(pathPoints, #pathPoints)
		redrawDots()
		print("[PathMaker] Titik terakhir dihapus.")
	end
end

--=== UI (RAYFIELD) ===--
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
	Name = "Manual Path Maker",
	LoadingTitle = "Init",
	LoadingSubtitle = "Custom Path Creator",
	KeySystem = false
})

local Tab = Window:CreateTab("Path Builder", 4483362458)

Tab:CreateButton({
	Name = "↩️ Undo Titik Terakhir",
	Callback = undoLast
})
Tab:CreateButton({
	Name = "🧹 Clear Semua Titik",
	Callback = clearDots
})
Tab:CreateInput({
	Name = "💾 Save Jalur (nama file)",
	PlaceholderText = "contoh: jalur1",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		savePath(input)
	end
})
Tab:CreateInput({
	Name = "📂 Load Jalur (nama file)",
	PlaceholderText = "contoh: jalur1",
	RemoveTextAfterFocusLost = false,
	Callback = function(input)
		loadPath(input)
	end
})

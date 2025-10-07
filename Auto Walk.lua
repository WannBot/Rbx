-- WS Auto Walk Controller (Opsi B: semua kontrol Auto Walk di UI, gerak avatar = sistem lama MoveTo)
-- UI: Obsidian (deividcomsono / Linoria-based)
-- Fitur: Load JSON (GitHub RAW), visual titik (platform), Play All / Path1-Path5, Stop, Clear
-- + WalkSpeed / JumpPower / NoClip / Theme

----------------------------------------------------
-- LOAD UI LIBRARIES (Obsidian – deividcomsono)
----------------------------------------------------
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

----------------------------------------------------
-- SERVICES & INITIALS
----------------------------------------------------
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local HttpService  = game:GetService("HttpService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hum       = character:WaitForChild("Humanoid")
local hrp       = character:WaitForChild("HumanoidRootPart")

-- refresh refs on respawn
player.CharacterAdded:Connect(function(char)
	character = char
	hum = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
	task.wait(0.3)
	-- apply movement states back after respawn
	if _G.__WS_walkEnabled  then hum.WalkSpeed  = _G.__WS_walkSpeedValue or 16 end
	if _G.__WS_jumpEnabled  then hum.UseJumpPower = true; hum.JumpPower = _G.__WS_jumpPowerValue or 50 end
end)

----------------------------------------------------
-- STATES
----------------------------------------------------
_G.__WS_walkEnabled   = false
_G.__WS_jumpEnabled   = false
_G.__WS_noclipEnabled = false
_G.__WS_walkSpeedValue = 16
_G.__WS_jumpPowerValue = 50

-- auto walk (struktur sistem lama)
local platforms        = {}   -- Part list (titik)
local replaying        = false
local shouldStopReplay = false

----------------------------------------------------
-- HELPERS: movement toggles
----------------------------------------------------
local function applyWalk()
	if hum and hum.Parent then
		hum.WalkSpeed = _G.__WS_walkEnabled and _G.__WS_walkSpeedValue or 16
	end
end

local function applyJump()
	if hum and hum.Parent then
		hum.UseJumpPower = true
		hum.JumpPower = _G.__WS_jumpEnabled and _G.__WS_jumpPowerValue or 50
	end
end

RunService.Stepped:Connect(function()
	if _G.__WS_noclipEnabled and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

----------------------------------------------------
-- SISTEM LAMA: visual & replay (MoveTo)
----------------------------------------------------
local function clearPlatforms()
	for _, p in ipairs(platforms) do
		if p and p.Parent then p:Destroy() end
	end
	table.clear(platforms)
end

local function visualizePoints(pointsTable)
	-- bikin bola neon kecil di tiap titik
	for _, pos in ipairs(pointsTable) do
		local part = Instance.new("Part")
		part.Name = "WS_AutoWalk_Point"
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 190, 80)
		part.Size = Vector3.new(0.9, 0.9, 0.9)
		part.Shape = Enum.PartType.Ball
		part.Position = Vector3.new(pos.X, pos.Y, pos.Z)
		part.Parent = workspace
		table.insert(platforms, part)
	end
end

local function deserializePlatformData(jsonStr)
	clearPlatforms()
	local data = HttpService:JSONDecode(jsonStr)
	-- data = array objek {X,Y,Z}
	visualizePoints(data)
end

local function replayPath()
	if replaying or #platforms == 0 then return end
	replaying = true
	shouldStopReplay = false
	local h = player.Character:WaitForChild("Humanoid")
	for i, platform in ipairs(platforms) do
		if shouldStopReplay then break end
		h:MoveTo(platform.Position + Vector3.new(0, 3, 0))
		h.MoveToFinished:Wait()
		task.wait(0.20)
	end
	replaying = false
end

local function replayFromJSON_URL(url)
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if not ok then
		Library:Notify("Gagal mengambil JSON", 3)
		return
	end
	deserializePlatformData(res)
	task.wait(0.25)
	replayPath()
end

----------------------------------------------------
-- WINDOW & TABS
----------------------------------------------------
local Window = Library:CreateWindow({
	Title = "WS",
	Footer = "Antartika Path Controller",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Main    = Window:AddTab("Main Fiture", "user"),
	Auto    = Window:AddTab("Auto Walk",   "move"),
	Setting = Window:AddTab("Setting",     "settings"),
}

----------------------------------------------------
-- TAB: MAIN FITURE
----------------------------------------------------
local MainBox = Tabs.Main:AddLeftGroupbox("Movement Control")

MainBox:AddToggle("WS_Walk_Toggle", {
	Text = "WalkSpeed ON/OFF",
	Default = false,
	Callback = function(v)
		_G.__WS_walkEnabled = v
		applyWalk()
	end
})

MainBox:AddSlider("WS_Walk_Slider", {
	Text = "Speed",
	Default = 16, Min = 10, Max = 100, Rounding = 0,
	Callback = function(v)
		_G.__WS_walkSpeedValue = v
		if _G.__WS_walkEnabled then applyWalk() end
	end
})

MainBox:AddToggle("WS_Jump_Toggle", {
	Text = "JumpPower ON/OFF",
	Default = false,
	Callback = function(v)
		_G.__WS_jumpEnabled = v
		applyJump()
	end
})

MainBox:AddSlider("WS_Jump_Slider", {
	Text = "JumpPower",
	Default = 50, Min = 25, Max = 200, Rounding = 0,
	Callback = function(v)
		_G.__WS_jumpPowerValue = v
		if _G.__WS_jumpEnabled then applyJump() end
	end
})

MainBox:AddToggle("WS_NoClip_Toggle", {
	Text = "NoClip ON/OFF",
	Default = false,
	Callback = function(v)
		_G.__WS_noclipEnabled = v
	end
})

----------------------------------------------------
-- TAB: AUTO WALK (semua kontrol auto walk dipindah ke UI)
----------------------------------------------------
local AutoBox = Tabs.Auto:AddLeftGroupbox("Load & Control")

-- input URL RAW JSON
local currentURL = "https://raw.githubusercontent.com/WannBot/WindUI/refs/heads/main/Path1.json"

AutoBox:AddInput("WS_URL_Input", {
	Text = "GitHub RAW JSON URL",
	Default = currentURL,
	Placeholder = "https://raw.githubusercontent.com/<user>/<repo>/<branch>/Path1.json",
	Numeric = false, Finished = true,
	Callback = function(value)
		if value and #value > 0 then
			currentURL = value
			Library:Notify("URL set", 1.5)
		end
	end
})

AutoBox:AddButton("Load JSON & Visualize", function()
	local ok, res = pcall(function() return game:HttpGet(currentURL) end)
	if not ok then
		Library:Notify("Download gagal", 2)
		return
	end
	local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
	if not ok2 or typeof(data) ~= "table" then
		Library:Notify("Format JSON invalid", 2)
		return
	end
	deserializePlatformData(res)
	Library:Notify("Path loaded: " .. tostring(#platforms) .. " titik", 2)
end)

AutoBox:AddButton("Play Loaded Path", function()
	if #platforms == 0 then
		Library:Notify("Belum ada path yang diload", 2)
		return
	end
	replayPath()
end)

AutoBox:AddButton("Stop", function()
	shouldStopReplay = true
	replaying = false
	Library:Notify("Stopped", 1.5)
end)

AutoBox:AddButton("Clear Visual", function()
	clearPlatforms()
	Library:Notify("Cleared", 1.5)
end)

-- Play All & per-path (dari repo kamu)
local baseURL = "https://raw.githubusercontent.com/WannBot/WindUI/refs/heads/main/"

AutoBox:AddDivider()

AutoBox:AddButton("Play ALL (Path1 → Path5)", function()
	task.spawn(function()
		for i = 1, 5 do
			if shouldStopReplay then break end
			replayFromJSON_URL(baseURL .. "Path" .. i .. ".json")
			task.wait(0.35)
		end
	end)
end)

for i = 1, 5 do
	AutoBox:AddButton("Play Path" .. i, function()
		replayFromJSON_URL(baseURL .. "Path" .. i .. ".json")
	end)
end

----------------------------------------------------
-- TAB: SETTING (Theme & Config)
----------------------------------------------------
local SettingBox = Tabs.Setting:AddLeftGroupbox("Theme / Config")

SettingBox:AddDropdown("ThemeSelect", {
	Values = { "Dark", "Light", "Aqua", "Midnight" },
	Default = "Dark",
	Text = "Select Theme",
	Callback = function(opt) Window:SetTheme(opt) end,
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("WS")
SaveManager:SetFolder("WS/config")
SaveManager:BuildConfigSection(Tabs.Setting)
ThemeManager:ApplyToTab(Tabs.Setting)

-- toggle UI (default)
Library.ToggleKeybind = Enum.KeyCode.RightShift

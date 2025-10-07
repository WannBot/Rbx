-- 🧠 WS Auto Walk Controller (Full Combined)
-- Library: Obsidian (deividcomsono)
-- Author: WannBot / ChatGPT Mod

----------------------------------------------------
-- ✅ LOAD LIBRARY
----------------------------------------------------
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

----------------------------------------------------
-- ✅ SERVICES & VARIABLES
----------------------------------------------------
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hum = character:WaitForChild("Humanoid")

-- Auto update Humanoid on respawn
player.CharacterAdded:Connect(function(char)
	character = char
	hum = char:WaitForChild("Humanoid")
	task.wait(0.5)
	if walkEnabled then hum.WalkSpeed = walkSpeedValue end
	if jumpEnabled then
		hum.UseJumpPower = true
		hum.JumpPower = jumpPowerValue
	end
end)

-- State
local walkEnabled, jumpEnabled, noclipEnabled = false, false, false
local walkSpeedValue, jumpPowerValue = 16, 50
local autoWalkActive, playAll = false, false

----------------------------------------------------
-- ⚙️ BASIC FUNCTIONS
----------------------------------------------------
local function applyWalk()
	if hum and hum.Parent then
		hum.WalkSpeed = walkEnabled and walkSpeedValue or 16
	end
end

local function applyJump()
	if hum and hum.Parent then
		hum.UseJumpPower = true
		hum.JumpPower = jumpEnabled and jumpPowerValue or 50
	end
end

RunService.Stepped:Connect(function()
	if noclipEnabled and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
end)

----------------------------------------------------
-- 🪟 WINDOW UI
----------------------------------------------------
local Window = Library:CreateWindow({
	Title = "WS",
	Footer = "Antartika Path Controller",
	Icon = 95816097006870,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Main = Window:AddTab("Main Fiture", "user"),
	Auto = Window:AddTab("Auto Walk", "move"),
	Setting = Window:AddTab("Setting", "settings"),
}

----------------------------------------------------
-- 🟢 MAIN TAB
----------------------------------------------------
local MainBox = Tabs.Main:AddLeftGroupbox("Movement Control")

MainBox:AddToggle("WalkspeedToggle", {
	Text = "WalkSpeed ON/OFF",
	Default = false,
	Callback = function(v) walkEnabled = v; applyWalk() end,
})

MainBox:AddSlider("WalkspeedValue", {
	Text = "Speed",
	Default = 16, Min = 10, Max = 100, Rounding = 0,
	Callback = function(v) walkSpeedValue = v; if walkEnabled then applyWalk() end end,
})

MainBox:AddToggle("JumpToggle", {
	Text = "JumpPower ON/OFF",
	Default = false,
	Callback = function(v) jumpEnabled = v; applyJump() end,
})

MainBox:AddSlider("JumpPowerValue", {
	Text = "JumpPower",
	Default = 50, Min = 25, Max = 200, Rounding = 0,
	Callback = function(v) jumpPowerValue = v; if jumpEnabled then applyJump() end end,
})

MainBox:AddToggle("NoClip", {
	Text = "NoClip ON/OFF",
	Default = false,
	Callback = function(v) noclipEnabled = v end,
})

----------------------------------------------------
-- 🧭 AUTO WALK TAB
----------------------------------------------------
local AutoBox = Tabs.Auto:AddLeftGroupbox("Map Antartika")

-- Base GitHub Path
local baseURL = "https://raw.githubusercontent.com/WannBot/WindUI/refs/heads/main/"

local function playPathFile(filename)
	local url = baseURL .. filename .. ".json"
	print("[AutoWalk] Mengambil:", url)

	local ok, response = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok then
		Library:Notify("Gagal ambil file " .. filename, 3)
		return
	end

	local okDecode, data = pcall(function()
		return HttpService:JSONDecode(response)
	end)
	if not okDecode or typeof(data) ~= "table" then
		Library:Notify("JSON invalid di " .. filename, 3)
		return
	end

	autoWalkActive = true
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	hrp.Anchored = false

	Library:Notify("Playing " .. filename .. " (" .. #data .. " titik)", 3)

	for i, pos in ipairs(data) do
		if not autoWalkActive then break end
		local target = Vector3.new(pos.X, pos.Y, pos.Z)
		local dist = (hrp.Position - target).Magnitude
		local tweenTime = math.clamp(dist / 20, 0.3, 3)
		local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.05)
	end

	autoWalkActive = false
	Library:Notify("Selesai " .. filename, 2)
end

local function stopPath()
	autoWalkActive = false
	Library:Notify("Auto walk dihentikan", 2)
end

-- Auto buttons
AutoBox:AddToggle("PlayAll", {
	Text = "PLAY ALL (Path1 → Path5)",
	Default = false,
	Callback = function(state)
		playAll = state
		if state then
			task.spawn(function()
				for i = 1, 5 do
					playPathFile("Path" .. i)
					if not playAll then break end
				end
				playAll = false
			end)
		else
			stopPath()
		end
	end,
})

for i = 1, 5 do
	AutoBox:AddToggle("Path" .. i, {
		Text = "Play Path" .. i,
		Default = false,
		Callback = function(state)
			if state then playPathFile("Path" .. i) else stopPath() end
		end,
	})
end

----------------------------------------------------
-- ⚙️ SETTING TAB
----------------------------------------------------
local SettingBox = Tabs.Setting:AddLeftGroupbox("Theme")

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

Library.ToggleKeybind = Enum.KeyCode.RightShift

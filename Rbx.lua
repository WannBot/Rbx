-- // Teleporter 7 Pos + Rayfield UI + Main Fiture (Fly Camera-Based, NoClip, Speed, Invisible)
-- // Gunakan di game sendiri / testing. Jangan dipakai untuk eksploit di game orang lain.

-----------------------------
-- KONFIGURASI POSISI
-----------------------------
local OFFSET_Y = 3
local POINTS = {
    -- GANTI koordinat sesuai map-mu:
    Vector3.new(388, 310, -185),    -- 1
    Vector3.new(99, 412, 615),      -- 2
    Vector3.new(10, 601, 998),      -- 3
    Vector3.new(871, 865, 583),     -- 4
    Vector3.new(1622, 1080, 157),   -- 5
    Vector3.new(2969, 1528, 708),   -- 6
    Vector3.new(1803, 1982, 2169),  -- 7
    Vector3.new(516, 14, -994),     -- Basecamp (opsional)
}
local DEFAULT_DELAY = 2 -- detik
local TOGGLE_KEY = "L"  -- toggle UI loop

-----------------------------
-- SERVICES & VAR
-----------------------------
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local player  = Players.LocalPlayer

local currentDelay = DEFAULT_DELAY
local autoLoop     = false
local loopThread   = nil

-----------------------------
-- CORE TELEPORT
-----------------------------
local function getCharHum()
	local char = player.Character or player.CharacterAdded:Wait()
	return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(i)
	if i < 1 or i > #POINTS then return end
	local _, _, hrp = getCharHum()
	hrp.CFrame = CFrame.new(POINTS[i] + Vector3.new(0, OFFSET_Y, 0))
end

local function clampDelay(x)
	if type(x) ~= "number" or x <= 0 then return DEFAULT_DELAY end
	if x < 0.1 then x = 0.1 end
	if x > 30 then x = 30 end
	return x
end

local function startLoop()
	if autoLoop then return end
	autoLoop = true
	loopThread = coroutine.create(function()
		while autoLoop do
			for i = 1, #POINTS do
				if not autoLoop then break end
				teleportTo(i)
				task.wait(currentDelay)
			end
		end
	end)
	coroutine.resume(loopThread)
end

local function stopLoop()
	autoLoop = false
end

-----------------------------
-- RAYFIELD UI
-----------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "WS",
    Icon = 0,
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "Teleporter",
    ShowText = "Teleporter",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Teleporter7",
        FileName = "Config"
    },
    KeySystem = false,
})

-- ===== Tab: Main Fiture =====
local TabMain = Window:CreateTab("Main Fiture", "layout-grid")

-- ==== Fly (Camera-Based) ====
-- Joystick/WASD mengikuti arah kamera (maju kamera = terbang ke depan/atas jika kamera menengadah)
local flyEnabled = false
local flySpeed   = 60
local flyConn -- RenderStepped connection

local function setFly(state)
	local char, hum, hrp = getCharHum()
	if state then
		if flyEnabled then return end
		flyEnabled = true
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.Physics)

		flyConn = RS.RenderStepped:Connect(function()
			if not flyEnabled then return end
			char, hum, hrp = getCharHum()
			local cam = workspace.CurrentCamera
			if not cam then return end

			-- Input dari WASD/joystick bawaan
			local move  = hum.MoveDirection
			-- Arah kamera (ikut pitch untuk naik/turun)
			local look  = cam.CFrame.LookVector
			local right = cam.CFrame.RightVector

			-- Kombinasi X/Z input terhadap orientasi kamera (mengandung komponen Y dari look)
			local vel = (look * move.Z + right * move.X) * flySpeed

			hrp.AssemblyLinearVelocity = vel
			hrp.AssemblyAngularVelocity = Vector3.zero
		end)
	else
		if not flyEnabled then return end
		flyEnabled = false
		if flyConn then flyConn:Disconnect() flyConn = nil end
		if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
	end
end

TabMain:CreateSection("Fly (Camera-Based)")
TabMain:CreateToggle({
	Name = "Aktifkan Fly (ikut arah kamera)",
	CurrentValue = false,
	Flag = "FlyToggle",
	Callback = function(on) setFly(on) end,
})
TabMain:CreateSlider({
	Name = "Kecepatan Fly",
	Range = {10, 200},
	Increment = 1,
	Suffix = "",
	CurrentValue = flySpeed,
	Flag = "FlySpeed",
	Callback = function(val) flySpeed = math.clamp(tonumber(val) or flySpeed, 10, 200) end,
})

-- ==== NoClip ====
local noclip = false
local noclipConn
local function setNoClip(state)
	local char = player.Character
	if state then
		if noclip then return end
		noclip = true
		noclipConn = RS.Stepped:Connect(function()
			char = player.Character
			if not char then return end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	else
		if not noclip then return end
		noclip = false
		if noclipConn then noclipConn:Disconnect() noclipConn = nil end
		-- biarkan Roblox yang restore collision saat respawn
	end
end

TabMain:CreateSection("No Clip")
TabMain:CreateToggle({
	Name = "Aktifkan No Clip",
	CurrentValue = false,
	Flag = "NoClipToggle",
	Callback = function(on) setNoClip(on) end,
})

-- ==== Speed Run (WalkSpeed) ====
local defaultWalkSpeed = 16
local function setRunSpeed(v)
	local _, hum = getCharHum()
	hum.WalkSpeed = math.clamp(v, 1, 200)
end

TabMain:CreateSection("Speed Run")
TabMain:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 200},
	Increment = 1,
	Suffix = "",
	CurrentValue = defaultWalkSpeed,
	Flag = "RunSpeed",
	Callback = function(val) setRunSpeed(tonumber(val) or defaultWalkSpeed) end,
})
TabMain:CreateButton({
	Name = "Reset WalkSpeed (16)",
	Callback = function() setRunSpeed(16) end,
})

-- ==== Invisible (Local) ====
-- Membuat karakter tak terlihat di client-mu (pemain lain masih bisa melihat).
local function setInvisibleLocal(state)
	local char = player.Character
	if not char then return end
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.LocalTransparencyModifier = state and 1 or 0
		elseif obj:IsA("Decal") then
			obj.Transparency = state and 1 or 0
		end
	end
end

TabMain:CreateSection("Invisible (Local)")
TabMain:CreateToggle({
	Name = "Jadikan diri tak terlihat (local)",
	CurrentValue = false,
	Flag = "InvisibleLocal",
	Callback = function(on) setInvisibleLocal(on) end,
})

-- ===== Tab: Teleporter (seperti sebelumnya) =====
local Tab = Window:CreateTab("Teleporter", "map-pin")

Tab:CreateSection("Manual Teleport")
for i = 1, #POINTS do
	Tab:CreateButton({
		Name = ("TP %d"):format(i),
		Callback = function() teleportTo(i) end,
	})
end

Tab:CreateSection("Auto Loop")
local ToggleLoop = Tab:CreateToggle({
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

Rayfield:Notify({
	Title = "Teleporter siap",
	Content = "Selamat menggunakan script",
	Duration = 3,
	Image = "Fire"
})

Tab:CreateSection("Keybinds")
for i = 1, #POINTS do
	Tab:CreateKeybind({
		Name = ("Keybind TP %d"):format(i),
		CurrentKeybind = tostring(i),
		HoldToInteract = false,
		Flag = ("BindTP%d"):format(i),
		Callback = function() teleportTo(i) end,
	})
end
Tab:CreateKeybind({
	Name = "Toggle Auto Loop",
	CurrentKeybind = TOGGLE_KEY,
	HoldToInteract = false,
	Flag = "BindLoop",
	Callback = function()
		local newState = not autoLoop
		ToggleLoop:Set(newState)
		if newState then startLoop() else stopLoop() end
	end,
})

Rayfield:LoadConfiguration()

-- Teleporter 7 Pos (Client/LocalScript)
-- Fitur:
-- [✓] 7 tombol manual (TP1..TP7)
-- [✓] Auto loop P1→P7→ulang dengan Start/Stop
-- [✓] Pilihan delay teleport (TextBox + preset 0.5 / 1 / 2 / 5 detik)
-- Ubah koordinat di bagian CONFIG di bawah.

-----------------------------
-- CONFIG (ubah sesukanya) --
-----------------------------
local OFFSET_Y = 3 -- naikkan sedikit supaya tidak nancep ke lantai

local POINTS = {
	-- GANTI koordinat di bawah:
	Vector3.new(100, 10, 50),    -- Pos 1
	Vector3.new(150, 12, -30),   -- Pos 2
	Vector3.new(1615, 1080, 158),    -- Pos 3
	Vector3.new(-40, 15, 75),    -- Pos 4
	Vector3.new(0,   25, 0),     -- Pos 5
	Vector3.new(220, 8, -120),   -- Pos 6
	Vector3.new(-100, 18, 40),   -- Pos 7
}

local DEFAULT_DELAY = 2 -- detik jika TextBox kosong/tidak valid

--------------------------------
-- DEPENDENCIES & SHORTCUTS  --
--------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

--------------------------------
-- STATE / RUNTIME VARIABLES  --
--------------------------------
local autoLoop = false
local loopThread = nil
local currentDelay = DEFAULT_DELAY

--------------------------------
-- HELPER: DAPATKAN HRP       --
--------------------------------
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:FindFirstChild("HumanoidRootPart")
end

--------------------------------
-- TELEPORT CORE              --
--------------------------------
local function teleportTo(index)
	if index < 1 or index > #POINTS then return end
	local hrp = getHRP()
	if not hrp then return end
	local p = POINTS[index]
	hrp.CFrame = CFrame.new(p + Vector3.new(0, OFFSET_Y, 0))
end

--------------------------------
-- DELAY PARSER               --
--------------------------------
local function clampDelay(num)
	if not num or num ~= num or num <= 0 then return DEFAULT_DELAY end
	-- batas wajar: min 0.1, max 30 detik
	if num < 0.1 then num = 0.1 end
	if num > 30 then num = 30 end
	return num
end

--------------------------------
-- GUI BUILDER                --
--------------------------------
local function makeButton(parent, text, height)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -20, 0, height or 28)
	b.Position = UDim2.new(0, 10, 0, 0)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text
	b.AutoButtonColor = true
	b.BackgroundTransparency = 0.1
	b.Parent = parent
	return b
end

local function buildUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Teleporter7"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 200, 0, 370)
	frame.Position = UDim2.new(0, 20, 0.5, -185)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 12)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 10)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.Text = "Teleporter 7 Pos"
	title.Parent = frame

	-- --- Delay controls
	local delayLabel = Instance.new("TextLabel")
	delayLabel.Size = UDim2.new(1, -20, 0, 22)
	delayLabel.Position = UDim2.new(0, 10, 0, 0)
	delayLabel.BackgroundTransparency = 1
	delayLabel.Font = Enum.Font.GothamSemibold
	delayLabel.TextXAlignment = Enum.TextXAlignment.Left
	delayLabel.TextSize = 14
	delayLabel.Text = "Delay (detik):"
	delayLabel.Parent = frame

	local delayBox = Instance.new("TextBox")
	delayBox.Size = UDim2.new(1, -20, 0, 28)
	delayBox.Position = UDim2.new(0, 10, 0, 0)
	delayBox.ClearTextOnFocus = false
	delayBox.Text = tostring(DEFAULT_DELAY)
	delayBox.PlaceholderText = "cth: 0.5 / 1 / 2 / 5"
	delayBox.TextScaled = false
	delayBox.TextSize = 14
	delayBox.Font = Enum.Font.Gotham
	delayBox.BackgroundTransparency = 0.1
	delayBox.Parent = frame

	delayBox.FocusLost:Connect(function(enterPressed)
		local num = tonumber(delayBox.Text)
		currentDelay = clampDelay(num)
		delayBox.Text = tostring(currentDelay)
	end)

	-- Preset row
	local presetRow = Instance.new("Frame")
	presetRow.Size = UDim2.new(1, -20, 0, 30)
	presetRow.Position = UDim2.new(0, 10, 0, 0)
	presetRow.BackgroundTransparency = 1
	presetRow.Parent = frame

	local hLayout = Instance.new("UIListLayout", presetRow)
	hLayout.FillDirection = Enum.FillDirection.Horizontal
	hLayout.Padding = UDim.new(0, 6)
	hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	hLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local function makePreset(txt, val)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.25, -6, 1, 0)
		b.Text = txt
		b.Font = Enum.Font.Gotham
		b.TextSize = 14
		b.BackgroundTransparency = 0.1
		b.Parent = presetRow
		b.Activated:Connect(function()
			currentDelay = clampDelay(val)
			delayBox.Text = tostring(currentDelay)
		end)
	end
	makePreset("0.5s", 0.5)
	makePreset("1s", 1)
	makePreset("2s", 2)
	makePreset("5s", 5)

	-- --- Manual buttons TP1..TP7
	local manualLabel = Instance.new("TextLabel")
	manualLabel.Size = UDim2.new(1, -20, 0, 22)
	manualLabel.Position = UDim2.new(0, 10, 0, 0)
	manualLabel.BackgroundTransparency = 1
	manualLabel.Font = Enum.Font.GothamSemibold
	manualLabel.TextXAlignment = Enum.TextXAlignment.Left
	manualLabel.TextSize = 14
	manualLabel.Text = "Manual Teleport:"
	manualLabel.Parent = frame

	for i = 1, #POINTS do
		local btn = makeButton(frame, ("TP %d"):format(i))
		btn.Activated:Connect(function()
			teleportTo(i)
		end)
	end

	-- --- Auto Loop controls
	local loopLabel = Instance.new("TextLabel")
	loopLabel.Size = UDim2.new(1, -20, 0, 22)
	loopLabel.Position = UDim2.new(0, 10, 0, 0)
	loopLabel.BackgroundTransparency = 1
	loopLabel.Font = Enum.Font.GothamSemibold
	loopLabel.TextXAlignment = Enum.TextXAlignment.Left
	loopLabel.TextSize = 14
	loopLabel.Text = "Auto Loop:"
	loopLabel.Parent = frame

	local startBtn = makeButton(frame, "Mulai Auto Loop")
	local stopBtn = makeButton(frame, "Stop Auto Loop")

	local function stopLoop()
		autoLoop = false
		-- Biarkan thread keluar sendiri saat cek flag
	end

	local function runLoop()
		autoLoop = true
		if loopThread and coroutine.status(loopThread) ~= "dead" then
			-- sudah berjalan
			return
		end
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

	startBtn.Activated:Connect(runLoop)
	stopBtn.Activated:Connect(stopLoop)

	-- Hotkey: angka 1..7 untuk TP, L untuk toggle loop
	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local map = {
			[Enum.KeyCode.One] = 1,
			[Enum.KeyCode.Two] = 2,
			[Enum.KeyCode.Three] = 3,
			[Enum.KeyCode.Four] = 4,
			[Enum.KeyCode.Five] = 5,
			[Enum.KeyCode.Six] = 6,
			[Enum.KeyCode.Seven] = 7,
		}
		if map[input.KeyCode] then
			teleportTo(map[input.KeyCode])
		elseif input.KeyCode == Enum.KeyCode.L then
			if autoLoop then
				stopLoop()
			else
				runLoop()
			end
		end
	end)
end

-- Build GUI saat PlayerGui siap
task.defer(buildUI)
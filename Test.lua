local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- === Rayfield UI ===
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Quiz Auto Answer",
    LoadingTitle = "Quiz Bot",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "QuizCFG",
        FileName = "AutoAnswer"
    },
    KeySystem = false,
})
local Tab = Window:CreateTab("Quiz", 4483362458)
local Section = Tab:CreateSection("Mode Auto Jawab")

-- === Variabel ===
local mode = "OFF"  -- OFF / CLICK / SHOW

-- === UI Rayfield Controls ===
Tab:CreateButton({
    Name = "Matikan (OFF)",
    Callback = function()
        mode = "OFF"
        print("Mode:", mode)
    end,
})
Tab:CreateButton({
    Name = "Auto Klik Jawaban",
    Callback = function()
        mode = "CLICK"
        print("Mode:", mode)
    end,
})
Tab:CreateButton({
    Name = "Hanya Tampilkan Jawaban",
    Callback = function()
        mode = "SHOW"
        print("Mode:", mode)
    end,
})

-- === UI Display Jawaban ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnswerDisplay"
screenGui.ResetOnSpawn = false
screenGui.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 300, 0, 50)
label.Position = UDim2.new(0.5, -150, 0.1, 0) -- tengah atas
label.BackgroundTransparency = 0.3
label.BackgroundColor3 = Color3.fromRGB(0,0,0)
label.TextColor3 = Color3.fromRGB(255,255,0)
label.TextStrokeTransparency = 0
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = "Mode OFF"
label.Parent = screenGui

-- === Fungsi Parser Soal ===
local function parseQuestion(text)
    local num1, op, num2 = text:match("(%d+)%s*([%+%-%*/x÷])%s*(%d+)")
    if not num1 or not op or not num2 then return nil end
    num1, num2 = tonumber(num1), tonumber(num2)

    if op == "+" then return num1 + num2
    elseif op == "-" then return num1 - num2
    elseif op == "*" or op == "x" or op == "×" then return num1 * num2
    elseif op == "/" or op == "÷" then return num1 / num2 end
end

-- === Fungsi Klik Jawaban ===
local function clickAnswer(result)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Text == tostring(result) then
            firesignal(obj.MouseButton1Click)
            print("Klik jawaban:", result)
            return
        end
        if obj:IsA("ImageButton") or obj:IsA("TextButton") then
            local labelChild = obj:FindFirstChildWhichIsA("TextLabel")
            if labelChild and labelChild.Text == tostring(result) then
                firesignal(obj.MouseButton1Click)
                print("Klik jawaban:", result)
                return
            end
        end
    end
end

-- === Loop Deteksi ===
RunService.Heartbeat:Connect(function()
    local questionLabel = gui:FindFirstChild("QuestionLabel", true)
    if not questionLabel or not questionLabel:IsA("TextLabel") then
        label.Text = "Menunggu soal..."
        label.TextColor3 = Color3.fromRGB(255,255,0)
        return
    end

    local result = parseQuestion(questionLabel.Text)
    if not result then
        label.Text = "Soal tidak dikenali"
        label.TextColor3 = Color3.fromRGB(255,0,0)
        return
    end

    if mode == "CLICK" then
        label.Text = "Auto Klik: " .. tostring(result)
        label.TextColor3 = Color3.fromRGB(0,255,0)
        clickAnswer(result)

    elseif mode == "SHOW" then
        label.Text = "Jawaban: " .. tostring(result)
        label.TextColor3 = Color3.fromRGB(0,255,0)

    elseif mode == "OFF" then
        label.Text = "Mode OFF"
        label.TextColor3 = Color3.fromRGB(255,255,0)
    end
end)

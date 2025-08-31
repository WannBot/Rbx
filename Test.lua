-- LocalScript di StarterPlayerScripts (khusus developer test)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- >>> Rayfield UI <<<
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Quiz Auto Answer",
    LoadingTitle = "Auto Jawab Bot",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "QuizCFG",
        FileName = "AutoAnswer"
    },
    KeySystem = false,
})

local Tab = Window:CreateTab("Quiz", 4483362458)
local Section = Tab:CreateSection("Pengaturan Auto Jawab")

-- Status toggle
local autoAnswer = false

-- Toggle di UI
Tab:CreateToggle({
    Name = "Auto Jawab ( + - × ÷ )",
    CurrentValue = false,
    Callback = function(Value)
        autoAnswer = Value
        print("Auto Answer:", autoAnswer)
    end,
})

-- Fungsi parsing soal
local function parseQuestion(text)
    -- Contoh: "5 + 3 = ???" atau "12 ÷ 4 = ???"
    local num1, op, num2 = text:match("(%d+)%s*([%+%-%*/x÷])%s*(%d+)")
    if not num1 or not op or not num2 then return nil end
    num1, num2 = tonumber(num1), tonumber(num2)

    if op == "+" then
        return num1 + num2
    elseif op == "-" then
        return num1 - num2
    elseif op == "*" or op == "x" or op == "×" then
        return num1 * num2
    elseif op == "/" or op == "÷" then
        return num1 / num2
    end
end

-- Fungsi klik tombol jawaban sesuai hasil
local function clickAnswer(result)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Text == tostring(result) then
            firesignal(obj.MouseButton1Click)
            print("Jawaban otomatis:", result)
            break
        end
    end
end

-- Loop deteksi pertanyaan
RunService.Heartbeat:Connect(function()
    if not autoAnswer then return end

    local questionLabel = gui:FindFirstChild("QuestionLabel", true)
    if questionLabel and questionLabel:IsA("TextLabel") then
        local result = parseQuestion(questionLabel.Text)
        if result then
            clickAnswer(result)
        end
    end
end)

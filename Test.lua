-- LocalScript (StarterPlayerScripts) untuk debug developer
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- >>> Rayfield UI <<<
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Answer Debug",
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
local Section = Tab:CreateSection("Auto Answer Settings")

local autoAnswer = false

-- Toggle Auto Jawab
Tab:CreateToggle({
    Name = "Auto Jawab ( +  -  ×  ÷ )",
    CurrentValue = false,
    Callback = function(Value)
        autoAnswer = Value
    end,
})

-- Fungsi parsing soal
local function parseQuestion(text)
    -- Bisa menangkap 3 format: +  -  *  /  x  ÷
    local num1, op, num2 = text:match("(%d+)%s*([%+%-%*/x÷])%s*(%d+)")
    if not num1 or not op or not num2 then
        return nil
    end
    num1, num2 = tonumber(num1), tonumber(num2)

    if op == "+" then
        return num1 + num2
    elseif op == "-" then
        return num1 - num2
    elseif op == "*" or op == "x" or op == "×" then
        return num1 * num2
    elseif op == "/" or op == "÷" then
        -- pembagian, hati-hati pembulatan
        return num1 / num2
    end
end

-- Fungsi klik tombol jawaban
local function chooseAnswer(answer)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Text == tostring(answer) then
            firesignal(obj.MouseButton1Click)
            print("Jawaban otomatis:", answer)
            break
        end
    end
end

-- Loop cek pertanyaan
game:GetService("RunService").Heartbeat:Connect(function()
    if not autoAnswer then return end

    local questionLabel = gui:FindFirstChild("QuestionLabel", true)
    if questionLabel and questionLabel:IsA("TextLabel") then
        local result = parseQuestion(questionLabel.Text)
        if result then
            chooseAnswer(result)
        end
    end
end)

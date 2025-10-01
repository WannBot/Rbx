-- Fluent UI 1.2.2 (custom remake)
local Library = {}
Library.Themes = {"Arctic","Rose","Midnight","Forest","Sunset","Ocean","Emerald","Sapphire","Cloud","Grape","Bloody"}

-- Window
function Library:CreateWindow(info)
    local window = Instance.new("ScreenGui")
    window.Name = "FluentUI"
    window.ResetOnSpawn = false
    window.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 520, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25,25,30)
    mainFrame.Parent = window

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = (info.Title or "Fluent UI") .. " | ".. (info.SubTitle or "1.2.2 by Dawid")
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 120, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(30,30,35)
    sidebar.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.Parent = sidebar
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local tabFolder = Instance.new("Folder")
    tabFolder.Name = "Tabs"
    tabFolder.Parent = mainFrame

    function Library:AddTab(name)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Text = name
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 16
        button.BackgroundColor3 = Color3.fromRGB(45,45,50)
        button.TextColor3 = Color3.fromRGB(200,200,200)
        button.Parent = sidebar

        local tabFrame = Instance.new("ScrollingFrame")
        tabFrame.Size = UDim2.new(1, -130, 1, -50)
        tabFrame.Position = UDim2.new(0, 130, 0, 50)
        tabFrame.BackgroundTransparency = 1
        tabFrame.CanvasSize = UDim2.new(0,0,2,0)
        tabFrame.Visible = false
        tabFrame.Parent = tabFolder

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Parent = tabFrame
        tabLayout.Padding = UDim.new(0,6)

        button.MouseButton1Click:Connect(function()
            for _,t in ipairs(tabFolder:GetChildren()) do
                if t:IsA("ScrollingFrame") then
                    t.Visible = false
                end
            end
            tabFrame.Visible = true
        end)

        return {
            AddToggle = function(_,data,callback)
                local tgl = Instance.new("TextButton")
                tgl.Size = UDim2.new(1, -10, 0, 30)
                tgl.Text = "[ ] "..data.Text
                tgl.Font = Enum.Font.SourceSans
                tgl.TextSize = 16
                tgl.BackgroundColor3 = Color3.fromRGB(55,55,60)
                tgl.TextColor3 = Color3.fromRGB(230,230,230)
                tgl.Parent = tabFrame
                local state = data.Default or false
                tgl.MouseButton1Click:Connect(function()
                    state = not state
                    tgl.Text = (state and "[✓] " or "[ ] ")..data.Text
                    if callback then callback(state) end
                end)
            end,

            AddSlider = function(_,data,callback)
                local sldr = Instance.new("TextLabel")
                sldr.Size = UDim2.new(1, -10, 0, 30)
                sldr.Text = data.Text..": "..tostring(data.Default)
                sldr.Font = Enum.Font.SourceSans
                sldr.TextSize = 16
                sldr.BackgroundColor3 = Color3.fromRGB(55,55,60)
                sldr.TextColor3 = Color3.fromRGB(230,230,230)
                sldr.Parent = tabFrame
                local val = data.Default or 0
                -- slider fake (gunakan callback langsung)
                sldr.InputBegan:Connect(function()
                    val = math.random(data.Min,data.Max)
                    sldr.Text = data.Text..": "..val
                    if callback then callback(val) end
                end)
            end,

            AddButton = function(_,data)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -10, 0, 30)
                btn.Text = data.Text
                btn.Font = Enum.Font.SourceSans
                btn.TextSize = 16
                btn.BackgroundColor3 = Color3.fromRGB(55,55,60)
                btn.TextColor3 = Color3.fromRGB(230,230,230)
                btn.Parent = tabFrame
                btn.MouseButton1Click:Connect(function()
                    if data.Callback then data.Callback() end
                end)
            end,
        }
    end

    return Library
end

--========================================
-- PEMAKAIAN
--========================================

local Win = Library:CreateWindow({
    Title = "Fluent",
    SubTitle = "1.2.2 by dawid"
})

local Main = Win:AddTab("Main")
local Settings = Win:AddTab("Settings")

Main:AddToggle({Text="God Mode", Default=false}, function(state) print("God:",state) end)
Main:AddSlider({Text="WalkSpeed", Min=10, Max=200, Default=16}, function(val) print("Speed:",val) end)
Main:AddButton({Text="Test Button", Callback=function() print("Clicked!") end})

Settings:AddToggle({Text="Acrylic", Default=false}, function(v) print("Acrylic:",v) end)
Settings:AddToggle({Text="Transparency", Default=false}, function(v) print("Trans:",v) end)

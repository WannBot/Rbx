-- Services
local PlayerService = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")

-- Wait for player to load
local player = PlayerService.LocalPlayer
if not player then
player = PlayerService.PlayerAdded:Wait()
end

-- Wait for player GUI to be ready
player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false
screenGui.Name = "MovementRecorderGui"

-- Create Frame
local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0.5, -110, 0.5, -100)
frame.Active = true
frame.Draggable = true

-- === HEADER DAN TOMBOL KONTROL ===
local header = Instance.new("Frame")
header.Parent = frame
header.Size = UDim2.new(1, 0, 0, 25)
header.Position = UDim2.new(0, 0, 0, -50)
header.BackgroundColor3 = Color3.fromRGB(30, 60, 120)
header.BorderSizePixel = 0
header.Active = false
header.Draggable = false

local headerTitle = Instance.new("TextLabel")
headerTitle.Parent = header
headerTitle.Size = UDim2.new(1, -90, 1, 0)
headerTitle.Position = UDim2.new(0, 10, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Movement Recorder"
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.TextScaled = true
headerTitle.Font = Enum.Font.SourceSansBold

-- Tombol Close
local closeButton = Instance.new("ImageButton")
closeButton.Parent = header
closeButton.Image = "rbxassetid://6031094678" -- icon close (X)
closeButton.Size = UDim2.new(0, 18, 0, 18)
closeButton.Position = UDim2.new(1, -25, 0.5, -9)
closeButton.BackgroundTransparency = 1

-- Tombol Fullscreen
local fullButton = Instance.new("ImageButton")
fullButton.Parent = header
fullButton.Image = "rbxassetid://6031091004" -- icon expand
fullButton.Size = UDim2.new(0, 18, 0, 18)
fullButton.Position = UDim2.new(1, -50, 0.5, -9)
fullButton.BackgroundTransparency = 1

-- Tombol Minimize
local minimizeButton = Instance.new("ImageButton")
minimizeButton.Parent = header
minimizeButton.Image = "rbxassetid://6035067836" -- icon minimize
minimizeButton.Size = UDim2.new(0, 18, 0, 18)
minimizeButton.Position = UDim2.new(1, -75, 0.5, -9)
minimizeButton.BackgroundTransparency = 1

-- Drag frame by clicking header
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

header.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- Logika tombol
local isMinimized = false
local isFullSize = false
local originalSize = frame.Size
local originalPosition = frame.Position

-- Minimize
minimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	for _, obj in ipairs(frame:GetChildren()) do
		if obj ~= header then
			obj.Visible = not isMinimized
		end
	end
	frame.Size = isMinimized and UDim2.new(0, 220, 0, 25) or originalSize
end)

-- Fullscreen
fullButton.MouseButton1Click:Connect(function()
	if not isFullSize then
		originalSize = frame.Size
		originalPosition = frame.Position
		frame.Size = UDim2.new(0.9, 0, 0.9, 0)
		frame.Position = UDim2.new(0.05, 0, 0.05, 0)
	else
		frame.Size = originalSize
		frame.Position = originalPosition
	end
	isFullSize = not isFullSize
end)

-- Close
closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Efek hover ringan (tombol glow)
local function addHoverEffect(button)
	button.MouseEnter:Connect(function()
		button.ImageColor3 = Color3.fromRGB(150, 200, 255)
	end)
	button.MouseLeave:Connect(function()
		button.ImageColor3 = Color3.fromRGB(255, 255, 255)
	end)
end

addHoverEffect(closeButton)
addHoverEffect(fullButton)
addHoverEffect(minimizeButton)

-- Create Buttons
local recordButton = Instance.new("TextButton")
recordButton.Parent = frame
recordButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
recordButton.Size = UDim2.new(0, 60, 0, 30)
recordButton.Position = UDim2.new(0, 10, 0, 20)
recordButton.Text = "Record"
recordButton.TextScaled = true

local stopRecordButton = Instance.new("TextButton")
stopRecordButton.Parent = frame
stopRecordButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
stopRecordButton.Size = UDim2.new(0, 60, 0, 30)
stopRecordButton.Position = UDim2.new(0, 80, 0, 20)
stopRecordButton.Text = "Stop Record"
stopRecordButton.TextScaled = true

local stopReplayButton = Instance.new("TextButton")
stopReplayButton.Parent = frame
stopReplayButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
stopReplayButton.Size = UDim2.new(0, 60, 0, 30)
stopReplayButton.Position = UDim2.new(0, 150, 0, 20)
stopReplayButton.Text = "Stop Replay"
stopReplayButton.TextScaled = true

local destroyButton = Instance.new("TextButton")
destroyButton.Parent = frame
destroyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
destroyButton.Size = UDim2.new(0, 90, 0, 30)
destroyButton.Position = UDim2.new(0, 10, 0, 60)
destroyButton.Text = "Destroy"
destroyButton.TextScaled = true

local deleteButton = Instance.new("TextButton")
deleteButton.Parent = frame
deleteButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
deleteButton.Size = UDim2.new(0, 90, 0, 30)
deleteButton.Position = UDim2.new(0, 120, 0, 60)
deleteButton.Text = "Delete"
deleteButton.TextScaled = true

-- Status Indicator
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = frame
statusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Size = UDim2.new(0, 220, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0, -30)
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.TextScaled = true

-- Create Scrollable List
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Parent = frame
scrollFrame.Size = UDim2.new(0, 200, 0, 80)
scrollFrame.Position = UDim2.new(0, 10, 0, 140)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Dynamically adjusted
scrollFrame.ScrollBarThickness = 8

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.Padding = UDim.new(0, 5)

-- Variables for recording and platforms
local recording = false
local replaying = false
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") -- Get the Humanoid
local platforms = {}
local yellowPlatforms = {}
local platformData = {}
local platformCounter = 0
local lastPosition = nil
local replayThread
local yellowToRedMapping = {} -- Mapping of yellow platforms to red platforms

-- Add these variables at the top with other declarations
local currentReplayThread = nil
local shouldStopReplay = false
local currentPlatformIndex = 0
local totalPlatformsToPlay = 0
local currentRecordingPlatform = nil -- Track the platform currently being recorded

-- Global Variables for Force Movement (from provided script)
local forceActiveConnection = nil
local forceSpeedMultiplier = 1.0 -- 1.0 = same as walk speed, 2.0 = double walk speed, etc.
local isClimbing = false
local allConnections = {} -- Table to hold all connections for easy cleanup from the force script

-- This function sets up the state-change listener for a character's humanoid
local function setupCharacterForce(characterToSetup)
local humanoidToSetup = characterToSetup:WaitForChild("Humanoid")

-- Function to update the isClimbing status  
local function onStateChanged(oldState, newState)  
    isClimbing = (newState == Enum.HumanoidStateType.Climbing)  
end  
  
-- Connect to the StateChanged event and store the connection for later cleanup  
local stateConnection = humanoidToSetup.StateChanged:Connect(onStateChanged)  
table.insert(allConnections, stateConnection)

end

-- Function to stop the force movement
local function stopForceMovement()
if forceActiveConnection then
forceActiveConnection:Disconnect()
forceActiveConnection = nil
end

local char = player.Character  
if char and char.PrimaryPart then  
    local rootPart = char.PrimaryPart  
    -- Crucially, reset velocity to avoid residual movement  
    rootPart.AssemblyLinearVelocity = Vector3.new(0, rootPart.AssemblyLinearVelocity.Y, 0)  
end

end

-- Function to start the force movement
local function startForceMovement()
if forceActiveConnection then return end

forceActiveConnection = RunService.Heartbeat:Connect(function()  
    local char = player.Character  
    local rootPart = char and char.PrimaryPart  
    local hum = char and char:FindFirstChildOfClass("Humanoid")  

    if not rootPart or not hum then  
        stopForceMovement()  
        return  
    end  
      
    -- If the character is climbing, do nothing.  
    if isClimbing then  
        return  
    end  
      
    local verticalVelocity = rootPart.AssemblyLinearVelocity.Y  
    local moveSpeed = hum.WalkSpeed * forceSpeedMultiplier  
    local lookVector = rootPart.CFrame.LookVector  
    local horizontalDirection = Vector3.new(lookVector.X, 0, lookVector.Z).Unit  
    local horizontalVelocity = horizontalDirection * moveSpeed  
      
    local finalVelocity = Vector3.new(horizontalVelocity.X, verticalVelocity, horizontalVelocity.Z)  
    rootPart.AssemblyLinearVelocity = finalVelocity  
end)

end

-- Pathfinding function
local function calculatePath(start, goal)
local path = PathfindingService:CreatePath()
path:ComputeAsync(start, goal)
return path
end

-- Helper Functions
local function isCharacterMoving()
local currentPosition = character.PrimaryPart.Position
if lastPosition then
local distance = (currentPosition - lastPosition).magnitude
lastPosition = currentPosition
return distance > 0.05
end
lastPosition = currentPosition
return false
end

local function cleanupPlatform(platform)
for i, p in ipairs(platforms) do
if p == platform then
table.remove(platforms, i)
platformData[platform] = nil
break
end
end
end

local function addPlatformToScrollFrame(platformName)
local button = Instance.new("TextButton")
button.Parent = scrollFrame
button.Size = UDim2.new(1, -10, 0, 25)
button.Text = platformName
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(150, 150, 255)

local playButton = Instance.new("TextButton")  
playButton.Parent = button  
playButton.Size = UDim2.new(0, 50, 1, 0)  
playButton.Position = UDim2.new(1, -40, 0, 0)  
playButton.Text = "Play"  
playButton.TextScaled = true  
playButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  

playButton.MouseButton1Click:Connect(function()  
    if replaying then return end  

    -- Stop any existing replay first  
    if currentReplayThread then  
        shouldStopReplay = true  
        task.wait() -- Allow cancellation to propagate  
    end  

    -- Reset control flags  
    replaying = true  
    shouldStopReplay = false  

    -- Extract platform number safely  
    local platformNumber = tonumber(button.Text:match("%d+"))  
    if not platformNumber or platformNumber < 1 or platformNumber > #platforms then  
        statusLabel.Text = "Status: Invalid platform index"  
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
        return  
    end  

    local platform = platforms[platformNumber]  

    -- Update initial status  
    statusLabel.Text = string.format("Starting playback from Platform %d", platformNumber)  
    statusLabel.TextColor3 = Color3.fromRGB(0, 0, 255)  

    -- Walk to the platform before replaying (Pathfinding Integrated)  
    local function walkToPlatform(destination)  
        local humanoidCurrent = character:WaitForChild("Humanoid")  
        local rootPart = character:WaitForChild("HumanoidRootPart")  

        -- Ensure the Humanoid is alive and can move  
        if not humanoidCurrent or humanoidCurrent.Health <= 0 then  
            return  
        end  

        local path = calculatePath(rootPart.Position, destination)  

        if path.Status == Enum.PathStatus.Success then  
            local waypoints = path:GetWaypoints()  
            for _, waypoint in ipairs(waypoints) do  
                if shouldStopReplay then break end  
                humanoidCurrent:MoveTo(waypoint.Position)  
                if waypoint.Action == Enum.PathWaypointAction.Jump then  
                    humanoidCurrent.Jump = true  
                end  
                humanoidCurrent.MoveToFinished:Wait()  
            end  
        else  
            -- Fallback: Directly move to the destination if pathfinding fails  
            humanoidCurrent:MoveTo(destination)  
            humanoidCurrent.MoveToFinished:Wait()  
        end  
    end  

    -- Replay logic for sequential platforms (Improved)  
    local function replayPlatforms(startIndex)  
        totalPlatformsToPlay = #platforms -- Total platforms  
        currentPlatformIndex = startIndex -- Starting point  

        for i = startIndex, #platforms do  
            if shouldStopReplay then break end  
              
            -- Update status with absolute position  
            statusLabel.Text = string.format("Playing from Platform %d/%d", currentPlatformIndex, totalPlatformsToPlay)  
            statusLabel.TextColor3 = Color3.fromRGB(0, 0, 255)  
              
            local currentPlatform = platforms[i]  
              
            -- PHASE 1: Walk to platform using pathfinding (NO FORCE MOVEMENT)  
            stopForceMovement() -- Ensure force movement is off during pathfinding  
            walkToPlatform(currentPlatform.Position + Vector3.new(0, 3, 0))  
              
            if shouldStopReplay then break end -- Check if replay was stopped during pathfinding  

            local movements = platformData[currentPlatform]  
            if movements then  
                -- PHASE 2: Interpolate movements (ACTIVATE FORCE MOVEMENT)  
                startForceMovement() -- Activate force movement for interpolation  

                for j = 1, #movements - 1 do  
                    if shouldStopReplay then break end   

                    local startMovement = movements[j]  
                    local endMovement = movements[j + 1]  
                    endMovement.isJumping = startMovement.isJumping  

                    local startTime = tick()  

                    local distance = (endMovement.position - startMovement.position).magnitude  
                    local speedFactor = 0.01    
                    local duration = distance * speedFactor  
                    duration = math.max(duration, 0.01)  

                    local endTime = startTime + duration  

                    while tick() < endTime do  
                        if shouldStopReplay then break end  
                        local alpha = (tick() - startTime) / duration  
                        alpha = math.min(alpha, 1)  

                        local interpolatedPosition = startMovement.position:Lerp(endMovement.position, alpha)  
                        local startOrientation = startMovement.orientation  
                        local endOrientation = endMovement.orientation  
                        local interpolatedOrientation = CFrame.fromEulerAnglesXYZ(  
                            math.rad(startMovement.orientation.X),   
                            math.rad(startMovement.orientation.Y),   
                            math.rad(startMovement.orientation.Z)  
                        ):Lerp(  
                            CFrame.fromEulerAnglesXYZ(  
                                math.rad(endMovement.orientation.X),  
                                math.rad(endMovement.orientation.Y),  
                                math.rad(endMovement.orientation.Z)  
                            ),   
                            alpha  
                        )  

                        character:SetPrimaryPartCFrame(CFrame.new(interpolatedPosition) * interpolatedOrientation)  

                        if endMovement.isJumping then  
                            humanoid.Jump = true  
                        end  

                        game:GetService("RunService").Heartbeat:Wait()  
                    end  
                end  
                stopForceMovement() -- Deactivate force movement after interpolation for this platform  
            end  
            wait(0.5) -- Small pause between platforms  
            currentPlatformIndex += 1 -- Move to next platform index  
        end  
          
        -- Final cleanup after all platforms are processed or replay is stopped  
        if not shouldStopReplay then  
            statusLabel.Text = "Status: Completed all platforms"  
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  
            task.wait(1)  
        end  
          
        replaying = false  
        statusLabel.Text = "Status: Idle"  
        statusLabel.TextColor3 = Color3.fromRGB(0, 0, 0)  
        stopForceMovement() -- Ensure force movement is off when replay completely ends  
    end  

    -- Start new replay in a tracked thread  
    currentReplayThread = task.spawn(function()  
        replayPlatforms(platformNumber)  
        currentReplayThread = nil  
    end)  
end)

end

-- Modify the stopReplayButton click handler
stopReplayButton.MouseButton1Click:Connect(function()
if replaying then
shouldStopReplay = true
replaying = false
statusLabel.Text = string.format("Stopped at Platform %d/%d", currentPlatformIndex-1, totalPlatformsToPlay)
statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
task.wait(2)
statusLabel.Text = "Status: Idle"
-- Cancel any ongoing movement
if character:FindFirstChild("Humanoid") then
character.Humanoid:MoveTo(character.HumanoidRootPart.Position)
end
stopForceMovement() -- Ensure force movement is off when replay is stopped
end
end)

-- Function to add text label to a platform
local function addTextLabelToPlatform(platform, platformNumber)
local billboardGui = Instance.new("BillboardGui")
billboardGui.Size = UDim2.new(1, 0, 0.5, 0)
billboardGui.StudsOffset = Vector3.new(0, 3, 0)
billboardGui.AlwaysOnTop = true

local textLabel = Instance.new("TextLabel")  
textLabel.Size = UDim2.new(1, 0, 1, 0)  
textLabel.BackgroundTransparency = 1  
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  
textLabel.TextScaled = true  
textLabel.Text = tostring(platformNumber)  
textLabel.Parent = billboardGui  

billboardGui.Parent = platform

end

-- Function to serialize platform data to JSON
local function serializePlatformData()
local data = {
redPlatforms = {},
yellowPlatforms = {},
mappings = {}
}

-- Save red platforms  
for i, platform in ipairs(platforms) do  
    local movementsData = {}  
    for _, movement in ipairs(platformData[platform]) do  
        table.insert(movementsData, {  
            position = {X = movement.position.X, Y = movement.position.Y, Z = movement.position.Z},  
            orientation = {X = movement.orientation.X, Y = movement.orientation.Y, Z = movement.orientation.Z},  
            isJumping = movement.isJumping  
        })  
    end  
    table.insert(data.redPlatforms, {  
        position = {X = platform.Position.X, Y = platform.Position.Y, Z = platform.Position.Z},  
        movements = movementsData  
    })  
end  

-- Save yellow platforms and their mappings  
for i, yellowPlatform in ipairs(yellowPlatforms) do  
    table.insert(data.yellowPlatforms, {  
        position = {X = yellowPlatform.Position.X, Y = yellowPlatform.Position.Y, Z = yellowPlatform.Position.Z}  
    })  

    -- Store mapping index (map yellow platform to the corresponding red platform index)  
    if yellowToRedMapping[yellowPlatform] then  
        local redIndex = table.find(platforms, yellowToRedMapping[yellowPlatform])  
        table.insert(data.mappings, redIndex)  
    end  
end  

local rawData = HttpService:JSONEncode(data)  
return rawData

end

-- Function to deserialize platform data from JSON
local function deserializePlatformData(jsonData)
local success, data = pcall(function()
return HttpService:JSONDecode(jsonData)
end)

if not success then  
    warn("Failed to decode JSON data:", data)  
    statusLabel.Text = "Status: Invalid JSON data"  
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
    return  
end  

if not data or type(data) ~= "table" then  
    warn("Invalid data format after decoding JSON")  
    statusLabel.Text = "Status: Invalid data format"  
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
    return  
end  

-- Clear existing data  
for _, platform in ipairs(platforms) do platform:Destroy() end  
for _, yellowPlatform in ipairs(yellowPlatforms) do yellowPlatform:Destroy() end  
platforms = {}  
yellowPlatforms = {}  
yellowToRedMapping = {}  
platformData = {}  
platformCounter = 0  
currentRecordingPlatform = nil -- Reset this too  

-- Clear scroll frame and recreate UIListLayout  
scrollFrame:ClearAllChildren()  
local uiListLayout = Instance.new("UIListLayout")  
uiListLayout.Parent = scrollFrame  
uiListLayout.Padding = UDim.new(0, 5)  

-- Load red platforms (updated movement processing)  
if data.redPlatforms then  
    for _, platformInfo in ipairs(data.redPlatforms) do  
        local platform = Instance.new("Part")  
        platform.Size = Vector3.new(5, 1, 5)  
        platform.Position = Vector3.new(platformInfo.position.X, platformInfo.position.Y, platformInfo.position.Z)  
        platform.Anchored = true  
        platform.BrickColor = BrickColor.Red()  
        platform.CanCollide = false  
        platform.Parent = workspace  

        -- Convert serialized movement data back to proper Vector3 formats  
        local restoredMovements = {}  
        if platformInfo.movements then  
            for _, movement in ipairs(platformInfo.movements) do  
                table.insert(restoredMovements, {  
                    position = Vector3.new(movement.position.X, movement.position.Y, movement.position.Z),  
                    orientation = Vector3.new(movement.orientation.X, movement.orientation.Y, movement.orientation.Z),  
                    isJumping = movement.isJumping  
                })  
            end  
        end  

        platformData[platform] = restoredMovements  -- Store converted movements  

        addTextLabelToPlatform(platform, #platforms + 1)  
        table.insert(platforms, platform)  

        platformCounter += 1  
        addPlatformToScrollFrame("Platform " .. platformCounter)  
    end  
end  


-- Load yellow platforms and mappings  
if data.yellowPlatforms then  
    for i, yellowInfo in ipairs(data.yellowPlatforms) do  
        local yellowPlatform = Instance.new("Part")  
        yellowPlatform.Size = Vector3.new(5, 1, 5)  
        yellowPlatform.Position = Vector3.new(yellowInfo.position.X, yellowInfo.position.Y, yellowInfo.position.Z)  
        yellowPlatform.Anchored = true  
        yellowPlatform.BrickColor = BrickColor.Yellow()  
        yellowPlatform.CanCollide = false  
        yellowPlatform.Parent = workspace  

        if data.mappings and data.mappings[i] then  
            addTextLabelToPlatform(yellowPlatform, data.mappings[i])  
            -- Rebuild yellowToRedMapping using loaded platforms  
            if platforms[data.mappings[i]] then  
                yellowToRedMapping[yellowPlatform] = platforms[data.mappings[i]]  
            else  
                 warn("Mapping points to non-existent red platform index:", data.mappings[i])  
            end  
        end  
         table.insert(yellowPlatforms, yellowPlatform)  
    end  
end  


scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #platforms * 30)  
statusLabel.Text = "Status: Platform data loaded"  
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)

end

-- Handle character respawn or reset
player.CharacterAdded:Connect(function(newCharacter)
character = newCharacter
humanoid = newCharacter:WaitForChild("Humanoid") -- Get Humanoid for new character
lastPosition = nil
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(0, 0, 0)

-- Re-setup force movement character listener for new character  
for _, connection in ipairs(allConnections) do  
    connection:Disconnect()  
end  
allConnections = {}  
setupCharacterForce(newCharacter)  

if recording then  
    platformCounter = 0  
    platforms = {}  
    yellowPlatforms = {}  
    platformData = {}  
    yellowToRedMapping = {}  
    currentRecordingPlatform = nil -- Reset on character added  
    scrollFrame:ClearAllChildren()  
    local uiListLayout = Instance.new("UIListLayout")  
    uiListLayout.Parent = scrollFrame  
    uiListLayout.Padding = UDim.new(0, 5)  
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  
end  
-- Ensure force movement is off after character reset  
stopForceMovement()  
shouldStopReplay = true -- Stop any ongoing replay  
replaying = false  
if currentReplayThread then  
    task.cancel(currentReplayThread) -- Cancel the replay thread  
    currentReplayThread = nil  
end

end)

-- Initial setup for force movement
if player.Character then
setupCharacterForce(player.Character)
end
-- The CharacterAdded connection for force movement is already handled above in player.CharacterAdded:Connect

-- Button Functions
recordButton.MouseButton1Click:Connect(function()
if not recording then
recording = true
statusLabel.Text = "Status: Recording"
statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)

if #yellowPlatforms > 0 then  
        local lastYellowPlatform = yellowPlatforms[#yellowPlatforms]  
        -- Walk to the last yellow platform using pathfinding  
        local humanoidCurrent = character:WaitForChild("Humanoid")  
        local rootPart = character:WaitForChild("HumanoidRootPart")  

        -- Ensure the Humanoid is alive and can move  
        if humanoidCurrent and humanoidCurrent.Health > 0 then  
            local path = calculatePath(rootPart.Position, lastYellowPlatform.Position + Vector3.new(0, 3, 0))  

            if path.Status == Enum.PathStatus.Success then  
                local waypoints = path:GetWaypoints()  
                for _, waypoint in ipairs(waypoints) do  
                    humanoidCurrent:MoveTo(waypoint.Position)  
                    if waypoint.Action == Enum.PathWaypointAction.Jump then  
                        humanoidCurrent.Jump = true  
                    end  
                    humanoidCurrent.MoveToFinished:Wait()  
                end  
            else  
                -- Fallback: Directly move to the destination if pathfinding fails  
                humanoidCurrent:MoveTo(lastYellowPlatform.Position + Vector3.new(0, 3, 0))  
                humanoidCurrent.MoveToFinished:Wait()  
            end  
        else  
            -- Handle cases where humanoid or HumanoidRootPart are missing or invalid  
            warn("Humanoid or HumanoidRootPart is missing or invalid.")  
        end  
    else  
       character:SetPrimaryPartCFrame(CFrame.new(character.PrimaryPart.Position)) -- Added to prevent errors when no yellow platforms available  
    end  

    platformCounter += 1  
    local platform = Instance.new("Part")  
    platform.Name = "Platform " .. platformCounter  
    platform.Size = Vector3.new(5, 1, 5)  
    platform.Position = character.PrimaryPart.Position - Vector3.new(0, 3, 0)  
    platform.Anchored = true  
    platform.BrickColor = BrickColor.Red()  
    platform.CanCollide = false  
    platform.Parent = workspace  

    -- Add text label to the platform  
    addTextLabelToPlatform(platform, platformCounter)  

    table.insert(platforms, platform)  
    platformData[platform] = {}  
    currentRecordingPlatform = platform -- Set the current recording platform  

    addPlatformToScrollFrame("Platform " .. platformCounter)  
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #platforms * 30)  

    -- Start recording movement, orientation, and jump state  
    spawn(function()  
        while recording do  
            -- Check if the current recording platform still exists  
            if not currentRecordingPlatform or not currentRecordingPlatform.Parent then  
                recording = false  
                statusLabel.Text = "Error: Missing Red Platform (Recording Stopped)"  
                statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
                break -- Exit the recording loop  
            end  

            if isCharacterMoving() then  
                table.insert(platformData[currentRecordingPlatform], { -- Use currentRecordingPlatform  
                    position = character.PrimaryPart.Position,  
                    orientation = character.PrimaryPart.Orientation,  
                    isJumping = humanoid.Jump -- Record jump state  
                })  
            end  
            game:GetService("RunService").Heartbeat:Wait() -- Use Heartbeat for recording  
        end  
    end)  
end

end)

stopRecordButton.MouseButton1Click:Connect(function()
if recording then
-- Check if the current recording platform still exists before stopping
if not currentRecordingPlatform or not currentRecordingPlatform.Parent then
recording = false -- Ensure recording stops
statusLabel.Text = "Error: Missing Red Platform (Cannot Stop Record)"
statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
currentRecordingPlatform = nil -- Clear the reference
return -- Prevent spawning yellow platform
end

recording = false  
    statusLabel.Text = "Status: Stopped Recording"  
    statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)  

    local yellowPlatform = Instance.new("Part")  
    yellowPlatform.Size = Vector3.new(5, 1, 5)  
    yellowPlatform.Position = character.PrimaryPart.Position - Vector3.new(0, 3, 0)  
    yellowPlatform.Anchored = true  
    yellowPlatform.BrickColor = BrickColor.Yellow()  
    yellowPlatform.CanCollide = false  
    yellowPlatform.Parent = workspace  

    -- Add text label to the yellow platform  
    addTextLabelToPlatform(yellowPlatform, platformCounter)  

    table.insert(yellowPlatforms, yellowPlatform)  
    yellowToRedMapping[yellowPlatform] = currentRecordingPlatform -- Map yellow platform to the last red platform  
    currentRecordingPlatform = nil -- Clear the reference after stopping  
end

end)

destroyButton.MouseButton1Click:Connect(function()
for _, platform in ipairs(platforms) do
platform:Destroy()
end
for _, yellowPlatform in ipairs(yellowPlatforms) do
yellowPlatform:Destroy()
end
platforms = {}
yellowPlatforms = {}
platformData = {}
yellowToRedMapping = {}
platformCounter = 0
currentRecordingPlatform = nil -- Reset this

-- Cleanup force movement connections as well  
stopForceMovement()  
for _, connection in ipairs(allConnections) do  
    connection:Disconnect()  
end  
allConnections = {}  

screenGui:Destroy()

end)

deleteButton.MouseButton1Click:Connect(function()
-- Delete the last red platform
if #platforms > 0 then
local lastPlatform = platforms[#platforms]

-- Check if the platform being deleted is the one currently being recorded  
    if recording and lastPlatform == currentRecordingPlatform then  
        recording = false -- Stop recording immediately  
        statusLabel.Text = "Error: Missing Red Platform (Recording Stopped)"  
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
        currentRecordingPlatform = nil -- Clear the reference  
    end  

    lastPlatform:Destroy()  
    cleanupPlatform(lastPlatform)  -- Removes from platforms array  

    -- Delete corresponding button (only TextButtons)  
    local buttons = {}  
    for _, child in ipairs(scrollFrame:GetChildren()) do  
        if child:IsA("TextButton") then  
            table.insert(buttons, child)  
        end  
    end  
    if #buttons > 0 then  
        buttons[#buttons]:Destroy()  
    end  

    platformCounter -= 1  
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #platforms * 30)  
end  

-- Cleanup yellow platforms  
for yellowPlatform, redPlatform in pairs(yellowToRedMapping) do  
    if not table.find(platforms, redPlatform) then  
        yellowPlatform:Destroy()  
        yellowToRedMapping[yellowPlatform] = nil  
        local index = table.find(yellowPlatforms, yellowPlatform)  
        if index then  
             table.remove(yellowPlatforms, index)  
        end  
    end  
end

end)

-- First, add these variables to your variables section at the top
local saveChunks = {}
local currentChunkIndex = 0
local totalChunks = 0
local CHUNK_SIZE = 20 -- This is the number of platforms per chunk, adjust based on your clipboard size limits

-- Replace your existing saveButton.MouseButton1Click with this:
local saveButton = Instance.new("TextButton")
saveButton.Parent = frame
saveButton.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
saveButton.Size = UDim2.new(0, 90, 0, 30)
saveButton.Position = UDim2.new(0, 10, 0, 90)
saveButton.Text = "Save"
saveButton.TextScaled = true

saveButton.MouseButton1Click:Connect(function()
    local jsonData = serializePlatformData()
    local folderPath = "AutoWalk"

    -- Buat folder jika belum ada
    if makefolder and not isfolder(folderPath) then
        makefolder(folderPath)
    end

    -- Tentukan nama file
    local fileName = folderPath .. "/AutoWalk_Path_" .. os.date("%Y%m%d_%H%M%S") .. ".json"

    -- Simpan file JSON
    if writefile then
        local success, err = pcall(function()
            writefile(fileName, jsonData)
        end)

        if success then
            statusLabel.Text = "✅ Saved to file: " .. fileName
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            statusLabel.Text = "❌ Failed to save: " .. tostring(err)
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    else
        -- Fallback kalau executor tidak support writefile
        if setclipboard then
            setclipboard(jsonData)
            statusLabel.Text = "📋 Copied JSON (writefile not supported)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        else
            statusLabel.Text = "❌ Cannot save file (unsupported)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)
          

-- Add a new button for navigating chunks
local nextChunkButton = Instance.new("TextButton")
nextChunkButton.Parent = frame
nextChunkButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
nextChunkButton.Size = UDim2.new(0, 90, 0, 30)
nextChunkButton.Position = UDim2.new(0, 120, 0, 90)  -- Next to the save button
nextChunkButton.Text = "Next Chunk"
nextChunkButton.TextScaled = true

nextChunkButton.MouseButton1Click:Connect(function()
if #saveChunks > 0 and currentChunkIndex < totalChunks then
currentChunkIndex = currentChunkIndex + 1
setclipboard(saveChunks[currentChunkIndex])
statusLabel.Text = string.format("Chunk %d/%d copied. Save it before continuing",
currentChunkIndex, totalChunks)
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
elseif currentChunkIndex == totalChunks then
statusLabel.Text = "All chunks have been copied"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
else
statusLabel.Text = "No chunks to copy"
statusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
end
end)

-- === Resize Handle ===
local UserInputService = game:GetService("UserInputService")

local resizeHandle = Instance.new("Frame")
resizeHandle.Parent = frame
resizeHandle.Size = UDim2.new(0, 15, 0, 15)
resizeHandle.AnchorPoint = Vector2.new(1, 1)
resizeHandle.Position = UDim2.new(1, 0, 1, 0)
resizeHandle.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
resizeHandle.BorderSizePixel = 0
resizeHandle.Active = true
resizeHandle.Draggable = false

local resizing = false
local dragStart, startSize

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		dragStart = input.Position
		startSize = frame.Size
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Size = UDim2.new(startSize.X.Scale, startSize.X.Offset + delta.X, startSize.Y.Scale, startSize.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = false
	end
end)

-- TextLabel for instructions
local pasteLabel = Instance.new("TextLabel")
pasteLabel.Parent = frame
pasteLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pasteLabel.Size = UDim2.new(0, 200, 0, 20)
pasteLabel.Position = UDim2.new(0, 10, 0, 230)
pasteLabel.Text = "Paste Platform Data Here"
pasteLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
pasteLabel.TextScaled = true

-- TextBox for pasting platform data
local pasteTextBox = Instance.new("TextBox")
pasteTextBox.Parent = frame
pasteTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pasteTextBox.Size = UDim2.new(0, 200, 0, 30)
pasteTextBox.Position = UDim2.new(0, 10, 0, 255)
pasteTextBox.Text = ""
pasteTextBox.PlaceholderText = "Paste JSON data here"
pasteTextBox.ClearTextOnFocus = false
pasteTextBox.MultiLine = true
pasteTextBox.TextScaled = true

-- Load Button: Paste and deserialize platform data
local loadButton = Instance.new("TextButton")
loadButton.Parent = frame
loadButton.BackgroundColor3 = Color3.fromRGB(255, 255, 100)
loadButton.Size = UDim2.new(0, 90, 0, 25)
loadButton.Position = UDim2.new(0, 10, 0, 290)
loadButton.Text = "Load"
loadButton.TextScaled = true

-- Modify the load button to handle combined chunks and URL loading
loadButton.MouseButton1Click:Connect(function()
local input = pasteTextBox.Text

-- Check for empty input (after trimming whitespace)  
if input:gsub("%s", "") == "" then  
    statusLabel.Text = "Status: No data to load"  
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
    return -- Stop if no input  
end  

local loadedSuccessfully = false  

-- Check if input is a URL  
if input:match("^https?://") then  
    statusLabel.Text = "Loading 0%"  
    local url = input  
    local success, response = pcall(function()  
        return game:HttpGet(url, true, function(content, contentLength)  
            local progress = math.floor((#content/contentLength)*100)  
            statusLabel.Text = "Loading "..progress.."%"  
        end)  
    end)  

    if success then  
        -- Try to handle stacked JSON objects from URL  
        local combinedData = {  
            redPlatforms = {},  
            yellowPlatforms = {},  
            mappings = {}  
        }  
          
        local redPlatformOffset = 0  
        local successfulParsing = false  
          
        -- Split the response by lines or potential JSON objects  
        for jsonStr in response:gmatch("[^\r\n]+") do  
            local parseSuccess, chunk = pcall(function()  
                return HttpService:JSONDecode(jsonStr)  
            end)  
              
            -- Check if it's a valid chunk format  
            if parseSuccess and type(chunk) == "table" and type(chunk.redPlatforms) == "table" then  
                successfulParsing = true  
                  
                -- Add all red platforms  
                for _, platform in ipairs(chunk.redPlatforms) do  
                    table.insert(combinedData.redPlatforms, platform)  
                end  
                  
                -- Add all yellow platforms with adjusted mappings  
                if type(chunk.yellowPlatforms) == "table" then  
                    for i, yellowPlatform in ipairs(chunk.yellowPlatforms) do  
                        table.insert(combinedData.yellowPlatforms, yellowPlatform)  
                        -- Adjust the mapping to account for the offset  
                        if type(chunk.mappings) == "table" and chunk.mappings[i] then  
                            table.insert(combinedData.mappings, chunk.mappings[i] + redPlatformOffset)  
                        end  
                    end  
                end  
                  
                -- Update offset for next chunk  
                redPlatformOffset = redPlatformOffset + #chunk.redPlatforms  
            end  
        end  
          
        if successfulParsing then  
             -- Only clear if we successfully parsed *at least one* chunk  
            if #platforms > 0 or #yellowPlatforms > 0 then  
                for _, platform in ipairs(platforms) do platform:Destroy() end  
                for _, yellowPlatform in ipairs(yellowPlatforms) do yellowPlatform:Destroy() end  
                platforms = {}  
                yellowPlatforms = {}  
                platformData = {}  
                yellowToRedMapping = {}  
                platformCounter = 0  
                currentRecordingPlatform = nil -- Reset this too  
                scrollFrame:ClearAllChildren()  
                local uiListLayout = Instance.new("UIListLayout")  
                uiListLayout.Parent = scrollFrame  
                uiListLayout.Padding = UDim.new(0, 5)  
                scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  
            end  

            -- Convert combined data to JSON and load  
            local combinedJson = HttpService:JSONEncode(combinedData)  
            deserializePlatformData(combinedJson) -- This function handles its own validation/errors  
            loadedSuccessfully = true -- Indicate success  
        else  
            -- If stacked parsing failed, try loading as a single JSON object  
            local successDeserialize = pcall(deserializePlatformData, response) -- deserializePlatformData has internal validation  

            if successDeserialize then  
                -- deserializePlatformData handles clearing if successful  
                 loadedSuccessfully = true -- Indicate success  
            end  
        end  
    else  
        statusLabel.Text = "Load failed: "..tostring(response):sub(1,50)  
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
        return -- Stop if URL fetch fails  
    end  
else  
    -- Not a URL, treat as direct JSON input  
    local inputJson = input  
      
    -- Try to handle stacked JSON objects  
    local combinedData = {  
        redPlatforms = {},  
        yellowPlatforms = {},  
        mappings = {}  
    }  
      
    local redPlatformOffset = 0  
    local successfulParsing = false  
      
    -- Split the input by lines or potential JSON objects  
    for jsonStr in inputJson:gmatch("[^\r\n]+") do  
        local success, chunk = pcall(function()  
            return HttpService:JSONDecode(jsonStr)  
        end)  
          
        -- Check if it's a valid chunk format  
        if success and type(chunk) == "table" and type(chunk.redPlatforms) == "table" then  
            successfulParsing = true  
              
            -- Add all red platforms  
            for _, platform in ipairs(chunk.redPlatforms) do  
                table.insert(combinedData.redPlatforms, platform)  
            end  
              
            -- Add all yellow platforms with adjusted mappings  
             if type(chunk.yellowPlatforms) == "table" then  
                for i, yellowPlatform in ipairs(chunk.yellowPlatforms) do  
                    table.insert(combinedData.yellowPlatforms, yellowPlatform)  
                    -- Adjust the mapping to account for the offset  
                    if type(chunk.mappings) == "table" and chunk.mappings[i] then  
                        table.insert(combinedData.mappings, chunk.mappings[i] + redPlatformOffset)  
                    end  
                end  
            end  
              
            -- Update offset for next chunk  
            redPlatformOffset = redPlatformOffset + #chunk.redPlatforms  
        end  
    end  
      
    if successfulParsing then  
        -- Only clear if we successfully parsed *at least one* chunk  
        if #platforms > 0 or #yellowPlatforms > 0 then  
            for _, platform in ipairs(platforms) do platform:Destroy() end  
            for _, yellowPlatform in ipairs(yellowPlatforms) do yellowPlatform:Destroy() end  
            platforms = {}  
            yellowPlatforms = {}  
            platformData = {}  
            yellowToRedMapping = {}  
            platformCounter = 0  
            currentRecordingPlatform = nil -- Reset this too  
             scrollFrame:ClearAllChildren()  
            local uiListLayout = Instance.new("UIListLayout")  
            uiListLayout.Parent = scrollFrame  
            uiListLayout.Padding = UDim.new(0, 5)  
             scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)  
        end  

        -- Convert combined data to JSON and load  
        local combinedJson = HttpService:JSONEncode(combinedData)  
        deserializePlatformData(combinedJson) -- This function handles its own validation/errors  
        loadedSuccessfully = true -- Indicate success  
    else  
        -- If stacked parsing failed, try loading as a single JSON object  
        local successDeserialize = pcall(deserializePlatformData, inputJson) -- deserializePlatformData has internal validation  

        if successDeserialize then  
            -- deserializePlatformData handles clearing if successful  
            loadedSuccessfully = true -- Indicate success  
        end  
    end  
end  

-- Final status update based on whether anything was loaded  
if loadedSuccessfully then  
    statusLabel.Text = "Status: Platform data loaded"  
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  
else  
    -- If deserializePlatformData itself failed (handled internally),   
    -- its status message is already shown. If the input was just invalid   
    -- and didn't match URL/stacked/single JSON, show a generic parse error.  
     -- This check might be redundant if deserializePlatformData always sets status  
     -- but it's a fallback in case the initial parsing attempts fail.  
     if statusLabel.Text == "Status: Idle" or statusLabel.TextColor3 == Color3.fromRGB(0,0,0) then  
         statusLabel.Text = "Status: Failed to parse data"  
         statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)  
     end  
end

end)

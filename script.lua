-- LocalScript (Place in StarterPlayerScripts or StarterGui)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Configuration
local TARGET_PATH = "workspace>Map>Stage_10>WinPart"
local FALLBACK_CFRAME = CFrame.new(
    -2163.90015, 62.7859077, -15.7000008,
    -1.1920929e-07, 0, 1.00000012,
    0, 1, 0,
    -1.00000012, 0, -1.1920929e-07
)
local TELEPORT_ATTEMPTS = 50
local CHECK_INTERVAL = 0.01 -- Check every 0.01 seconds

-- Parse the path
local function getPartFromPath(path)
    local parts = {}
    for part in string.gmatch(path, "[^>]+") do
        table.insert(parts, part)
    end
    
    local current = workspace
    for _, partName in ipairs(parts) do
        current = current:FindFirstChild(partName)
        if not current then
            return nil
        end
    end
    return current
end

-- Create CheatPanel GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Main Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 320, 0, 400)
panel.Position = UDim2.new(0.5, -160, 0.5, -200)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 1
panel.BorderColor3 = Color3.fromRGB(60, 60, 70)
panel.Active = true
panel.Draggable = true
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "⚡ CHEAT PANEL"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button (now toggles instead of closes)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 1, -10)
toggleButton.Position = UDim2.new(1, -35, 0, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "◀"
toggleButton.Parent = titleBar

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent = toggleButton

-- Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -60)
contentContainer.Position = UDim2.new(0, 10, 0, 50)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = panel

-- Section Label
local sectionLabel = Instance.new("TextLabel")
sectionLabel.Size = UDim2.new(1, 0, 0, 25)
sectionLabel.Position = UDim2.new(0, 0, 0, 0)
sectionLabel.BackgroundTransparency = 1
sectionLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
sectionLabel.TextSize = 14
sectionLabel.Font = Enum.Font.GothamBold
sectionLabel.Text = "TELEPORT CONTROL"
sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
sectionLabel.Parent = contentContainer

-- Teleport Toggle Switch (Slide)
local toggleSection = Instance.new("Frame")
toggleSection.Size = UDim2.new(1, 0, 0, 60)
toggleSection.Position = UDim2.new(0, 0, 0, 30)
toggleSection.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleSection.BorderSizePixel = 0
toggleSection.Parent = contentContainer

local toggleSectionCorner = Instance.new("UICorner")
toggleSectionCorner.CornerRadius = UDim.new(0, 6)
toggleSectionCorner.Parent = toggleSection

-- Toggle Label
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(0.5, 0, 1, 0)
toggleLabel.Position = UDim2.new(0, 15, 0, 0)
toggleLabel.BackgroundTransparency = 1
toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleLabel.TextSize = 14
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.Text = "TELEPORT"
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = toggleSection

-- Toggle Switch
local toggleSwitch = Instance.new("Frame")
toggleSwitch.Size = UDim2.new(0, 60, 0, 30)
toggleSwitch.Position = UDim2.new(1, -75, 0.5, -15)
toggleSwitch.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleSwitch.BorderSizePixel = 0
toggleSwitch.Parent = toggleSection

local toggleSwitchCorner = Instance.new("UICorner")
toggleSwitchCorner.CornerRadius = UDim.new(1, 0)
toggleSwitchCorner.Parent = toggleSwitch

-- Toggle Knob
local toggleKnob = Instance.new("Frame")
toggleKnob.Size = UDim2.new(0, 24, 0, 24)
toggleKnob.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
toggleKnob.BorderSizePixel = 0
toggleKnob.Parent = toggleSwitch

local toggleKnobCorner = Instance.new("UICorner")
toggleKnobCorner.CornerRadius = UDim.new(1, 0)
toggleKnobCorner.Parent = toggleKnob

-- Status Display
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 80)
statusFrame.Position = UDim2.new(0, 0, 0, 100)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = contentContainer

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusFrame

-- Status Labels
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 0.4, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 2)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = "● Teleport: OFF"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

local positionStatus = Instance.new("TextLabel")
positionStatus.Size = UDim2.new(1, -10, 0.3, 0)
positionStatus.Position = UDim2.new(0, 5, 0.4, 0)
positionStatus.BackgroundTransparency = 1
positionStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
positionStatus.TextSize = 10
positionStatus.Font = Enum.Font.Gotham
positionStatus.Text = "Position: Checking..."
positionStatus.TextXAlignment = Enum.TextXAlignment.Left
positionStatus.Parent = statusFrame

local targetStatus = Instance.new("TextLabel")
targetStatus.Size = UDim2.new(1, -10, 0.3, 0)
targetStatus.Position = UDim2.new(0, 5, 0.7, 0)
targetStatus.BackgroundTransparency = 1
targetStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
targetStatus.TextSize = 10
targetStatus.Font = Enum.Font.Gotham
targetStatus.Text = "Target: Unknown"
targetStatus.TextXAlignment = Enum.TextXAlignment.Left
targetStatus.Parent = statusFrame

-- Stats Display
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, 0, 0, 60)
statsFrame.Position = UDim2.new(0, 0, 0, 190)
statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statsFrame.BorderSizePixel = 0
statsFrame.Parent = contentContainer

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 6)
statsCorner.Parent = statsFrame

local attemptsLabel = Instance.new("TextLabel")
attemptsLabel.Size = UDim2.new(1, -10, 0.5, 0)
attemptsLabel.Position = UDim2.new(0, 5, 0, 2)
attemptsLabel.BackgroundTransparency = 1
attemptsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
attemptsLabel.TextSize = 10
attemptsLabel.Font = Enum.Font.Gotham
attemptsLabel.Text = "Attempts: 0"
attemptsLabel.TextXAlignment = Enum.TextXAlignment.Left
attemptsLabel.Parent = statsFrame

local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(1, -10, 0.5, 0)
distanceLabel.Position = UDim2.new(0, 5, 0.5, 0)
distanceLabel.BackgroundTransparency = 1
distanceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
distanceLabel.TextSize = 10
distanceLabel.Font = Enum.Font.Gotham
distanceLabel.Text = "Distance: -"
distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
distanceLabel.Parent = statsFrame

-- State variables
local isTeleporting = false
local isTeleportEnabled = false
local teleportConnection = nil
local positionCheckConnection = nil
local targetPart = nil
local useFallback = false
local currentAttempts = 0
local targetPosition = Vector3.new(0, 0, 0)

-- Update status function
local function updateStatus(text, color, icon)
    statusLabel.Text = (icon or "●") .. " " .. text
    statusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

-- Update target info
local function updateTargetInfo(found)
    if found then
        targetStatus.Text = "✅ Target: WinPart (Found)"
        targetStatus.TextColor3 = Color3.fromRGB(50, 255, 50)
    else
        targetStatus.Text = "⚠️ Target: Using Fallback"
        targetStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
    end
end

-- Check if player is at target position
local function isPlayerAtTarget()
    character = player.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local distance = (rootPart.Position - targetPosition).Magnitude
    return distance < 2
end

-- Teleport function with continuous checking
local function performTeleport()
    if isTeleporting then return end
    
    -- Get character
    character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        updateStatus("No character!", Color3.fromRGB(255, 50, 50), "❌")
        return
    end
    
    -- Get target
    targetPart = getPartFromPath(TARGET_PATH)
    local targetCFrame
    
    if targetPart then
        targetCFrame = targetPart.CFrame
        updateTargetInfo(true)
    else
        targetCFrame = FALLBACK_CFRAME
        useFallback = true
        updateTargetInfo(false)
    end
    
    targetPosition = targetCFrame.Position + Vector3.new(0, 5, 0)
    isTeleporting = true
    currentAttempts = 0
    
    updateStatus("Teleporting...", Color3.fromRGB(255, 200, 50), "🔄")
    
    -- Start continuous checking
    local checkCount = 0
    local maxChecks = 500 -- Check for ~5 seconds (500 * 0.01 = 5 seconds)
    local teleportSuccess = false
    
    -- Position check loop
    while checkCount < maxChecks and isTeleportEnabled do
        checkCount = checkCount + 1
        currentAttempts = currentAttempts + 1
        
        -- Update UI
        attemptsLabel.Text = "Attempts: " .. currentAttempts
        
        -- Check if already at target
        if isPlayerAtTarget() then
            teleportSuccess = true
            updateStatus("Position secured!", Color3.fromRGB(50, 255, 50), "✅")
            break
        end
        
        -- Teleport to target
        rootPart.CFrame = CFrame.new(targetPosition) * targetCFrame.Rotation
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        -- Update distance
        local currentDistance = (rootPart.Position - targetPosition).Magnitude
        distanceLabel.Text = string.format("Distance: %.2f", currentDistance)
        
        -- Check if teleport worked
        if currentDistance < 2 then
            teleportSuccess = true
            updateStatus("Teleported!", Color3.fromRGB(50, 255, 50), "✅")
            break
        end
        
        -- Wait 0.01 seconds before next check
        task.wait(CHECK_INTERVAL)
    end
    
    if teleportSuccess then
        -- Hold position for 1-3 seconds with continuous checking
        local holdTime = math.random(10, 30) / 10
        updateStatus(string.format("Holding (%.1fs)...", holdTime), Color3.fromRGB(255, 200, 50), "⏱️")
        
        local startTime = tick()
        local holdChecks = 0
        
        while tick() - startTime < holdTime and isTeleportEnabled do
            holdChecks = holdChecks + 1
            
            -- Check if still at position
            if not isPlayerAtTarget() then
                -- Reposition
                rootPart.CFrame = CFrame.new(targetPosition) * targetCFrame.Rotation
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                updateStatus("Repositioning...", Color3.fromRGB(255, 200, 50), "🔄")
            end
            
            -- Update distance during hold
            local currentDist = (rootPart.Position - targetPosition).Magnitude
            distanceLabel.Text = string.format("Distance: %.2f", currentDist)
            
            task.wait(CHECK_INTERVAL)
        end
        
        updateStatus("Position secured!", Color3.fromRGB(50, 255, 50), "✅")
    else
        updateStatus("Failed to teleport!", Color3.fromRGB(255, 50, 50), "❌")
    end
    
    isTeleporting = false
end

-- Toggle teleport on/off
local function toggleTeleport()
    isTeleportEnabled = not isTeleportEnabled
    
    if isTeleportEnabled then
        -- Turn ON
        toggleSwitch.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        toggleKnob.Position = UDim2.new(0.55, 0, 0.1, 0)
        toggleButton.Text = "▶"
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        updateStatus("Teleport: ON", Color3.fromRGB(50, 255, 50), "🟢")
        
        -- Start teleport loop
        if teleportConnection then
            teleportConnection:Disconnect()
        end
        
        teleportConnection = RunService.Heartbeat:Connect(function()
            if isTeleportEnabled and not isTeleporting then
                performTeleport()
            end
        end)
        
        -- Start position monitoring
        if positionCheckConnection then
            positionCheckConnection:Disconnect()
        end
        
        positionCheckConnection = RunService.Heartbeat:Connect(function()
            if isTeleportEnabled and not isTeleporting then
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local pos = rootPart.Position
                    positionStatus.Text = string.format("Position: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
                    
                    -- Check distance to target
                    if targetPosition ~= Vector3.new(0, 0, 0) then
                        local dist = (pos - targetPosition).Magnitude
                        distanceLabel.Text = string.format("Distance: %.2f", dist)
                    end
                end
            end
        end)
        
        -- Perform initial teleport
        task.wait(0.1)
        if isTeleportEnabled and not isTeleporting then
            performTeleport()
        end
        
    else
        -- Turn OFF
        toggleSwitch.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        toggleKnob.Position = UDim2.new(0.05, 0, 0.1, 0)
        toggleButton.Text = "◀"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        updateStatus("Teleport: OFF", Color3.fromRGB(200, 200, 200), "●")
        
        -- Stop connections
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        
        if positionCheckConnection then
            positionCheckConnection:Disconnect()
            positionCheckConnection = nil
        end
        
        isTeleporting = false
        currentAttempts = 0
        attemptsLabel.Text = "Attempts: 0"
        distanceLabel.Text = "Distance: -"
    end
end

-- Toggle button click (title bar)
toggleButton.MouseButton1Click:Connect(toggleTeleport)

-- Toggle switch click
local toggleHitbox = Instance.new("TextButton")
toggleHitbox.Size = UDim2.new(1, 0, 1, 0)
toggleHitbox.Position = UDim2.new(0, 0, 0, 0)
toggleHitbox.BackgroundTransparency = 1
toggleHitbox.Text = ""
toggleHitbox.Parent = toggleSwitch

toggleHitbox.MouseButton1Click:Connect(toggleTeleport)

-- Label click
toggleLabel.MouseButton1Click:Connect(toggleTeleport)

-- Keyboard shortcut (Insert key to toggle)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleTeleport()
    end
end)

-- Panel visibility toggle (double click title bar)
local lastClickTime = 0
titleBar.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastClickTime < 0.3 then
        panel.Visible = not panel.Visible
    end
    lastClickTime = currentTime
end)

-- Monitor target availability
RunService.Heartbeat:Connect(function()
    if not isTeleporting then
        local part = getPartFromPath(TARGET_PATH)
        if part then
            targetPart = part
            if targetStatus.Text:find("Fallback") then
                updateTargetInfo(true)
            end
        else
            if targetStatus.Text:find("Found") then
                updateTargetInfo(false)
            end
        end
    end
end)

-- Character respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
end)

print("🔥 CheatPanel loaded!")
print("🔄 Click toggle or press INSERT to start/stop teleport")
print("🎯 Target: workspace>Map>Stage_10>WinPart")
print("📍 Fallback: " .. tostring(FALLBACK_CFRAME.Position))
print("⏱️ Checking position every 0.01 seconds")

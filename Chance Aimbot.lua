--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui") 

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") 

--// Tạo luồng chạy độc lập
task.spawn(function()
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local network = modules and modules:FindFirstChild("Network")
    local RemoteEvent = network and network:FindFirstChild("RemoteEvent")

    --// GUI Setup
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ChanceAimbotUI_Protected"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    -- Main draggable frame
    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    mainFrame.AutomaticSize = Enum.AutomaticSize.Y
    mainFrame.Size = UDim2.new(0, 180, 0, 0)
    mainFrame.Position = UDim2.new(0, 20, 0, 100)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = mainFrame

    -- Dragging logic
    local dragging, dragInput, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Hide/Unhide Button
    local hideButton = Instance.new("TextButton")
    hideButton.Size = UDim2.new(0, 40, 0, 40)
    hideButton.Position = UDim2.new(0, 20, 0, 20)
    hideButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    hideButton.TextColor3 = Color3.new(1, 1, 1)
    hideButton.TextScaled = true
    hideButton.Text = "HIDE"
    hideButton.Active = true
    hideButton.Draggable = true
    hideButton.Parent = screenGui

    local uiHidden = false
    hideButton.MouseButton1Click:Connect(function()
        uiHidden = not uiHidden
        for _, child in ipairs(screenGui:GetChildren()) do
            if child ~= hideButton then child.Visible = not uiHidden end
        end
        hideButton.Text = uiHidden and "UNHIDE" or "HIDE"
    end)

    -- Buttons Setup
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 140, 0, 30)
    toggleButton.LayoutOrder = 1
    toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Text = "Chance Aim: OFF"
    toggleButton.Parent = mainFrame

    local modeButton = Instance.new("TextButton")
    modeButton.Size = UDim2.new(0, 140, 0, 30)
    modeButton.LayoutOrder = 2
    modeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    modeButton.TextColor3 = Color3.new(1, 1, 1)
    modeButton.Text = "Prediction Mode: Velocity"
    modeButton.Parent = mainFrame

    local aimModeButton = Instance.new("TextButton")
    aimModeButton.Size = UDim2.new(0, 140, 0, 30)
    aimModeButton.LayoutOrder = 4
    aimModeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    aimModeButton.TextColor3 = Color3.new(1, 1, 1)
    aimModeButton.Text = "Aim Behavior Mode: Normal"
    aimModeButton.Parent = mainFrame

    local spinSpeedBox = Instance.new("TextBox")
    spinSpeedBox.Size = UDim2.new(0, 140, 0, 30)
    spinSpeedBox.LayoutOrder = 5
    spinSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    spinSpeedBox.TextColor3 = Color3.new(1, 1, 1)
    spinSpeedBox.Text = "0.5"
    spinSpeedBox.PlaceholderText = "Spin Duration (sec)"
    spinSpeedBox.ClearTextOnFocus = false
    spinSpeedBox.Visible = false
    spinSpeedBox.Parent = mainFrame

    local predictionBox = Instance.new("TextBox")
    predictionBox.Size = UDim2.new(0, 140, 0, 30)
    predictionBox.LayoutOrder = 3
    predictionBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    predictionBox.TextColor3 = Color3.new(1, 1, 1)
    predictionBox.Text = "4"
    predictionBox.PlaceholderText = "Prediction (Velocity)"
    predictionBox.ClearTextOnFocus = false
    predictionBox.Visible = true
    predictionBox.Parent = mainFrame

    local messageToggleButton = Instance.new("TextButton")
    messageToggleButton.Size = UDim2.new(0, 140, 0, 30)
    messageToggleButton.LayoutOrder = 6
    messageToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    messageToggleButton.TextColor3 = Color3.new(1, 1, 1)
    messageToggleButton.Text = "Message When Aim: OFF"
    messageToggleButton.Parent = mainFrame

    local messageBox = Instance.new("TextBox")
    messageBox.Size = UDim2.new(0, 140, 0, 30)
    messageBox.LayoutOrder = 7
    messageBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    messageBox.TextColor3 = Color3.new(1, 1, 1)
    messageBox.PlaceholderText = "Message to send"
    messageBox.ClearTextOnFocus = false
    messageBox.Text = "Target Locked!"
    messageBox.Visible = false
    messageBox.Parent = mainFrame

    local autoCoinflipToggle = Instance.new("TextButton")
    autoCoinflipToggle.Size = UDim2.new(0, 140, 0, 30)
    autoCoinflipToggle.LayoutOrder = 8
    autoCoinflipToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    autoCoinflipToggle.TextColor3 = Color3.new(1, 1, 1)
    autoCoinflipToggle.Text = "Auto Coinflip: OFF"
    autoCoinflipToggle.Parent = mainFrame

    -- ĐÃ CHỈNH SỬA TÊN: "Charges: 1/2/3"
    local chargesLimitButton = Instance.new("TextButton")
    chargesLimitButton.Size = UDim2.new(0, 140, 0, 30)
    chargesLimitButton.LayoutOrder = 9
    chargesLimitButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    chargesLimitButton.TextColor3 = Color3.new(1, 1, 1)
    chargesLimitButton.Text = "Charges: 2"
    chargesLimitButton.Visible = false
    chargesLimitButton.Parent = mainFrame

    -- Config & States
    local active = false
    local predictionMode = "Velocity"
    local aimMode = "Normal"
    local aimDuration = 1.51
    local spinDuration = 0.5
    local movementThreshold = 0.5
    local aimTargets = {"Slasher", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Guest666", "Nosferatu", "REDZ_GUY", "skibidi", "kibidi", "tommylikesroblox"}

    local messageWhenAim = false
    local messageSentThisAim = false
    
    local autoCoinflip = false
    local maxChargesLimit = 2
    local coinflipCooldown = 1.76 

    -- Các biến ghim mục tiêu UI Coin Flip
    local targetChargesLabel = nil
    local targetCoinFlipBtn = nil

    local Humanoid, HRP = nil, nil
    local lastTriggerTime = 0
    local aiming = false
    local prevFlintVisibleAim = false
    local originalAutoRotate = nil

    -- Buttons Logic
    toggleButton.MouseButton1Click:Connect(function()
        active = not active
        toggleButton.Text = active and "Chance Aim: ON" or "Chance Aim: OFF"
    end)

    modeButton.MouseButton1Click:Connect(function()
        if predictionMode == "Velocity" then
            predictionMode = "Ping"
            modeButton.Text = "Prediction Mode: Ping"
            predictionBox.Visible = false
        elseif predictionMode == "Ping" then
            predictionMode = "Infront HRP"
            modeButton.Text = "Prediction Mode: Infront HRP"
            predictionBox.Visible = true
            predictionBox.PlaceholderText = "Studs Infront Target"
        elseif predictionMode == "Infront HRP" then
            predictionMode = "Infront HRP (Ping Adjust)"
            modeButton.Text = "Prediction Mode: Infront (Ping)"
            predictionBox.Visible = false
        else
            predictionMode = "Velocity"
            modeButton.Text = "Prediction Mode: Velocity"
            predictionBox.Visible = true
            predictionBox.PlaceholderText = "Prediction (Velocity)"
        end
    end)

    aimModeButton.MouseButton1Click:Connect(function()
        if aimMode == "Normal" then
            aimMode = "360"
            aimModeButton.Text = "Aim Behavior Mode: 360"
            spinSpeedBox.Visible = true
        else
            aimMode = "Normal"
            aimModeButton.Text = "Aim Behavior Mode: Normal"
            spinSpeedBox.Visible = false
        end
    end)

    messageToggleButton.MouseButton1Click:Connect(function()
        messageWhenAim = not messageWhenAim
        messageToggleButton.Text = messageWhenAim and "Message When Aim: ON" or "Message When Aim: OFF"
        messageBox.Visible = messageWhenAim
    end)

    autoCoinflipToggle.MouseButton1Click:Connect(function()
        autoCoinflip = not autoCoinflip
        autoCoinflipToggle.Text = autoCoinflip and "Auto Coinflip: ON" or "Auto Coinflip: OFF"
        chargesLimitButton.Visible = autoCoinflip
    end)

    spinSpeedBox.FocusLost:Connect(function() spinDuration = tonumber(spinSpeedBox.Text) or 0.5 end)
    
    -- Logic click đổi tên mới
    chargesLimitButton.MouseButton1Click:Connect(function()
        if maxChargesLimit == 1 then
            maxChargesLimit = 2
        elseif maxChargesLimit == 2 then
            maxChargesLimit = 3
        else
            maxChargesLimit = 1
        end
        chargesLimitButton.Text = "Charges: " .. tostring(maxChargesLimit)
    end)

    -- Helpers
    local function setupCharacter(char)
        if not char then return end
        Humanoid = char:FindFirstChildOfClass("Humanoid")
        HRP = char:FindFirstChild("HumanoidRootPart")
    end
    if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(setupCharacter)

    local function getPingSeconds()
        local pingStat = Stats.Network.ServerStatsItem["Data Ping"]
        return pingStat and (pingStat:GetValue() / 1000) or 0.1
    end

    local function sendChatMessage(text)
        if not text or text:match("^%s*$") then return end
        pcall(function()
            local TextChatService = game:GetService("TextChatService")
            local channel = TextChatService.TextChannels.RBXGeneral
            if channel then channel:SendAsync(text) end
        end)
    end

    local function locateCoinFlipObjects()
        if targetChargesLabel and targetCoinFlipBtn and targetChargesLabel:IsDescendantOf(game) and targetCoinFlipBtn:IsDescendantOf(game) then
            return 
        end

        targetChargesLabel = nil
        targetCoinFlipBtn = nil

        pcall(function()
            for _, obj in ipairs(PlayerGui:GetDescendants()) do
                if obj:IsA("GuiButton") or obj:IsA("ImageButton") or obj:IsA("TextButton") then
                    local isRef = false
                    for _, child in ipairs(obj:GetDescendants()) do
                        if child:IsA("TextLabel") then
                            local textLower = string.lower(child.Text)
                            if string.find(textLower, "one shot") or string.find(textLower, "reroll") then
                                isRef = true
                                break
                            end
                        end
                    end
                    
                    if isRef then
                        local validLabels = {}
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("TextLabel") then
                                local num = tonumber(child.Text)
                                if num and num >= 0 and num <= 3 then
                                    table.insert(validLabels, child)
                                end
                            end
                        end
                        if #validLabels > 0 then
                            table.sort(validLabels, function(a, b)
                                return a.AbsolutePosition.Y < b.AbsolutePosition.Y
                            end)
                            targetChargesLabel = validLabels[1]
                        end
                    end
                    
                    if not targetCoinFlipBtn then
                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("TextLabel") and string.find(string.lower(child.Text), "coin") then
                                targetCoinFlipBtn = obj
                                break
                            end
                        end
                    end
                end
            end
        end)
    end

    local function extremeClick(button)
        if not button then return end
        local events = {"MouseButton1Click", "MouseButton1Down", "MouseButton1Up", "Activated", "InputBegan", "TouchTap"}
        for _, eventName in ipairs(events) do
            pcall(function()
                local connections = getconnections(button[eventName])
                for _, connection in ipairs(connections) do
                    if connection.Function then task.spawn(connection.Function) end
                    connection:Fire()
                end
            end)
        end
    end

    local function getValidTarget()
        local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
        if killersFolder then
            for _, name in ipairs(aimTargets) do
                local target = killersFolder:FindFirstChild(name)
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local hum = target:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then return target.HumanoidRootPart, hum end
                end
            end
        end
        return nil, nil
    end

    local function CalculateAimPosition(targetHRP)
        if not targetHRP then return nil end
        local velocity = targetHRP.Velocity
        
        if predictionMode == "Ping" then
            if velocity.Magnitude <= movementThreshold then return targetHRP.Position end
            return targetHRP.Position + (velocity * getPingSeconds())
        elseif predictionMode == "Infront HRP" then
            local studs = tonumber(predictionBox.Text) or 0
            if velocity.Magnitude > movementThreshold then return targetHRP.Position + (targetHRP.CFrame.LookVector * studs) end
        elseif predictionMode == "Infront HRP (Ping Adjust)" then
            if velocity.Magnitude <= movementThreshold then return targetHRP.Position end
            return targetHRP.Position + (targetHRP.CFrame.LookVector * (getPingSeconds() * 60))
        else
            local prediction = tonumber(predictionBox.Text) or 0
            if velocity.Magnitude <= movementThreshold then return targetHRP.Position end
            return targetHRP.Position + (velocity * (prediction / 60))
        end
        return targetHRP.Position
    end

    local function isFlintlockVisible()
        if not LocalPlayer.Character then return false end
        local flint = LocalPlayer.Character:FindFirstChild("Flintlock", true)
        if not flint then return false end
        if not (flint:IsA("BasePart") or flint:IsA("MeshPart") or flint:IsA("UnionOperation")) then
            flint = flint:FindFirstChildWhichIsA("BasePart", true)
        end
        return flint and flint.Transparency < 1 or false
    end

    if RemoteEvent then
        local namecall
        namecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if active and self == RemoteEvent and (method == "FireServer" or method == "fireServer") then
                local targetHRP, _ = getValidTarget()
                if targetHRP then
                    local aimPos = CalculateAimPosition(targetHRP)
                    if aimPos then
                        for i, arg in pairs(args) do
                            if typeof(arg) == "Vector3" then args[i] = aimPos
                            elseif typeof(arg) == "CFrame" then args[i] = CFrame.new(aimPos) end
                        end
                        return namecall(self, unpack(args))
                    end
                end
            end
            return namecall(self, ...)
        end)
    end

    task.spawn(function()
        while true do
            if autoCoinflip then
                locateCoinFlipObjects()
                
                local currentCharges = 0
                if targetChargesLabel and targetChargesLabel.Parent then
                    currentCharges = tonumber(targetChargesLabel.Text) or 0
                end
                
                if currentCharges < maxChargesLimit then
                    if RemoteEvent then
                        pcall(function()
                            RemoteEvent:FireServer("UseActorAbility", "CoinFlip")
                            RemoteEvent:FireServer("UseActorAbility", "Coinflip")
                        end)
                    end
                    
                    if targetCoinFlipBtn and targetCoinFlipBtn.Parent then
                        extremeClick(targetCoinFlipBtn)
                    end
                end
            end
            
            task.wait(coinflipCooldown)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not active or not Humanoid or not HRP then return end
        local isVisible = isFlintlockVisible()
        
        if isVisible and not prevFlintVisibleAim and not aiming then
            lastTriggerTime = tick()
            aiming = true
            messageSentThisAim = false
        end
        prevFlintVisibleAim = isVisible
        
        if aiming then
            local elapsed = tick() - lastTriggerTime
            local targetHRP, _ = getValidTarget()
            
            if targetHRP and messageWhenAim and not messageSentThisAim then
                messageSentThisAim = true
                sendChatMessage(messageBox.Text)
            end
            
            if aimMode == "360" then
                if elapsed <= spinDuration then
                    local spinProgress = elapsed / spinDuration
                    local spinAngle = math.rad(360 * spinProgress)
                    HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, spinAngle, 0)
                elseif elapsed <= spinDuration + 0.7 then
                    if not originalAutoRotate then originalAutoRotate = Humanoid.AutoRotate end
                    Humanoid.AutoRotate = false
                    HRP.AssemblyAngularVelocity = Vector3.zero
                    
                    if targetHRP then
                        local aimPos = CalculateAimPosition(targetHRP)
                        if aimPos then
                            local direction = (aimPos - HRP.Position).Unit
                            local yRot = math.atan2(-direction.X, -direction.Z)
                            HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, yRot, 0)
                        end
                    end
                else
                    aiming = false
                    if originalAutoRotate ~= nil then Humanoid.AutoRotate = originalAutoRotate originalAutoRotate = nil end
                end
            else 
                if elapsed <= aimDuration then
                    if not originalAutoRotate then originalAutoRotate = Humanoid.AutoRotate end
                    Humanoid.AutoRotate = false
                    HRP.AssemblyAngularVelocity = Vector3.zero
                    
                    if targetHRP then
                        local aimPos = CalculateAimPosition(targetHRP)
                        if aimPos then
                            local direction = (aimPos - HRP.Position).Unit
                            local yRot = math.atan2(-direction.X, -direction.Z)
                            HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, yRot, 0)
                        end
                    end
                else
                    aiming = false
                    if originalAutoRotate ~= nil then Humanoid.AutoRotate = originalAutoRotate originalAutoRotate = nil end
                end
            end
        end
    end)
end)

--// QUÉT DỌN LIÊN TỤC
task.spawn(function()
    while task.wait(0.1) do
        for _, obj in pairs(CoreGui:GetDescendants()) do
            if obj:IsA("TextLabel") and (string.find(obj.Text, "Interface Hidden") or string.find(obj.Text, "reopen")) then
                local mainFrameObj = obj:FindFirstAncestorOfClass("Frame")
                if mainFrameObj then mainFrameObj:Destroy() end
            end
        end
    end
end)

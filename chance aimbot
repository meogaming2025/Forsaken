--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui") -- Thêm CoreGui để né quét

local LocalPlayer = Players.LocalPlayer

--// Tạo luồng chạy độc lập
task.spawn(function()
    -- Lấy nhanh RemoteEvent không dùng WaitForChild vô hạn
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    local network = modules and modules:FindFirstChild("Network")
    local RemoteEvent = network and network:FindFirstChild("RemoteEvent")

    --// GUI Setup - ĐƯỢC ĐẨY THẲNG VÀO COREGUI ĐỂ CHỐNG XÓA
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ChanceAimbotUI_Protected"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui -- Né bộ quét của game cực tốt

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

    -- Config & States
    local active = false
    local predictionMode = "Velocity"
    local aimMode = "Normal"
    local aimDuration = 1.51
    local spinDuration = 0.5
    local movementThreshold = 0.5
    local aimTargets = {"Slasher", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Guest666", "Nosferatu", "REDZ_GUY", "skibidi", "kibidi", "tommylikesroblox"}

    local Humanoid, HRP = nil, nil
    local lastTriggerTime = 0
    local aiming = false
    local prevFlintVisibleAim = false
    local originalAutoRotate = nil

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

    spinSpeedBox.FocusLost:Connect(function() spinDuration = tonumber(spinSpeedBox.Text) or 0.5 end)

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

    local function getValidTarget()
        local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
        if killersFolder then
            for _, name in ipairs(aimTargets) do
                local target = killersFolder:FindFirstChild(name)
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local hum = target:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        return target.HumanoidRootPart, hum
                    end
                end
            end
        end
        return nil, nil
    end

    -- Hàm tính toán vị trí nhắm bắn
    local function CalculateAimPosition(targetHRP)
        if not targetHRP then return nil end
        local velocity = targetHRP.Velocity
        
        if predictionMode == "Ping" then
            if velocity.Magnitude <= movementThreshold then return targetHRP.Position end
            return targetHRP.Position + (velocity * getPingSeconds())
        elseif predictionMode == "Infront HRP" then
            local studs = tonumber(predictionBox.Text) or 0
            if velocity.Magnitude > movementThreshold then
                return targetHRP.Position + (targetHRP.CFrame.LookVector * studs)
            end
        elseif predictionMode == "Infront HRP (Ping Adjust)" then
            if velocity.Magnitude <= movementThreshold then return targetHRP.Position end
            return targetHRP.Position + (targetHRP.CFrame.LookVector * (getPingSeconds() * 60))
        else -- Velocity mode
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

    --// LOGIC 1: HOOK REMOTE EVENT ÉP TỌA ĐỘ QUA MẠNG
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
                            if typeof(arg) == "Vector3" then
                                args[i] = aimPos
                            elseif typeof(arg) == "CFrame" then
                                args[i] = CFrame.new(aimPos)
                            end
                        end
                        return namecall(self, unpack(args))
                    end
                end
            end
            return namecall(self, ...)
        end)
    end

    --// LOGIC 2: XOAY NHÂN VẬT ĐỒNG BỘ CAMERA
    RunService.RenderStepped:Connect(function()
        if not active or not Humanoid or not HRP then return end
        
        local isVisible = isFlintlockVisible()
        if isVisible and not prevFlintVisibleAim and not aiming then
            lastTriggerTime = tick()
            aiming = true
        end
        prevFlintVisibleAim = isVisible
        
        if aiming then
            local elapsed = tick() - lastTriggerTime
            local targetHRP, _ = getValidTarget()
            
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
            else -- Normal Mode
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

--// QUÉT DỌN LIÊN TỤC: Xóa sổ các bảng thông báo rác ẩn menu
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

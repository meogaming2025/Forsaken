--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Các biến trạng thái logic
local autoSlashActive = false
local facingCheckActive = false 
local rangeVisualActive = false
local facingVisualActive = false 

-- Tốc độ delay mặc định (Giây)
local slashDelay = 0.1

-- Kích thước mặc định của chiếc HỘP (Chỉ dùng khi bật Facing Check)
local boxX = 8   -- Chiều ngang (X)
local boxY = 10  -- Chiều cao (Y)
local boxZ = 9   -- Chiều sâu / Tầm dài (Z)

-- Khoảng cách chém 360 độ (Có thể tùy chỉnh qua ô nhập Circle Range)
local defaultSlash360Range = 9

-- Độ đậm mặc định (0 = Đặc hoàn toàn, 1 = Trong suốt biến mất)
local boxOpacity = 0.6
local circleOpacity = 0.7

--// THƯ MỤC CHỨA SURVIVORS
local SurvivorsFolder = workspace:FindFirstChild("Survivors") or (workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Survivors"))

local function getSurvivorsFolder()
    if SurvivorsFolder then return SurvivorsFolder end
    SurvivorsFolder = workspace:FindFirstChild("Survivors") or (workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Survivors"))
    return SurvivorsFolder
end

--// TẠO UI LÊN MÀN HÌNH (Tự động fallback nếu CoreGui bị chặn)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SlasherScriptUI_Protected"
screenGui.ResetOnSpawn = false

local success, err = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Khung chính (Main Frame)
local mainFrame = Instance.new("Frame")
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Active = true
mainFrame.Parent = screenGui
mainFrame.AutomaticSize = Enum.AutomaticSize.Y
mainFrame.Size = UDim2.new(0, 200, 0, 0)
mainFrame.Position = UDim2.new(0, 20, 0, 120)

-- Tự động sắp xếp dọc
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = mainFrame

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = mainFrame

-- Logic Kéo Thả (Draggable)
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

-- Nút Ẩn/Hiện Menu
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 60, 0, 30)
hideButton.Position = UDim2.new(0, 20, 0, 80)
hideButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
hideButton.TextColor3 = Color3.new(1, 1, 1)
hideButton.TextScaled = true
hideButton.Text = "HIDE"
hideButton.Active = true
hideButton.Draggable = true
hideButton.Parent = screenGui

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 4)
hideCorner.Parent = hideButton

local uiHidden = false
hideButton.MouseButton1Click:Connect(function()
    uiHidden = not uiHidden
    mainFrame.Visible = not uiHidden
    hideButton.Text = uiHidden and "UNHIDE" or "HIDE"
end)

-------------------------------------------------------------------------
-- GIAO DIỆN CHỨC NĂNG
-------------------------------------------------------------------------

-- 1. Toggle: Auto Slash
local autoSlashToggle = Instance.new("TextButton")
autoSlashToggle.Size = UDim2.new(0, 180, 0, 30)
autoSlashToggle.LayoutOrder = 1
autoSlashToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
autoSlashToggle.TextColor3 = Color3.new(1, 1, 1)
autoSlashToggle.Text = "Auto Slash: OFF"
autoSlashToggle.Parent = mainFrame

-- 2. Toggle: Visual Range
local rangeVisualToggle = Instance.new("TextButton")
rangeVisualToggle.Size = UDim2.new(0, 180, 0, 30)
rangeVisualToggle.LayoutOrder = 2
rangeVisualToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
rangeVisualToggle.TextColor3 = Color3.new(1, 1, 1)
rangeVisualToggle.Text = "Visual Range: OFF"
rangeVisualToggle.Parent = mainFrame

-- 3. Toggle: Facing Visual
local facingVisualToggle = Instance.new("TextButton")
facingVisualToggle.Size = UDim2.new(0, 180, 0, 30)
facingVisualToggle.LayoutOrder = 3
facingVisualToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
facingVisualToggle.TextColor3 = Color3.new(1, 1, 1)
facingVisualToggle.Text = "Facing Visual: OFF"
facingVisualToggle.Parent = mainFrame

-- 4. Toggle: Facing Check
local facingCheckToggle = Instance.new("TextButton")
facingCheckToggle.Size = UDim2.new(0, 180, 0, 30)
facingCheckToggle.LayoutOrder = 4
facingCheckToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
facingCheckToggle.TextColor3 = Color3.new(1, 1, 1)
facingCheckToggle.Text = "Facing Check: OFF"
facingCheckToggle.Parent = mainFrame

-- 5. Ô NHẬP TỐC ĐỘ DELAY (MỚI THÊM)
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0, 180, 0, 18)
delayLabel.LayoutOrder = 5
delayLabel.BackgroundTransparency = 1
delayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
delayLabel.TextSize = 11
delayLabel.Text = "--- Slash Delay (Seconds) ---"
delayLabel.Parent = mainFrame

local delayInput = Instance.new("TextBox")
delayInput.Size = UDim2.new(0, 180, 0, 30)
delayInput.LayoutOrder = 6
delayInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
delayInput.TextColor3 = Color3.new(0.4, 1, 0.4) -- Màu xanh lá cho nổi bật
delayInput.Text = tostring(slashDelay)
delayInput.PlaceholderText = "Delay e.g. 0.1"
delayInput.ClearTextOnFocus = false
delayInput.Parent = mainFrame

-- 6. Ô nhập khoảng cách vòng tròn + Độ đậm (Circle Range & Opacity)
local circleLabel = Instance.new("TextLabel")
circleLabel.Size = UDim2.new(0, 180, 0, 18)
circleLabel.LayoutOrder = 7
circleLabel.BackgroundTransparency = 1
circleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
circleLabel.TextSize = 11
circleLabel.Text = "--- Circle Range & Opacity (0-1) ---"
circleLabel.Parent = mainFrame

local circleInputFrame = Instance.new("Frame")
circleInputFrame.Size = UDim2.new(0, 180, 0, 30)
circleInputFrame.LayoutOrder = 8
circleInputFrame.BackgroundTransparency = 1
circleInputFrame.Parent = mainFrame

local circleInput = Instance.new("TextBox")
circleInput.Size = UDim2.new(0, 90, 1, 0)
circleInput.Position = UDim2.new(0, 0, 0, 0)
circleInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
circleInput.TextColor3 = Color3.new(1, 1, 1)
circleInput.Text = tostring(defaultSlash360Range)
circleInput.PlaceholderText = "Range"
circleInput.ClearTextOnFocus = false
circleInput.Parent = circleInputFrame

local circleOpacInput = Instance.new("TextBox")
circleOpacInput.Size = UDim2.new(0, 85, 1, 0)
circleOpacInput.Position = UDim2.new(0, 95, 0, 0)
circleOpacInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
circleOpacInput.TextColor3 = Color3.new(1, 1, 1)
circleOpacInput.Text = tostring(circleOpacity)
circleOpacInput.PlaceholderText = "Opac"
circleOpacInput.ClearTextOnFocus = false
circleOpacInput.Parent = circleInputFrame

-- 7. Nhãn tiêu đề kích thước Box + Opacity
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(0, 180, 0, 18)
sizeLabel.LayoutOrder = 9
sizeLabel.BackgroundTransparency = 1
sizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
sizeLabel.TextSize = 11
sizeLabel.Text = "--- Box Size (X,Y,Z) & Opacity ---"
sizeLabel.Parent = mainFrame

-- Khung chứa các ô nhập kích thước nằm ngang
local sizeInputsFrame = Instance.new("Frame")
sizeInputsFrame.Size = UDim2.new(0, 180, 0, 30)
sizeInputsFrame.LayoutOrder = 10
sizeInputsFrame.BackgroundTransparency = 1
sizeInputsFrame.Parent = mainFrame

local boxXInput = Instance.new("TextBox")
boxXInput.Size = UDim2.new(0, 40, 1, 0)
boxXInput.Position = UDim2.new(0, 0, 0, 0)
boxXInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
boxXInput.TextColor3 = Color3.new(1, 1, 1)
boxXInput.Text = tostring(boxX)
boxXInput.PlaceholderText = "X"
boxXInput.ClearTextOnFocus = false
boxXInput.Parent = sizeInputsFrame

local boxYInput = Instance.new("TextBox")
boxYInput.Size = UDim2.new(0, 40, 1, 0)
boxYInput.Position = UDim2.new(0, 45, 0, 0)
boxYInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
boxYInput.TextColor3 = Color3.new(1, 1, 1)
boxYInput.Text = tostring(boxY)
boxYInput.PlaceholderText = "Y"
boxYInput.ClearTextOnFocus = false
boxYInput.Parent = sizeInputsFrame

local boxZInput = Instance.new("TextBox")
boxZInput.Size = UDim2.new(0, 40, 1, 0)
boxZInput.Position = UDim2.new(0, 90, 0, 0)
boxZInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
boxZInput.TextColor3 = Color3.new(1, 1, 1)
boxZInput.Text = tostring(boxZ)
boxZInput.PlaceholderText = "Z"
boxZInput.ClearTextOnFocus = false
boxZInput.Parent = sizeInputsFrame

local boxOpacInput = Instance.new("TextBox")
boxOpacInput.Size = UDim2.new(0, 40, 1, 0)
boxOpacInput.Position = UDim2.new(0, 135, 0, 0)
boxOpacInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
boxOpacInput.TextColor3 = Color3.new(1, 1, 1)
boxOpacInput.Text = tostring(boxOpacity)
boxOpacInput.PlaceholderText = "Opac"
boxOpacInput.ClearTextOnFocus = false
boxOpacInput.Parent = sizeInputsFrame


-------------------------------------------------------------------------
-- KHỞI TẠO CÁC ĐỐI TƯỢNG VẼ (BOX VÀNG & VÒNG ĐỎ)
-------------------------------------------------------------------------
local visualPart = Instance.new("Part")
visualPart.Name = "SlasherVisualBox"
visualPart.Anchored = true
visualPart.CanCollide = false
visualPart.CanQuery = false
visualPart.CanTouch = false
visualPart.CastShadow = false
visualPart.Material = Enum.Material.ForceField
visualPart.Color = Color3.fromRGB(255, 255, 0)
visualPart.Transparency = 1
visualPart.Size = Vector3.new(boxX, boxY, boxZ)
visualPart.Parent = workspace.CurrentCamera

local selectionBox = Instance.new("SelectionBox")
selectionBox.Color3 = Color3.fromRGB(255, 230, 0)
selectionBox.LineThickness = 0.05
selectionBox.Adornee = visualPart
selectionBox.Transparency = boxOpacity
selectionBox.Visible = false
selectionBox.Parent = visualPart

local circlePart = Instance.new("Part")
circlePart.Name = "SlasherVisualCircle"
circlePart.Shape = Enum.PartType.Cylinder
circlePart.Anchored = true
circlePart.CanCollide = false
circlePart.CanQuery = false
circlePart.CanTouch = false
circlePart.CastShadow = false
circlePart.Material = Enum.Material.ForceField
circlePart.Color = Color3.fromRGB(255, 0, 0)
circlePart.Transparency = 1
circlePart.Size = Vector3.new(0.15, defaultSlash360Range * 2, defaultSlash360Range * 2)
circlePart.Parent = workspace.CurrentCamera

local circleSelection = Instance.new("SelectionBox")
circleSelection.Color3 = Color3.fromRGB(255, 50, 50)
circleSelection.LineThickness = 0.05
circleSelection.Adornee = circlePart
circleSelection.Transparency = circleOpacity
circleSelection.Visible = false
circleSelection.Parent = circlePart

local function refreshVisuals()
    visualPart.Size = Vector3.new(boxX, boxY, boxZ)
    circlePart.Size = Vector3.new(0.15, defaultSlash360Range * 2, defaultSlash360Range * 2)

    if facingVisualActive then
        visualPart.Transparency = boxOpacity
        selectionBox.Visible = true
        selectionBox.Transparency = boxOpacity
    else
        visualPart.Transparency = 1
        selectionBox.Visible = false
    end

    if rangeVisualActive then
        circlePart.Transparency = circleOpacity
        circleSelection.Visible = true
        circleSelection.Transparency = circleOpacity
    else
        circlePart.Transparency = 1
        circleSelection.Visible = false
    end
end

-- Lắng nghe thay đổi giá trị nhập thủ công
delayInput.FocusLost:Connect(function()
    local val = tonumber(delayInput.Text)
    if val and val >= 0 then
        slashDelay = val
    else
        delayInput.Text = tostring(slashDelay)
    end
end)

boxXInput.FocusLost:Connect(function() boxX = tonumber(boxXInput.Text) or boxX refreshVisuals() end)
boxYInput.FocusLost:Connect(function() boxY = tonumber(boxYInput.Text) or boxY refreshVisuals() end)
boxZInput.FocusLost:Connect(function() boxZ = tonumber(boxZInput.Text) or boxZ refreshVisuals() end)
boxOpacInput.FocusLost:Connect(function()
    local val = tonumber(boxOpacInput.Text)
    if val and val >= 0 and val <= 1 then boxOpacity = val else boxOpacInput.Text = tostring(boxOpacity) end
    refreshVisuals()
end)

circleInput.FocusLost:Connect(function() defaultSlash360Range = tonumber(circleInput.Text) or defaultSlash360Range refreshVisuals() end)
circleOpacInput.FocusLost:Connect(function()
    local val = tonumber(circleOpacInput.Text)
    if val and val >= 0 and val <= 1 then circleOpacity = val else circleOpacInput.Text = tostring(circleOpacity) end
    refreshVisuals()
end)

-- Sự kiện click các nút
autoSlashToggle.MouseButton1Click:Connect(function()
    autoSlashActive = not autoSlashActive
    autoSlashToggle.Text = autoSlashActive and "Auto Slash: ON" or "Auto Slash: OFF"
end)

rangeVisualToggle.MouseButton1Click:Connect(function()
    rangeVisualActive = not rangeVisualActive
    rangeVisualToggle.Text = rangeVisualActive and "Visual Range: ON" or "Visual Range: OFF"
    refreshVisuals()
end)

facingVisualToggle.MouseButton1Click:Connect(function()
    facingVisualActive = not facingVisualActive
    facingVisualToggle.Text = facingVisualActive and "Facing Visual: ON" or "Facing Visual: OFF"
    refreshVisuals()
end)

facingCheckToggle.MouseButton1Click:Connect(function()
    facingCheckActive = not facingCheckActive
    facingCheckToggle.Text = facingCheckActive and "Facing Check: ON" or "Facing Check: OFF"
end)

-- Cập nhật vị trí các đối tượng vẽ
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        if rangeVisualActive then
            circlePart.CFrame = hrp.CFrame * CFrame.new(0, -2.8, 0) * CFrame.Angles(0, 0, math.rad(90))
        else
            circlePart.CFrame = CFrame.new(0, -9999, 0)
        end

        if facingVisualActive then
            local targetCFrame = hrp.CFrame * CFrame.new(0, 0, -boxZ / 2)
            visualPart.CFrame = targetCFrame
        else
            visualPart.CFrame = CFrame.new(0, -9999, 0)
        end
    else
        visualPart.CFrame = CFrame.new(0, -9999, 0)
        circlePart.CFrame = CFrame.new(0, -9999, 0)
    end
end)

-- Bo tròn góc UI
for _, child in ipairs(mainFrame:GetChildren()) do
    if child:IsA("TextButton") or child:IsA("TextBox") then
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = child
    end
end
for _, child in ipairs(sizeInputsFrame:GetChildren()) do
    if child:IsA("TextBox") then
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = child
    end
end
for _, child in ipairs(circleInputFrame:GetChildren()) do
    if child:IsA("TextBox") then
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = child
    end
end


--// PHẦN KẾT NỐI MẠNG VÀ LOGIC AUTO SLASH QUÉT CHÉM + DEBUG LOGS
task.spawn(function()
    warn("[Slasher Debug] Khởi động luồng Auto Slash...")
    
    local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
    if not Modules then return end

    local Network1 = Modules:WaitForChild("Network", 5)
    if not Network1 then return end

    local Network2 = Network1:WaitForChild("Network", 5)
    if not Network2 then return end

    local RemoteEvent = Network2:WaitForChild("RemoteEvent", 5)
    if not RemoteEvent then return end

    print("[Slasher Debug] Hệ thống mạng đã sẵn sàng để nhận lệnh delay mới!")

    local function sendSlashPayload()
        local bytes = { 3, 5, 0, 0, 0, 83, 108, 97, 115, 104 }
        local b = buffer.create(#bytes)
        for i = 1, #bytes do
            buffer.writeu8(b, i - 1, bytes[i])
        end
        RemoteEvent:FireServer("UseActorAbility", { b })
    end

    local function isTargetInVisualBox(myHrp, targetHrp)
        local relativePos = myHrp.CFrame:PointToObjectSpace(targetHrp.Position)
        local inX = math.abs(relativePos.X) <= (boxX / 2)
        local inY = math.abs(relativePos.Y) <= (boxY / 2)
        local inZ = (relativePos.Z < 0) and (math.abs(relativePos.Z) <= boxZ)
        return inX and inY and inZ
    end

    -- Vòng lặp quét chém liên tục phụ thuộc vào cấu hình Slash Delay công khai
    while true do
        -- Sử dụng biến slashDelay linh hoạt thay vì ép cứng thời gian
        if slashDelay and slashDelay > 0 then
            task.wait(slashDelay)
        else
            task.wait() -- Fallback an toàn tối thiểu tránh treo game nếu delay nhập bằng 0
        end

        if autoSlashActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp = LocalPlayer.Character.HumanoidRootPart
            local folder = getSurvivorsFolder()
            local targets = {}
            
            if folder then
                local children = folder:GetChildren()
                for _, child in ipairs(children) do
                    if child:IsA("Model") and child ~= LocalPlayer.Character and child:FindFirstChild("HumanoidRootPart") then
                        local humanoid = child:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            table.insert(targets, child)
                        end
                    end
                end
            else
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            table.insert(targets, player.Character)
                        end
                    end
                end
            end
            
            for _, targetChar in ipairs(targets) do
                local targetHrp = targetChar.HumanoidRootPart
                
                if facingCheckActive then
                    if isTargetInVisualBox(myHrp, targetHrp) then
                        sendSlashPayload()
                        break
                    end
                else
                    local distance = (myHrp.Position - targetHrp.Position).Magnitude
                    if distance <= defaultSlash360Range then
                        sendSlashPayload()
                        break
                    end
                end
            end
        end
    end
end)

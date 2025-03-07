local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

local aiming = false
local aimbotKey = nil

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.Enabled = true

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(0, 200, 0, 50)
Label.Position = UDim2.new(1, -220, 0, 20)
Label.BackgroundTransparency = 1
Label.Text = "Aimbot = Not Set"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 24
Label.Parent = ScreenGui

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0, 200, 0, 50)
InputBox.Position = UDim2.new(1, -220, 0, 100)
InputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Press a key for aimbot"
InputBox.TextSize = 20
InputBox.ClearTextOnFocus = false
InputBox.Parent = ScreenGui
InputBox.Visible = false

local function setAimbotKey(input)
    aimbotKey = input
    Label.Text = "Aimbot = " .. aimbotKey
    InputBox.Visible = false
end

InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and InputBox.Text ~= "" then
        local key = InputBox.Text:upper()
        local keyCode = Enum.KeyCode[key]
        if keyCode then
            setAimbotKey(keyCode.Name)
        else
            Label.Text = "Aimbot = Invalid Key"
        end
    end
end)

local guiVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        guiVisible = not guiVisible
        ScreenGui.Enabled = guiVisible
        InputBox.Visible = guiVisible
    end
end)

local function getVisibleEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= nil and player.Team.Name ~= LocalPlayer.Team.Name and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(headPos.X, headPos.Y) - UserInputService:GetMouseLocation()).Magnitude
            if distance < shortestDistance and onScreen then
                closestPlayer = player
                shortestDistance = distance
            end
        end
    end

    return closestPlayer
end

local function shootAtEnemy(enemy)
    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")

    if not humanoid or not enemy or not enemy.Character then return end

    local enemyHumanoid = enemy.Character:FindFirstChild("Humanoid")
    if enemyHumanoid and enemyHumanoid.Health <= 0 then return end

    while aiming and enemy.Character and enemy.Character:FindFirstChild("Head") do
        local tool = character:FindFirstChild("Tool")
        if not tool then
            tool = character:FindFirstChild("Gun")
        end
        if tool then
            tool:Activate()
        end
        wait(0.1)
    end
end

local function updateCamera()
    if aiming then
        local targetEnemy = getVisibleEnemy()
        if targetEnemy then
            local targetPos = targetEnemy.Character.Head.Position
            local cameraPos = Camera.CFrame.Position
            local newCFrame = CFrame.new(cameraPos, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.2)

            shootAtEnemy(targetEnemy)
        end
    end
end

RunService.RenderStepped:Connect(updateCamera)

UserInputService.InputBegan:Connect(function(input)
    if aimbotKey and input.KeyCode.Name == aimbotKey then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if aimbotKey and input.KeyCode.Name == aimbotKey then
        aiming = false
    end
end)

-- Notification with timeout
local function displayNotification(character)
    local notification = Instance.new("Hint")
    notification.Parent = character
    notification.Text = "Developed by - veckz\nJoin Project Aim Discord - https://discord.gg/f62VttUHU8"

    setclipboard("https://discord.gg/f62VttUHU8") -- Copy Discord link to clipboard

    delay(10, function()
        notification:Destroy()
    end)
end

if LocalPlayer.Character then
    displayNotification(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(displayNotification)

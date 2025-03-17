local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

local aiming = false -- Aimbot is initially disabled

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

-- Use Rayfield's Keybind Flag to toggle aimbot
local KeybindFlag = "Keybind1"

UserInputService.InputBegan:Connect(function(input)
    if Rayfield.Flags[KeybindFlag] then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not Rayfield.Flags[KeybindFlag] then
        aiming = false
    end
end)

local Players = game:GetService('Players')
local TS = game:GetService('TweenService')
local RS = game:GetService('RunService')
local SG = game:GetService('StarterGui')

local camera = game.Workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = localCharacter:WaitForChild("HumanoidRootPart")
local localHumanoid = localCharacter:WaitForChild("Humanoid")

local playerList = Players:GetPlayers()
local mouse = localPlayer:GetMouse()

local target
local clicked = true
local debounce = false

local screenGUI = script.Parent.Main
local revertCamera = screenGUI.Revert.RevertCameraButton
local playerSpectated = screenGUI.SpectateImage.PlayerSpectated

local default_text = "Currently Not Spectating Anyone"
local sound = revertCamera.click_sound

local invisGoals = {}
local undoGoals = {}

invisGoals.LocalTransparencyModifier = 1
undoGoals.LocalTransparencyModifier = 0

local tweenInfo = TweenInfo.new(
    .5,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.Out
)

local t = {
	[Vector3.new(0,1,0)] = 1,
	[Vector3.new(100,1,100)] = 2,
	[Vector3.new(200,1,200)] = 3,
	[Vector3.new(300,1,300)] = 4,
}

local function getOtherPlayers()
    local count = 0
    for amount, plr in ipairs(playerList) do
        if plr ~= localPlayer and plr ~= nil then
            local character = plr.Character or plr.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            count += 1
            return humanoid, character, plr, amount
        end
    end
end

local function changeCameraSubject()
    target = mouse.Target
	mouse.TargetFilter = target

	if not debounce and clicked == true then
		debounce = true

		if target ~= nil and target.Parent ~= localCharacter then
			if target.Parent:FindFirstChild("HumanoidRootPart") ~= nil then
				local clickedCharacter = target.Parent
				local clickedPlayer = game.Players:GetPlayerFromCharacter(clickedCharacter)
                
                sound:Play()
                camera.CameraSubject = clickedCharacter
                playerSpectated.Text = "Spectating: " .. tostring(clickedPlayer)
			end
		end

		wait(.5)
		debounce = false
	end
end

local function revertBackToNormalCamera()
	if not debounce then
		debounce = true
		sound:Play()
		camera.CameraSubject = localCharacter
        playerSpectated.Text = default_text
		wait(.5)
		debounce = false
	end
end

local function checkDistance()
    for _, plr in pairs(playerList) do
        if plr ~= localPlayer and plr ~= nil then
            local character = plr.Character or plr.CharacterAdded:Wait()
            local HRP = character:WaitForChild("HumanoidRootPart")
            local distance = math.floor((humanoidRootPart.Position - HRP.Position).Magnitude)
            return distance
        end
    end
end

local function setInvisibility(char)
    for _, child in pairs(char:GetDescendants()) do
        if child:IsA("BasePart") or child:IsA("Decal") then
            local tween = TS:Create(child, tweenInfo, invisGoals)
            tween:Play()
        end
    end
end

local function undoInvisibility(char)
    for _, child in pairs(char:GetDescendants()) do
        if child:IsA("BasePart") or child:IsA("Decal") then
            local tween = TS:Create(child, tweenInfo, undoGoals)
            tween:Play()
        end
    end
end


local function validateDistance()
    local closestMagnitude, closesID = nil, 1
    local magnitude = checkDistance()
    local humanoid, character, plr = getOtherPlayers()
    local range = 150

    for pos, id in pairs(t) do
        if not closestMagnitude then
            closestMagnitude = magnitude
            closesID = id
        end
        if magnitude and magnitude <= range and magnitude <= closestMagnitude and character ~= nil and magnitude then
            closestMagnitude = magnitude
            closesID = id
            clicked = true
            mouse.Button1Down:Connect(changeCameraSubject)
            undoInvisibility(character)
            print(magnitude)
        elseif magnitude >= range then
            clicked = false
            camera.CameraSubject = localCharacter
            setInvisibility(character)
            if camera.CameraSubject ~= character then
                playerSpectated.Text = default_text
            end
        end
    end
end

local function changeCamera()
    playerSpectated.Text = default_text
    camera.CameraSubject = localCharacter
end

local _, char, plr, amount = getOtherPlayers()
repeat wait(.1) until typeof(tonumber(amount)) >= "2" and char ~= nil

while true do
    wait(.5)
    local humanoid, character = getOtherPlayers()

    validateDistance()
    humanoid.Died:Connect(changeCamera)
    revertCamera.MouseButton1Down:Connect(revertBackToNormalCamera)
end
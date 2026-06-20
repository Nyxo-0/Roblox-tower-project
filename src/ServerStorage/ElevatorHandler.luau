local TS = game:GetService("TweenService")

local gameFolder = workspace:WaitForChild("Game")
local elevator = gameFolder:WaitForChild("Elevator")

local sliders = elevator:WaitForChild("DoorSliders")
local leftDoor = sliders:WaitForChild("DoorLeft")
local rightDoor = sliders:WaitForChild("DoorRight")

local doorTweenInfo = TweenInfo.new(
	6.5,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.InOut
)

local leftOpenPos = leftDoor.Position + Vector3.new(-5.5, 0, 0)
local rightOpenPos = rightDoor.Position + Vector3.new(5.5, 0, 0)
local leftClosePos = leftDoor.Position
local rightClosePos = rightDoor.Position

local leftDoorTweenOpen = TS:Create(leftDoor, doorTweenInfo, {CFrame = CFrame.new(leftOpenPos)})
local leftDoorTweenClose = TS:Create(leftDoor, doorTweenInfo, {CFrame = CFrame.new(leftClosePos)})
local rightDoorTweenOpen = TS:Create(rightDoor, doorTweenInfo, {CFrame = CFrame.new(rightOpenPos)})
local rightDoorTweenClose = TS:Create(rightDoor, doorTweenInfo, {CFrame = CFrame.new(rightClosePos)})

local doorState = false

local handler = {}

function handler:OpenDoors()
	if doorState then return "Door already open!" end
	
	doorState = true
	
	leftDoorTweenOpen:Play()
	rightDoorTweenOpen:Play()
	
	return "Opened doors"
end

function handler:CloseDoors()
	if not doorState then return "Door already closed!" end
	
	doorState = false
	
	leftDoorTweenClose:Play()
	rightDoorTweenClose:Play()

	return "Closed doors"
end

return handler

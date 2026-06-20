local SS = game:GetService("ServerStorage")

local elevatorHandler = require(SS:WaitForChild("ElevatorHandler"))

while true do
	task.wait(4)
	
	elevatorHandler:OpenDoors()
	print("Opened")
	task.wait(8)
	elevatorHandler:CloseDoors()
	print("Closed")
	task.wait(3)
end
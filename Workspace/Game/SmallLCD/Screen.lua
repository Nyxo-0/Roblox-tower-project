-- @ScriptType: Script
local RS = game:GetService("ReplicatedStorage")

local events = RS:WaitForChild("Events")
local updateScreen = events:WaitForChild("UpdateScreen")

local screen = script.Parent:WaitForChild("ScreenLED")
local pixelFolder = screen:WaitForChild("Screen"):WaitForChild("Pixels")

local function wipeScreen()
	for _, v in pairs(pixelFolder:GetDescendants()) do
		if v:IsA("Frame") then
			if v.BackgroundColor3 ~= Color3.new(0, 0, 0) then
				v.BackgroundColor3 = Color3.new(0, 0, 0)
			end
		end
	end
end

local function append(t1, t2)
	local result = table.create(#t1 + #t2)

	local n = 0
	for i = 1, #t1 do
		n += 1
		result[n] = t1[i]
	end

	for i = 1, #t2 do
		n += 1
		result[n] = t2[i]
	end

	return result
end

updateScreen.OnClientEvent:Connect(function(to: string, pattern: any, pattern2: any?)
	if to ~= script:GetAttribute("ScreenID") then return end
	if not pattern or not pattern:IsA("ModuleScript") then return end
	if pattern2 and not pattern2:IsA("ModuleScript") then return end
	
	wipeScreen()
	
	local array
	
	if not pattern2 then
		array = require(pattern)
	else
		array = append(require(pattern), require(pattern2))
	end
	
	for _, v in pairs(array) do
		local column = tostring(v[1])
		local row = tostring(v[2])
		
		if column and row then
			local pixel = pixelFolder:FindFirstChild(column)
			
			if pixel then
				pixel = pixel:FindFirstChild(row)
				
				if pixel then
					pixel.BackgroundColor3 = Color3.new(1, 0, 0)
				end
			end
		end
	end
end)
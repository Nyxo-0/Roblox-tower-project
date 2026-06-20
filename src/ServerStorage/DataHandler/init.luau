local Players = game:GetService("Players")
local ProfileStore = require(script:WaitForChild("ProfileStore"))

local activeProfiles = {}
local profileTemplate = require(script:WaitForChild("DataTemplate"))

local profileStore = ProfileStore.New("PlayerDataTest0001", profileTemplate)

local valueTypes = require(script:WaitForChild("ValueTypes"))

---------------------------------------------------------

local handler = {}

function handler:Init()
	for _, v in pairs(Players:GetPlayers()) do
		task.spawn(function()
			handler:PlayerJoin(v)
		end)
	end
	
	Players.PlayerAdded:Connect(function(plr)
		handler:PlayerJoin(plr)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		handler:PlayerLeave(plr)
	end)
	game:BindToClose(function()
		handler:StopServer()
	end)
end

function handler:GetPlayerKey(plr: Player)
	return tostring(plr.UserId)
end

function handler:GetPlayerProfile(plr: Player)
	return activeProfiles[handler:GetPlayerKey(plr)]
end

function handler:GetPath(instance: Instance)
	local underPlayer = false
	
	if instance:IsDescendantOf(Players) and instance.Parent ~= Players then
		underPlayer = true
	end
	
	if underPlayer == true then
		local path = {}
		
		local function getPath(ins)
			if ins.Parent:IsA("Player") then return end
			
			path[#path + 1] = ins.Parent.Name
			getPath(ins.Parent)
		end
		
		getPath(instance)
		
		return path
	else
		warn("Instance is not under a player")
		return nil
	end
end

function handler:CreateStats(plr: Player, stat: {any}, path: any?, savedPaths: {any}?)
	path = path or plr
	savedPaths = savedPaths or {}
	
	for i, v in pairs(stat) do
		if type(v) == "table" then
			local folder = Instance.new("Folder")
			folder.Name = i
			folder.Parent = path
			handler:CreateStats(plr, v, folder, savedPaths)
		else
			if valueTypes[type(v)] ~= nil then
				local profile = handler:GetPlayerProfile(plr)
				
				local value = Instance.new(valueTypes[type(v)])
				value.Name = i
				value.Parent = path
				
				local parent = profile.Data
				local dataPath = savedPaths[i] or handler:GetPath(value)
				
				if savedPaths[i] == nil then
					savedPaths[i] = dataPath
				end
				
				if dataPath then
					for b = #dataPath, 1, -1 do
						parent = parent[dataPath[b]]
					end
				end
				
				value.Value = parent[i]
				
				value.Changed:Connect(function()
					parent[i] = value.Value
				end)
			else
				warn(tostring(v).." is not a valid type")
			end
		end
	end
end

function handler:PlayerJoin(plr: Player)
	if plr.Parent ~= Players then return end
	
	local playerKey = handler:GetPlayerKey(plr)
	
	if activeProfiles[playerKey] then return end
	
	local profile = profileStore:StartSessionAsync(playerKey,
		{
			Cancel = function()
				return plr.Parent ~= Players -- check if player is ingame
			end
		}
	)
	
	if profile ~= nil then -- profile loaded 
		profile:Reconcile()
		
		profile.OnSessionEnd:Connect(function()
			activeProfiles[playerKey] = nil
			if plr.Parent == Players then
				plr:Kick("Data session ended.")
			end
		end)
		
		activeProfiles[playerKey] = profile
		
		handler:CreateStats(plr, profile.Data)
	else
		plr:Kick("Failed to load data, please try again.")
	end
end

function handler:PlayerLeave(plr: Player)
	local playerKey = handler:GetPlayerKey(plr)
	local plrData = activeProfiles[playerKey]
	
	if plrData ~= nil then
		plrData:EndSession()
		activeProfiles[playerKey] = nil
	end
end

function handler:StopServer()
	for _, profile in pairs(activeProfiles) do
		profile:EndSession()
	end
end

return handler

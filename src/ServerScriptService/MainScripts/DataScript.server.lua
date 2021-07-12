--//DataStore Variables//--
local DSS = game:GetService('DataStoreService')
local dataStore = DSS:GetDataStore("AdvanceData")

--//Receiving Data Function//--
local function getData(player)

	local leaderstats = Instance.new('Folder')
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local money = Instance.new('IntValue')
	money.Name = "Money"
	money.Parent = leaderstats

	local coins = Instance.new('IntValue')
	coins.Name = "Coins"
	coins.Parent = leaderstats

	local UserId = "Player_" .. player.UserId
	local data

	local count = 0
	local tries = 3

	local success, err

	repeat
		success, err = pcall(function()
			data = dataStore:GetAsync(UserId)
		end)

		count += 1
	until count >= tries or success

	if not success then
		player:Kick("Avoiding Dataloss.")
		warn("Failed to return data. Error Code: " .. tostring(err))
	end	
	
	if success then
		if data ~= nil then
			money.Value = data[1]
			coins.Value = data[2]
		end
	end		
end

--//Saving Data Function//--
local function saveData(player)

	local saveTable = {
		player.leaderstats.Money.Value;    
		player.leaderstats.Coins.Value
	}

	local UserId = "Player_" .. player.UserId

	local success, err = pcall(function()
		dataStore:UpdateAsync(UserId, function(oldValue)
			return saveTable				
		end)
	end)	

	if success then
		print("Data Saved!")
	else
		print("Not Saved :(")
	end

end

--//Verification Check//--
local function verifyData(player)
	getData(player)
end

--//Verification Check//--
local function validateData(player)
	local success, err = pcall(function()
		saveData(player)        
	end)

	if success then
		print("Data has been saved!")
	elseif not success then
		print("Data has not been saved :(")
		saveData(player)
	end
end

--//Calls the functions written above when needed//--
game.Players.PlayerAdded:Connect(verifyData)
game.Players.PlayerRemoving:Connect(validateData)

--//Shutdown Data Save//--
local function ShutdownSave()
	game:BindToClose(function()
		for _, player in pairs(game.Players:GetPlayers()) do
			saveData(player)
		end
	end)
end

--//Validation Check//--
local success, err = pcall(function()
	ShutdownSave()    
end)

if not success then
	ShutdownSave()
	warn(err)
end
rednet.open("bottom")
local databasePath = "db"
local database

if not fs.exists(databasePath) then
	database = {}
	local file = fs.open(databasePath, "w")
	file.write("{}")
	file.close()
else	
	local file = fs.open(databasePath, "r")
	database = textutils.unserialise(file.readAll())
	file.close()
end

print("Database loaded.")

while true do
	local id, data = rednet.receive("otto")
	print(textutils.serialise(data))
	if data.type == "getPlayerBalance" then
		print("Fetching balance for ", data.player)
		rednet.send(id, database[data.player], "otto")
	elseif data.type == "setPlayerBalance" then
		print("Setting balance for ", data.player, " to ", data.balance)
		database[data.player].balance = data.balance
		local file = fs.open(databasePath, "w")
		file.write(textutils.serialise(database))
		file.close()
		rednet.send(id, nil, "otto")
	elseif data.type == "addPlayer" then
		print("Adding player: #"..data.player, data.name)
		database[data.player] = {
			name=data.name,
			balance=0
		}
		local file = fs.open(databasePath, "w")
		file.write(textutils.serialise(database))
		file.close()
		rednet.send(id, nil, "otto")

	end
end

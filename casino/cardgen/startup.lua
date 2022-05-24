MAINFRAME_ID = 57

function addPlayer(player, name)
	rednet.send(MAINFRAME_ID, {type="addPlayer", player=player, name=name}, "otto")
	rednet.receive("otto")
	return
end


local drive = peripheral.wrap("top")
rednet.open("bottom")

while true do
	term.clear()
	term.setCursorPos(1,1)
	term.setTextColor(colors.yellow)
	term.write("Enter player username")
	term.setCursorPos(1,2)
	term.write("> ")
	term.setTextColor(colors.white)
	local input = read()
	term.setTextColor(colors.yellow)
	term.write("Generating card for "..input)

	turtle.turnLeft()
	turtle.suck()
	turtle.dropUp()
	local player = drive.getDiskID()
	addPlayer(player, input)
	drive.setDiskLabel(input.."'ProxBucks - $0")
	local filePath = fs.combine(drive.getMountPath(), "bal")
	file = fs.open(filePath, "w")
	file.write("0")
	file.close()
	turtle.suckUp()
	turtle.turnRight()
	turtle.drop()
end

local monitor, drive, surface, screen, width, height, font, buttons

MAINFRAME_ID = 57
PAYOUT_FEE = 5

local currencyValues = {
	["minecraft:diamond"]=1
}

function waitForButtonPress()
  local pressed = false
  while not pressed do
		local event, button, px, py = os.pullEvent("monitor_touch")
    for text,button in pairs(buttons) do
      if px >= button.x and px <= button.x + button.width and py >= button.y and py <= button.y + button.height then
        button.cb()
        buttons = {}
        pressed = true
      end
    end
  end
end

function getButtonSurface(text, bg)
  local textSize = surface.getTextSize(text, font)
  local button = surface.create(textSize + 2, 7)
  button:fillRect(0,0,textSize+2, 7, bg)
  button:drawText(text, font, 1, 1, colors.black)
  return button
end

function button(surface, text, bg, x, y, func, center)
  local button = getButtonSurface(text, bg)
  if center then
    x = math.floor(x - button.width / 2)
  end
  surface:drawSurface(button, x, y)
  buttons[text] = {x=x, y=y, width=button.width, height=button.height, cb=func}
  return button
end

function getPlayerBalance(player)
	rednet.send(MAINFRAME_ID, {type="getPlayerBalance", player=player}, "otto")
	local _, data = rednet.receive("otto")
	if not data then
		return nil
	end
	return data.name, data.balance
end

function setPlayerBalance(player, balance)
	rednet.send(MAINFRAME_ID, {type="setPlayerBalance", player=player, balance=balance}, "otto")
	rednet.receive("otto")
	local filePath = fs.combine(drive.getMountPath(), "bal")
	file = fs.open(filePath, "w")
	file.write(tostring(balance))
	file.close()
	return
end

function centerText(text, y, color)
	local tWidth = surface.getTextSize(text, font)
	screen:drawText(text, font, math.floor((width - tWidth) / 2), y, color)
end

function dropInventory()
	for i=1,16 do
		turtle.select(i)
		turtle.drop()
	end
end

function countMoney()
	turtle.turnRight()
	local sum = 0
	for i=1,2 do
		for slot=1,16 do
			turtle.select(slot)
			local item = turtle.getItemDetail(slot)
			local isValid = false
			for currency,value in pairs(currencyValues) do
				if item and item.name == currency then
					isValid = true
					sum = sum + value * item.count
				end
			end
			if isValid then
				turtle.drop()
			elseif item then
				turtle.turnLeft()
				turtle.drop()
				turtle.turnRight()
			end
		end
	end
	turtle.select(1)
	turtle.turnLeft()
	return sum
end

function dropMoney(amount)
	turtle.turnRight()
	turtle.select(1)
	while amount > 0 do
		turtle.suck()
		local item = turtle.getItemDetail(1)
		if item == nil then
			turtle.turnLeft()
			return nil
		end
		local amountDropping = math.min(item.count, amount)
		turtle.turnLeft()
		turtle.drop(amountDropping)
		turtle.turnRight()
		amount = amount - amountDropping
		turtle.drop()
	end
	turtle.turnLeft()
end

function setup()
	buttons = {}
	surface = dofile("surface")
	monitor = peripheral.find("monitor")
	drive = peripheral.wrap("bottom")
	monitor.setTextScale(0.5)
	term.redirect(monitor)
  width, height = term.getSize()
  screen = surface.create(width, height)
  font = surface.loadFont(surface.load("font"))
	rednet.open("back")
	redstone.setOutput("top", true)
end

function sleepTick()
	os.sleep(0.05)
end

function detectHack(actualBalance)
	local filePath = fs.combine(drive.getMountPath(), "bal")
	if not fs.exists(filePath) then
		return false
	end
	local file = fs.open(filePath, "r")
	local fakeBalance = tonumber(file.readAll())
	file.close()
	file = fs.open(filePath, "w")
	file.write(tostring(actualBalance))
	file.close()
	if fakeBalance ~= actualBalance then
		return true
	end
	return false
end

setup()
while true do
	screen:clear()
	centerText("Insert", 0, colors.white)
	centerText("Card", 6, colors.white)
	centerText("Use Q", 12, colors.yellow)
	centerText("Muscle", 18, colors.yellow)
	screen:output()
	turtle.select(1)
	local item = turtle.getItemDetail()
	if item and item.name == "computercraft:disk_expanded" then
		redstone.setOutput("top", false)
		turtle.dropDown()
		local player = drive.getDiskID()
		local name,balance = getPlayerBalance(player)
		if detectHack(balance) then
			screen:clear()
			centerText("Nice Try", 8, colors.red)
			centerText("Nerd.", 14, colors.red)
			screen:output()
			os.sleep(5)
			turtle.suckDown()
			turtle.drop()
			os.sleep(2)
			redstone.setOutput("top", true)
		else
			if balance == nil then
				turtle.suckDown()
				turtle.drop()
				screen:clear()
				centerText("INVALID", 0, colors.red)
				centerText("CARD", 6, colors.red)
				centerText("Try", 12, colors.white)
				centerText("Again", 18, colors.white)
				screen:output()
				os.sleep(2)
				redstone.setOutput("top", true)
			else
				local userAction
				while userAction ~= "done" do
					screen:clear()
					centerText("WELCOME", 1, colors.green)
					centerText("$"..tostring(balance), 8, colors.lightBlue)
					button(screen, "DEPOSIT", colors.lime, width / 2, 15, function() userAction="deposit" end, true)
					button(screen, "PAYOUT", colors.red, width / 2, 23, function() userAction="withdraw" end, true)
					button(screen, "DONE", colors.white, width / 2, 31, function() userAction="done" end, true)
					screen:output()
					waitForButtonPress()

					if userAction == "deposit" then
						redstone.setOutput("top", true)
						screen:clear()
						centerText("Insert", 0, colors.white)
						centerText("$$$", 6, colors.lightBlue)
						centerText("Use Q", 12, colors.yellow)
						centerText("Muscle", 18, colors.yellow)
						button(screen, "DONE", colors.red, width / 2, 24, function() end, true)
						screen:output()
						waitForButtonPress()
						redstone.setOutput("top", false)
						screen:clear()
						centerText("Counting", 2, colors.white)
						centerText("...", 6, colors.white)
						screen:output()
						local sum = countMoney()
						setPlayerBalance(player, balance + sum)
						balance = balance + sum
					elseif userAction == "withdraw" then
						screen:clear()
						centerText("PAYOUT", 1, colors.white)
						centerText("$"..tostring(balance), 7, colors.lightBlue)
						local payoutAmount
						if balance < 8 then
							centerText("MINIMUM", 14, colors.red)
							centerText("$8", 20, colors.red)
							button(screen, "DONE", colors.lime, width / 2, 28, function() end, true)
							screen:output()
							waitForButtonPress()
						else
							button(screen, "ALL", colors.yellow, width / 2, 14, function() payoutAmount="all" end, true)
							if balance >= 16 then
								button(screen, "HALF", colors.yellow, width / 2, 22, function() payoutAmount="half" end, true)
								button(screen, "DONE", colors.lime, width / 2, 30, function() payoutAmount="cancel" end, true)
							else
								button(screen, "DONE", colors.lime, width / 2, 22, function() payoutAmount="cancel" end, true)
							end
							screen:drawString("Withdrawal fee: "..tostring(PAYOUT_FEE).."%", 0, height - 1, colors.black, colors.gray)
							screen:output()
							waitForButtonPress()
							local diamondsToDrop = 0
							if payoutAmount == "all" then
								diamondsToDrop = balance
							elseif payoutAmount == "half" then
								diamondsToDrop = balance / 2
							end
							setPlayerBalance(player, math.floor(balance - diamondsToDrop))
							balance = math.floor(balance - diamondsToDrop)
							diamondsToDrop = math.floor(diamondsToDrop * (1 - PAYOUT_FEE / 100))
							dropMoney(diamondsToDrop)
						end
					end
				end
				screen:clear()
				centerText("Thanks!", 0, colors.white)
				centerText("Good", 12, colors.yellow)
				centerText("Luck", 18, colors.yellow)
				screen:output()

				name, balance = getPlayerBalance(player)
				if balance ~= nil then
					drive.setDiskLabel(name.."ProxBucks - $"..tostring(balance))
				end
				turtle.suckDown()
				turtle.drop()
				os.sleep(4)
				redstone.setOutput("top", true)
			end
		end
	elseif item then
		redstone.setOutput("top", false)
		turtle.drop()
		os.sleep(2)
		redstone.setOutput("top", true)
	end
	-- if count > 0 then
	-- 	redstone.setOutput("right", false)
	-- 	turtle.dropDown()
	-- 	local player = drive.getDiskID()
	-- 	setPlayerBalance(player, count)
	-- 	if balance ~= nil then
	-- 		drive.setDiskLabel("L'Otto Card - $"..tostring(balance))
	-- 	end
	-- end
	dropInventory()
end

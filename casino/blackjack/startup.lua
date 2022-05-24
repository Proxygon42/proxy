local surface, monitor, width, height, screen, font, cardBg, cardBack, drive, buttons, deck, bigfont, lastBet, speaker, bouncingCards, logo

MAX_BET = 128
MAINFRAME_ID = 57

math.round = function(x) return x + 0.5 - (x + 0.5) % 1 end
function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function setup()
  surface = dofile("surface")
  monitor = peripheral.wrap("monitor_8")
	drive = peripheral.wrap("bottom")
	rednet.open("right")
	speaker = peripheral.find("speaker")
  monitor.setTextScale(0.5)
  term.redirect(monitor)
  term.setPaletteColor(colors.lightGray, 0xc5c5c5)
  term.setPaletteColor(colors.orange, 0xf15c5c)
  term.setPaletteColor(colors.gray, 0x363636)
  term.setPaletteColor(colors.green, 0x044906)
	width, height = term.getSize()
  screen = surface.create(width, height)
  font = surface.loadFont(surface.load("font"))
  bigfont = surface.loadFont(surface.load("gothic"))
  cardBg = surface.load("card.nfp")
	cardBack = surface.load("cardback.nfp")
	logo = surface.load("logo.nfp")
  buttons = {}
  deck = {}
  local i = 1
  for _,suit in ipairs({"heart", "diamond", "club", "spade"}) do
    for _,num in ipairs({"A", "T", "J", "Q", "K"}) do
      deck[i] = num..suit;
      i = i + 1
    end
    for num = 2, 9, 1 do
      deck[i] = tostring(num)..suit;
      i = i + 1
    end
	end
	shuffle(deck)
	bouncingCards = {}
	
	for i=1,4 do
		bouncingCards[i] = {
			x=-math.floor(math.random() * screen.width * 2),
			mirror=math.random() > 0.5,
			card=deck[i]
		}
	end
end

function drawCard(cardID)
	local number = cardID:sub(1, 1)
	if number == "T" then
		number = "10"
	end
	local suit = cardID:sub(2, -1)
	local card = surface.create(12, 15)
  suit = surface.load(suit..".nfp")
  card:drawSurface(cardBg, 0, 0)
  card:drawSurface(suit, 5, 2)
  card:drawText(number, font, 2, 8, colors.black)
  return card
end

function run()
  local club = surface.load("club.nfp")
  screen:clear(colors.green)
  --screen:drawSurfaceSmall(club, 0, 0)
  screen:drawSurface(drawCard("K", "spade"), 3, 3)
  screen:drawSurface(drawCard("A", "club"), 16, 3)
  screen:drawSurface(drawCard("1", "heart"), 3, 18)
  screen:drawSurface(drawCard("2", "diamond"), 16, 18)
  --screen:drawString(tostring(width)..", "..tostring(height), font, 2, 2, colors.red)
  screen:output()
end

function getButtonSurface(text, bg)
  local textSize = surface.getTextSize(text, font)
  local button = surface.create(textSize + 2, 7)
  button:fillRect(0,0,textSize+2, 7, bg)
  button:drawText(text, font, 1, 1, colors.black)
  return button
end

function betSlider(balance, func)
	local value
	if lastBet ~= nil then
		value = math.min(balance, lastBet)
	else 
		value = math.min(MAX_BET / 2, math.floor(balance / 2))
	end
	local buttonPressed = false
	local quitPressed = false
  while not buttonPressed and not quitPressed do
		screen:clear(colors.green)

    screen:drawText("BALANCE:", font, math.round((screen.width - surface.getTextSize("BALANCE:", font)) / 2), 2, colors.white)
    screen:drawText("$"..tostring(balance), bigfont, math.round((screen.width - surface.getTextSize("$"..tostring(balance), bigfont)) / 2), 8, colors.white)
    local betText = tostring(value)
    local betTextWidth = surface.getTextSize(betText, font)
    -- local betButton = getButtonSurface("BET", colors.lightBlue)
    -- slider:drawSurface(betButton, math.floor(slider.width / 2), 8)

    local updateValue = function(amount)
      return function ()
        value = math.floor(value + amount)
        value = math.min(math.min(MAX_BET, balance), math.max(1, value))
      end
		end
		local yOffset = height - 20
    local betButton = button(screen, "BET", colors.lightBlue, screen.width / 2, yOffset + 8, function() buttonPressed = true end, true)
		button(screen, "QUIT", colors.red, 0, screen.height - 7, function() quitPressed = true end)
		button(screen, "-1", colors.red, math.round(screen.width / 2 - betButton.width / 2 - 11), yOffset, updateValue(-1))
    button(screen, "-8", colors.red, math.round(screen.width / 2 - betButton.width / 2 - 22), yOffset, updateValue(-8))
    button(screen, "+1", colors.lime, math.round(screen.width / 2 + betButton.width / 2 + 2), yOffset, updateValue(1))
    button(screen, "+8", colors.lime, math.round(screen.width / 2 + betButton.width / 2 + 12), yOffset, updateValue(8))
    screen:fillRect(math.round((screen.width - betButton.width)/2), yOffset, betButton.width, 7, colors.white)
    screen:drawText(betText, font, math.round((screen.width - betTextWidth) / 2), yOffset + 1, colors.black)
    screen:output()
    waitForButtonPress(0, 0)
	end
	if quitPressed then
		return nil
	end
	lastBet = value
  return value
end

function waitForButtonPress(ox, oy)
  local pressed = false
  while not pressed do
		local event, button, px, py = os.pullEvent("monitor_touch")
    px = px - ox
		py = py - oy
    for text,button in pairs(buttons) do
      if px >= button.x and px <= button.x + button.width and py >= button.y and py <= button.y + button.height then
        button.cb()
        buttons = {}
        pressed = true
      end
    end
  end
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

function getHandScore(hand)
	local sum = 0
	local aceCount = 0
	for _,card in ipairs(hand) do
		local nStr = card:sub(1, 1)
		local number = tonumber(nStr)
		if number == nil then
			if nStr == "A" then
				number = 11
				aceCount = aceCount + 1
			else
				number = 10
			end
		end
		sum = sum + number
	end
	local soft = aceCount > 0
	while sum > 21 and aceCount > 0 do
		sum = sum - 10
		aceCount = aceCount - 1
	end
	return sum, soft
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

function sleep()
  os.sleep(0.1)
end

function ease(x)
	local n1 = 7.5625
	local d1 = 2.75

	if x < 1 / d1 then
		return n1 * x * x
	elseif x < 2 / d1 then
		x = x - 1.5 / d1
		return n1 * x * x + 0.75
	elseif x < 2.5 / d1 then
		x = x - 2.25 / d1
		return n1 * x * x + 0.9375
	else
		x = x - 2.625 / d1
		return n1 * x * x + 0.984375
	end
end

-- for i=0,1,0.01 do
-- 	print(-ease(i) * 79)
-- 	os.sleep(0.05)
-- end


local jX, aX = 0,-30
function drawIdleScreen()
  screen:clear(colors.green)
	for i,card in ipairs(bouncingCards) do
		local x = card.x
		if card.mirror then
			x = (screen.width - cardBack.width) - x
		end

		screen:drawSurface(drawCard(card.card), x, math.round((ease(card.x / screen.width)) * (screen.height * 0.75) + (screen.height * 0.25)) - cardBack.height)
		bouncingCards[i].x = card.x + 1
		if card.x > width then
			bouncingCards[i].x = -cardBack.width - 5
			card.card = deck[math.floor(math.random() * #deck) + 1]
		end
	end
	screen:drawSurface(logo, 0, 0)
	-- screen:drawText(" BLACK\n   JACK", bigfont, -1, 1, colors.black)
	-- screen:drawText(" BLACK\n   JACK", bigfont, -1, -1, colors.black)
	-- screen:drawText(" BLACK\n   JACK", bigfont, 1, 1, colors.black)
	-- screen:drawText(" BLACK\n   JACK", bigfont, 1, -1, colors.black)
	-- screen:drawText(" BLACK\n   JACK", bigfont, 0, 0, colors.orange)
  screen:output()
end

function quit()
  local player = drive.getDiskID()
  local name, balance = getPlayerBalance(player)
  if balance ~= nil then
    drive.setDiskLabel(name.."ProxBucks - $"..tostring(balance))
  end
  turtle.suckDown()
  turtle.dropUp()
  redstone.setOutput("top", false)
  os.sleep(0.1)
	redstone.setOutput("top", true)
	os.sleep(0.1)
  redstone.setOutput("top", false)
  os.sleep(0.1)
  redstone.setOutput("top", true)
end

function loop()

  screen:clear(colors.green)
  local player = drive.getDiskID()
  local _,balance = getPlayerBalance(player)
  if balance == nil then
    quit()
    return
  end
  screen:drawText(tostring(balance), font, 0,0,colors.black)
	local betAmount = betSlider(balance, quit)
	if betAmount == nil or betAmount == 0 then
    quit()
    return
  end

	shuffle(deck)

	local playerHand = {deck[1], deck[3]}
	local dealerHand = {deck[2], deck[4]}
	local deckIndex = 5

	local userAction = ""
	local handScore = getHandScore(playerHand)
	local dealerScore, dealerSoft = getHandScore(dealerHand)
	local winState
	local canDouble = balance >= betAmount * 2
	local hasDoubled = false

	local function drawPlayerHand(hand, y, hideCard)
		local cardDeltaX = cardBack.width + 2
		if cardDeltaX * #hand > screen.width then
			cardDeltaX = (screen.width - 7) / #hand
		end
		local cardX = (screen.width - (#hand * cardDeltaX)) / 2
		for i,card in ipairs(hand) do
			local img
			if hideCard and i == 2 then
				img = cardBack
			else
				img = drawCard(card)
			end
			screen:drawSurface(img, math.round(cardX), y)
			cardX = cardX + cardDeltaX
		end
	end
	
	local function drawBottomButtons(buttons)
		local totalWidth = 0
		for _, button in ipairs(buttons) do
			button.width = surface.getTextSize(button.text, font) + 4
			totalWidth = totalWidth + button.width
		end
		local leftX = math.round((screen.width - totalWidth) / 2)
		local accWidth = 0
		for _, b in ipairs(buttons) do
			button(screen, b.text, b.color, leftX + accWidth, screen.height - 8, b.func)
			accWidth = accWidth + b.width
		end
	end

	local function drawHands(hideDealerCard, showPlayerButtons)
		screen:clear(colors.green)
		drawPlayerHand(dealerHand, 5, hideDealerCard)
		drawPlayerHand(playerHand, screen.height - 10 - cardBack.height)
		if showPlayerButtons then
			local buttons = {}
			if not hasDoubled then
				buttons[1] = {
					text="HIT",
					color=colors.lightBlue,
					func=function() userAction = "hit" end
				}
			end
			buttons[#buttons + 1] = {
				text="STAND",
				color=colors.lightBlue,
				func=function() userAction = "stand" end
			}
			if canDouble then
				buttons[#buttons + 1]={
					text="x2",
					color=colors.lightBlue,
					func=function() userAction = "double" end
				}
			end
			drawBottomButtons(buttons)
			-- button(screen, "HIT", colors.lightBlue, hitPos, screen.height - 8, function() userAction = "hit" end)
			-- button(screen, "STAND", colors.lightBlue, hitPos + hitWidth + 1, screen.height - 8, function() userAction = "stand" end)
		end
		screen:output()
	end

	if handScore == 21 and dealerScore == 21 then
		winState = "push"
	elseif handScore == 21 then
		winState = "blackjack"
	elseif dealerScore == 21 then
		winState = "dealer blackjack"
	end

	if winState == nil then
		-- Do player actions
		while userAction ~= "stand" and handScore < 21 do
			drawHands(true, true)
			waitForButtonPress(0, 0)
			if userAction == "hit" or userAction == "double" then
				if userAction == "double" then
					hasDoubled = true
				end
				canDouble = false
				playerHand[#playerHand + 1] = deck[deckIndex]
				deckIndex = deckIndex + 1
				handScore = getHandScore(playerHand)
			end
		end

		drawHands(false, false)

		if handScore > 21 then
			winState = "busted"
		else
			while dealerScore < 17 or (dealerScore == 17 and dealerSoft) do
				os.sleep(1.5)
				-- do dealer hit
				dealerHand[#dealerHand + 1] = deck[deckIndex]
				deckIndex = deckIndex + 1
				dealerScore, dealerSoft = getHandScore(dealerHand)

				drawHands(false, false)
			end
			if dealerScore > 21 then
				winState = "you win"
			elseif dealerScore == handScore then
				winState = "push"
			elseif dealerScore > handScore then
				winState = "try again"
			else
				winState = "you win"
			end
		end
	end

	local payoutMult
	if winState == "you win" and hasDoubled then
		payoutMult = 2
	elseif winState == "you win" then
		payoutMult = 1
	elseif winState == "push" then
		payoutMult = 0
	elseif winState == "blackjack" then
		payoutMult = 1.5
	elseif hasDoubled then
		payoutMult = -2
	else
		payoutMult = -1 
	end
	if payoutMult > 0 then
		speaker.playSound("minecraft:entity.player.levelup")
	elseif payoutMult < 0 then
		speaker.playSound("minecraft:entity.witch.ambient")
	end
	local payout = math.floor(payoutMult * betAmount)
	setPlayerBalance(player, balance + payout)

	local playAgain;
	drawHands(false, false)
	drawBottomButtons({
		[1]={
			text="PLAY AGAIN",
			color=colors.lightBlue,
			func=function() playAgain = true end
		},
		[2]={
			text="QUIT",
			color=colors.orange,
			func=function() playAgain = false end
		}
	})
	local winText = string.upper(winState)
	local winTextWidth = surface.getTextSize(winText, font)
	screen:drawText(winText, font, math.round((screen.width - winTextWidth) / 2), math.round(screen.height / 2 - 5), colors.yellow)
	screen:output()
	waitForButtonPress(0, 0)
	if not playAgain then
		quit()
		return
	end
end

setup()
while true do
  if not drive.isDiskPresent() then
    drawIdleScreen()
  else
    loop()
  end
  os.sleep(0.05)
end

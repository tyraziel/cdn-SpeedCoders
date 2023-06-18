---------------------------------------------------------------------------------------
-- Project: SpeedCoder-9 Christian Dev Network
--
-- Name of Game: Pooch Herder
--
-- Date: June 11, 2011
--
-- Version: 1.0
--
-- File name: main.lua
--
-- Code type: Speed Coder
--
-- Author: Tyraziel (Andrew Potozniak)
--
-- Released with the following license -
-- CC BY-NC-SA 3.0
-- http://creativecommons.org/licenses/by-nc-sa/3.0/
---------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

system.activate( "multitouch" )

--Setup the onExit Listener
local onSystem = function( event )
  if event.type == "applicationExit" then
    if system.getInfo( "environment" ) == "device" then
      -- prevents iOS 4+ multi-tasking crashes
      os.exit()
    end
  end
end
Runtime:addEventListener( "system", onSystem )

--Setup the HUD and JoyStick and some other debugging stuff
local hudGroup = display.newGroup()

local debugPooch = display.newRoundedRect(15, 300, 15, 15, 2)
debugPooch.strokeWidth = 3
debugPooch:setFillColor(0, 0, 0)
debugPooch:setStrokeColor(180, 0, 180)
debugPooch.isVisible = false

local touching_pooch = false

hudGroup:insert(debugPooch)

local score = 0
local timeLeft = 0
local actualRound = 1
local timeToNextRound = 3500

--Score
local scoreLabel = display.newText("Score: ", 340, 5, native.systemFont, 20)
scoreLabel:setTextColor(255, 255, 255)

local scoreNumberText = display.newText(score, 420, 5, native.systemFont, 20)
scoreNumberText:setTextColor(255, 255, 255)

--Time Left Label
local timeLeftLabel = display.newText("Time Left: ", 150, 5, native.systemFont, 20)
timeLeftLabel:setTextColor(255, 255, 255)

local timeLeftNumberText = display.newText(timeLeft, 280, 5, native.systemFont, 20)
timeLeftNumberText:setTextColor(255, 255, 255)

local roundLabel = display.newText("Round: ", 10, 5, native.systemFont, 20)
timeLeftLabel:setTextColor(255, 255, 255)

local roundNumberText = display.newText(actualRound, 100, 5, native.systemFont, 20)
roundNumberText:setTextColor(255, 255, 255)

local nextRoundText = display.newText("Next Round 1", 80, 65, native.systemFont, 50)
nextRoundText:setTextColor(255, 255, 255)

local gameOverText = display.newText("GAME OVER", 100, 65, native.systemFont, 50)
gameOverText:setTextColor(155, 0, 0)

gameOverText.isVisible = false

hudGroup:insert(scoreLabel)
hudGroup:insert(scoreNumberText)
hudGroup:insert(timeLeftLabel)
hudGroup:insert(timeLeftNumberText)
hudGroup:insert(roundLabel)
hudGroup:insert(roundNumberText)
hudGroup.isVisible = true

--Main Group
local mainGroup = display.newGroup()

--Pooches
local pooches = {}
poochVelocity = 25
poochObeyTime = 3100 --will result in 3000 for round 1

--Puppy Mat
local puppyMat = display.newCircle(display.contentWidth / 2, display.contentHeight / 2, 35)
puppyMat:setFillColor(120,120,120)
puppyMat.strokeWidth = 3
puppyMat:setStrokeColor(230,230,230)

mainGroup:insert(puppyMat)

local gameOver = false
local winRound = false

function touchPooch(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began" and not t.obeying) then

    --Some Strange Calc to get pooch toward mat
    
    local xMag = puppyMat.x - t.x
    local yMag = puppyMat.y - t.y
    
    local dist = math.sqrt(xMag*xMag + yMag*yMag)
    
    t.velX = (xMag/dist) * poochVelocity * t.velFactor
    t.velY = (yMag/dist) * poochVelocity * t.velFactor
        
    t.timeToObey = poochObeyTime
    t.obeying = true

	t:setFillColor(255,255,255)
    
  end
  
  if(phase == "ended" or phase == "cancelled") then
    display.getCurrentStage():setFocus( t, nil )
  end
  
  return true
end

function loadRound(round)
  for index, pooch in pairs(pooches) do
    pooch:removeSelf()
    table.remove(pooches, index)
  end
  
  poochObeyTime = poochObeyTime - 100
  if(poochObeyTime < 500) then
    poochObeyTime = 500
  end
  timeLeft = 30
  
  for count = 1, round, 1 do
  
    local choice = math.random(5)
    
    local pooch = display.newRoundedRect(0, 0, 20, 20, 2)
    pooch.strokeWidth = 3
    pooch.timeToObey = 0
    pooch.obeying = false
    pooch.nextRandomMovement = math.random(2500) + 2500
    
    if(choice == 1) then
      pooch:setFillColor(222, 184, 135)
      pooch:setStrokeColor(111, 90, 70)
      pooch.velFactor = 2.0      
      pooch.origR = 222
      pooch.origG = 184
      pooch.origB = 135
    elseif(choice == 2) then
      pooch:setFillColor(185,42,42)
      pooch:setStrokeColor(90, 21, 21)  
      pooch.velFactor = 1.5
      pooch.origR = 185
      pooch.origG = 42
      pooch.origB = 42
    elseif(choice == 3) then
      pooch:setFillColor(218,165,32)
      pooch:setStrokeColor(100, 80, 15)  
      pooch.velFactor = 3.0
      pooch.origR = 218
      pooch.origG = 165
      pooch.origB = 32
    elseif(choice == 4) then
      pooch:setFillColor(233,150,122)
      pooch:setStrokeColor(110, 75, 60)  
      pooch.velFactor = 2.5
      pooch.origR = 233
      pooch.origG = 150
      pooch.origB = 122
    elseif(choice == 5) then
      pooch:setFillColor(211,211,211)
      pooch:setStrokeColor(100, 100, 100)  
      pooch.velFactor = 0.5
      pooch.origR = 211
      pooch.origG = 211
      pooch.origB = 211
    end
    

    
    local poochOnMat = true
    
    while(poochOnMat) do
      pooch.x = math.random(display.contentWidth - 10) + 5
      pooch.y = math.random(display.contentHeight-30) + 25
      
      local distX = pooch.x - puppyMat.x
      local distY = pooch.y - puppyMat.y
      
      pooch.velX = 0
      pooch.velY = 0
      pooch.obeying = false
      
      if (distX < 0) then
        pooch.velX = -poochVelocity * pooch.velFactor
      elseif (distX > 0) then
        pooch.velX = poochVelocity * pooch.velFactor      
      end
      if(distY < 0) then
        pooch.velY = -poochVelocity * pooch.velFactor
      elseif(distY > 0) then
        pooch.velY = poochVelocity * pooch.velFactor
      end
      
      poochOnMat = (((distX*distX) + (distY*distY)) < 2209)  -- 35 radius + 3 stroke width squared  (+9 for puppy)
    end
    
    table.insert(pooches,pooch)
    mainGroup:insert(pooch)
    pooch:addEventListener("touch", touchPooch)
  end

  roundNumberText.text = round  
end

local gameTimer = {}
gameTimer.lastTime = 0
local timeInGameOver = 0

local function gameLoop(event)
  local timeSinceLastCall = event.time - gameTimer.lastTime
  local secondsElapsed = timeSinceLastCall / 1000
  local millisElapsed = timeSinceLastCall
  
  gameTimer.lastTime = event.time
  
  if(not gameOver) then
    if(not winRound) then
      --Update Pooches
      
      local allPoochesOnMat = true
      
      for index, pooch in pairs(pooches) do
        pooch.x = pooch.x + (pooch.velX * secondsElapsed)
        pooch.y = pooch.y + (pooch.velY * secondsElapsed)
      
        if(pooch.x < 0)then
          pooch.velX = -pooch.velX
        elseif(pooch.x > display.contentWidth) then
          pooch.velX = -pooch.velX
        end
        if(pooch.y < 0)then
          pooch.velY = -pooch.velY
        elseif(pooch.y > display.contentHeight) then
          pooch.velY = -pooch.velY
        end

        if(pooch.obeying) then
          pooch.timeToObey = pooch.timeToObey - millisElapsed

	      if(pooch.timeToObey < 0) then
	        pooch.obeying = false
	        pooch:setFillColor(pooch.origR, pooch.origG, pooch.origB)
	      
            local xMag = math.random(100) - 50
            local yMag = math.random(100) - 50
    
            local dist = math.sqrt(xMag*xMag + yMag*yMag)
         
            pooch.velX = (xMag/dist) * poochVelocity * pooch.velFactor
            pooch.velY = (yMag/dist) * poochVelocity * pooch.velFactor

            pooch.nextRandomMovement = math.random(2500) + 2500

	        --Move AWAY from PAD
	      end
	    else
	      pooch.nextRandomMovement = pooch.nextRandomMovement - millisElapsed
	      if(pooch.nextRandomMovement < 0) then
	        local xMag = math.random(100) - 50
            local yMag = math.random(100) - 50
    
            local dist = math.sqrt(xMag*xMag + yMag*yMag)
         
            pooch.velX = (xMag/dist) * poochVelocity * pooch.velFactor
            pooch.velY = (yMag/dist) * poochVelocity * pooch.velFactor

            pooch.nextRandomMovement = math.random(2500) + 2500
	      end
        end
        
        --Check for pooch on mat

        if(allPoochesOnMat) then 
          local distX = pooch.x - puppyMat.x
          local distY = pooch.y - puppyMat.y
          allPoochesOnMat = (((distX*distX) + (distY*distY)) < 1225)
        end
      
      end
      
      --check all pooches on mat
      if(allPoochesOnMat)then
        for index, pooch in pairs(pooches) do
          pooch:removeSelf()
          --table.remove(pooches, index)
        end
        pooches = {}
        
        winRound = true
        score = score + math.ceil(timeLeft) * actualRound
        timeToNextRound = 3500
        actualRound = actualRound + 1
        nextRoundText.isVisible = true
        nextRoundText.text = "Next Round "..actualRound
      end
      
      timeLeft = timeLeft - secondsElapsed    
      if(timeLeft < 0)then
        gameOver = true
        timeLeft = 0
      end
    else -- ROUND WON
      timeToNextRound = timeToNextRound - millisElapsed
      if(timeToNextRound < 0) then
        loadRound(actualRound)
        winRound = false
        nextRoundText.isVisible = false
      end
    end
  else --GAME OVER
    gameOverText.isVisible = true
    timeInGameOver = timeInGameOver + millisElapsed
  end
  
  --update score text and timeLeft
  scoreNumberText.text = score
  timeLeftNumberText.text = math.ceil(timeLeft)
end

timeToNextRound = 3500
winRound = true

Runtime:addEventListener( "enterFrame", gameLoop )

function globalTouch(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began" and gameOver and timeInGameOver > 2500) then
	timeToNextRound = 3500
	actualRound = 1
	winRound = true
	gameOver = false
	gameOverText.isVisible = false
    nextRoundText.isVisible = true
    nextRoundText.text = "Next Round "..actualRound
    roundNumberText.text = actualRound
	timeInGameOver = 0
	score = 0
	for index, pooch in pairs(pooches) do
      pooch:removeSelf()
    end
    pooches = {}
  end  
  return true
end

Runtime:addEventListener("touch", globalTouch) 

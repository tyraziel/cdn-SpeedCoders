---------------------------------------------------------------------------------------
-- Project: SpeedCoder-13 Christian Dev Network
--
-- Name of Game: Project P
--
-- Date: October 22, 2011
--
-- Version: 1.0
--
-- File name: main.lua
--
-- Code type: Speed Game
--
-- Author: Tyraziel (Andrew Potozniak)
--
-- Released with the following license -
-- CC BY-NC-SA 3.0
-- http://creativecommons.org/licenses/by-nc-sa/3.0/
--
---------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

--system.activate( "multitouch" )

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

--local debugTopUI = display.newLine(0, 16, 480, 16)
--debugTopUI.width = 3
--debugTopUI:setColor(180, 180, 0)

--hudGroup:insert(debugTopUI)

--local topUI = display.newRect(0,0,480,16)
--topUI:setFillColor(0, 0, 0)

--topUI:toBack()

--hudGroup:insert(topUI)

--dPad:setReferencePoint(display.CenterReferencePoint)

--Physics Engine
local physics = require 'physics'
physics.start()
physics.setGravity(0, 0)
physics.setVelocityIterations(6)
physics.setPositionIterations(16)

--physics.setDrawMode( "debug" ) -- shows collision engine outlines only
--physics.setDrawMode( "hybrid" ) -- overlays collision outlines on normal Corona objects
physics.setDrawMode( "normal" ) -- the default Corona renderer, with no collision outlines

--Main Group
local mainGroup = display.newGroup()

local function initPaddlePart()
  local paddlePart = display.newRoundedRect(0, 0, 10, 10, 2)
  paddlePart:setReferencePoint(display.CenterReferencePoint)
  paddlePart.strokeWidth = 0
  paddlePart:setFillColor(255, 255, 255)
  paddlePart:setStrokeColor(255, 255, 255)
  physics.addBody(paddlePart,{density=1000.0, friction=0.0, bounce=0.0})
  paddlePart.what = "paddlePart" -- help to know what this is for the event listener
  paddlePart.isFixedRotation = true
  paddlePart.isSensor = true --allows things to pass through
  paddlePart.isVisible = true
  paddlePart.alpha = 0.0

  return paddlePart
end

local playerPaddleGroup = display.newGroup()

local playerStartX = 25
local playerStartY = 145

local playerPaddlePartA = initPaddlePart()
playerPaddlePartA.x = playerStartX
playerPaddlePartA.y = playerStartY

local playerPaddlePartB = initPaddlePart()
playerPaddlePartB.x = playerStartX
playerPaddlePartB.y = playerStartY + 10

local playerPaddlePartC = initPaddlePart()
playerPaddlePartC.x = playerStartX
playerPaddlePartC.y = playerStartY + 20

local playerPaddlePartD = initPaddlePart()
playerPaddlePartD.x = playerStartX
playerPaddlePartD.y = playerStartY + 30

local playerPaddlePartE = initPaddlePart()
playerPaddlePartE.x = playerStartX
playerPaddlePartE.y = playerStartY + 40

playerPaddleGroup:insert(playerPaddlePartA)
playerPaddleGroup:insert(playerPaddlePartB)
playerPaddleGroup:insert(playerPaddlePartC)
playerPaddleGroup:insert(playerPaddlePartD)
playerPaddleGroup:insert(playerPaddlePartE)

playerPaddleGroup.isVisible = false
playerPaddleGroup.rezzingUp = false
playerPaddleGroup.speedY = 0.0
playerPaddleGroup.score = 0

mainGroup:insert(playerPaddleGroup)

local cpuPaddleGroup = display.newGroup()

local cpuStartX = 455
local cpuStartY = 145

local cpuPaddlePartA = initPaddlePart()
cpuPaddlePartA.x = cpuStartX
cpuPaddlePartA.y = cpuStartY

local cpuPaddlePartB = initPaddlePart()
cpuPaddlePartB.x = cpuStartX
cpuPaddlePartB.y = cpuStartY + 10

local cpuPaddlePartC = initPaddlePart()
cpuPaddlePartC.x = cpuStartX
cpuPaddlePartC.y = cpuStartY + 20

local cpuPaddlePartD = initPaddlePart()
cpuPaddlePartD.x = cpuStartX
cpuPaddlePartD.y = cpuStartY + 30

local cpuPaddlePartE = initPaddlePart()
cpuPaddlePartE.x = cpuStartX
cpuPaddlePartE.y = cpuStartY + 40

cpuPaddleGroup:insert(cpuPaddlePartA)
cpuPaddleGroup:insert(cpuPaddlePartB)
cpuPaddleGroup:insert(cpuPaddlePartC)
cpuPaddleGroup:insert(cpuPaddlePartD)
cpuPaddleGroup:insert(cpuPaddlePartE)

cpuPaddleGroup.isVisible = false
cpuPaddleGroup.rezzingUp = false
cpuPaddleGroup.speedY = 0.0
cpuPaddleGroup.score = 0

local scoreText = display.newText(playerPaddleGroup.score.."-"..cpuPaddleGroup.score, 205, 50, native.systemFont, 36)
scoreText:setTextColor(255,255,255)
scoreText.isVisible = false

mainGroup:insert(cpuPaddleGroup)

local ball = display.newCircle(0, 0, 7)
ball:setReferencePoint(display.CenterReferencePoint)
ball.strokeWidth = 0
ball:setFillColor(255, 255, 255)
ball:setStrokeColor(255, 255, 255)
physics.addBody(ball,{density=1000.0, friction=0.0, bounce=0.0})
ball.what = "ball" -- help to know what this is for the event listener
ball.isFixedRotation = true
--paddlePart.isSensor = true --allows things to pass through
ball.isVisible = false
ball.x = 240
ball.y = 160

mainGroup:insert(ball)

hudGroup:toFront()

local gameState = {gameOver = false, paused = true, win = false, endGame = false, begin = true, startRezz = false, rezzingUp = false, paddleBounce = false}
local gameTimer = {lastTime = 0, timeLeftForRezz = 0, timeLeftForNoBounce = 0}

local function collideWithBall( self, event )

  if ( event.phase == "began" and not self.isInvincible) then
    local destroyOther = false
  
    if(event.other.what == "paddlePart") then
      if(gameState.paddleBounce == false and (ball.x < 455 and ball.x > 25))then
        gameState.paddleBounce = true
        gameTimer.timeLeftForNoBounce = 500
        self.speedX = -self.speedX
        
        local change = ((math.random() -0.5) * 3.0)
        
        ball.speedY = 70 * (change)
        if(ball.speedX < 0)then
          ball.speedX = ball.speedX - math.random(0,10)
        else
          ball.speedX = ball.speedX + math.random(0,10)
        end
        print("ballspeed: "..ball.speedX.."###"..ball.speedY)
      end
    elseif(event.other.what == "Item") then
      --powerup goodness?
    end
  
    --TODO Remove me
    print( "ball: "..self.what .. ": collision began with " .. event.other.what )
    
    if(destroyOther) then
      event.other:removeSelf()
    end
  end
  
end

ball.collision = collideWithBall
ball:addEventListener( "collision", ball )

local function gameLoop(event)
  local timeSinceLastCall = event.time - gameTimer.lastTime
  local secondsElapsed = timeSinceLastCall / 1000
  local millisElapsed = timeSinceLastCall
  
  gameTimer.lastTime = event.time
  
  if(not gameState.endGame) then
    if(not gameState.gameOver) then
      if(not gameState.paused) then
        if(gameState.startRezz) then

          gameTimer.timeLeftForRezz = 9000
          gameState.rezzingUp = true
          gameState.startRezz = false
          
        elseif(gameState.rezzingUp) then
          gameTimer.timeLeftForRezz = gameTimer.timeLeftForRezz - millisElapsed

          --Flicker in game grid for 3 seconds
          --Flicker in paddles for 3 seconds
          --Flicker in ball for 3 seconds
          if(gameTimer.timeLeftForRezz < 9000) then
            playerPaddleGroup.rezzingUp = true
            cpuPaddleGroup.rezzingUp = true
            playerPaddleGroup.isVisible = true
            cpuPaddleGroup.isVisible = true
          end
          
          
          if(gameTimer.timeLeftForRezz < 6000) then
            playerPaddleGroup.rezzingUp = true
            cpuPaddleGroup.rezzingUp = true
            playerPaddleGroup.isVisible = true
            cpuPaddleGroup.isVisible = true
          end
          
          if(gameTimer.timeLeftForRezz < 3000) then
            playerPaddleGroup.rezzingUp = false
            cpuPaddleGroup.rezzingUp = false
            ball.rezzingUp = true
            ball.isVisible = true
          end
                    
          if(gameTimer.timeLeftForRezz < 0) then
            gameState.rezzingUp = false
            ball.rezzingUp = false
          end
          
          if(playerPaddleGroup.rezzingUp)then
            local num = math.random(1,2500)
            if(num < 100)then
              playerPaddlePartA.alpha = math.random() + 0.1
            elseif(num < 200)then
              playerPaddlePartB.alpha = math.random() + 0.1
            elseif(num < 300)then
              playerPaddlePartC.alpha = math.random() + 0.1
            elseif(num < 400)then
              playerPaddlePartD.alpha = math.random() + 0.1
            elseif(num < 500)then
              playerPaddlePartE.alpha = math.random() + 0.1
            end
          elseif(playerPaddleGroup.isVisible) then
            playerPaddlePartA.alpha = 1.0
            playerPaddlePartB.alpha = 1.0
            playerPaddlePartC.alpha = 1.0
            playerPaddlePartD.alpha = 1.0
            playerPaddlePartE.alpha = 1.0
          end
          
          if(cpuPaddleGroup.rezzingUp)then
            local num = math.random(1,2500)
            if(num < 100)then
              cpuPaddlePartA.alpha = math.random() + 0.1
            elseif(num < 200)then
              cpuPaddlePartB.alpha = math.random() + 0.1
            elseif(num < 300)then
              cpuPaddlePartC.alpha = math.random() + 0.1
            elseif(num < 400)then
              cpuPaddlePartD.alpha = math.random() + 0.1
            elseif(num < 500)then
              cpuPaddlePartE.alpha = math.random() + 0.1
            end
          elseif(cpuPaddleGroup.isVisible)then
            cpuPaddlePartA.alpha = 1.0
            cpuPaddlePartB.alpha = 1.0
            cpuPaddlePartC.alpha = 1.0
            cpuPaddlePartD.alpha = 1.0
            cpuPaddlePartE.alpha = 1.0
          end
          
          if(ball.rezzingUp)then
            local num = math.random(1,1000)
            if(num < 100)then
              ball.alpha = math.random() + 0.1
            end
          elseif(ball.isVisible)then
            ball.alpha = 1.0
            ball.speedX = 70.0 + math.random(0,30)
            ball.speedY = 70.0 * math.random(-1,1)
          end
          
        else  ---- GAME PLAY
          if(ball.rezzingUp)then
            ball.x = 240
            ball.y = 160
            local num = math.random(1,500)
            if(num < 100)then
              ball.alpha = math.random() + 0.1
            end
            gameTimer.timeLeftForRezz = gameTimer.timeLeftForRezz - millisElapsed
            scoreText.text = playerPaddleGroup.score.."-"..cpuPaddleGroup.score
            scoreText.isVisible = true
            if(gameTimer.timeLeftForRezz < 0)then
              ball.rezzingUp = false
              ball.alpha = 1.0
              scoreText.isVisible = false
              ball.speedY = 70.0 * math.random(-1,1)
            end
          end


          if(gameState.paddleBounce)then
            gameTimer.timeLeftForNoBounce = gameTimer.timeLeftForNoBounce - millisElapsed
            if(gameTimer.timeLeftForNoBounce < 0)then
              gameState.paddleBounce = false
            end
          end

          -- Game Playing
          if(not ball.rezzingUp) then
            ball.x = ball.x + (ball.speedX * secondsElapsed)
            ball.y = ball.y + (ball.speedY * secondsElapsed)
        
            if (ball.y < 0) then
              ball.speedY = -ball.speedY
            elseif (ball.y > 320) then
              ball.speedY = -ball.speedY
            end
           
            if(ball.x < 0) then
              cpuPaddleGroup.score = cpuPaddleGroup.score + 1
            elseif( ball.x > 480) then
              playerPaddleGroup.score = playerPaddleGroup.score + 1
            end
          
            if(ball.x < 0 or ball.x > 480) then
              ball.rezzingUp = true
              ball.alpha = 0.0
              gameTimer.timeLeftForRezz = 1500
              --Re-Establish Speed
            end
          end          
          
          if(ball.y < cpuPaddlePartC.y - 25)then
            cpuPaddleGroup.speedY = -70
          elseif(ball.y > cpuPaddlePartC.y + 25)then
            cpuPaddleGroup.speedY = 70
          end
          
          playerPaddlePartA.y = playerPaddlePartA.y + (playerPaddleGroup.speedY * secondsElapsed)
          playerPaddlePartB.y = playerPaddlePartB.y + (playerPaddleGroup.speedY * secondsElapsed)
          playerPaddlePartC.y = playerPaddlePartC.y + (playerPaddleGroup.speedY * secondsElapsed)
          playerPaddlePartD.y = playerPaddlePartD.y + (playerPaddleGroup.speedY * secondsElapsed)
          playerPaddlePartE.y = playerPaddlePartE.y + (playerPaddleGroup.speedY * secondsElapsed)

          cpuPaddlePartA.y = cpuPaddlePartA.y + (cpuPaddleGroup.speedY * secondsElapsed)
          cpuPaddlePartB.y = cpuPaddlePartB.y + (cpuPaddleGroup.speedY * secondsElapsed)
          cpuPaddlePartC.y = cpuPaddlePartC.y + (cpuPaddleGroup.speedY * secondsElapsed)
          cpuPaddlePartD.y = cpuPaddlePartD.y + (cpuPaddleGroup.speedY * secondsElapsed)
          cpuPaddlePartE.y = cpuPaddlePartE.y + (cpuPaddleGroup.speedY * secondsElapsed)
          
          if(cpuPaddleGroup.score > 4)then
            gameState.win = false
            gameState.gameOver = true
          elseif(playerPaddleGroup.score > 4) then
            gameState.win = true
            gameState.gameOver = true
          end
        end
        

      end
    else -- GAMEOVER
      scoreText.text = playerPaddleGroup.score.."-"..cpuPaddleGroup.score
      scoreText.isVisible = true
      if(gameState.win) then
        local winText = display.newText("YOU WIN!", 100, 115, native.systemFont, 64)
        winText:setTextColor(0,255,64)
      else
        local loseText = display.newText("YOU LOSE!", 50, 115, native.systemFont, 64)
        loseText:setTextColor(255,255,0)
      end
      gameState.endGame = true
    end
  end
end

Runtime:addEventListener( "enterFrame", gameLoop )

local startText = display.newText("Touch anywhere to Start!", 25, 135, native.systemFont, 36)
startText:setTextColor(255,255,255)

--Global Touch Event
function globalTouch(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began") then
    if(gameState.begin) then
      gameState.paused = false
      startText:removeSelf()
      gameState.begin = false
      gameState.startRezz = true
    elseif(gameState.paused == false and gameState.rezzingUp == false) then
      --Define Speed of paddle
	  print("PADDLE SPEED: "..event.x.."#"..event.y.."  %% "..(event.y - playerPaddlePartC.y ))
	  print("PADDLE GROUP: "..playerPaddlePartC.y.."#")

      playerPaddleGroup.speedY = event.y - playerPaddlePartC.y 
    end
  elseif(phase == "moved") then
    if(gameState.paused == false and gameState.rezzingUp == false) then
    
    end
    -- What to do with paddle movement?
  
  elseif(phase == "ended") then
    if(gameState.paused == false and gameState.rezzingUp == false) then
      playerPaddleGroup.speedY = 0
    end    
  end
  
  return true
end

Runtime:addEventListener("touch", globalTouch)
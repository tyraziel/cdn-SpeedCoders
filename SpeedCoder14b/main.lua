---------------------------------------------------------------------------------------
-- Project: SpeedCoder-14 Christian Dev Network
-- Name of Game: Pie Fighters
-- Date: November 25, 2011
-- Version: 1.0
-- File name: main.lua
-- Code type: Speed Game
-- Author: Tyraziel (Andrew Potozniak)
-- Released with the following lisense -
-- CC BY-NC-SA 3.0
-- http://creativecommons.org/licenses/by-nc-sa/3.0/
---------------------------------------------------------------------------------------

--Setup some defaults
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

--Setup HUD
local hudGroup = display.newGroup()

--local topUI = display.newRect(0,0,480,32)
--topUI:setFillColor(255, 255, 255)

--topUI:toBack()

--hudGroup:insert(topUI)

local pauseText

local gameOverText = display.newText("GAME OVER!", 50, 115, native.systemFont, 64)
gameOverText:setTextColor(255,255,0)

hudGroup:insert(gameOverText)
gameOverText.isVisible = false

local winText = display.newText("YOU WIN!", 100, 115, native.systemFont, 64)
winText:setTextColor(0,255,64)

hudGroup:insert(winText)
winText.isVisible = false

local pauseButton = display.newImage("pause-button.png", 425, 265)
pauseButton.alpha = 0.75
hudGroup:insert(pauseButton)

local scoreLabel = display.newText("Score: 0", 0, 0, native.systemFont, 16)
scoreLabel:setTextColor(255,255,255)
scoreLabel:setReferencePoint(display.TopLeftReferencePoint);
scoreLabel.x = 10
scoreLabel.y = 10
hudGroup:insert(scoreLabel)

local debugVelX = display.newText("VelX: 0", 20, 288, native.systemFont, 12)
debugVelX:setTextColor(255,255,255)
debugVelX:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugVelX)

local debugVelY = display.newText("VelY: 0", 20, 300, native.systemFont, 12)
debugVelY:setTextColor(255,255,255)
debugVelY:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugVelY)

local debugCalibVelX = display.newText("CalX: 0", 20, 264, native.systemFont, 12)
debugCalibVelX:setTextColor(255,255,255)
debugCalibVelX:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugCalibVelX)

local debugCalibVelY = display.newText("CalY: 0", 20, 276, native.systemFont, 12)
debugCalibVelY:setTextColor(255,255,255)
debugCalibVelY:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugCalibVelY)

local debugDiffVelX = display.newText("DifX: 0", 20, 240, native.systemFont, 12)
debugDiffVelX:setTextColor(255,255,255)
debugDiffVelX:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugDiffVelX)

local debugDiffVelY = display.newText("DifY: 0", 20, 252, native.systemFont, 12)
debugDiffVelY:setTextColor(255,255,255)
debugDiffVelY:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugDiffVelY)

local debugMainGroupX = display.newText("MGX: 0", 200, 288, native.systemFont, 12)
debugMainGroupX:setTextColor(255,255,255)
debugMainGroupX:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugMainGroupX)

local debugMainGroupY = display.newText("MGY: 0", 200, 300, native.systemFont, 12)
debugMainGroupY:setTextColor(255,255,255)
debugMainGroupY:setReferencePoint(display.CenterLeftReferencePoint);
hudGroup:insert(debugMainGroupY)
--480,320 -- 240,160

local crossHairs = {}

crossHairs[1] = display.newRect(0,0,5,10)
crossHairs[1]:setReferencePoint(display.CenterReferencePoint);
crossHairs[1]:setFillColor(128,128,128)
crossHairs[1].x = 230
crossHairs[1].y = 150
crossHairs[1].rotation = 135
hudGroup:insert(crossHairs[1])
crossHairs[1].isVisible = false

crossHairs[2] = display.newRect(0,0,5,10)
crossHairs[2]:setReferencePoint(display.CenterReferencePoint);
crossHairs[2]:setFillColor(128,128,128)
crossHairs[2].x = 250
crossHairs[2].y = 150
crossHairs[2].rotation = 45
hudGroup:insert(crossHairs[2])
crossHairs[2].isVisible = false

crossHairs[3] = display.newRect(0,0,5,10)
crossHairs[3]:setReferencePoint(display.CenterReferencePoint);
crossHairs[3]:setFillColor(128,128,128)
crossHairs[3].x = 230
crossHairs[3].y = 170
crossHairs[3].rotation = 45
hudGroup:insert(crossHairs[3])
crossHairs[3].isVisible = false

crossHairs[4] = display.newRect(0,0,5,10)
crossHairs[4]:setReferencePoint(display.CenterReferencePoint);
crossHairs[4]:setFillColor(128,128,128)
crossHairs[4].x = 250
crossHairs[4].y = 170
crossHairs[4].rotation = 135
hudGroup:insert(crossHairs[4])
crossHairs[4].isVisible = false

--Main Group
local mainGroup = display.newGroup()

mainGroup.x = 0
mainGroup.y = 0

local gameState = {gameOver = false, paused = true, win = false, endGame = false, begin = true,
                   playing = false}
                   
local gameTimer = {lastTime = 0, gunCoolDown = 0}

local spaceShip = {velX = 0, velY = 0, calX = 0, calY = 0,
                   firing = false, firingCoolDown = 500, firingTime = 0}

local starField = {}

local enemies = {}

local bullets = {}

local explosions = {}

local gameInfo = {xMin = -500, xMax = 500,
                  yMin = -500, yMax = 500,
                  enemyCreateMinTime = 500, enemyCreateMaxTime = 2500,
                  timeLeftTillEnemyCreate = 1000, 
                  maxEnemies = 5, currentEnemies = 0,
                  score = 0, playMusic = true}

hudGroup:toFront()

--local backgroundMusic = audio.loadStream("the_file.ogg")
--local backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=0 }  )
--audio.rewind(backgroundMusic)
--audio.stop(backgroundMusicChannel)

local function createStarField()
  for i=1, 500 do
    starField[i] = display.newRect(0,0,5,5)
    starField[i]:setReferencePoint(display.CenterReferencePoint);
    starField[i]:setFillColor(255,255,255)
    mainGroup:insert(starField[i])
    
    starField[i].x = math.random(gameInfo.xMin,gameInfo.xMax) + 240
    starField[i].y = math.random(gameInfo.yMin,gameInfo.yMax) + 160

  end
  
end

local function addStar()
    newStar = display.newRect(0,0,5,5)
    newStar:setReferencePoint(display.CenterReferencePoint);
    newStar:setFillColor(255,255,255)
    
    --Might need to evaluate this because of the mainGroup
    mainGroup:insert(newStar)
    newStar.x = math.random(gameInfo.xMin,gameInfo.xMax) + 240
    newStar.y = math.random(gameInfo.yMin,gameInfo.yMax) + 160
    
    table.insert(starField, newStar)
end

local function gameLoop(event)
  local timeSinceLastCall = event.time - gameTimer.lastTime
  local secondsElapsed = timeSinceLastCall / 1000
  local millisElapsed = timeSinceLastCall
  
  gameTimer.lastTime = event.time

  debugVelX.text = "VelX: "..spaceShip.velX
  debugVelY.text = "VelY: "..spaceShip.velY
  debugCalibVelX.text = "CalX: "..spaceShip.calX
  debugCalibVelY.text = "CalY: "..spaceShip.calY
  debugDiffVelX.text = "DifX: "..(spaceShip.calX - spaceShip.velX)
  debugDiffVelY.text = "DifY: "..(spaceShip.calY - spaceShip.velY)
  debugMainGroupX.text = "MGX: "..mainGroup.x
  debugMainGroupY.text = "MGY: "..mainGroup.y
  scoreLabel.text = "Score: "..gameInfo.score
  
  if(not gameState.endGame) then
    if(not gameState.gameOver) then
      if(not gameState.paused) then
          mainGroup.x = mainGroup.x + (spaceShip.calX - spaceShip.velX) * 10
          mainGroup.y = mainGroup.y + (spaceShip.calY - spaceShip.velY) * 10
          
          --mainGroup.x = mainGroup.x - 50 * secondsElapsed
          --mainGroup.y = mainGroup.y - 50 * secondsElapsed
          
          if(mainGroup.x > gameInfo.xMax) then
            mainGroup.x = gameInfo.xMax
          elseif(mainGroup.x < gameInfo.xMin) then
            mainGroup.x = gameInfo.xMin
          end
          
          if(mainGroup.y > gameInfo.yMax) then
            mainGroup.y = gameInfo.yMax
          elseif(mainGroup.y < gameInfo.yMin) then
            mainGroup.y = gameInfo.yMin
          end
          
          
          for index, explosion in pairs(explosions) do
            explosion.timeToLive = explosion.timeToLive - millisElapsed
                        
            if(explosion.timeToLive < 0) then
              table.remove(explosions, index)
              explosion:removeSelf()
            else
              explosion.x = explosion.x + explosion.velX * secondsElapsed
              explosion.y = explosion.y + explosion.velY * secondsElapsed
              explosion.alpha = explosion.timeToLive / 1500
            end      
          end
          
          --check stars for distance away to create enemies
          
          if(gameInfo.currentEnemies < gameInfo.maxEnemies) then
            gameInfo.timeLeftTillEnemyCreate = gameInfo.timeLeftTillEnemyCreate - millisElapsed
            
            if (gameInfo.timeLeftTillEnemyCreate < 0) then
              print("Attempting to create ENEMY!!!")
              --Loop through stars till you find one in a respectable distance and create it as
              --an enemy
              for index, star in pairs(starField) do
                --local distance = () * (star.x - mainGroup.x + 240) + (star.y - mainGroup.y + 160) * (star.y - mainGroup.y + 160)
                
                
                if(star.x < 480 - mainGroup.x and star.y < 320 - mainGroup.y and
                   star.x > 0 - mainGroup.x and star.y > 0 - mainGroup.y) then
                  print("Created ENEMY! "..index.."@"..star.x.." "..star.y.." ### "..mainGroup.x.." "..mainGroup.y)
                  table.remove(starField, index)
                  
                  star.xScale = 3.00
                  star.yScale = 3.00
                  star:setFillColor(147,112,219)
                  --147,112,219
                  --148,0,211
                  
                  star.velX = math.random(-50,50)
                  star.velY = math.random(-50,50)
                  star.timeTillChangeMove = math.random(500,2500)
                  star.timeTillFire = math.random(1500,5000)
                  --give it enemy qualities
                  
                  table.insert(enemies, star)
                  gameInfo.currentEnemies = gameInfo.currentEnemies + 1
                  break
                end
              end
              
              gameInfo.timeLeftTillEnemyCreate = math.random(gameInfo.enemyCreateMinTime, gameInfo.enemyCreateMaxTime)
            end
          end
                    
          --check enemies for distance away to remove them
          for index, enemy in pairs(enemies) do
            --print ("ENEMY "..index)
            enemy.timeTillChangeMove = enemy.timeTillChangeMove - millisElapsed
            
            if(enemy.timeTillChangeMove < 0)then
              enemy.velX = math.random(-50,50)
              enemy.velY = math.random(-50,50)
              enemy.timeTillChangeMove = math.random(500,2500)
            end
            
            if(enemy.timeTillFire < 0) then
              enemy.timeTillFire = math.random(1500,5000)
            end
            
            enemy.x = enemy.x + enemy.velX * secondsElapsed
            enemy.y = enemy.y + enemy.velY * secondsElapsed
            
            if(enemy.x < 255 - mainGroup.x and enemy.y < 175 - mainGroup.y and
               enemy.x > 225 - mainGroup.x and enemy.y > 145 - mainGroup.y) then
               print("ENEMY "..index.." in crosshairs!")
            end
            
            if((enemy.x > 480 - mainGroup.x or enemy.x < 0 - mainGroup.x) or
               (enemy.y > 320 - mainGroup.y or enemy.y < 0 - mainGroup.y)) then
               print ("ENEMY "..index.." out of view!")
               table.remove(enemies, index)
               enemy:removeSelf()
               gameInfo.currentEnemies = gameInfo.currentEnemies - 1
            end
          end
          
          
          if(spaceShip.firing) then
            spaceShip.firingTime = spaceShip.firingTime + millisElapsed
            
            bullets[1].x = bullets[1].x + 480 * secondsElapsed
            bullets[2].x = bullets[2].x - 480 * secondsElapsed
            
            local scale = (240 - bullets[1].x) / 240
            if(scale < .25) then scale = .25 end
            
            bullets[1].xScale = scale
            bullets[1].yScale = scale

            bullets[2].xScale = scale
            bullets[2].yScale = scale
            
            if(spaceShip.firingTime > spaceShip.firingCoolDown) then
              --check enemies for hit!
            
              for i=1,4 do
                crossHairs[i]:setFillColor(128,128,128)
              end
              spaceShip.firing = false
              spaceShip.firingTime = 0
              
              bullets[1]:removeSelf()
              bullets[2]:removeSelf()
              
              for index, enemy in pairs(enemies) do
                if(enemy.x < 255 - mainGroup.x and enemy.y < 175 - mainGroup.y and
                  enemy.x > 225 - mainGroup.x and enemy.y > 145 - mainGroup.y) then
                  print("ENEMY "..index.." SHOT!")
                  
                  local shotX = enemy.x
                  local shotY = enemy.y
                  
                  table.remove(enemies, index)
                  enemy:removeSelf()
                  gameInfo.currentEnemies = gameInfo.currentEnemies - 1                  
                  
                  gameInfo.score = gameInfo.score + 50
                  
                  for i=1,20 do
                    local explosion = display.newCircle(0,0,4)
                    explosion:setReferencePoint(display.CenterReferencePoint)
                    explosion:setFillColor(255,69,0)
                    mainGroup:insert(explosion)
                    explosion.x = shotX
                    explosion.y = shotY
                    explosion.velX = math.random(-100,100)
                    explosion.velY = math.random(-100,100)
                    explosion.timeToLive = 1500
                    table.insert(explosions, explosion)
                  end
                end              
              end
            end
          end
      end
    else -- GAMEOVER
      if(gameState.win) then

      else

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
      
      if(gameInfo.playMusic) then
        --backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=0 }  )
      end
      
      spaceShip.calX = spaceShip.velX
      spaceShip.calY = spaceShip.velY
      createStarField()
      gameState.playing = true
      for i=1,4 do
        crossHairs[i].isVisible = true
      end
    elseif(gameState.playing and not gameState.paused and not spaceShip.firing)then
      spaceShip.firing = true
      
      for i=1,4 do
        crossHairs[i]:setFillColor(128,0,0)
      end
      
      bullets[1] = display.newCircle(0,0,10)
      bullets[1]:setFillColor(128,0,0)
      bullets[1]:setReferencePoint(display.CenterReferencePoint);
      bullets[1].x = 0
      bullets[1].y = 160
      
      bullets[2] = display.newCircle(0,0,10)
      bullets[2]:setFillColor(128,0,0)
      bullets[2]:setReferencePoint(display.CenterReferencePoint);
      bullets[2].x = 480
      bullets[2].y = 160
      
      hudGroup:insert(bullets[1])
      hudGroup:insert(bullets[2])
      
    end
  elseif(phase == "moved") then
  
  elseif(phase == "ended") then

  end
  
  return true
end

Runtime:addEventListener("touch", globalTouch)

--Times Per Second
system.setAccelerometerInterval(60)

local function onTilt( event )
  spaceShip.velX = -event.yGravity --landscape x = yGravity
  spaceShip.velY = -event.xGravity --landscape y = xGravity
end
 
Runtime:addEventListener( "accelerometer", onTilt )

function pauseButtonTouch(event)
  local t = event.target
  local phase = event.phase
  
  if(event.phase == "began") then
    if(not gameState.gameOver and not gameState.begin) then
  
    gameState.paused = not gameState.paused
    
      if(gameState.paused) then
        pauseText = display.newText("PAUSED", 0, 65, native.systemFont, 128)
        pauseText:setTextColor(255,255,255)
        pauseText.alpha = 1
        pauseText.isVisible = true
       --audio.stop(backgroundMusicChannel)
      else
        spaceShip.calX = spaceShip.velX
        spaceShip.calY = spaceShip.velY
        pauseText:removeSelf()
        if(gameInfo.playMusic) then
          --backgroundMusicChannel = audio.play( backgroundMusic, { channel=1, loops=-1, fadein=0 }  )
        end
      end
    end
  end
  return true
end

pauseButton:addEventListener("touch", pauseButtonTouch)
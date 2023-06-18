---------------------------------------------------------------------------------------
-- Project: SpeedCoder-15 Christian Dev Network
-- Name of Game: Log Collector
-- Date: May 26, 2012
-- Version: 1.0
-- File name: main.lua
-- Code type: Speed Game
-- Author: Tyraziel (Andrew Potozniak)
-- Released with the following license -
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

--local topUI = display.newRect(0,0,480,16)
--topUI:setFillColor(255, 255, 255)
--topUI:toBack()
--hudGroup:insert(topUI)

--Main Group
local mainGroup = display.newGroup()

local gameOverText = display.newText("GAME OVER!", 50, 115, native.systemFont, 64)
gameOverText:setTextColor(255,255,0)

hudGroup:insert(gameOverText)
gameOverText.isVisible = false

hudGroup:toFront()

local gameState = {gameOver = false, paused = true, win = false, endGame = false, begin = true, startRezz = false, rezzingUp = false, paddleBounce = false}
local gameTimer = {lastTime = 0, timeLeftForRezz = 0, timeLeftForNoBounce = 0}

local campSite = nil
local fireWood = {}

local maxFireWood = 5
local timeUntilNextWoodSpawnMS = 500
local maxTimeUntilNextWoodSpawnMS = 1000
local minTimeUntilNextWoodSpawnMS = 250

local fire = nil
local fireParticles = {}
local fireNumberParticles = 500

local minTimeToLive = 0
local maxTimeToLive = 500
local logsCollected = 0

local gatheringWood = false

local fingerDrags = {}
local fingerDragsTimeToLive = 750

local createNewFingerDrag = function(x,y)
  drag = display.newCircle(x,y,4)
  drag:setReferencePoint(display.CenterReferencePoint)
  drag.x = x
  drag.y = y
  drag.timeToLive = fingerDragsTimeToLive
  drag:setFillColor(255, 255, 255)

  table.insert(fingerDrags, drag)
end

local startGatheringWood = function(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began" and not gatheringWood) then
    gatheringWood = true
  end
end

local loadGame = function()
  campSite = display.newRoundedRect(0,0,35,35,4)
  campSite:setReferencePoint(display.CenterReferencePoint)
  campSite.strokeWidth = 2
  campSite:setFillColor(0, 128, 0)
  campSite:setStrokeColor(0, 255, 0)
  campSite.x = 260
  campSite.y = 160
  campSite:addEventListener("touch", startGatheringWood)

  fire = display.newRoundedRect(0,0,25,10,4)
  fire:setReferencePoint(display.CenterReferencePoint)
  fire.strokeWidth = 2
  fire:setFillColor(160, 82, 45)-- 255, 168, 73 -----28
  fire:setStrokeColor(156, 42, 0)
  fire.x = 220
  fire.y = 170
  fire.strength = 500
  fire.maxStrength = 500
  fire.strengthLoss = 100

  for i=1,fireNumberParticles do
    fireParticle = display.newRect(0,0,1,1)
    fireParticle.isVisible = true
    fireParticle.timeToLive = math.random(minTimeToLive,maxTimeToLive)
    fireParticle.speed = math.random(5,50)
    fireParticle.x = math.random(209,231)
    fireParticle.y = 165
    table.insert(fireParticles, fireParticle)
  end
end

local destroyGame = function()
  display.remove(campSite)
  campSite = nil
  display.remove(fire)
  fire = nil

  for i=1,#fireParticles do
    fireParticles[i].isVisible = false
    display.remove(fireParticles[i])
    fireParticles[i] = nil
  end

  for i=1,#fireWood do
    if(fireWood[i] ~= nil) then
      fireWood[i].isVisible = false
      display.remove(fireWood[i])
      fireWood[i] = nil
    end
  end

  for i=1,#fingerDrags do
    fingerDrags[i].isVisible = false
    display.remove(fingerDrags[i])
    fingerDrags[i] = nil
  end
end

local pickUpFireWood = function(event)
  local t = event.target
  local phase = event.phase

  if(phase == "moved" and gatheringWood) then
    t.removeMe = true
    gatheringWood = false
  end
end

local gameLoop = function(event)
  local timeSinceLastCall = event.time - gameTimer.lastTime
  local secondsElapsed = timeSinceLastCall / 1000
  local millisElapsed = timeSinceLastCall
  
  gameTimer.lastTime = event.time
  
  if(not gameState.endGame) then
    if(not gameState.gameOver) then
      if(not gameState.paused) then

        fire.strength = fire.strength - fire.strengthLoss * secondsElapsed

        if(fire.strength < 0) then
          gameState.gameOver = true
        else
          for i=1,#fingerDrags do
            if(fingerDrags[i] ~= nil) then
              fingerDrags[i].timeToLive = fingerDrags[i].timeToLive - millisElapsed
              local theAlpha = fingerDrags[i].timeToLive/fingerDragsTimeToLive
              if(theAlpha < .05) then
                fingerDrags[i].alpha = .05
              else
                fingerDrags[i].alpha = theAlpha
              end
              if(fingerDrags[i].timeToLive < 0) then
                display.remove(fingerDrags[i])
                fingerDrags[i] = nil
              end
            else
              table.remove(fingerDrags, i)
            end
          end

          for i=1,fireNumberParticles do
            fireParticles[i].timeToLive = fireParticles[i].timeToLive - millisElapsed
            fireParticles[i].y = fireParticles[i].y - fireParticles[i].speed * secondsElapsed

            fireParticles[i]:setFillColor(127+(128 * (fireParticles[i].timeToLive/maxTimeToLive)), 40+(128 * (fireParticles[i].timeToLive/maxTimeToLive)), 45+(28 * (fireParticles[i].timeToLive/maxTimeToLive)))

            if(fireParticles[i].timeToLive < 0) then
              fireParticles[i].timeToLive = math.random(minTimeToLive,maxTimeToLive - (maxTimeToLive * (1-(fire.strength / fire.maxStrength))))
              fireParticles[i].speed = math.random(5,50)
              fireParticles[i].x = math.random(209,231)
              fireParticles[i].y = 165
            end
          end

          timeUntilNextWoodSpawnMS = timeUntilNextWoodSpawnMS - millisElapsed
          if(timeUntilNextWoodSpawnMS < 0) then
            if(table.getn(fireWood) < maxFireWood) then
              local newFireWood = display.newRoundedRect(0,0,20,10,2)
              newFireWood:setReferencePoint(display.CenterReferencePoint)
              newFireWood.strokeWidth = 2
              newFireWood:setFillColor(210, 105, 30)
              newFireWood:setStrokeColor(100, 50, 15)
              newFireWood.rotation = math.random(0,360)
              newFireWood.x = math.random(10,470)
              newFireWood.y = math.random(10,310)
              newFireWood.removeMe = false

              newFireWood:addEventListener("touch",pickUpFireWood)

              table.insert(fireWood, newFireWood)
            end

            timeUntilNextWoodSpawnMS = math.random(minTimeUntilNextWoodSpawnMS, maxTimeUntilNextWoodSpawnMS)
          end

          for i=1, #fireWood do
            if(fireWood[i] ~= nil and fireWood[i].removeMe) then
              display.remove(fireWood[i])
              fireWood[i] = nil

              logsCollected = logsCollected + 1
              fire.strength = fire.strength + 250
              if(fire.strength > fire.maxStrength) then
                fire.strength = fire.maxStrength
              end

            elseif(fireWood[i] == nil) then
              table.remove(fireWood,i)
            end
          end

        end
        
      end
    else -- GAMEOVER
      destroyGame()
      local winText = display.newText("GAME OVER!", 25, 115, native.systemFont, 64)
      winText:setTextColor(255,255,255)
      winText:setReferencePoint(display.CenterReferencePoint)
      winText.x = 240
      winText.y = 50
      local winText2 = display.newText("You've Collected "..logsCollected.." logs", 100, 115, native.systemFont, 32)
      winText2:setReferencePoint(display.CenterReferencePoint)
      winText2.x = 240
      winText2.y = 160
      gameState.endGame = true
    end
  end
end

Runtime:addEventListener( "enterFrame", gameLoop )

local startText = display.newText("Touch anywhere to Start!", 25, 135, native.systemFont, 36)
startText:setTextColor(255,255,255)

--Global Touch Event
local globalTouch = function(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began") then
    if(gameState.begin) then
      gameState.paused = false
      startText:removeSelf()
      gameState.begin = false
      loadGame()
    elseif(not gameState.begin and not gameState.paused and not gameState.gameOver and gatheringWood) then
      createNewFingerDrag(event.x, event.y)
    end
  elseif(phase == "moved") then
    if(not gameState.begin and not gameState.paused and not gameState.gameOver and gatheringWood) then
      createNewFingerDrag(event.x, event.y)
    end
  elseif(phase == "ended") then
    if(not gameState.begin and not gameState.paused and not gameState.gameOver and gatheringWood) then
      gatheringWood = false
    end
  end
  
  return true
end

Runtime:addEventListener("touch", globalTouch)
---------------------------------------------------------------------------------------
-- Project: SpeedCoder-14 Christian Dev Network
-- Name of Game: Turkey Hunt
-- Date: November 24, 2011
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

local topUI = display.newRect(0,0,480,32)
topUI:setFillColor(255, 255, 255)

topUI:toBack()

hudGroup:insert(topUI)

--Main Group
local mainGroup = display.newGroup()

local gameOverText = display.newText("GAME OVER!", 50, 115, native.systemFont, 64)
gameOverText:setTextColor(255,255,0)

hudGroup:insert(gameOverText)
gameOverText.isVisible = false

local startText = display.newText("Touch anywhere to Start!", 25, 135, native.systemFont, 36)
startText:setTextColor(255,255,255)

hudGroup:insert(startText)

local roundText = display.newText("Round: ", 175, 135, native.systemFont, 36)
roundText:setTextColor(255,255,255)

hudGroup:insert(roundText)
roundText.isVisible = false

local flyAwayText = display.newText("FLY AWAY!", 145, 135, native.systemFont, 36)
flyAwayText:setTextColor(255,255,255)

hudGroup:insert(flyAwayText)
flyAwayText.isVisible = false

local gotEmText = display.newText("GOT EM!", 165, 135, native.systemFont, 36)
gotEmText:setTextColor(255,255,255)

hudGroup:insert(gotEmText)
gotEmText.isVisible = false

local bulletUI = {}

for i=1,5 do
  bulletUI[i] = display.newCircle(300+(i*30),16,12)
  bulletUI[i]:setFillColor(32,32,32)
  bulletUI[i]:setStrokeColor(0,0,0)
  bulletUI[i].strokeWidth = 3
  hudGroup:insert(bulletUI[i])
end

local turkeyUI = {}

for i=1,16 do
  turkeyUI[i] = display.newCircle(i*19,16,8)
  turkeyUI[i]:setFillColor(200,200,0)
  turkeyUI[i]:setStrokeColor(0,0,0)
  turkeyUI[i].strokeWidth = 2
  turkeyUI[i].isActiveTurkey = false
  turkeyUI[i].isFlyAwayTurkey = false
  turkeyUI[i].isDeadTurkey = false
  turkeyUI[i].isVisible = false
  hudGroup:insert(turkeyUI[i])
end


hudGroup:toFront()

local gameState = {gameOver = false, paused = true, win = false, endGame = false, begin = true, 
                   hunting = false, flyAway = false, roundStart = false, intermission = false, allDead = false}
local gameTimer = {lastTime = 0, timeLeftForRoundStart = 0, timeLeftForIntermission = 0, timeLeftTillFlyAway = 0, timeLeftForFlyAway = 0, timeLeftForAllDead = 0}

local gameInfo = {round = 0, score = 0, subRound = 0, 
                  deadDropSpeed = 150, flyAwaySpeed = 250, totalRounds = 4,
                  turkeysKilledThisRound = 0, turkeysKilledThisSubRound = 0, 
                  turkeysFlownAwayThisRound = 0, turkeysFlownAwayThisSubRound = 0, 
                  turkeysLeftCount = 16
                 }

local gunInfo = {shotsLeft = 0}

local shots = {}

local roundInfo = {
  {subRounds = 5, flyAwayTime = 10000, speedFactor = 1.00, changeFactor = 1.00, maxDistance = 400, minDistance = 100, turkeysInRound = 10, hensLeft = 0, bossGobblersLeft = 0, turkeySubRound = {2,2,2,2,2}, henSubRound = {0,0,0,0,0}, bossGobblerSubRound = {0,0,0,0,0}, bulletsSubRound = {5,5,5,4,4}},
  {subRounds = 5, flyAwayTime = 7500, speedFactor = 2.00, changeFactor = 1.00, maxDistance = 400, minDistance = 100, turkeysInRound = 12, hensLeft = 0, bossGobblersLeft = 0, turkeySubRound = {3,3,3,2,1}, henSubRound = {0,0,0,0,0}, bossGobblerSubRound = {0,0,0,0,0}, bulletsSubRound = {5,5,4,3,2}},
  {subRounds = 5, flyAwayTime = 5000, speedFactor = 2.50, changeFactor = 1.00, maxDistance = 300, minDistance = 150, turkeysInRound = 5, hensLeft = 0, bossGobblersLeft = 0, turkeySubRound = {1,1,1,1,1}, henSubRound = {0,0,0,0,0}, bossGobblerSubRound = {0,0,0,0,0}, bulletsSubRound = {1,1,1,1,1}},
  {subRounds = 5, flyAwayTime = 3000, speedFactor = 3.00, changeFactor = 1.00, maxDistance = 300, minDistance = 150, turkeysInRound = 15, hensLeft = 0, bossGobblersLeft = 0, turkeySubRound = {3,3,3,3,3}, henSubRound = {0,0,0,0,0}, bossGobblerSubRound = {0,0,0,0,0}, bulletsSubRound = {5,4,3,2,2}},
}

local turkeys = {{},{},{}}
local hens = {{},{}}

local bossGobbler = nil
--139-139-131

--Hen = bad stuff
--Boss Gobbler = 2 hits
--turkeys will have 
--  time to switch move
--  hits left

local function setBullets()
  for i=1, 5 do
    if(gunInfo.shotsLeft >= i) then
      bulletUI[i]:setFillColor(128,128,128)    
    else
      bulletUI[i]:setFillColor(32,32,32)
    end

  end
end

local function setTurkeyUI()
  for i=1,roundInfo[gameInfo.round].turkeysInRound do
    if(turkeyUI[i].isFlyAwayTurkey) then
      turkeyUI[i]:setFillColor(200,0,0)
    elseif(turkeyUI[i].isDeadTurkey) then
      turkeyUI[i]:setFillColor(0,200,0)
    elseif(turkeyUI[i].isActiveTurkey) then
      turkeyUI[i]:setFillColor(200,200,200)
    else
      turkeyUI[i]:setFillColor(200,200,0)
    end    
  end
end

function shootTurkey(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began" and not t.isDead and not t.isFlyAway) then
    t.isDead = true
	t:setFillColor(155,18,18)
	
	--ADD POINTS TO SCORE HERE
    gunInfo.shotsLeft = gunInfo.shotsLeft - 1
    setBullets()
    gameInfo.turkeysKilledThisSubRound = gameInfo.turkeysKilledThisSubRound + 1
    gameInfo.turkeysKilledThisRound = gameInfo.turkeysKilledThisRound + 1
    turkeyUI[gameInfo.turkeysLeftCount + gameInfo.turkeysKilledThisSubRound].isDeadTurkey = true
    setTurkeyUI()
	--print("GOT A TURKEY!")
  end
  
  if(phase == "ended" or phase == "cancelled") then
--    display.getCurrentStage():setFocus( t, nil )   don't remember what this is for
  end
  
  return true
end

local function initTurkeys()
  turkeys[1] = display.newCircle(150,150,16)
  turkeys[2] = display.newCircle(350,150,16)
  turkeys[3] = display.newCircle(250,250,16)

  for i=1, 3 do
    turkeys[i].isVisible = false
    turkeys[i]:addEventListener("touch", shootTurkey)
  end
  --add to main group?
end

local function resetTurkeys()
  turkeys[1]:setFillColor(139,125,107)
  turkeys[2]:setFillColor(139,119,101)
  turkeys[3]:setFillColor(139,131,120)
  
  for i=1, 3 do
    turkeys[i].isVisible = false
    turkeys[i].isDead = false
    turkeys[i].isFlyAway = false
    turkeys[i].x = 100
    turkeys[i].y = 100
    turkeys[i].velX = 0
    turkeys[i].velY = 0
    turkeys[i].moveTillSwitch = 100
    turkeys[i].deadTime = 0
  end
end

local function areTurkeysDead()
  return ((turkeys[1].isDead or not turkeys[1].isVisible) and 
          (turkeys[2].isDead or not turkeys[2].isVisible) and 
          (turkeys[3].isDead or not turkeys[3].isVisible))
end

local function initHens()
  hens[1] = display.newCircle(150,150,16)
  hens[2] = display.newCircle(350,150,16)
  hens[1].isVisible = false
  hens[2].isVisible = false
end

local function resetHens()
  hens[1]:setFillColor(255,222,173)
  hens[2]:setFillColor(238,232,205)
  hens[1].isVisible = false
  hens[2].isVisible = false
end

local function initBossGobbler()

end

local function resetBossGobbler()

end

local function startRound()
  flyAwayText.isVisible = false

  gameInfo.round = gameInfo.round + 1
  gameInfo.subRound = 0
  gameInfo.turkeysKilledThisRound = 0
  gameInfo.turkeysFlownAwayThisRound = 0
  gameInfo.turkeysLeftCount = 16
  
  if(gameInfo.round > gameInfo.totalRounds) then
    gameState.gameOver = true
    return
  end
  
  roundText.text = "Round: "..gameInfo.round
  roundText.isVisible = true
  
  gameState.flyAway = false
  gameState.intermission = false
  gameState.roundStart = true
  gameState.hunting = false
  
  gameTimer.timeLeftForRoundStart = 2000
  gameTimer.timeLeftForIntermission = 2000
  
  for i=1,16 do
    turkeyUI[i].isActiveTurkey = false
    turkeyUI[i].isFlyAwayTurkey = false
    turkeyUI[i].isDeadTurkey = false
    turkeyUI[i].isVisible = true
  end
  
  if (roundInfo[gameInfo.round].turkeysInRound < 16) then
    for i=roundInfo[gameInfo.round].turkeysInRound+1, 16 do
      turkeyUI[i].isVisible = false
      gameInfo.turkeysLeftCount = gameInfo.turkeysLeftCount - 1
    end
  end
  
  setTurkeyUI()
end

local function startIntermission()
  flyAwayText.isVisible = false
  gotEmText.isVisible = false
  
  gameState.flyAway = false
  gameState.intermission = true
  gameState.roundStart = false
  gameState.hunting = false
  gameState.allDead = false
  
  gameTimer.timeLeftForIntermission = 2000
end

local function startHunting()
  roundText.isVisible = false

  gameInfo.subRound = gameInfo.subRound + 1
  gameInfo.turkeysKilledThisSubRound = 0
  gameInfo.turkeysFlownAwayThisSubRound = 0
  if(gameInfo.subRound > roundInfo[gameInfo.round].subRounds) then
    gameInfo.subRound = 0
    startRound()
    return
  end

  gameState.flyAway = false
  gameState.intermission = false
  gameState.roundStart = false
  gameState.hunting = true
  gameState.allDead = false
  
  gameTimer.timeLeftTillFlyAway = roundInfo[gameInfo.round].flyAwayTime
  
  resetTurkeys()
  
  for i=1, roundInfo[gameInfo.round].turkeySubRound[gameInfo.subRound] do
    turkeys[i].isVisible = true
    
    --x should be -10 or 490
    
    turkeys[i].x = 10 + (math.random(0,1) * 460)
    turkeys[i].y = math.random(35,275)
    
    --roundInfo[gameInfo.round].changeFactor
    
    if(turkeys[i].x < 0) then
      turkeys[i].velX = 25 * math.random(1,4) * roundInfo[gameInfo.round].speedFactor
    else
      turkeys[i].velX = -25 * math.random(1,4) * roundInfo[gameInfo.round].speedFactor
    end
    
    if(turkeys[i].y < 150) then
      turkeys[i].velY = 25 * math.random(0,4) * roundInfo[gameInfo.round].speedFactor
    else
      turkeys[i].velY = -25 * math.random(0,4) * roundInfo[gameInfo.round].speedFactor
    end
    
    turkeys[i].moveTillSwitch = math.random(roundInfo[gameInfo.round].minDistance, roundInfo[gameInfo.round].maxDistance)
    
    turkeyUI[gameInfo.turkeysLeftCount].isActiveTurkey = true
    gameInfo.turkeysLeftCount = gameInfo.turkeysLeftCount - 1
    setTurkeyUI()
  end
  
  gunInfo.shotsLeft = roundInfo[gameInfo.round].bulletsSubRound[gameInfo.subRound]
  
  setBullets()
  --displayBullets
  --gunInfo.shotsLeft
  --roundInfo[gameInfo.round].bulletsSubRound[gameInfo.subRound]
  
  --print ("SHOTS FOR ROUND: "..gunInfo.shotsLeft)
end

local function flyAway()
  flyAwayText.isVisible = true
  
  gameState.flyAway = true
  gameState.intermission = false
  gameState.roundStart = false
  gameState.hunting = false
  gameState.allDead = false
  
  for index, shot in pairs(shots) do
    table.remove(shot, index)
    if(shot.x ~= nil) then
      shot:removeSelf()
    end
  end
  
  for i=1, 3 do
    if(turkeys[i].isVisible and not turkeys[i].isDead) then
      gameInfo.turkeysFlownAwayThisSubRound = gameInfo.turkeysFlownAwayThisSubRound + 1
      gameInfo.turkeysFlownAwayThisRound = gameInfo.turkeysFlownAwayThisRound + 1
      turkeyUI[gameInfo.turkeysLeftCount + gameInfo.turkeysKilledThisSubRound + gameInfo.turkeysFlownAwayThisSubRound].isFlyAwayTurkey = true
      setTurkeyUI()
    end
  end
  
  gameTimer.timeLeftForFlyAway = 2500
end

local function endSubRound()
  gameState.flyAway = false
  gameState.intermission = false
  gameState.roundStart = false
  gameState.hunting = false
  gameState.allDead = false
  startIntermission()
end

local function allDead()
  gotEmText.isVisible = true
  
  gameState.flyAway = false
  gameState.intermission = false
  gameState.roundStart = false
  gameState.hunting = false
  gameState.allDead = true
  
  for index, shot in pairs(shots) do
    table.remove(shot, index)
    if(shot.x ~= nil) then
      shot:removeSelf()
    end
  end
  
  gameTimer.timeLeftForAllDead = 2500
end

local function gameLoop(event)
  local timeSinceLastCall = event.time - gameTimer.lastTime
  local secondsElapsed = timeSinceLastCall / 1000
  local millisElapsed = timeSinceLastCall
  
  gameTimer.lastTime = event.time
  
  if(not gameState.endGame) then
    if(not gameState.gameOver) then
      if(not gameState.paused) then
      
        if(gameState.roundStart) then
          gameTimer.timeLeftForRoundStart = gameTimer.timeLeftForRoundStart - millisElapsed
          if(gameTimer.timeLeftForRoundStart < 1) then
            startHunting()
          end

        elseif(gameState.intermission)then
          gameTimer.timeLeftForIntermission = gameTimer.timeLeftForIntermission - millisElapsed
          
          for i=1, 3 do
            if(turkeys[i].isVisible and turkeys[i].isDead) then
              turkeys[i].y = turkeys[i].y + gameInfo.deadDropSpeed * secondsElapsed
            end
          end
          
          if(gameTimer.timeLeftForIntermission < 1) then
            startHunting()
          end

        elseif(gameState.hunting)then
          gameTimer.timeLeftTillFlyAway = gameTimer.timeLeftTillFlyAway - millisElapsed
          
          for i=1, 3 do
            if(turkeys[i].isVisible and not turkeys[i].isDead) then

              turkeys[i].moveTillSwitch = turkeys[i].moveTillSwitch - math.abs(turkeys[i].velX * secondsElapsed) - math.abs(turkeys[i].velY * secondsElapsed)
              
              if(turkeys[i].moveTillSwitch < 0) then
                turkeys[i].velX = 25 * math.random(-4,4) * roundInfo[gameInfo.round].speedFactor
                turkeys[i].velY = 25 * math.random(-4,4) * roundInfo[gameInfo.round].speedFactor
                if(turkeys[i].velX == 0 and turkeys[i].velY == 0) then
                  turkeys[i].velY = 25 * math.random(1,4) * roundInfo[gameInfo.round].speedFactor
                end
                turkeys[i].moveTillSwitch = math.random(roundInfo[gameInfo.round].minDistance, roundInfo[gameInfo.round].maxDistance)
              end
              
              --Move Turkeys
            
              turkeys[i].x = turkeys[i].x + turkeys[i].velX * secondsElapsed
              turkeys[i].y = turkeys[i].y + turkeys[i].velY * secondsElapsed
              
              if(turkeys[i].x < 0 or turkeys[i].x > 480) then
                turkeys[i].velX = -turkeys[i].velX
              end
              
              if(turkeys[i].x < 0) then
                turkeys[i].x = 0
              elseif(turkeys[i].x > 480) then
                turkeys[i].x = 480
              end
              
              if(turkeys[i].y < 32 or turkeys[i].y > 320) then
                turkeys[i].velY = -turkeys[i].velY              
              end
              
              if(turkeys[i].y < 32) then
                turkeys[i].y = 32
              elseif(turkeys[i].y > 320) then
                turkeys[i].y = 320
              end
              
            elseif(turkeys[i].isVisible and turkeys[i].isDead) then
              turkeys[i].y = turkeys[i].y + gameInfo.deadDropSpeed * secondsElapsed
            end
            

          end
          
          for index, shot in pairs(shots) do
            if(shot.x == nil) then
              table.remove(shot, index)
            else
              shot.timeToLive = shot.timeToLive - millisElapsed
              --print("SHOT "..index..shot.timeToLive)
              if(shot.timeToLive < 1) then
                shot:removeSelf()
              end
            end
          end
          
          if((gunInfo.shotsLeft < 1 or gameTimer.timeLeftTillFlyAway < 1) and not areTurkeysDead()) then
            flyAway()
          end
          
          if(areTurkeysDead()) then
            allDead()
          end
          
        elseif(gameState.flyAway)then        
          gameTimer.timeLeftForFlyAway = gameTimer.timeLeftForFlyAway - millisElapsed
          
          for i=1, 3 do
            if(turkeys[i].isVisible and not turkeys[i].isDead) then
              turkeys[i].y = turkeys[i].y - gameInfo.flyAwaySpeed * secondsElapsed
            elseif(turkeys[i].isVisible and turkeys[i].isDead) then
              turkeys[i].y = turkeys[i].y + gameInfo.deadDropSpeed * secondsElapsed
            end
          end
          
          if(gameTimer.timeLeftForFlyAway < 1) then
            endSubRound()
          end
        elseif(gameState.allDead)then        
          gameTimer.timeLeftForAllDead = gameTimer.timeLeftForAllDead - millisElapsed
          
          for i=1, 3 do
            if(turkeys[i].isVisible and turkeys[i].isDead) then
              turkeys[i].y = turkeys[i].y + gameInfo.deadDropSpeed * secondsElapsed
            end
          end
          
          if(gameTimer.timeLeftForAllDead < 1) then
            endSubRound()
          end
        end
      end
    else -- GAMEOVER
      gameState.endGame = true
      gameOverText.isVisible = true
    end
  end
end

Runtime:addEventListener( "enterFrame", gameLoop )

--Global Touch Event
function globalTouch(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began") then
    if(gameState.begin) then
      gameState.paused = false
      startText.isVisible = false
      gameState.begin = false
      initTurkeys()
      initHens()
      initBossGobbler()
      startRound()
    elseif(gameState.hunting) then
      --print("SHOT TAKEN")
      gunInfo.shotsLeft = gunInfo.shotsLeft - 1
      --local shot = display.newCircle(event.x, event.y, 2)
      --shot.timeToLive = 500
      --table.insert(shots, shot)
      setBullets()
    end
  elseif(phase == "moved") then
  
  elseif(phase == "ended") then

  end
  
  return true
end

Runtime:addEventListener("touch", globalTouch)
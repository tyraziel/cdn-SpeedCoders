---------------------------------------------------------------------------------------
-- Project: SpeedCoder-8 Christian Dev Network
--
-- Name of Game: Planet of the Reverse E Arcade Shooter
--
-- Date: June 1, 2011
--
-- Version: 1.0
--
-- File name: main.lua
--
-- Code type: Speed Coder
--
-- Author: Tyraziel (Andrew Potozniak)
--
-- Released with the following lisense -
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

local centerDot = display.newImage("center_dot.png", 0, 0)
local center_dot_x = 55
local center_dot_y = 270
local center_dot_touched = false
centerDot:setReferencePoint(display.CenterReferencePoint)
centerDot.x = center_dot_x
centerDot.y = center_dot_y

local dPad = display.newImage("d_pad.png", 0, 0)
dPad.x = 55
dPad.y = 270
dPad:setReferencePoint(display.CenterReferencePoint)

function dPadTouch(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began" and not center_dot_touched) then
    center_dot_touched = true
    centerDot.x = event.x
    centerDot.y = event.y
    display.getCurrentStage():setFocus(t, event.id)  
  elseif(phase == "moved") then
    if(center_dot_touched) then
      local x = event.x - dPad.x
      local y = event.y - dPad.y
    
      if(x > dPad.width / 2) then
        x = dPad.width / 2
      elseif(x < (dPad.width / -2))then
        x = dPad.width / -2
      end
      if(y > dPad.height / 2) then
        y = dPad.height / 2
      elseif(y < dPad.height / -2) then
        y = dPad.height / -2
      end    
    
      centerDot.x = center_dot_x + x
      centerDot.y = center_dot_y + y
    end
  elseif(phase == "ended" or phase == "cancelled") then
    center_dot_touched = false
    centerDot.x = center_dot_x
    centerDot.y = center_dot_y
    display.getCurrentStage():setFocus( t, nil )
  end
    
  return true
  
end

dPad:addEventListener("touch", dPadTouch)

hudGroup:insert(centerDot)
hudGroup:insert(dPad)

local debugDPad = display.newRoundedRect(125, 300, 15, 15, 2)
debugDPad.strokeWidth = 3
debugDPad:setFillColor(0, 0, 0)
debugDPad:setStrokeColor(180, 0, 0)

local debugGlobalTouch = display.newRoundedRect(150, 300, 15, 15, 2)
debugGlobalTouch.strokeWidth = 3
debugGlobalTouch:setFillColor(0, 0, 0)
debugGlobalTouch:setStrokeColor(0, 0, 180)

local global_touch = false

hudGroup:insert(debugDPad)
hudGroup:insert(debugGlobalTouch)

local score = 0
local lives = 5

--Score
local scoreLabel = display.newText("Score: ", 340, 5, native.systemFont, 20)
scoreLabel:setTextColor(255, 255, 255)

local scoreNumberText = display.newText(score, 420, 5, native.systemFont, 20)
scoreNumberText:setTextColor(255, 255, 255)

--Lives
local livesLabel = display.newText("Lives: ", 250, 5, native.systemFont, 20)
livesLabel:setTextColor(255, 255, 255)

local livesNumberText = display.newText(lives, 310, 5, native.systemFont, 20)
livesNumberText:setTextColor(255, 255, 255)

hudGroup:insert(scoreLabel)
hudGroup:insert(scoreNumberText)
hudGroup:insert(livesLabel)
hudGroup:insert(livesNumberText)

--Physics Engine
local physics = require 'physics'
physics.start()
physics.setGravity(0, 0)

--physics.setDrawMode( "debug" ) -- shows collision engine outlines only
--physics.setDrawMode( "hybrid" ) -- overlays collision outlines on normal Corona objects
--physics.setDrawMode( "normal" ) -- the default Corona renderer, with no collision outlines

--Main Group
local mainGroup = display.newGroup()

local spaceShip = display.newImage("poc_arrow.png", 0, 0)
spaceShip:setReferencePoint(display.CenterReferencePoint)
spaceShip.x = 140
spaceShip.y = 160
spaceShip.rotation = 90
local triangleShape = { 0,-10, 10,10, -10,10}
physics.addBody(spaceShip,{density=0.0, friction=0.0, bounce=0.0, shape=triangleShape})

spaceShip.what = "SpaceShip" -- help to know what this is for the event listener

spaceShip.isFixedRotation = true
spaceShip.isSensor = true --allows things to pass through

--Setup other spaceship things
spaceShip.isInvincible = false
spaceShip.invincibleTimeToLive = 2500
spaceShip.invincibleTimeLived = 0 -- invincible time 
spaceShip.rateOfMovement = 2.5
spaceShip.maxX = 180

--Add spaces ship to main group
mainGroup:insert(spaceShip)

--Ship Bullets
local shipBullets = {}

--Enemy Bullets
local enemyBullets = {}

--Enemies
local enemies = {}

--Boss
local boss = {}
local bossGroup = display.newGroup()

--Game Content
local gameContent = {

  {what = "Enemy", enterAt=25, enterX=500, enterY=150, moveX=40, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=5},
  {what = "Enemy", enterAt=50, enterX=500, enterY=50, moveX=40, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=5},
  {what = "Enemy", enterAt=75, enterX=500, enterY=200, moveX=40, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=5},
  {what = "Enemy", enterAt=100, enterX=500, enterY=75, moveX=40, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=5},

  {what = "Enemy", enterAt=200, enterX=500, enterY=100, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=2, bulletSpeed=150, hits=2, points=15},
  {what = "Enemy", enterAt=200, enterX=500, enterY=150, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=2, bulletSpeed=150, hits=2, points=15},
  {what = "Enemy", enterAt=200, enterX=500, enterY=200, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=2, bulletSpeed=150, hits=2, points=15},

  {what = "Enemy", enterAt=300, enterX=500, enterY=75, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=10},
  {what = "Enemy", enterAt=300, enterX=500, enterY=125, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=10},
  {what = "Enemy", enterAt=300, enterX=500, enterY=175, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=10},
  {what = "Enemy", enterAt=300, enterX=500, enterY=225, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=1, bulletSpeed=150, hits=1, points=10},
  
  {what = "Enemy", enterAt=450, enterX=500, enterY=100, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=3, bulletSpeed=150, hits=2, points=20},
  {what = "Enemy", enterAt=450, enterX=500, enterY=150, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=3, bulletSpeed=150, hits=2, points=20},
  {what = "Enemy", enterAt=450, enterX=500, enterY=200, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=3, bulletSpeed=150, hits=2, points=20},

  {what = "Enemy", enterAt=475, enterX=500, enterY=75, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=3, bulletSpeed=150, hits=2, points=20},
  {what = "Enemy", enterAt=475, enterX=500, enterY=125, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=3, bulletSpeed=150, hits=2, points=20},
  {what = "Enemy", enterAt=475, enterX=500, enterY=175, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=3, bulletSpeed=150, hits=2, points=20},
  {what = "Enemy", enterAt=475, enterX=500, enterY=225, moveX=20, moveY=0, yMin=0, yMax=0, fireEvery=1000, bullets=3, bulletSpeed=150, hits=2, points=20},

  {what = "Enemy", enterAt=650, enterX=500, enterY=150, moveX=20, moveY=100, yMin=50, yMax=300, fireEvery=500, bullets=40, bulletSpeed=150, hits=4, points=100},

  {what = "Enemy", enterAt=950, enterX=500, enterY=50, moveX=20, moveY=100, yMin=50, yMax=300, fireEvery=500, bullets=40, bulletSpeed=150, hits=4, points=100},
  {what = "Enemy", enterAt=950, enterX=500, enterY=100, moveX=20, moveY=100, yMin=50, yMax=300, fireEvery=500, bullets=40, bulletSpeed=150, hits=4, points=100},
  {what = "Enemy", enterAt=950, enterX=500, enterY=150, moveX=20, moveY=100, yMin=50, yMax=300, fireEvery=500, bullets=40, bulletSpeed=150, hits=4, points=100},
  {what = "Enemy", enterAt=950, enterX=500, enterY=200, moveX=20, moveY=100, yMin=50, yMax=300, fireEvery=500, bullets=40, bulletSpeed=150, hits=4, points=100},

  {what = "Boss", enterAt=1450}
}

local gameOver = false
local win = false

local function collideWithSpaceShip( self, event )

  if ( event.phase == "began" and not self.isInvincible) then
    if(event.other.what == "Enemy" or 
       event.other.what == "EnemyBullet" or
       event.other.what == "Boss") then

      lives = lives - 1
      self.isInvincible = true
      self.invincibleTimeLived = 0
	
	  if(event.other.what ~= "Boss") then
        event.other:removeSelf()
      end

      if(lives < 1)then
        gameOver = true
      end

    elseif(event.other.what == "PowerUp") then
      --powerup goodness?

    end
  
    --print( "SPACE SHIP: "..self.what .. ": collision began with " .. event.other.what )
  elseif (self.isInvincible) then
    --print ("INVINCIBLE")
  end
  
end

spaceShip.collision = collideWithSpaceShip
spaceShip:addEventListener( "collision", spaceShip )

local function spaceShipBulletCollideWithEnemy(self, event)
  if ( event.phase == "began") then
    --print("BULLET: ".. self.what .. ": collision began with " .. event.other.what )
  
    if(event.other.what == "Enemy") then

	  event.other.hitsLeft = event.other.hitsLeft - 1
	  
	  --do some cool color change
	  event.other.alpha = event.other.hitsLeft / 2
	  
	  
	  if(event.other.hitsLeft < 1) then
	    --print("REMOVE")
	    event.other.isVisible = false
	    event.other:removeSelf()
	    --event.other = nil
	    self:removeSelf()
	    
	    score = score + event.other.points
	  else
	  	self:removeSelf()
	    score = score + 5
	  end
	  
	  
	  --check for zero hits left and remove enemy

    elseif(event.other.what == "Boss") then
      self:removeSelf()
    
      --remove life from boss
      boss.hitsLeft = boss.hitsLeft - 1
      score = score + 5 + 75 - boss.hitsLeft
      
      if(boss.hitsLeft < 1) then
        win = true
        gameOver = true
        spaceShip.isInvincible = true
        boss.part1:removeSelf()
        boss.part2:removeSelf()
        boss.part3:removeSelf()
        boss.part4:removeSelf()
        
        score = score + 10000 + (lives * 590)
      end
      


    end
  
    --print("BULLET: ".. self.what .. ": collision began with " .. event.other.what )
  end
end


--Global Touch Event for Bullets
function globalTouch(event)
  local t = event.target
  local phase = event.phase

  if(phase == "began") then
	global_touch = true
	
	--fire bullet if not invincible
	if(not spaceShip.isInvincible) then
	  --Fire Bullet
	  local shipBullet = display.newCircle(spaceShip.x + 10, spaceShip.y+1, 3) 
    
      physics.addBody(shipBullet)
      shipBullet.isBullet = true
      shipBullet.isSensor = true
      shipBullet.what = "Bullet"
      shipBullet:setLinearVelocity( 150, 0 )
    
      shipBullet:setFillColor(255, 255, 255)
	  
	  shipBullet.collision = spaceShipBulletCollideWithEnemy
      shipBullet:addEventListener( "collision", shipBullet )

      table.insert(shipBullets,shipBullet)
	
	  mainGroup:insert(shipBullet)
	end
	
  end
  if(phase == "ended") then
    global_touch = false
  end
  
  return true
end

Runtime:addEventListener("touch", globalTouch) 

local gameTimer = {}
gameTimer.lastTime = 0
local pixelsMoved = 0
local pixelsPerSecond = 25

local bossFight = false

local function gameLoop(event)
  local timeSinceLastCall = event.time - gameTimer.lastTime
  local secondsElapsed = timeSinceLastCall / 1000
  local millisElapsed = timeSinceLastCall
  
  gameTimer.lastTime = event.time
  
  if(not gameOver) then

  
    --Move Camera
    if(not bossFight) then
      local factorOfMovement = pixelsPerSecond * secondsElapsed
      pixelsMoved = pixelsMoved + factorOfMovement
      mainGroup.x = mainGroup.x - factorOfMovement
      spaceShip.x = spaceShip.x + factorOfMovement
    end
  
    --Invinciblity (helpful when hit)
    if(spaceShip.isInvincible) then 
      spaceShip.invincibleTimeLived = spaceShip.invincibleTimeLived + millisElapsed
    
	  spaceShip.isVisible = not spaceShip.isVisible
    
      if(spaceShip.invincibleTimeLived > spaceShip.invincibleTimeToLive) then
        spaceShip.isInvincible = false
        spaceShip.isVisible = true
        spaceShip.invincibleTimeLived = 0
      end
    end
  
    --Insert Enemies
    if(not bossFight) then
      for index, enemyContent in pairs(gameContent) do
--      print(enemy.what.." "..enemy.enterAt)
        if (pixelsMoved > enemyContent.enterAt and enemyContent.what ~= "Boss") then
      
    
          local newEnemy = display.newRect(enemyContent.enterX + enemyContent.enterAt, enemyContent.enterY, 15, 15)
          newEnemy.what = "Enemy"
          newEnemy.strokeWidth = 2
          newEnemy:setFillColor(28,0,128)
          newEnemy:setStrokeColor(100,0,255)
          physics.addBody(newEnemy)
          newEnemy.isSensor = true   ---comment me
          newEnemy.hitsLeft = enemyContent.hits
          
          newEnemy.fireEvery = enemyContent.fireEvery
          newEnemy.bullets = enemyContent.bullets
          newEnemy.bulletSpeed = enemyContent.bulletSpeed
          newEnemy.timeSinceLastFire = 0
          
          newEnemy.points = enemyContent.points
          
          newEnemy.speedX = -enemyContent.moveX
          newEnemy.speedY = enemyContent.moveY
          newEnemy.yMin = enemyContent.yMin
          newEnemy.yMax = enemyContent.yMax
          
          mainGroup:insert(newEnemy)
      
          table.remove(gameContent, index) ---comment me too
          table.insert(enemies,newEnemy)
        --{what = "Enemy", enterAt=50, enterX=380, enterY=25, moveX=0, moveY=25, yMin=10, yMax=50, hits=1}
        elseif(pixelsMoved > enemyContent.enterAt and enemyContent.what == "Boss") then
      
          bossFight = true
          boss.part1 = display.newRoundedRect(500 + enemyContent.enterAt, 30, 250, 60, 3)
          boss.part2 = display.newRoundedRect(500 + enemyContent.enterAt, 130, 250, 60, 3)
          boss.part3 = display.newRoundedRect(500 + enemyContent.enterAt, 230, 250, 60, 3)
          boss.part4 = display.newRoundedRect(700 + enemyContent.enterAt, 35, 50, 245, 3)
          
          boss.fightTime = 0
          boss.timeSinceLastBullets = 0
          boss.bulletInterval = 1000
          
          mainGroup:insert(boss.part1)
          mainGroup:insert(boss.part2)
          mainGroup:insert(boss.part3)
          mainGroup:insert(boss.part4)
          
          physics.addBody(boss.part1)
          physics.addBody(boss.part2)
          physics.addBody(boss.part3)
          physics.addBody(boss.part4)
          
          boss.part1.isSensor = true
          boss.part2.isSensor = true
          boss.part3.isSensor = true
          boss.part4.isSensor = true
          
          boss.part1.what = "Boss"
          boss.part2.what = "Boss"
          boss.part3.what = "Boss"
          boss.part4.what = "Boss"
          
          boss.speedX = 0
          boss.speedY = 0
          boss.invincible = true
          boss.hitsLeft = 75
    
        end
      end
    else -- boss fight
      boss.fightTime = boss.fightTime + millisElapsed
      boss.timeSinceLastBullets = boss.timeSinceLastBullets + millisElapsed
      
      --Scripted Movement
      if(boss.fightTime < 2500) then --2.5 seconds move in to screen
        boss.speedX = 100
        boss.speedY = 0
      elseif(boss.fightTime < 4500) then --2.0 seconds move up and left
        boss.speedX = 100
        boss.speedY = 100
      elseif(boss.fightTime < 6500) then --2.0 seconds move left
        boss.speedX = 100
        boss.speedY = 0
      elseif(boss.fightTime < 8500) then --2.0 seconds move right
        boss.speedX = -100
        boss.speedY = 0
      elseif(boss.fightTime < 10500) then -- 2.0 seconds move down and right
        boss.speedX = -100
        boss.speedY = -100
      elseif(boss.fightTime < 12500) then -- 2.0 seconds move down and left
        boss.speedX = 100
        boss.speedY = -100
      elseif(boss.fightTime < 14500) then -- 2.0 seconds move left
        boss.speedX = 100
        boss.speedY = 0
      elseif(boss.fightTime < 16500) then -- 2.0 seconds move right
        boss.speedX = -100
        boss.speedY = 0
      elseif(boss.fightTime < 18500) then -- 2.0 seconds move right and up
        boss.speedX = -100
        boss.speedY = 100
      elseif(boss.fightTime < 22000) then -- 3.5 seconds move left
        boss.speedX = 100
        boss.speedY = 0
      elseif(boss.fightTime < 25500) then -- 3.5 seconds move right
        boss.speedX = -100
        boss.speedY = 0
      elseif(boss.fightTime < 30000) then -- wait
        boss.speedX = 0
        boss.speedY = 0
        boss.bulletInterval = 250
      else
        boss.fightTime = 2500
        boss.bulletInterval = 1000
        boss.timeSinceLastBullets = 0
        boss.speedX = 0
        boss.speedY = 0
      end

--          boss.timeSinceLastBullets = 0
--          boss.bulletInterval = 500

      if(boss.timeSinceLastBullets > boss.bulletInterval) then
          local enemyBullet = display.newCircle(boss.part1.x-130, boss.part1.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, 0 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)

          enemyBullet = display.newCircle(boss.part1.x-130, boss.part1.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, -50 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)

          enemyBullet = display.newCircle(boss.part1.x-130, boss.part1.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, 50 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)
  	      
          enemyBullet = display.newCircle(boss.part2.x-130, boss.part2.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, 0 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)

          enemyBullet = display.newCircle(boss.part2.x-130, boss.part2.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, -50 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)

          enemyBullet = display.newCircle(boss.part2.x-130, boss.part2.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, 50 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)

          enemyBullet = display.newCircle(boss.part3.x-130, boss.part3.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, 0 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)

          enemyBullet = display.newCircle(boss.part3.x-130, boss.part3.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, -50 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)

          enemyBullet = display.newCircle(boss.part3.x-130, boss.part3.y, 3)
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity(-175, 50 )
          enemyBullet:setFillColor(255, 0, 255)
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)
  	      
  	      boss.timeSinceLastBullets = 0
      end

      boss.part1.x = boss.part1.x - boss.speedX * secondsElapsed
      boss.part2.x = boss.part2.x - boss.speedX * secondsElapsed
      boss.part3.x = boss.part3.x - boss.speedX * secondsElapsed
      boss.part4.x = boss.part4.x - boss.speedX * secondsElapsed
        
      boss.part1.y = boss.part1.y - boss.speedY * secondsElapsed
      boss.part2.y = boss.part2.y - boss.speedY * secondsElapsed
      boss.part3.y = boss.part3.y - boss.speedY * secondsElapsed
      boss.part4.y = boss.part4.y - boss.speedY * secondsElapsed
      
    end
  
    --Check for enemies stuff
    for index, enemy in pairs(enemies) do
      if(enemy.x == nil) then
        table.remove(enemies, index)
      else
        enemy.timeSinceLastFire = enemy.timeSinceLastFire + millisElapsed
        if(enemy.timeSinceLastFire > enemy.fireEvery and enemy.bullets > 0) then
          --Fire enemyBullet
        
          local enemyBullet = display.newCircle(enemy.x - 5, enemy.y + 1, 3) 
    
          physics.addBody(enemyBullet)
          enemyBullet.isBullet = true
          enemyBullet.isSensor = true
          enemyBullet.what = "EnemyBullet"
          enemyBullet:setLinearVelocity( -enemy.bulletSpeed, 0 )
    

          enemyBullet:setFillColor(0, 255, 255)
		
  	      mainGroup:insert(enemyBullet)
  	      table.insert(enemyBullets,enemyBullet)
  	      
  	      --Might need to add enemyBullet to table to check for offscreen
 
          enemy.timeSinceLastFire = 0
          enemy.bullets = enemy.bullets - 1
        end

--          newEnemy.speedX = enemyContent.moveX
--          newEnemy.speedY = enemyContent.moveY
--          newEnemy.yMin = enemyContent.yMin
--          newEnemy.yMax = enemyContent.yMax

        if(enemy.x < pixelsMoved) then
          --print("ENEMY OFFSCREEN")
          enemy:removeSelf()
        end

        
        enemy.x = enemy.x + enemy.speedX * secondsElapsed
        enemy.y = enemy.y + enemy.speedY * secondsElapsed
        
        if(enemy.y < enemy.yMin or enemy.y > enemy.yMax)then
          enemy.speedY = enemy.speedY * -1
        end
        
      end
    
    end
  
    --Check for enemyBullets off screen
    for index, enemyBullet in pairs(enemyBullets) do
      if(enemyBullet.x == nil) then
        table.remove(enemyBullets, index)
      elseif(enemyBullet.x + 20 < pixelsMoved) then
          --print("ENEMY BULLET OFFSCREEN")
          enemyBullet:removeSelf()
      end
    end

    --Check for spaceShipBullets off screen
    for index, shipBullet in pairs(shipBullets) do
      if(shipBullet.x == nil) then
        table.remove(shipBullets, index)
      elseif(shipBullet.x > pixelsMoved + 480) then
          --print("BULLET OFFSCREEN")
          shipBullet:removeSelf()
      end
    end
    
  
  --only move guy if center_dot_touched
    if (center_dot_touched) then
      debugDPad:setFillColor(140, 0, 0)
  
      local dx = centerDot.x - center_dot_x
      local dy = (centerDot.y - center_dot_y)

      local val = -dy / dx
  
      local deg = 90 - math.deg(math.atan(val))
  
      spaceShip.x = spaceShip.x + dx * secondsElapsed * spaceShip.rateOfMovement
      spaceShip.y = spaceShip.y + dy * secondsElapsed * spaceShip.rateOfMovement
    
      if (spaceShip.x < 0+pixelsMoved) then
        spaceShip.x = 0+pixelsMoved
      elseif(spaceShip.x > spaceShip.maxX+pixelsMoved) then
        spaceShip.x = spaceShip.maxX+pixelsMoved
      end
      if (spaceShip.y < 0) then
        spaceShip.y = 0
      elseif( spaceShip.y > display.contentHeight) then
        spaceShip.y = display.contentHeight
      end

    else
	  debugDPad:setFillColor(0, 0, 0)
    end
  
    if(global_touch)then
      debugGlobalTouch:setFillColor(0, 0, 140)
    else
      debugGlobalTouch:setFillColor(0, 0, 0)
    end
    
  else --GAME OVER
    if(win) then
      local gameOverText = display.newText("YOU WIN!", 150, 100, native.systemFont, 50)
      gameOverText:setTextColor(155, 155, 155)
      spaceShip.isVisible = true
    else
      local gameOverText = display.newText("GAME OVER", 130, 100, native.systemFont, 50)
      gameOverText:setTextColor(155, 0, 0)
      spaceShip.isVisible = false
    end  
  end
  
  --update score text and lives
  scoreNumberText.text = score
  livesNumberText.text = lives

  
end

Runtime:addEventListener( "enterFrame", gameLoop )
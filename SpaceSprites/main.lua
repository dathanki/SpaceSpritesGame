-- Developed by: Dhaval Thanki 
-- Student ID: 0871347
-- A simple 2D space-age shooter



display.setStatusBar(display.HiddenStatusBar)
local xWidth = display.contentCenterX
local xHeight = display.contentCenterY

local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

local enemies = display.newGroup()

local gameActive = true
local waveProgress = 1
local numHit = 0
local shipMoveX = 0
local ship 
local speed = 9
local shootbtn
local numEnemy = 0
local enemyArray = {}
local onCollision
local score = 0
local gameovertxt
local numBullets = 3
local ammo
local AmmoActive = true

local removeEnemies
local createGame
local createEnemy
local shoot
local createShip
local newGame
local gameOver
local nextWave
local checkforProgress
local createAmmo
local setAmmoOn
local backgroundMusic

local shot = audio.loadSound ("laserbeam.mp3")
local wavesnd = audio.loadSound ("wave.mp3")
local ammosnd = audio.loadSound ("ammo.mp3")
local backgroundsnd = audio.loadStream ( "musicbackground.mp3")


	local background = display.newImage("spacebackground.png", 100, 100)
	background.x = xWidth
	background.y = xHeight
	
	textScore = display.newText("Score: "..score, 135, 55, nil, 50)
	textWave = display.newText ("Wave: "..waveProgress, 135, 125, nil, 50)
	textBullets = display.newText ("Bullets: "..numBullets, 135, 195, nil, 50)

	local leftArrow = display.newImage("left.png")
	leftArrow.x = 65
	leftArrow.y = display.contentHeight - 80
	local rightArrow = display.newImage("right.png")
	rightArrow.x = 225
	rightArrow.y = display.contentHeight - 80
	
	shootbtn = display.newImage("shootbutton.png")
	shootbtn.x = display.contentWidth - 100
	shootbtn.y = display.contentHeight - 100
	
	
	-- create gamepad
	local function stopShip(event)
		if event.phase == "ended" then
			shipMoveX = 0 
		end
	end
	

	local function moveShip(event)
		ship.x = ship.x + shipMoveX
	end
	

	function leftArrowtouch()
		shipMoveX = - speed
	end
	

	function rightArrowtouch()
		shipMoveX = speed
	end
	
	
	local function createWalls(event)	
		if ship.x < 0 then
			ship.x = 0
		end
		if ship.x > display.contentWidth then
			ship.x = display.contentWidth
		end
	end
	
function createShip()
	ship = display.newImage ("ship.png")
	physics.addBody(ship, "static", {density = 1, friction = 0, bounce = 0});
	ship.x = xWidth
	ship.y = display.contentHeight - 155
	ship.myName = "ship"
end

function createEnemy()
	numEnemy = numEnemy + 2

	print(numEnemy)
			enemies:toFront()
			enemyArray[numEnemy]  = display.newImage("enemy.png")
			physics.addBody ( enemyArray[numEnemy] , {density=0.5, friction=0, bounce=0})
			enemyArray[numEnemy] .myName = "enemy" 
			startlocationX = math.random (0, display.contentWidth)
			enemyArray[numEnemy] .x = startlocationX
			startlocationY = math.random (-500, -100)
			enemyArray[numEnemy] .y = startlocationY
		
			transition.to ( enemyArray[numEnemy] , { time = math.random (12000, 20000), x= math.random (0, display.contentWidth ), y=ship.y+500 } )
			enemies:insert(enemyArray[numEnemy] )
end

function createAmmo()
	
		ammo = display.newImage("ammo.png")
		physics.addBody ( ammo,  {density = 0.5, friction=0, bounce=0 })
		ammo.myName = "ammo" 
		startlocationX = math.random (0, display.contentWidth)
		ammo .x = startlocationX
		startlocationY = math.random (-500, -100)
		ammo .y = startlocationY
		
		transition.to ( ammo, {time = math.random (5000, 10000 ), x= math.random (0, display.contentWidth ), y=ship.y+500 } ) 
	
		local function rotationAmmo ()
		ammo.rotation = ammo.rotation + 45
		end

		rotationTimer = timer.performWithDelay(200, rotationAmmo, -1)
		
		
end

	function shoot(event)
		
		if (numBullets ~= 0) then
			numBullets = numBullets - 1
			local bullet = display.newImage("bullet.png")
			physics.addBody(bullet, "static", {density = 3, friction = 0, bounce = 0});
			bullet.x = ship.x 
			bullet.y = ship.y 
			bullet.myName = "bullet"
			textBullets.text = "Bullets "..numBullets
			transition.to ( bullet, { time = 1000, x = ship.x, y =-100} )
			audio.play(shot)
		end 
		
	end
 

function onCollision(event)
	if(event.object1.myName =="ship" and event.object2.myName =="enemy") then	
			
			
			local function setgameOver()
			gameovertxt = display.newText(  "Game Over", xWidth-20, xHeight-50, "Arcade", 75 )
			gameovertxt:addEventListener("tap",  newGame)
			end
			transition.to( ship, { time=1500, xScale = 0.7, yScale = 0.7, alpha=0, onComplete=setgameOver  } )
			gameActive = false
			removeEnemies()
			audio.fadeOut(backgroundsnd)
			audio.rewind (backgroundsnd)
			
	end	
	
	if(event.object1.myName =="ship" and event.object2.myName =="ammo") then
		local function sizeBack()
		ship.xScale = 1.0
		ship.yScale = 1.0 
		
		end
		transition.to( ship, { time=500, xScale = 2.4, yScale = 2.4, onComplete = sizeBack  } )
		numBullets = numBullets + 2
		textBullets.text = "Bullets "..numBullets
		event.object2:removeSelf()
		event.object2.myName=nil
		timer.cancel(rotationTimer)
		audio.play(ammosnd)
		
	end

	if((event.object1.myName=="enemy" and event.object2.myName=="bullet") or 
		(event.object1.myName=="bullet" and event.object2.myName=="enemy")) then
			event.object1:removeSelf()
			event.object1.myName=nil
			event.object2:removeSelf()
			event.object2.myName=nil
			score = score + 10
			numBullets = numBullets + 1 
			textScore.text = "Score: "..score
			numHit = numHit + 1
			print ("numhit "..numHit)
			end
	
	
end

function removeEnemies()
	for i =1, #enemyArray do
		if (enemyArray[i].myName ~= nil) then
		enemyArray[i]:removeSelf()
		enemyArray[i].myName = nil
		end
	end
end


function newGame(event)	
		display.remove(event.target)	
		textScore.text = "Score: 0"
		numEnemy = 0
		ship.alpha = 1
		ship.xScale = 1.0
		ship.yScale = 1.0
		score = 0
		gameActive = true
		waveProgress = 1	
		backgroundMusic()
		numBullets = 3
		textBullets.text = "Bullets "..numBullets
		AmmoActive = true
end

function nextWave (event)
	display.remove(event.target)
	numHit = 0
	gameActive = true 
end

function setAmmoOn()
		AmmoActive = true
end

function ammoStatus()
	
	if gameActive then
		createEnemy()
		if AmmoActive then
			if (numBullets == 0) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 1) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 2) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 4) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 5) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
			if (numBullets == 6) then
		 	createAmmo()
		 	AmmoActive = false 	
			end
		end
	end
end


local function checkforProgress()
		if numHit == waveProgress then
			gameActive = false
			audio.play(wavesnd)
			removeEnemies()
			waveTxt = display.newText(  "Wave "..waveProgress.. " Completed", xWidth+20, xHeight-240, nil, 55 )
			waveProgress = waveProgress + 1
			textWave.text = "Wave: "..waveProgress
			print("wavenumber "..waveProgress)
			waveTxt:addEventListener("tap",  nextWave)
end
	
	
	for i =1, #enemyArray do
		if (enemyArray[i].myName ~= nil) then
			if(enemyArray[i].y > display.contentHeight) then
			    enemyArray[i]:removeSelf()
			    enemyArray[i].myName = nil
				score = score - 20 
				textScore.text = "Score: "..score
				warningTxt = display.newText(  "Watch out!", xWidth-42, ship.y-50, nil, 75 )
					local function showWarning()
					display.remove(warningTxt)
					end
				timer.performWithDelay(1000, showWarning)
				print("cleared")
		end
		end
	end
end

function backgroundMusic()
	audio.play (backgroundsnd, { loops = -1})
	audio.setVolume(0.5, {backgroundsnd} ) 	
end

function startGame()
createShip()
backgroundMusic()

shootbtn:addEventListener ( "tap", shoot )
rightArrow:addEventListener ("touch", rightArrowtouch)
leftArrow:addEventListener("touch", leftArrowtouch)
Runtime:addEventListener("enterFrame", createWalls)
Runtime:addEventListener("enterFrame", moveShip)
Runtime:addEventListener("touch", stopShip)
Runtime:addEventListener("collision" , onCollision)

timer.performWithDelay(5000, ammoStatus,0)
timer.performWithDelay ( 5000, setAmmoOn, 0 )
timer.performWithDelay(300, checkforProgress,0)

end

startGame()

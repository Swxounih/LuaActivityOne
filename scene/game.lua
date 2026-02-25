local composer = require( "composer" )
local scene = composer.newScene()

local backgound, platform, baloon, tapText, resetText, startText, gameoverText, restartText


local physics = require( "physics" )
physics.start()
physics.pause()
local tapCount = 0
local gameStarted = false

function scene:create( event )
	local sceneGroup = self.view

	local bg = display.newImageRect("images/bg.jpg", 1440, 3088)
	bg.x = display.contentCenterX
	bg.y = display.contentCenterY

	local pf = display.newImageRect("images/platform.png", 500, 180)
	pf.x = display.contentCenterX
	pf.y = display.contentCenterY+1500

	local bl = display.newImageRect("images/baloon.png", 700, 700)
	bl.x = display.contentCenterX
	bl.y = display.contentCenterY

	local tapText = display.newText( tapCount, display.contentCenterX, 300, native.systemFont, 250 )
	tapText:setFillColor( 255, 0, 0 )
	local resetText = display.newText( "Reset", display.contentCenterX -370,  270,  native.systemFont, 150)
	resetText:setFillColor( 255, 0, 0 )

	physics.addBody( pf, "static" )
	physics.addBody( bl, "dynamic", { radius=300, bounce=-0.25 } )

	local function pushBl()
		if gameStarted then
			bl:applyLinearImpulse( 0, -50, bl.x, bl.y )
			tapCount = tapCount + 1
			tapText.text = tapCount
		end
	end

	local function resetBl()
		tapText.text = 0
	end

	local function restartGame()
		tapCount = 0
		tapText.text = tapCount
		gameStarted = true
		physics.start()
		bl.x = display.contentCenterX
		bl.y = display.contentCenterY
		bl:setLinearVelocity(0, 0)
		if gameoverText then
			gameoverText:removeSelf()
		end
		if restartText then
			restartText:removeSelf()
		end
		if background then
			background:removeSelf()
		end
	end

	bl:addEventListener( "tap", pushBl )
	resetText:addEventListener("tap", resetBl)

	Runtime:addEventListener("enterFrame", function()
		if gameStarted then
			if bl.y <= (display.contentCenterY - 1544 + 300) or bl.y >= (display.contentCenterY + 1400 - 300) then
				physics.pause()
				gameStarted = false
				tapText.text = "0"
				background = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
				background:setFillColor(0.1, 0.1, 0.3, 0.8)
				gameoverText = display.newText( "GAMEOVER", display.contentCenterX -10,  1200,   native.systemFontBold, 200)
				gameoverText:setFillColor( 255, 0, 0, 0.8 )
				restartText = display.newText( "RESTART", display.contentCenterX -10,  1500,   native.systemFontBold, 200)
				restartText:setFillColor( 0, 255, 0, 0.8 )
				
				restartText:addEventListener("tap", restartGame)
				sceneGroup:insert(background)
				sceneGroup:insert(gameoverText)
				sceneGroup:insert(restartText)
			end
		end
	end)

	sceneGroup:insert(bg)
	sceneGroup:insert(pf)
	sceneGroup:insert(bl)
	sceneGroup:insert(tapText)
	sceneGroup:insert(resetText)

end

function scene:show( event )
	local phase = event.phase
	if phase == "did" then
		physics.start()
		gameStarted = true
	end
end

function scene:hide( event )
	local phase = event.phase
end

function scene:destroy( event )
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
local composer = require( "composer" )
local scene = composer.newScene()

local game_bg, platform, archon, tapText, resetText, startText, gameover_bg, gameoverText, restartText


local physics = require( "physics" )
physics.start()
physics.pause()
local tapCount = 0
local gameStarted = false

function scene:create( event )
	local sceneGroup = self.view

	game_bg= display.newImageRect("images/mondstadt.png", 1440, 3100)
	game_bg.x = display.contentCenterX
	game_bg.y = display.contentCenterY

	-- platform = display.newImageRect("images/platform.png", 500, 180)
	-- platform.x = display.contentCenterX
	-- platform.y = display.contentCenterY+1500

	archon = display.newImageRect("images/venti.png", 700, 700)
	archon.x = display.contentCenterX
	archon.y = display.contentCenterY

	tapText = display.newText( tapCount, display.contentCenterX, 300, native.systemFont, 250 )
	tapText:setFillColor( 255, 0, 0 )
	resetText = display.newText( "Reset", display.contentCenterX -370,  270,  native.systemFont, 150)
	resetText:setFillColor( 255, 0, 0 )

	-- physics.addBody( platform, "static|" )
	physics.addBody( archon, "dynamic", { radius=300, bounce=-0.7 } )

	local function pushArchon()
		if gameStarted then
			archon:applyLinearImpulse( 0, -45, archon.x, archon.y )
			tapCount = tapCount + 1
			tapText.text = tapCount
		end
	end

	local function resetBl()
		tapCount = 0
		tapText.text = tapCount
	end

	local function restartGame()
		tapCount = 0
		tapText.text = tapCount
		gameStarted = true
		physics.start()
		archon.x = display.contentCenterX
		archon.y = display.contentCenterY
		archon:setLinearVelocity(0, 0)
		if gameoverText then
			gameoverText:removeSelf()
		end
		if restartText then
			restartText:removeSelf()
		end
		if gameover_bg then
			gameover_bg:removeSelf()
		end
	end

	archon:addEventListener( "tap", pushArchon )
	resetText:addEventListener("tap", resetBl)

	Runtime:addEventListener("enterFrame", function()
		if gameStarted then
			if archon.y <= (display.contentCenterY - 1544 + 300) or archon.y >= (display.contentCenterY + 1500 - 300) then
				physics.pause()
				gameStarted = false
				tapText.text = "0"
				gameover_bg = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
				gameover_bg:setFillColor(0.1, 0.1, 0.3, 0.8)
				gameoverText = display.newText( "GAMEOVER", display.contentCenterX -10,  1200,   native.systemFontBold, 200)
				gameoverText:setFillColor( 255, 0, 0, 0.8 )
				restartText = display.newText( "RESTART", display.contentCenterX -10,  1500,   native.systemFontBold, 200)
				restartText:setFillColor( 0, 255, 0, 0.8 )
				restartText:addEventListener("tap", restartGame)
				sceneGroup:insert(gameover_bg)
				sceneGroup:insert(gameoverText)
				sceneGroup:insert(restartText)
			end
		end
	end)

	sceneGroup:insert(game_bg)
	-- sceneGroup:insert(platform)
	sceneGroup:insert(archon)
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
local physics = require( "physics" )
physics.start()


local tapCount = 0

local background = display.newImageRect( "background.png", 480, 800 )
background.x = display.contentCenterX
background.y = display.contentCenterY

local platform = display.newImageRect( "platform.png", 500, 50 )
platform.x = display.contentCenterX
platform.y = display.contentHeight-25

local tapText = display.newText( tapCount, display.contentCenterX, 50, native.systemFont, 100 )
----tapText:setFillColor( 0, 0, 0 )

local balloon = display.newImageRect( "balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY

physics.addBody( platform, "static" )
physics.addBody( balloon, "dynamic", { radius=55, bounce=0.5 } )

local function pushBalloon()
	balloon:applyLinearImpulse( 0, -0.75, balloon.x, balloon.y )
	tapCount = tapCount + 1
	tapText.text = tapCount
end



local restartText = display.newText	( "Reset", display.contentCenterX-150, display.contentHeight-760, native.systemFont, 30 )	


local function reset()
	-- balloon.x = display.contentCenterX
	-- balloon.y = display.contentCenterY
	-- balloon.y = display.contentHeight-70
	tapCount = 0
	tapText.text = tapCount
	

end

local function restartGame()
    -- Reset variables
    tapCount = 0
    tapText.text = tapCount
    gameOver = false

    -- Reset balloon position
    balloon.x = display.contentCenterX
    balloon.y = display.contentCenterY
    balloon:setLinearVelocity(0, 0)

    -- Restart physics
    physics.start()

	--remove game over text
	if gameOverText then
        gameOverText:removeSelf()
        gameOverText = nil
    end
    -- Remove restart button
    if restartButton then
        restartButton:removeSelf()
        restartButton = nil
    end
end


local function onCollision(event)
    if event.phase == "began" then
        
        if ( (event.object1 == balloon and event.object2 == platform) or
             (event.object1 == platform and event.object2 == balloon) ) then
            if gameOver then return end
            
			gameOver = true
            print("GAME OVER")
            physics.pause()

            -- Game Over Text
            gameOverText = display.newText(
                "GAME OVER",
                display.contentCenterX,
                display.contentCenterY - 100,
                native.systemFontBold,
                80
            )
            gameOverText:setFillColor(1, 0, 0)

            -- Restart Button
            restartButton = display.newText(
                "RESTART",
                display.contentCenterX,
                display.contentCenterY + 50,
                native.systemFontBold,
                50
            )
            restartButton:setFillColor(0, 1, 0)

            restartButton:addEventListener("tap", restartGame)
        end
    end
end

Runtime:addEventListener("collision", onCollision)




balloon:addEventListener( "tap", pushBalloon )
restartText:addEventListener( "tap", reset )
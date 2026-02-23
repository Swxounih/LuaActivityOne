--yasmien
local composer = require("composer")
local scene =composer.newScene()

local physics = require( "physics" )
physics.start()

function scene:create( e )
local sceneGroup =self.view

local tapCount = 0
local gameOver = false
local restartButton
local gameOverText



local background = display.newImageRect( sceneGroup,"images/background.jpg", 480, 800 )
background.x = display.contentCenterX
background.y = display.contentCenterY

local platform = display.newImageRect( sceneGroup,"images/platform.png", 500, 50 )
platform.x = display.contentCenterX
platform.y = display.contentHeight-25

local tapText = display.newText( tapCount, display.contentCenterX, 60, native.systemFont, 100 )
tapText:setFillColor( 0, 1, 0 )

local balloon = display.newImageRect( sceneGroup,"images/balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY

physics.addBody( platform, "static" )
physics.addBody( balloon, "dynamic", { radius=55, bounce=0.5 } )

local function pushBalloon()
    if gameOver then return end
    balloon:applyLinearImpulse( 0, -0.75, balloon.x, balloon.y )
    tapCount = tapCount + 1
    tapText.text = tapCount

end




local restartText = display.newText	( "Reset", display.contentCenterX+170, display.contentHeight-760, native.systemFont, 30 )	
restartText:setFillColor(0, 1, 0)

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


local function doGameOver()
    if gameOver then return end
    gameOver = true
    print("GAME OVER")
    physics.pause()

    if gameOverText then
        gameOverText:removeSelf()
        gameOverText = nil
    end

    -- Game Over Text
    gameOverText = display.newText(
        "GAME OVER",
        display.contentCenterX,
        display.contentCenterY - 100,
        native.systemFontBold,
        70
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


local function onCollision(event)
    if event.phase == "began" then
        
        if ( (event.object1 == balloon and event.object2 == platform) or
             (event.object1 == platform and event.object2 == balloon) ) then
            if gameOver then return end
            doGameOver()
        end
    end
end

local function bungosataas(event)
    if(balloon.y == display.contentHeight) then
        restartText.isVisible = true
    
    end

end

local function checkBounds(event)
    if gameOver then return end
    local top = balloon.y - (balloon.height or 0)/2
    if top < 0 then
        doGameOver()
    end
end

Runtime:addEventListener("enterFrame", checkBounds)




Runtime:addEventListener("collision", onCollision)


balloon:addEventListener( "tap", pushBalloon )
restartText:addEventListener( "tap", reset )

sceneGroup: insert(background)
sceneGroup: insert(platform)
sceneGroup: insert(balloon)
end

scene:addEventListener("create", scene)
return scene
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
--tapText:setFillColor( 0, 0, 0 )

local balloon = display.newImageRect( "balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY

physics.addBody( platform, "static" )
physics.addBody( balloon, "dynamic", { radius=50, bounce=0.1 } )

local function pushBalloon()
	balloon:applyLinearImpulse( 0, -0.75, balloon.x, balloon.y )
	tapCount = tapCount + 1
	tapText.text = tapCount
end

balloon:addEventListener( "tap", pushBalloon )

local restartText = display.newText	( "Reset", display.contentCenterX-150, display.contentHeight-760, native.systemFont, 30 )	


local function restartGame ()
	balloon.x = display.contentCenterX
	balloon.y = display.contentCenterY
	balloon.y = display.contentHeight-70
	tapCount = 0
	tapText.text = tapCount
	
	-- balloon.angularVelocity = 0
	-- balloon:setLinearVelocity( 0, 0 )
	
end

restartText:addEventListener( "tap", restartGame )

local composer = require( "composer" )
local scene = composer.newScene()

local backgound,bg, tapText, startText


function scene:create( event )
	local sceneGroup = self.view

bg = display.newImageRect("images/start_bg.png", 1440, 3088)
bg.x = display.contentCenterX
bg.y = display.contentCenterY


background = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
background:setFillColor(0, 0, 0 , 0.5)
startText = display.newText( "TAP THE BALLOON", display.contentCenterX -10,  600,  native.systemFontBold, 140)
startText:setFillColor( 300, 0, 0 )
edition= display.newText( "GENSHIN EDITION", display.contentCenterX -10,  800,  native.systemFont, 80)
edition:setFillColor( 300, 0, 0 )
tapText = display.newText( "START", display.contentCenterX -10,  1500,  native.systemFontBold, 200)
tapText:setFillColor( 255, 255, 0 )

local function onPush( )
	composer.gotoScene("scene.game") 
end

sceneGroup:insert(bg)
sceneGroup:insert(background)
sceneGroup:insert(edition)
sceneGroup:insert(startText)
sceneGroup:insert(tapText)

tapText:addEventListener("tap", onPush)
end

function scene:show( event )
	local phase = event.phase
	if phase == "did" then
		-- Scene is fully shown
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
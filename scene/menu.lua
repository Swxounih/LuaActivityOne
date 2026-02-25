
local composer = require( "composer" )
local scene = composer.newScene()

local backgound, platform, baloon, tapText, startText


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
bl.y = display.contentCenterY - 250

local background = display.newRect(display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
background:setFillColor(0, 0, 0 , 0.1) -- RGB
local startText = display.newText( "TAP THE BALOON", display.contentCenterX -10,  400,  native.systemFontBold, 140)
startText:setFillColor( 300, 0, 0 )

local tapText = display.newText( "START", display.contentCenterX -10,  1500,  native.systemFontBold, 250)
tapText:setFillColor( 255, 255, 0 )

local function onPush( )
	composer.gotoScene("scene.game") 
end

sceneGroup:insert(bg)
sceneGroup:insert(pf)
sceneGroup:insert(bl)
sceneGroup:insert(background)
sceneGroup:insert(startText)
sceneGroup:insert(tapText)

bl:addEventListener("tap", onPush)
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
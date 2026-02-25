local composer = require("composer")
local scene =composer.newScene()

local background, platform, tapText,balloon

background = display.newImageRect( sceneGroup,"images/background.jpg", 480, 800 )
background.x = display.contentCenterX
background.y = display.contentCenterY

platform = display.newImageRect( sceneGroup,"images/platform.png", 500, 100 )
platform.x = display.contentCenterX
platform.y = display.contentHeight - 50

tapText = display.newText( tapCount, display.contentCenterX, 60, native.systemFont, 40 )
--tapText:setFillColor( 0, 1, 0 )

balloon = display.newImageRect( sceneGroup,"images/balloon.png", 112, 130 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY

function scene: create(e)
    local sceneGroup = self.view

sceneGroup: insert(background)
sceneGroup: insert(platform)
sceneGroup: insert(balloon)

end

scene:addEventListener("create", scene)
return scene
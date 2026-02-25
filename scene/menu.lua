local composer = require("composer")
local scene = composer.newScene()

function scene:create(e)
    local sceneGroup = self.view

    -- Background
    local background = display.newImageRect(sceneGroup, "images/walls.jpg", 480, 800)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- Title Text
    local titleText = display.newText(sceneGroup, "BALLOON GAME", display.contentCenterX, 200, native.systemFontBold, 50)
    titleText:setFillColor(0, 1, 0)

    -- Play Button
    local playButton = display.newText(sceneGroup, "PLAY", display.contentCenterX, 350, native.systemFontBold, 60)
    playButton:setFillColor(1, 1, 0)

    -- Quit Button
    local quitButton = display.newText(sceneGroup, "QUIT", display.contentCenterX, 450, native.systemFontBold, 60)
    quitButton:setFillColor(1, 0, 0)

    -- Button Listeners
    local function onPlay(event)
        if event.phase == "ended" then
            composer.gotoScene("scene.game", { effect = "fade", time = 500 })
        end
    end

    local function onQuit(event)
        if event.phase == "ended" then
            native.requestExit()
        end
    end

    playButton:addEventListener("touch", onPlay)
    quitButton:addEventListener("touch", onQuit)
end

scene:addEventListener("create", scene)
return scene
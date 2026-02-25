local composer = require("composer")
local scene = composer.newScene()

local physics = require("physics")
physics.start()

function scene:create(e)
    local sceneGroup = self.view

    local tapCount = 0
    local gameOver = false
    local restartButton
    local gameOverText

    local background = display.newImageRect(sceneGroup, "images/walls.jpg", 480, 800)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local platform = display.newImageRect(sceneGroup, "images/platform.png", 500, 50)
    platform.x = display.contentCenterX
    platform.y = display.contentHeight - 25

    local tapText = display.newText(sceneGroup, tapCount, display.contentCenterX, 60, native.systemFont, 100)
    tapText:setFillColor(0, 1, 0)

    local balloon = display.newImageRect(sceneGroup, "images/chibi.png", 112, 112)
    balloon.x = display.contentCenterX
    balloon.y = display.contentCenterY

    physics.addBody(platform, "static")
    physics.addBody(balloon, "dynamic", { radius = 40, bounce = 0.5 })

    -- Menu Button (top-left)
    local menuButton = display.newText(sceneGroup, "MENU", 50, 30, native.systemFontBold, 28)
    menuButton:setFillColor(1, 1, 0)

    local function goToMenu(event)
        if event.phase == "ended" then
            physics.stop()
            composer.gotoScene("scene.menu", { effect = "fade", time = 500 })
        end
    end
    menuButton:addEventListener("touch", goToMenu)

    local function pushBalloon()
        if gameOver then return end
        balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
        tapCount = tapCount + 1
        tapText.text = tapCount
    end

    local function restartGame()
        tapCount = 0
        tapText.text = tapCount
        gameOver = false
        balloon.x = display.contentCenterX
        balloon.y = display.contentCenterY
        balloon:setLinearVelocity(0, 0)
        physics.start()

        if gameOverText then
            gameOverText:removeSelf()
            gameOverText = nil
        end
        if restartButton then
            restartButton:removeSelf()
            restartButton = nil
        end
    end

    local function doGameOver()
        if gameOver then return end
        gameOver = true
        physics.pause()

        gameOverText = display.newText(
            sceneGroup, "GAME OVER",
            display.contentCenterX, display.contentCenterY - 100,
            native.systemFontBold, 70
        )
        gameOverText:setFillColor(1, 0, 0)

        restartButton = display.newText(
            sceneGroup, "RESTART",
            display.contentCenterX, display.contentCenterY + 50,
            native.systemFontBold, 50
        )
        restartButton:setFillColor(0, 1, 0)
        restartButton:addEventListener("tap", restartGame)
    end

    local function onCollision(event)
        if event.phase == "began" then
            if (event.object1 == balloon and event.object2 == platform) or
               (event.object1 == platform and event.object2 == balloon) then
                doGameOver()
            end
        end
    end

    local function checkBounds(event)
        if gameOver then return end
        local top = balloon.y - (balloon.height or 0) / 2
        if top < 0 then
            doGameOver()
        end
    end

    Runtime:addEventListener("enterFrame", checkBounds)
    Runtime:addEventListener("collision", onCollision)
    balloon:addEventListener("tap", pushBalloon)
end

scene:addEventListener("create", scene)
return scene
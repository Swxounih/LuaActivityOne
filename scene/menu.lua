local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")

-- Initialize Physics
physics.start()
physics.pause() -- Keep it paused until the player clicks Start

function scene:create(event)
    local sceneGroup = self.view

    -- 1. Initialize Variables
    local screenShadow
    local startButtonGroup
    local extraButtonGroup
    local tapCount = 0
    local gameOver = false
    local gameStarted = false
    local gameOverText
    local restartButton

    -- 2. Create Background & Game Objects
    local background = display.newImageRect(sceneGroup, "images/road.jpg", 480, 800)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.isHitTestable = true -- Ensures it catches taps even if transparent

    local platform = display.newImageRect(sceneGroup, "images/platform.png", 500, 50)
    platform.x = display.contentCenterX
    platform.y = display.contentHeight - 25

    local tapText = display.newText(sceneGroup, tapCount, display.contentCenterX, 60, native.systemFont, 100)
    tapText:setFillColor(0, 1, 0)

    local balloon = display.newImageRect(sceneGroup, "images/glinda.png", 130, 130)
    balloon.x = display.contentCenterX
    balloon.y = display.contentCenterY

    -- 3. Physics Bodies
    physics.addBody(platform, "static")
    physics.addBody(balloon, "dynamic", {radius = 55, bounce = 0.5})

    --- 4. Helper Function: Create Stylish Buttons ---
    local function createCustomButton(label, yPos, color, onTap)
        local group = display.newGroup()
        sceneGroup:insert(group)

        local btnBg = display.newRoundedRect(group, display.contentCenterX, yPos, 300, 80, 12)
        btnBg:setFillColor(unpack(color)) 
        btnBg:setStrokeColor(1, 1, 1)
        btnBg.strokeWidth = 4

        local btnText = display.newText(group, label, btnBg.x, btnBg.y, native.systemFontBold, 30)
        btnText:setFillColor(1, 1, 1)

        group:addEventListener("tap", onTap)
        return group
    end

    --- 5. Game Functions ---

    local function startPlaying()
        gameStarted = true
        
        -- Clean up menu buttons
        if startButtonGroup then display.remove(startButtonGroup); startButtonGroup = nil end
        if extraButtonGroup then display.remove(extraButtonGroup); extraButtonGroup = nil end
        
        physics.start()
        balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
        return true
    end

    local function restartGame()
        -- Remove Game Over UI
        if screenShadow then display.remove(screenShadow); screenShadow = nil end
        if gameOverText then display.remove(gameOverText); gameOverText = nil end
        if restartButton then display.remove(restartButton); restartButton = nil end

        -- Reset Variables
        gameOver = false
        gameStarted = false
        tapCount = 0
        tapText.text = tapCount

        -- Reset Balloon
        balloon.x = display.contentCenterX
        balloon.y = display.contentCenterY
        balloon:setLinearVelocity(0, 0)
        balloon.angularVelocity = 0
        physics.pause()

        -- Re-create Menu Buttons
        startButtonGroup = createCustomButton("START PLAYING", display.contentCenterY + 100, {0, 0.6, 0}, startPlaying)
        extraButtonGroup = createCustomButton("HOW TO PLAY", display.contentCenterY + 200, {0, 0.4, 0.8}, function() print("Show Instructions"); return true end)
        
        return true
    end

    local function doGameOver()
        if gameOver then return end
        gameOver = true
        physics.pause()

        -- Dim the screen
        screenShadow = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
        screenShadow:setFillColor(0, 0, 0, 0.6)
        screenShadow:addEventListener("tap", function() return true end) -- Blocks taps to background

        gameOverText = display.newText(sceneGroup, "GAME OVER", display.contentCenterX, display.contentCenterY - 100, native.systemFontBold, 70)
        gameOverText:setFillColor(1, 0, 0)

        -- Restart Button UI
        restartButton = createCustomButton("RESTART", display.contentCenterY + 50, {0, 0.6, 0}, restartGame)
    end

    local function pushBalloon()
        -- Don't allow tapping if game hasn't started or is over
        if not gameStarted or gameOver then return true end
        
        balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
        tapCount = tapCount + 1
        tapText.text = tapCount
        return true
    end

    local function onCollision(event)
        if event.phase == "began" then
            if (event.object1 == balloon or event.object2 == balloon) and 
               (event.object1 == platform or event.object2 == platform) then
                doGameOver()
            end
        end
    end

    local function checkBounds()
        if gameOver or not gameStarted then return end
        -- Check if balloon goes off top
        if (balloon.y - 65) < 0 then 
            doGameOver() 
        end
    end

    -- 6. Event Listeners
    background:addEventListener("tap", pushBalloon)
    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame", checkBounds)

    -- 7. Initial State: Create the menu buttons
    startButtonGroup = createCustomButton("START PLAYING", display.contentCenterY + 100, {0, 0.6, 0}, startPlaying)
    extraButtonGroup = createCustomButton("HOW TO PLAY", display.contentCenterY + 200, {0, 0.4, 0.8}, function() print("Instructions clicked"); return true end)

end

scene:addEventListener("create", scene)
return scene
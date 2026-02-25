local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")

physics.start()
physics.pause() 

function scene:create(event)
    local sceneGroup = self.view

    -- 1. Variables
    local screenShadow
    local startButtonGroup
    local extraButtonGroup
    local tapCount = 0
    local gameOver = false
    local gameStarted = false
    local gameOverText
    local restartButton
    -- local birdTimer
    -- local birds = {} 
    local menuButtonGroup
    local menuPanelGroup
    local musicOn = true
    local highScore = 0

    -- Simple persistent high score load/save
    local function loadHighScore()
        local path = system.pathForFile("highscore.txt", system.DocumentsDirectory)
        local file = io.open(path, "r")
        if file then
            local contents = file:read("*a")
            io.close(file)
            local n = tonumber(contents)
            return n or 0
        end
        return 0
    end

    local function saveHighScore(value)
        local path = system.pathForFile("highscore.txt", system.DocumentsDirectory)
        local file = io.open(path, "w")
        if file then
            file:write(tostring(value))
            io.close(file)
        end
    end

    highScore = loadHighScore()

    -- 2. Create Layers & Game Objects
    local background = display.newImageRect(sceneGroup, "images/background.jpg", 480, 800)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.isHitTestable = true

    local platform = display.newImageRect(sceneGroup, "images/platform.png", 500, 50)
    platform.x = display.contentCenterX
    platform.y = display.contentHeight - 25

    local tapText = display.newText(sceneGroup, tapCount, display.contentCenterX, 60, native.systemFont, 100)
    tapText:setFillColor(0, 1, 0)

    local balloon = display.newImageRect(sceneGroup, "images/balloon.png", 112, 112)
    balloon.x = display.contentCenterX
    balloon.y = display.contentCenterY

    physics.addBody(platform, "static")
    -- Fit the physics radius to the balloon image (112x112 -> radius ~56)
    physics.addBody(balloon, "dynamic", {radius =56, bounce = 0.05})

    --- 3. Helper Function: Create Buttons ---
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

    -- Small helper to create icon button (top-left)
    local function createMenuIcon(x, y)
        local group = display.newGroup()
        sceneGroup:insert(group)
        local size = 56
        local bg = display.newRect(group, x, y, size, size)
        bg:setFillColor(0, 0, 0, 0.4)
        bg.strokeWidth = 2
        bg:setStrokeColor(1,1,1)
        local icon
        -- Try to use an icon image if available
        local success, err = pcall(function()
            icon = display.newImageRect(group, "images/menu.png", 34, 34)
            icon.x = x
            icon.y = y
        end)
        if not success then
            local txt = display.newText(group, "≡", x, y, native.systemFontBold, 28)
            txt:setFillColor(1)
        end
        return group
    end

    --- 4. Bird Mechanic Functions ---
    --[[ Bird spawning disabled
    local function spawnBird()
        if gameOver or not gameStarted then return end

        local birdWidth, birdHeight = 80, 80
        local bird = display.newImageRect(sceneGroup, "images/bird.png", birdWidth, birdHeight)
        table.insert(birds, bird)

        local fromLeft = math.random() > 0.5
        bird.x = fromLeft and -50 or (display.actualContentWidth + 50)
        bird.y = math.random(80, display.contentHeight - 200)
        bird.xScale = fromLeft and -1 or 1

        -- Updated Hitbox: Using a box that matches the bird's size
        physics.addBody(bird, "kinematic", { isSensor = true, box = { halfWidth=birdWidth/2, halfHeight=birdHeight/2 } })
        bird.myName = "bird"

        local targetX = fromLeft and (display.actualContentWidth + 80) or -80
        transition.to(bird, {
            x = targetX,
            time = math.random(2500, 4500),
            onComplete = function()
                if bird and bird.parent then
                    display.remove(bird)
                    for i = #birds, 1, -1 do
                        if birds[i] == bird then table.remove(birds, i) end
                    end
                end
            end
        })
    end
    --]]

    --- 5. Game Logic Functions ---
    
    -- Forward declare the functions so they can "see" each other
    local restartGame
    local startPlaying

    startPlaying = function()
        gameStarted = true
        if screenShadow then display.remove(screenShadow); screenShadow = nil end
        if startButtonGroup then display.remove(startButtonGroup); startButtonGroup = nil end
        if extraButtonGroup then display.remove(extraButtonGroup); extraButtonGroup = nil end
        
        physics.start()
        balloon:applyLinearImpulse(0, -0.80, balloon.x, balloon.y)
        -- birdTimer = timer.performWithDelay(2000, spawnBird, 0) -- disabled bird spawning

        
        return true
    end

    restartGame = function()
        -- Clean up Game Over UI
        if screenShadow then display.remove(screenShadow); screenShadow = nil end
        if gameOverText then display.remove(gameOverText); gameOverText = nil end
        if restartButton then display.remove(restartButton); restartButton = nil end
        
        -- Clean up Birds (disabled since bird spawning is commented out)
        -- for i = #birds, 1, -1 do
        --     display.remove(birds[i])
        --     table.remove(birds, i)
        -- end

        -- Define the Quit Logic
        local function quitApp()
            native.requestExit()
            return true
        end

        
        
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

        -- (timer removed) nothing to stop here

        -- Re-show Menu
        screenShadow = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
        screenShadow:setFillColor(0, 0, 0, 0.6)
        screenShadow:addEventListener("tap", function() return true end)

        -- Start Playing Button
        startButtonGroup = createCustomButton("START PLAYING", display.contentCenterY + 100, {0, 0.6, 0}, startPlaying)
        
        -- UPDATED: Quit Button (Red color {0.8, 0, 0})
        extraButtonGroup = createCustomButton("QUIT", display.contentCenterY + 200, {0.8, 0, 0}, quitApp)
        return true
    end

    local function doGameOver()
        if gameOver then return end
        gameOver = true
        physics.pause()
        -- if birdTimer then timer.cancel(birdTimer); birdTimer = nil end -- birdTimer disabled

        -- (timer removed) nothing to stop here

        screenShadow = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
        screenShadow:setFillColor(0, 0, 0, 0.6)
        screenShadow:addEventListener("tap", function() return true end) 

        gameOverText = display.newText(sceneGroup, "GAME OVER", display.contentCenterX, display.contentCenterY - 100, native.systemFontBold, 70)
        gameOverText:setFillColor(1, 0, 0)

        -- Update high score
        if tapCount and tapCount > (highScore or 0) then
            highScore = tapCount
            saveHighScore(highScore)
        end

        -- This now calls our restartGame logic directly
        restartButton = createCustomButton("RESTART", display.contentCenterY + 50, {0, 0.6, 0}, restartGame)
    end

    local function pushBalloon()
        if not gameStarted or gameOver then return true end
        balloon:applyLinearImpulse(0, -0.80, balloon.x, balloon.y)
        tapCount = tapCount + 1
        tapText.text = tapCount
        return true
    end

    local function onCollision(event)
        if event.phase == "began" then
            local obj1 = event.object1
            local obj2 = event.object2
            -- Bird collisions removed; only platform collisions trigger game over
            if (obj1 == platform or obj2 == platform) then
                doGameOver()
            end
        end
    end

    local function checkBounds()
        if gameOver or not gameStarted then return end
        if (balloon.y - 65) < 0 then doGameOver() end
    end

    -- 6. Event Listeners
    -- Only respond when the balloon itself is tapped
    balloon:addEventListener("tap", pushBalloon)
    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame", checkBounds)

    -- 7. Initial Run
    restartGame()
    -- Menu panel functions (open/close, music toggle, timer cycle)
    local function closeMenu()
        if menuPanelGroup then
            display.remove(menuPanelGroup)
            menuPanelGroup = nil
        end
    end

    local function toggleMusic(labelObj)
        musicOn = not musicOn
        if labelObj and labelObj.text then
            labelObj.text = "Music: " .. (musicOn and "On" or "Off")
        end
    end

    -- timer selection removed

    local function showMenu()
        if menuPanelGroup then
            closeMenu()
            return
        end
        menuPanelGroup = display.newGroup()
        sceneGroup:insert(menuPanelGroup)

        local shadow = display.newRect(menuPanelGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
        shadow:setFillColor(0,0,0,0.5)
        shadow:addEventListener("tap", function() closeMenu(); return true end)

        local panelW, panelH = 320, 320
        local panel = display.newRoundedRect(menuPanelGroup, display.contentCenterX, display.contentCenterY, panelW, panelH, 12)
        panel:setFillColor(0.1, 0.1, 0.1)
        panel.strokeWidth = 3
        panel:setStrokeColor(1,1,1)

        -- Music row
        local musicLabel = display.newText(menuPanelGroup, "Music: " .. (musicOn and "On" or "Off"), display.contentCenterX, display.contentCenterY - 80, native.systemFontBold, 24)
        musicLabel:setFillColor(1)
        local musicBtn = display.newRoundedRect(menuPanelGroup, display.contentCenterX, display.contentCenterY - 80, 240, 48, 8)
        musicBtn:setFillColor(0,0,0,0)
        musicBtn:addEventListener("tap", function() toggleMusic(musicLabel); return true end)

        -- (Timer UI removed)
        -- High score row
        local hsText = display.newText(menuPanelGroup, "High Score: " .. tostring(highScore), display.contentCenterX, display.contentCenterY + 60, native.systemFontBold, 24)
        hsText:setFillColor(1)

        -- Close button
        local closeBtn = display.newRoundedRect(menuPanelGroup, display.contentCenterX, display.contentCenterY + 130, 200, 48, 8)
        closeBtn:setFillColor(0, 0.6, 0)
        local closeTxt = display.newText(menuPanelGroup, "Close", closeBtn.x, closeBtn.y, native.systemFontBold, 22)
        closeTxt:setFillColor(1)
        closeBtn:addEventListener("tap", function() closeMenu(); return true end)
    end

    -- Create menu icon (top-left)
    menuButtonGroup = createMenuIcon(40, 40)
    menuButtonGroup:addEventListener("tap", function() showMenu(); return true end)
end

scene:addEventListener("create", scene)
return scene
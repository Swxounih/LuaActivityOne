local composer = require("composer")
local scene = composer.newScene()
local physics = require("physics")

physics.start()
physics.pause()
local backgroundMusic
local bgChannel

function scene:create(event)
    local sceneGroup = self.view

    -- Variables
    local screenShadow
    local startButtonGroup
    local extraButtonGroup
    local tapCount = 0
    local gameOver = false
    local gameStarted = false
    local gameOverText
    local restartButton
    local menuButtonGroup
    local menuPanelGroup
    local musicOn = true
    local mtIcon
    local menuMusicLabel
    local timerMinutes = 1
    local menuTimerLabel
    local timerDropdown
    local timerDropdownIcon
    local timerSeconds = 0
    local timerText
    local timerHandle
    local highScore = 0

    -- Persistent high score
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

    -- Persistent music setting
    local function loadMusicSetting()
        local path = system.pathForFile("music_setting.txt", system.DocumentsDirectory)
        local file = io.open(path, "r")
        if file then
            local contents = file:read("*a")
            io.close(file)
            if contents == "false" then return false end
            return true
        end
        return true
    end

    local function saveMusicSetting(value)
        local path = system.pathForFile("music_setting.txt", system.DocumentsDirectory)
        local file = io.open(path, "w")
        if file then
            file:write(tostring(value))
            io.close(file)
        end
    end

    local function loadTimerSetting()
        local path = system.pathForFile("timer_setting.txt", system.DocumentsDirectory)
        local file = io.open(path, "r")
        if file then
            local contents = file:read("*a")
            io.close(file)
            local n = tonumber(contents)
            if n and n >=1 and n <=5 then return n end
        end
        return 1
    end

    local function saveTimerSetting(value)
        local path = system.pathForFile("timer_setting.txt", system.DocumentsDirectory)
        local file = io.open(path, "w")
        if file then
            file:write(tostring(value))
            io.close(file)
        end
    end

    highScore = loadHighScore()
    musicOn = loadMusicSetting()
    timerMinutes = loadTimerSetting()

    -- Display objects
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
    physics.addBody(balloon, "dynamic", {radius = 55, bounce = 0.05})

    -- Helpers
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

    local function createMenuIcon(x, y)
        local group = display.newGroup()
        sceneGroup:insert(group)
        local size = 56
        local bg = display.newRect(group, x, y, size, size)
        bg:setFillColor(0, 0, 0, 0.4)
        bg.strokeWidth = 2
        bg:setStrokeColor(1, 1, 1)
        local icon
        local ok = pcall(function()
            icon = display.newImageRect(group, "images/menu.png", 34, 34)
            icon.x = x; icon.y = y
        end)
        if not ok then
            local txt = display.newText(group, "≡", x, y, native.systemFontBold, 28)
            txt:setFillColor(1)
        end
        return group
    end

    -- Game logic forward declarations
    local restartGame, startPlaying

    startPlaying = function()
        gameStarted = true
        if screenShadow then display.remove(screenShadow); screenShadow = nil end
        if startButtonGroup then display.remove(startButtonGroup); startButtonGroup = nil end
        if extraButtonGroup then display.remove(extraButtonGroup); extraButtonGroup = nil end
        physics.start()
        balloon:applyLinearImpulse(0, -0.80, balloon.x, balloon.y)
        -- start countdown timer
        if timerHandle then timer.cancel(timerHandle); timerHandle = nil end
        timerSeconds = timerMinutes * 60
        local function updateTimerDisplay()
            if not timerText then
                timerText = display.newText(sceneGroup, "", display.contentCenterX, 120, native.systemFontBold, 28)
                timerText:setFillColor(1)
            end
            local m = math.floor(math.max(timerSeconds,0) / 60)
            local s = math.floor(math.max(timerSeconds,0) % 60)
            timerText.text = string.format("%02d:%02d", m, s)
        end
        updateTimerDisplay()
        timerHandle = timer.performWithDelay(1000, function()
            timerSeconds = timerSeconds - 1
            updateTimerDisplay()
            if timerSeconds <= 0 then
                if timerHandle then timer.cancel(timerHandle); timerHandle = nil end
                doGameOver()
            end
        end, 0)
        return true
    end

    restartGame = function()
        -- stop and clear any running timer
        if timerHandle then timer.cancel(timerHandle); timerHandle = nil end
        if timerText then display.remove(timerText); timerText = nil end
        if screenShadow then display.remove(screenShadow); screenShadow = nil end
        if gameOverText then display.remove(gameOverText); gameOverText = nil end
        if restartButton then display.remove(restartButton); restartButton = nil end
        gameOver = false
        gameStarted = false
        tapCount = 0
        tapText.text = tapCount
        balloon.x = display.contentCenterX; balloon.y = display.contentCenterY
        balloon:setLinearVelocity(0, 0); balloon.angularVelocity = 0
        physics.pause()
        screenShadow = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
        screenShadow:setFillColor(0, 0, 0, 0.6)
        screenShadow:addEventListener("tap", function() return true end)
        if menuButtonGroup then sceneGroup:insert(menuButtonGroup) end
        startButtonGroup = createCustomButton("START PLAYING", display.contentCenterY + 100, {0, 0.6, 0}, startPlaying)
        extraButtonGroup = createCustomButton("QUIT", display.contentCenterY + 200, {0.8, 0, 0}, function() native.requestExit(); return true end)
        return true
    end

    local function doGameOver()
        if gameOver then return end
        -- stop timer when game ends
        if timerHandle then timer.cancel(timerHandle); timerHandle = nil end
        gameOver = true
        physics.pause()
        screenShadow = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
        screenShadow:setFillColor(0, 0, 0, 0.6)
        screenShadow:addEventListener("tap", function() return true end)
        if menuButtonGroup then sceneGroup:insert(menuButtonGroup) end
        gameOverText = display.newText(sceneGroup, "GAME OVER", display.contentCenterX, display.contentCenterY - 100, native.systemFontBold, 70)
        gameOverText:setFillColor(1, 0, 0)
        if tapCount and tapCount > (highScore or 0) then
            highScore = tapCount; saveHighScore(highScore)
        end
        restartButton = createCustomButton("RESTART", display.contentCenterY + 50, {0, 0.6, 0}, restartGame)
    end

    local function pushBalloon()
        if not gameStarted or gameOver then return true end
        balloon:applyLinearImpulse(0, -0.80, balloon.x, balloon.y)
        tapCount = tapCount + 1; tapText.text = tapCount
        return true
    end

    local function onCollision(event)
        if event.phase == "began" then
            local obj1 = event.object1; local obj2 = event.object2
            if (obj1 == platform or obj2 == platform) then doGameOver() end
        end
    end

    local function checkBounds()
        if gameOver or not gameStarted then return end
        if (balloon.y - 65) < 0 then doGameOver() end
    end

    balloon:addEventListener("tap", pushBalloon)
    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame", checkBounds)

    -- Music toggle logic
    local function toggleMusic(labelObj)
        musicOn = not musicOn
        if labelObj and labelObj.text then labelObj.text = "Music: " .. (musicOn and "On" or "Off") end
        saveMusicSetting(musicOn)
        if musicOn then
            if not backgroundMusic then
                local ok, m = pcall(function() return audio.loadStream("bgmusic/bgmusic.mp3") end)
                if ok then backgroundMusic = m end
            end
            if backgroundMusic then bgChannel = audio.play(backgroundMusic, {loops = -1, channel = 1}) end
        else
            if bgChannel then audio.stop(bgChannel); bgChannel = nil end
        end
        if menuMusicLabel and menuMusicLabel.text then menuMusicLabel.text = "Music: " .. (musicOn and "On" or "Off") end
        if mtIcon and mtIcon.text then mtIcon.text = (musicOn and "♪" or "⦻") end
    end

    -- Menu panel
    local function closeMenu()
        if menuPanelGroup then display.remove(menuPanelGroup); menuPanelGroup = nil; menuMusicLabel = nil; mtIcon = nil end
        timerDropdown = nil
        timerDropdownIcon = nil
    end

    local function showMenu()
        if menuPanelGroup then closeMenu(); return end
        menuPanelGroup = display.newGroup(); sceneGroup:insert(menuPanelGroup)
        local shadow = display.newRect(menuPanelGroup, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
        shadow:setFillColor(0,0,0,0.5); shadow:addEventListener("tap", function() closeMenu(); return true end)
        local panelW, panelH = 320, 320
        local panel = display.newRoundedRect(menuPanelGroup, display.contentCenterX, display.contentCenterY, panelW, panelH, 12)
        panel:setFillColor(0.1, 0.1, 0.1); panel.strokeWidth = 3; panel:setStrokeColor(1,1,1)
        local musicLabel = display.newText(menuPanelGroup, "Music: " .. (musicOn and "On" or "Off"), display.contentCenterX, display.contentCenterY - 80, native.systemFontBold, 24)
        musicLabel:setFillColor(1); menuMusicLabel = musicLabel
        local musicBtn = display.newRoundedRect(menuPanelGroup, display.contentCenterX, display.contentCenterY - 80, 240, 48, 8)
        musicBtn:setFillColor(0,0,0,0); musicBtn:addEventListener("tap", function() toggleMusic(musicLabel); return true end)
        -- small music icon inside menu
        mtIcon = display.newText(menuPanelGroup, (musicOn and "♪" or "⦻"), musicBtn.x + 90, musicBtn.y, native.systemFontBold, 28)
        mtIcon:setFillColor(1)
        mtIcon:addEventListener("tap", function() toggleMusic(musicLabel); return true end)
        -- Timer row (dropdown)
        menuTimerLabel = display.newText(menuPanelGroup, "Timer: " .. tostring(timerMinutes) .. " min", display.contentCenterX, display.contentCenterY - 20, native.systemFontBold, 22)
        menuTimerLabel:setFillColor(1)
        local timerBtn = display.newRoundedRect(menuPanelGroup, display.contentCenterX, display.contentCenterY - 20, 240, 40, 8)
        timerBtn:setFillColor(0,0,0,0)
        local function closeTimerDropdown()
            if timerDropdown then display.remove(timerDropdown); timerDropdown = nil end
            if timerDropdownIcon then display.remove(timerDropdownIcon); timerDropdownIcon = nil end
        end
        local function openTimerDropdown()
            if timerDropdown then closeTimerDropdown(); return end
            timerDropdown = display.newGroup()
            menuPanelGroup:insert(timerDropdown)
            local optsW, optsH = 200, 30
            local baseX = timerBtn.x
            local baseY = timerBtn.y + optsH/2 + 8
            for i=1,5 do
                local y = baseY + (i-1) * (optsH + 6)
                local optBg = display.newRoundedRect(timerDropdown, baseX, y, optsW, optsH, 6)
                optBg:setFillColor(0.12,0.12,0.12)
                local txt = display.newText(timerDropdown, tostring(i) .. " min", baseX, y, native.systemFont, 18)
                txt:setFillColor(1)
                optBg:addEventListener("tap", function()
                    timerMinutes = i
                    menuTimerLabel.text = "Timer: " .. tostring(timerMinutes) .. " min"
                    saveTimerSetting(timerMinutes)
                    -- if game running, reset countdown to new selection
                    if gameStarted then
                        timerSeconds = timerMinutes * 60
                        if timerText then timerText.text = string.format("%02d:%02d", math.floor(timerSeconds/60), timerSeconds%60) end
                    end
                    closeTimerDropdown()
                    return true
                end)
            end
        end
        timerBtn:addEventListener("tap", function() openTimerDropdown(); return true end)
        -- small dropdown icon to open timer choices
        timerDropdownIcon = display.newText(menuPanelGroup, "▾", timerBtn.x + 100, timerBtn.y, native.systemFontBold, 20)
        timerDropdownIcon:setFillColor(1)
        timerDropdownIcon:addEventListener("tap", function() openTimerDropdown(); return true end)

        local hsText = display.newText(menuPanelGroup, "High Score: " .. tostring(highScore), display.contentCenterX, display.contentCenterY + 90, native.systemFontBold, 24)
        hsText:setFillColor(1)
        local closeBtn = display.newRoundedRect(menuPanelGroup, display.contentCenterX, display.contentCenterY + 130, 200, 48, 8)
        closeBtn:setFillColor(0, 0.6, 0)
        local closeTxt = display.newText(menuPanelGroup, "Close", closeBtn.x, closeBtn.y, native.systemFontBold, 22)
        closeTxt:setFillColor(1)
        closeBtn:addEventListener("tap", function() closeMenu(); return true end)
    end

    -- Initial run
    restartGame()
    if musicOn then
        if not backgroundMusic then
            local ok, m = pcall(function() return audio.loadStream("bgmusic/bgmusic.mp3") end)
            if ok then backgroundMusic = m end
        end
        if backgroundMusic then bgChannel = audio.play(backgroundMusic, {loops = -1, channel = 1}) end
    end

    -- Create menu icon (top-left)
    menuButtonGroup = createMenuIcon(40, 40)
    menuButtonGroup:addEventListener("tap", function() showMenu(); return true end)
end

function scene:destroy(event)
    if bgChannel then audio.stop(bgChannel); bgChannel = nil end
    if backgroundMusic then audio.dispose(backgroundMusic); backgroundMusic = nil end
    if timerHandle then timer.cancel(timerHandle); timerHandle = nil end
    if timerText then display.remove(timerText); timerText = nil end
end

scene:addEventListener("create", scene)
scene:addEventListener("destroy", scene)
return scene

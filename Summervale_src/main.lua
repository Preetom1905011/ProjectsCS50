--[[
    This is Summervale
    Authored By Preetom Kumar Biswas
    2020
]]

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 1365
VIRTUAL_HEIGHT = 768

Class = require 'class'
push = require 'push'

require 'Player'
require 'Enemy'
require 'Map'

gameState = 'start'

playerChoice = 'A'

Difficulty = 'easy'


function love.load()

    math.randomseed(os.time())

    textFont = love.graphics.newFont('font.ttf', 24)
    smallFont = love.graphics.newFont('font.ttf', 32)
    largeFont = love.graphics.newFont('font.ttf', 64)
    subtitleFont = love.graphics.newFont('font.ttf', 48)

    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Summervale')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true;
    })

    musics = {
        ['intro'] = love.audio.newSource('sounds/intro/Our-Mountain_v003_Looping.mp3', 'static'),
        ['level1'] = love.audio.newSource('sounds/levels/Into-Battle_v001.mp3', 'static'),
        ['level2'] = love.audio.newSource('sounds/levels/Fantasy-Forest-Battle.mp3', 'static'),
        ['level3'] = love.audio.newSource('sounds/levels/Tower-Defense_Looping.mp3', 'static'),
        ['win'] = love.audio.newSource('sounds/finish/RPG-Battle-Climax.mp3', 'static'),
        --https://freesound.org/people/ClawVO/sounds/399749/
        ['lose'] = love.audio.newSource('sounds/finish/399749__clawvo__eerie-despair.mp3', 'static')
    }
    --the sounds were collected from the following links
    --https://freesound.org/people/LittleRobotSoundFactory/sounds/270391/
    --https://freesound.org/people/LittleRobotSoundFactory/sounds/270389/
    --https://freesound.org/people/LittleRobotSoundFactory/sounds/270388/
    --https://freesound.org/people/LittleRobotSoundFactory/sounds/270393/
    --https://freesound.org/people/LittleRobotSoundFactory/sounds/270401/
    sounds = {
        ['golem_dead'] = love.audio.newSource('sounds/golem_dead.wav', 'static'),
        ['golem_hit'] = love.audio.newSource('sounds/golem_hit.wav', 'static'),
        ['golem_passed'] = love.audio.newSource('sounds/golem_passed.wav', 'static'),
        ['shoot'] = love.audio.newSource('sounds/shoot.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static')
    }

    start_logo = love.graphics.newImage('graphics/elf/elf_logo.png')
    lose_logo = love.graphics.newImage('graphics/elf/lose_logo.png')
    win_logo = love.graphics.newImage('graphics/elf/win_logo.png')
    win_logo_priest = love.graphics.newImage('graphics/elf/win_logo_priest.png')

    icon_heroA = love.graphics.newImage('graphics/elf/heroA_icon.png')
    icon_heroB = love.graphics.newImage('graphics/elf/heroB_icon.png')

    love.keyboard.keysPressed = {}

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    sounds['select']:setVolume(1)
    if key == 'escape' then
        sounds['select']:play()
        if gameState == 'start' or gameState == 'win' or gameState == 'lose' then
            love.event.quit()
        elseif gameState == 'instructions' or gameState == 'credits' or gameState == 'menu_diff' then
            gameState = 'choose_hero'
        elseif gameState == 'play' or gameState == 'level_start' or gameState == 'wave_start' then
            gameState = 'quit_box'
        elseif gameState == 'quit_box' then
            musics['level'..tostring(level)]:stop()
            map:reset()
            gameState = 'start'
        else
            gameState = 'start'
        end

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            sounds['select']:play()
            gameState = 'choose_hero'
        elseif gameState == 'choose_hero' then
            sounds['select']:play()
            gameState = 'menu_diff'
        elseif gameState == 'menu_diff' then
            sounds['select']:play()
            map = Map()
            gameState = 'level_start'
        elseif gameState == 'level_start' then
            sounds['select']:play()
            gameState = 'play'
        elseif gameState == 'win' or gameState == 'lose' then
            sounds['select']:play()
            map:reset()
            gameState = 'choose_hero'
        end
    end

    if gameState == 'quit_box' then
        if key == 'y' or key == 'Y' then
            sounds['select']:play()
            musics['level'..tostring(level)]:stop()
            map:reset()
            gameState = 'start'
        elseif key == 'n' or key == 'N' then
            sounds['select']:play()
            gameState = 'play'
        end
    elseif gameState == 'choose_hero' then
        if key == 'left' then
            playerChoice = 'A'
            sounds['select']:play()
        elseif key == 'right' then
            playerChoice = 'B'
            sounds['select']:play()
        elseif key == 'q' or key == 'Q' then
            gameState = 'instructions'
            sounds['select']:play()
        elseif key == 'c' or key == 'C' then
            gameState = 'credits'
            sounds['select']:play()
        end
    elseif gameState == 'menu_diff' then
        if key == 'up' then
            sounds['select']:play()
            Difficulty = 'easy'
        elseif key == 'down' then
            sounds['select']:play()
            Difficulty = 'hard'
        end
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    if gameState == 'start' or gameState == 'instructions' or gameState == 'choose_hero' or gameState == 'credits' or gameState == 'menu_diff' then
        musics['intro']:setLooping(true)
        musics['intro']:setVolume(1)
        musics['intro']:play()
    else
        musics['intro']:stop()
    end

    if gameState == 'play' or gameState == 'quit_box' or gameState == 'wave_start' then
        musics['level'..tostring(level)]:setLooping(true)
        musics['level'..tostring(level)]:setVolume(1)
        musics['level'..tostring(level)]:play()
    else
        musics['level'..tostring(level)]:stop()
    end

    if gameState == 'win' then
        musics['win']:setLooping(true)
        musics['win']:setVolume(1)
        musics['win']:play()
    else
        musics['win']:stop()
    end
    if gameState == 'lose' then
        musics['lose']:setLooping(true)
        musics['lose']:setVolume(1)
        musics['lose']:play()
    else
        musics['lose']:stop()
    end

    if gameState == 'play' or gameState == 'wave_start' then
        map:update(dt)
    end

    love.keyboard.keysPressed = {}

end

function love.draw()
    push:apply('start')

    if gameState == 'start' then
        love.graphics.clear(102/255, 166/255, 17/255, 1)--green
        love.graphics.setFont(largeFont)
        love.graphics.setColor(255/255, 150/255, 52/255, 1)--orange
        love.graphics.printf("Summervale", 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.printf("Press Enter to Continue", 0, VIRTUAL_HEIGHT - 48, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(start_logo, 32, 32)

    elseif gameState == 'choose_hero' then
        love.graphics.clear(102/255, 166/255, 17/255, 1)--green
        love.graphics.setFont(largeFont)
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.printf("Choose Your Hero", 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Continue", 0, VIRTUAL_HEIGHT - 156, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Q To Go To Instructions", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press C To Go To Credits", 0, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH, 'center')

        love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
        love.graphics.printf("Elf Priest", 0, 484, VIRTUAL_WIDTH - 478, 'center')
        
        love.graphics.printf("Elf Ranger", 0, 484, VIRTUAL_WIDTH + 570, 'center')

        if playerChoice == 'A' then
            love.graphics.rectangle('line', 320, 170, 256, 300)
        elseif playerChoice == 'B' then
            love.graphics.rectangle('line', 840, 170, 256, 300)
        end

        love.graphics.setColor(1,1,1,1)

        love.graphics.draw(icon_heroA, 256, 84)
        love.graphics.draw(icon_heroB, 768, 84)

    elseif gameState == 'menu_diff' then
        love.graphics.clear(102/255, 166/255, 17/255, 1)--green
        love.graphics.setFont(largeFont)
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.printf("Choose Difficulty", 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter To Continue", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Esc to Go back", 0, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH, 'center')
        if Difficulty == 'easy' then
            love.graphics.printf("Hard Mode", 0, 312, VIRTUAL_WIDTH, 'center')
            love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
            love.graphics.printf("Easy Mode", 0, 256, VIRTUAL_WIDTH, 'center')
        else
            love.graphics.printf("Easy Mode", 0, 256, VIRTUAL_WIDTH, 'center')
            love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
            love.graphics.printf("Hard Mode", 0, 312, VIRTUAL_WIDTH, 'center')
        end
        love.graphics.setColor(1,1,1,1)

    elseif gameState == 'instructions' then
        love.graphics.clear(102/255, 166/255, 17/255, 1)--green
        love.graphics.setFont(largeFont)
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.printf("Instructions", 0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(textFont)
        --the instructions--
        love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
        love.graphics.printf("Protect Summervale. Don't Let the monsters pass", 0, 180, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("The Forest Trolls: Killshot - 1", 0, 256, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("The Mountain Golems: Killshot - 2", 0, 288, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("The White Walkers: Killshot - 3", 0, 320, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Use Up and Down Arrow keys to move the hero", 0, 432, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press space bar to shoot", 0, 464, VIRTUAL_WIDTH, 'center')

        
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.printf("Press Esc to go back", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1,1,1,1)

    elseif gameState == 'credits' then
        love.graphics.clear(102/255, 166/255, 17/255, 1)--green
        love.graphics.setFont(largeFont)
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.printf("Credits", 0, 16, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(textFont)
        love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
        love.graphics.printf("Musics", 0, 108, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("'Our Mountain_v003'", 0, 152, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("'INTO BATTLE'", 0, 184, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("'TOWER DEFENSE'", 0, 216, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("'Fantasy Forest Battle'", 0, 244, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("'RPG Battle Climax'", 0, 276, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("By Eric Matyas, www.soundimage.org", 0, 308, VIRTUAL_WIDTH, 'center')

        love.graphics.printf("'eerie despair'", 0, 372, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("By ClawVO, www.freesound.org", 0, 404, VIRTUAL_WIDTH, 'center')

        love.graphics.printf("Sound Effects", 0, 472, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("www.freesound.org", 0, 516, VIRTUAL_WIDTH, 'center')
        
        love.graphics.printf("Images", 0, 584, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("www.craftpix.net", 0, 628, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("www.opengameart.org", 0, 660, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("www.dafont.com", 0, 692, VIRTUAL_WIDTH, 'center')
        
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.printf("Press Esc to go back", 0, VIRTUAL_HEIGHT - 36, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1,1,1,1)

    elseif gameState == 'play' then        
        map:render()

    elseif gameState == 'level_start' then
        map:render()
        if level == 1 then
           love.graphics.setColor(127/255, 52/255, 5/255, 1)--brown
        elseif level == 2 then
            love.graphics.setColor(96/255, 70/255, 46/255, 1)--rockish
        elseif level == 3 then
            love.graphics.setColor(4/255, 92/255, 175/255, 1)--blue
        end
        love.graphics.setFont(largeFont)
        love.graphics.printf("Level "..tostring(level), 0, 128, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(subtitleFont)
        love.graphics.print(tagline, 404, 192)
        
        love.graphics.setColor(224/255, 217/255, 16/255, 1)--yellow
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Continue", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Esc to Quit", 0, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1,1,1,1)

    elseif gameState == 'wave_start' then
        map:render()
        love.graphics.setFont(largeFont)
        love.graphics.setColor(.9,0,0,1) -- red
        if wave_count == 2 then
            love.graphics.printf("Second Wave", 0, 256, VIRTUAL_WIDTH, 'center')
        elseif wave_count == 3 then
            love.graphics.printf("Final Wave", 0, 256, VIRTUAL_WIDTH, 'center')
        end


    elseif gameState == 'quit_box' then
        map:render()
        love.graphics.setColor(224/255, 217/255, 16/255, 1) --yellow
        love.graphics.rectangle('fill', 428, 192, 512, 256)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
        love.graphics.rectangle('line', 428, 192, 512, 256)
        love.graphics.printf("Do you want to quit?", 0, 212, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Yes: Press Y / Esc", 0, 300, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("No: Press N", 0, 364, VIRTUAL_WIDTH, 'center')


    elseif gameState == 'win' then
        love.graphics.clear(54/255, 176/255, 135/255, 1)--cyan
        --win logo--
        if playerChoice == 'B' then
            love.graphics.draw(win_logo, 32, 58)
        elseif playerChoice == 'A' then
            love.graphics.draw(win_logo_priest, 32, 58)
        end
        love.graphics.setFont(largeFont)
        love.graphics.setColor(44/255, 26/255, 116/255, 1) -- dark purple
        love.graphics.printf("The Hero is Victorious", 0, 44, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Play Again", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Esc to Exit", 0, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1,1,1,1)
        

    elseif gameState == 'lose' then
        love.graphics.clear(44/255, 26/255, 116/255, 1) -- dark purple
        love.graphics.draw(lose_logo, 32, 74)
        love.graphics.setFont(largeFont)
        love.graphics.setColor(92/255, 87/255, 112/255, 1) --light gray
        love.graphics.printf("The Hero has fallen", 0, 44, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Play Again", 0, VIRTUAL_HEIGHT - 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Esc to Exit", 0, VIRTUAL_HEIGHT - 44, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1,1,1,1)
    end

    
    
    FPS = love.timer.getFPS()
    

    push:apply('end')
end
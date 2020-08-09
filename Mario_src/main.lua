--declare screen size
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--virtual
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--day night variable
day = false
night = false
--initial game state
gameState = 'start'

--level counter
level_count = 1

--initial time and time counter
init_time = 100
time_left = 0
--time remaining after every level
time_saved = 0


--link the push and class file (class file for OOP)
push = require 'push'
Class = require 'class'

Timer = require 'Timer'

--link the classes for objects
require 'Map'


function love.load()
    --random seed generator, to give a different terrain everytime
    math.randomseed(os.time())

    --set select sound
    select_sound = love.audio.newSource('sounds/select.wav', 'static')
    --set music
    music = love.audio.newSource('sounds/music.mp3', 'static')

    --set font
    textfont = love.graphics.newFont('font.TTF', 16)
    largefont = love.graphics.newFont('font.TTF', 24)
    titlefont = love.graphics.newFont('font.TTF', 32)
    --initialize map and player
    timer = Timer()
    map = Map()

    --to account for love's default filtering and shows pixels crisp
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --give title
    love.window.setTitle('Alien Mario')
    --set the screen dimensions and other actions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    --create a table to store all the keys that were pressed during this app
    love.keyboard.keysPressed = {}
    --display timer
    timer:every(1, function() time_left = time_left - 1 end, 20000)
    --adjust looping, volume and play
    music:setLooping(true)
    music:setVolume(0.25)
    music:play()
end

--resize screen
function love.resize(w, h)
    push:resize(w, h)
end

--action when a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        if gameState == 'start' or gameState == 'gameover' then
            love.event.quit()
        elseif gameState == 'instructions' then
            gameState = 'start'
        else
            level_count = 1
            coin_count = 0
            map:reset()
            gameState = 'start'
        end
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'level_start'
            select_sound:play()

        elseif gameState == 'level_start' then
            if level_count == 1 then
                coin_count = 0
                time_saved = 0
                init_time = 100
            end
            gameState = 'play'
            if 100 - (level_count - 1) * 15 <= 10 then
                init_time = 20
            else
                init_time = 100 - (level_count - 1) * 15
            end
            time_left = init_time + time_saved
            if time_left < 50  and init_time <= 30 then
                time_left = 50
            end

        elseif gameState == 'win' then
            level_count = level_count + 1
            map:reset()
            gameState = 'level_start'
            select_sound:play()

        elseif gameState == 'gameover' then
            level_count = 1
            coin_count = 0
            map:reset()
            gameState = 'start'
            music:play()
        end

    elseif key == 'i' or key == 'I' then
        if gameState == 'start' then
            gameState = 'instructions'
            select_sound:play()
        end
    end

    --store the pressed keys in the table
    love.keyboard.keysPressed[key] = true
end

--write the custom keys pressed function
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    --give the map update function the dt parameter
    timer:update(dt)
    map:update(dt)

    --clear the keys pressed table after every open-close app
    love.keyboard.keysPressed = {}

end

function love.draw()
    --call push before starting drawing
    push:apply('start')

    --call function to show the movement
    --if camera moves to the right(+ve), then it will give the illusion of going to the left(-ve) and vice-versa
    --turn the co-ordinates into ints for smooth transition
    love.graphics.translate(-map.camX, -map.camY)

    --account for different gameStates
    if gameState == 'start' then
        love.graphics.clear(43 / 255, 74 / 255, 53 / 255, 1) -- dark green
        love.graphics.setFont(titlefont)
        love.graphics.setColor(25/255, 230/255, 73/255, 1) -- light greenish
        love.graphics.printf("Alien Mario", map.camX, map.camY + 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(textfont)
        love.graphics.setColor(25/255, 230/255, 128/255, 1)--light greenish/cyan
        love.graphics.printf("Press Enter to Advance", map.camX, map.camY + 60, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press I for Instructions", map.camX, map.camY + 180, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)--default
        love.graphics.printf("Press Esc to Exit", map.camX, map.camY + 200, VIRTUAL_WIDTH, 'center')
    
    elseif gameState == 'level_start' then
        love.graphics.clear(43 / 255, 74 / 255, 53 / 255, 1) -- dark green
        love.graphics.setFont(largefont)
        love.graphics.setColor(25/255, 230/255, 73/255, 1) -- light greenish
        love.graphics.printf("Level " ..tostring(level_count), map.camX, map.camY + 35, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(textfont)
        love.graphics.setColor(25/255, 230/255, 128/255, 1)--light greenish/cyan
        love.graphics.printf("Press Enter to Advance", map.camX, map.camY + 60, VIRTUAL_WIDTH, 'center')
        
        love.graphics.setColor(1, 1, 1, 1)--default
        love.graphics.printf("Press Esc to Quit", map.camX, map.camY + 200, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'play' then
        --set background color
        if night then
            love.graphics.clear(188 / 255, 20 / 255, 1, 1) -- purple
            love.graphics.setColor(49 / 255, 25 / 255, 230 / 255,1) -- blue
            love.graphics.printf("Mars: Night", map.camX, map.camY + 5, VIRTUAL_WIDTH, 'center')
        elseif day then
            love.graphics.clear(230/255, 73/255, 0/255, 1) -- orange
            love.graphics.printf("Mars: Day", map.camX, map.camY + 5, VIRTUAL_WIDTH, 'center')
        end

        love.graphics.setColor(1,1,1,1) -- default
        map:render()
        --display timer
        love.graphics.print("Time: " ..tostring(time_left), map.camX + VIRTUAL_WIDTH - 80, map.camY + 2)
        if time_left == 0 then
            gameState = 'gameover'
        end

    elseif gameState == 'gameover' then
        
        love.graphics.setFont(largefont)
        love.graphics.setColor(1,0,0, 1) -- red
        love.graphics.printf("Game Over", map.camX, map.camY + 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(textfont)

        love.graphics.printf("Coins: " ..tostring(coin_count), map.camX, map.camY + 60, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Restart", map.camX, map.camY + 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Esc to Exit", map.camX, map.camY + 200, VIRTUAL_WIDTH, 'center')
        
        --stop music
        music:stop()
        love.graphics.setColor(1,1,1,1) -- default

    elseif gameState == 'win' then
        map:render()
        love.graphics.setFont(largefont)
        love.graphics.setColor(1,0,0, 1) -- red
        love.graphics.printf("Level " ..tostring(level_count).." Complete", map.camX, map.camY + 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(textfont)
        love.graphics.printf("Press Enter to Advance", map.camX, map.camY + 60, VIRTUAL_WIDTH, 'center')

        love.graphics.setColor(1,1,1,1) -- default

    elseif gameState == 'instructions' then
        love.graphics.clear(43 / 255, 74 / 255, 53 / 255, 1) -- dark green
        
        love.graphics.setColor(25/255, 230/255, 73/255, 1) -- light green
        love.graphics.setFont(largefont)
        love.graphics.printf("Instructions", map.camX, map.camY + 25, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(textfont)
        love.graphics.printf("1. REACH THE FLAG BEFORE TIMER RUNS OUT", map.camX, map.camY + 60, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("2. COLLECT COINS BY HITTING YELLOW BLOCKS", map.camX, map.camY + 80, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("WITH THE HEAD", map.camX, map.camY + 100, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("3. DON'T FALL INTO THE PITS", map.camX, map.camY + 120, VIRTUAL_WIDTH, 'center')

        
        love.graphics.setColor(25/255, 230/255, 128/255, 1)--light greenish/cyan
        love.graphics.printf("Controls", map.camX, map.camY + 150, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Movements: Arrow keys", map.camX, map.camY + 170, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Jump: Space Bar", map.camX, map.camY + 190, VIRTUAL_WIDTH, 'center')

        love.graphics.setColor(1, 1, 1, 1) -- default
        love.graphics.printf("Press Esc to Go back", map.camX, map.camY + 220, VIRTUAL_WIDTH, 'center')
    end

    push:apply('end')
end
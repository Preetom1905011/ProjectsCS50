--[[This is Pong
    authored by Preetom Kumar Biswas
    Preetom1905011
    CS50 2020
]]

--the size of game window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- the res of the drawings(to give retro look)
VIRTUAL_WIDTH = 432 
VIRTUAL_HEIGHT = 243

--winning point & player
WINPOINT = 10
winningplayer = 0

-- the speed of paddle in pixel/s
PADDLE_SPEED = 200
--computer's reaction time (sort of)
react_time = 0

--link the push file $ class file
Class = require 'class'
push = require 'push'

--link the classes for paddle and ball
require 'Paddle'
require 'Ball'

--initial load, when game is opened, executes only once
function love.load()
    --default num in random function
    math.randomseed(os.time()) -- os.time() generates a random num

    love.graphics.setDefaultFilter('nearest', 'nearest') --disabling love's default filtering
    
    --create font objects(path, size in pixel)
    smallfont = love.graphics.newFont('font.TTF', 8)
    scorefont = love.graphics.newFont('font.TTF', 32)
    victoryfont = love.graphics.newFont('font.TTF', 24)

    --set title of the application
    love.window.setTitle('Pong')

    --make a table for sound effects
    -- key = function(path, type) //types can be stream or static
    sounds = {
        ['paddle_hit'] = love.audio.newSource('Sounds/paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('Sounds/wall_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('Sounds/point_scored.wav', 'static'),
        ['key_right'] = love.audio.newSource('Sounds/key_right.wav', 'static')
    }

    --set window visuals
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        vsync = true,
        resizable = true
    })

    --initialize players' scores
    player1score = 0
    player2score = 0

    --initialize player serve mode
    servingPlayer = math.random(2) == 1 and 1 or 2

    --construct paddles
    player1 = Paddle(5, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40, 5, 20)

    --construct ball
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    --initialize ball direction based on serving player
    if servingPlayer == 1 then
        ball.dx = 200
    elseif servingPlayer == 2 then
        ball.dx = -200
    end
    
    --initialize game state (can change into start, play, win etc.)
    gameState = 'start'

end

--to resize but not distort the aspecct ratio(thanks to push.lua)
function love.resize(width, height)
    push:resize(width, height)
end

--what happens when the game is running
--this function can run at a diff speed than the whole game
function love.update(dt) -- dt is time diff

    --call paddle's update function
    player1:update(dt)
    player2:update(dt)

    --update scores and reset ball
    if ball.x <= 0 then
        player2score = player2score + 1
        ball:reset()
        servingPlayer = 1
        ball.dx = 200
        
        sounds['point_scored']:play()

        if player2score >= WINPOINT then
            gameState = 'victory'
            winningplayer = 2
        else
            gameState = 'serve'
        end

    elseif ball.x >= VIRTUAL_WIDTH - ball.width then
        player1score = player1score + 1
        ball:reset()
        servingPlayer = 2
        ball.dx = -200
        
        sounds['point_scored']:play()

        if player1score >= WINPOINT then
            gameState = 'victory'
            winningplayer = 1
        else
            gameState = 'serve'
        end
    end
    --check for and react to collision with paddle
    if ball:collides(player1) then
        --deflect right
        ball.dx = -ball.dx * 1.03
        ball.x = player1.x + ball.width + 1

        sounds['paddle_hit']:play()

        --keep velocity in the same direction, but randomize it
        if ball.dy < 0 then
            ball.dy = -math.random(60, 150)
        else
            ball.dy = math.random(60, 150)
        end

    elseif ball:collides(player2) then
        --deflect left
        ball.dx = -ball.dx * 1.03
        ball.x = player2.x - ball.width
        
        sounds['paddle_hit']:play()

        --keep velocity in the same direction, but randomize it
        if ball.dy < 0 then
            ball.dy = -math.random(60, 150)
        else
            ball.dy = math.random(60, 150)
        end
    end

    --check for and react to collision with top and bottm screen
    if ball.y <= 0 then
        --deflect downwards
        ball.dy = -ball.dy
        ball.y = 0

        sounds['wall_hit']:play()

    elseif ball.y >= VIRTUAL_HEIGHT - ball.height then
        --deflect upwards
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - ball.height

        sounds['wall_hit']:play()
    end
    --declaring reaction time based on diffculty mode
    if difficulty == 'easy' then
        react_time = 0
    elseif difficulty == 'medium' then
        react_time = -20
    elseif difficulty == 'hard' then
        react_time = -40
    end

    --player1 (left) commands (computer)
    if gameMode == 'double' then
        --player1 (left) commands
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else 
            player1.dy = 0
        end

    elseif gameMode == 'single' then
        --computer commands
        if ball.dx < 0 then
            --when paddle is below the ball and ball goes up
            if player1.y < ball.y and ball.dy < 0 then
                player1.dy = math.min(-ball.dy - react_time, PADDLE_SPEED) -- paddle dy (+ve) and can't exceed paddle speed
            --when paddle is above the ball(Y axis) and ball speed is positive
                if ball.dy >= -50 then
                    --default paddle speed
                    player1.dy = (love.timer.getFPS() + 30 - react_time )
                end
            --when paddle is above the ball and ball goes down
            elseif player1.y > ball.y and ball.dy > 0 then
                player1.dy = math.max(-ball.dy + react_time, -PADDLE_SPEED) -- paddle dy (-ve) and can't exceed paddle speed
                if ball.dy <= 50 then
                    --default paddle speed
                    player1.dy = -(love.timer.getFPS() + 30 - react_time )
                end
            else
                --paddle speed and ball speed in the same direction
                if ball.dy > 0 then
                    player1.dy = math.min(ball.dy - react_time, PADDLE_SPEED) -- paddle dy (+ve)
                    if ball.dy <= 50 then
                         --default paddle speed
                        player1.dy = (love.timer.getFPS() + 30 - react_time )
                    end
                else
                    player1.dy = math.max(ball.dy + react_time, -PADDLE_SPEED) -- paddle dy (-ve)
                    if ball.dy >= -50 then
                         --default paddle speed
                        player1.dy = -(love.timer.getFPS() + 30 - react_time )
                    end
                end
            end
            
            --when ball is inside the paddle (sort of)
            if ball.y > player1.y and ball.y < player1.y + player1.width then
                --paddle stops
                player1.dy = 0
            end
        end
    end


    --player2 (right) commands
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    --when game is played
    if gameState == 'play' then
        --call ball's update function
        ball:update(dt)
    end

end

--what happens when some key is pressed
function love.keypressed(key)
    if key == 'escape' then --quit game when pressed 'Esc'
        if gameState == 'start' or gameState == 'end' or gameState == 'victory' then
            love.event.quit()
        elseif gameState == 'menu_players' then
            gameState = 'start'
        elseif gameState == 'menu_diff' then
            gameState = 'menu_players'
        elseif gameState == 'play' or gameState == 'serve' then
            gameState = 'end'
            player1score = 0
            player2score = 0
            ball:reset()
            servingPlayer = 2
            ball.dx = -200
        end
        sounds['key_right']:play()

    elseif key == 'enter' or key == 'return' then -- start or stop game when pressed enter
        if gameState == 'start' then
            gameState = 'menu_players'
            sounds['key_right']:play()
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    
    elseif key == '1' then
        if gameState == 'menu_players' then
            gameMode = 'single'
            gameState = 'menu_diff'
            sounds['key_right']:play()
        end
    elseif key == '2' then
        if gameState == 'menu_players' then
            gameMode = 'double'
            gameState = 'serve'
            sounds['key_right']:play()
        end
        
    elseif key == 'e' or key == 'E'then
        if gameState == 'menu_diff' then
            difficulty = 'easy'
            gameState = 'serve'
            sounds['key_right']:play()
        end
    elseif key == 'm' or key == 'M' then
        sounds['key_right']:play()

        if gameState == 'menu_diff' then
            difficulty = 'medium'
            gameState = 'serve'
        elseif gameState == 'victory' or gameState == 'end' then
            gameState = 'menu_players'
            player1score = 0
            player2score = 0
        
        end
    elseif key == 'h' or key == 'H' then
        if gameState == 'menu_diff' then
            difficulty = 'hard'
            gameState = 'serve'
            sounds['key_right']:play()
        end
    elseif key == 'r' or key == 'R' then
        if gameState == 'victory' or gameState == 'end' then
            gameState = 'serve'
            player1score = 0
            player2score = 0
            
            sounds['key_right']:play()
        end
    end
end

--the display function
function love.draw()
    push:apply('start') -- these commands will be done with push's instructions
    
    --draw background before everything else will cover all afterwards
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255) -- rgba values but love treats them as fractions from 0-1

    --apply small font for title
    love.graphics.setFont(smallfont)

    --change visual instructions based on game state
    if gameState == 'start' then
        love.graphics.printf(
            "Welcome To Pong!", -- text that's displayed
            0, -- x co-ordinate, since centering based on width
            20, -- y co-ordinate
            VIRTUAL_WIDTH, -- which line do you want align on
            'center' -- how do you want to align on that line
        )
        love.graphics.printf("Press Enter To Play", 0, 32, VIRTUAL_WIDTH, 'center')

        love.graphics.printf("Score " .. tostring(WINPOINT) .. " points to win", 0, 2 * VIRTUAL_HEIGHT / 3 , VIRTUAL_WIDTH, 'center')
        
        love.graphics.printf("Press Esc to Exit Game", 0, 3 * VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
        
    elseif gameState == 'menu_players' then
        love.graphics.printf("Press 1 for single player", 0 , 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press 2 for double players", 0, 32, VIRTUAL_WIDTH, 'center')

        love.graphics.printf("1 Player", 0, VIRTUAL_HEIGHT / 3 - 20, VIRTUAL_WIDTH - 80, 'center')
        love.graphics.printf("2 Players", 0, VIRTUAL_HEIGHT / 3 - 20, VIRTUAL_WIDTH + 90, 'center')

        love.graphics.printf("Press Esc to Go Back", 0, 3 * VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'menu_diff' then
        love.graphics.printf("Easy Mode : Press E", 0 , 32, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Medium Mode : Press M", 0, 48, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Hard Mode : Press H", 0, 64, VIRTUAL_WIDTH, 'center')
        
        love.graphics.printf("Press Esc to Go Back", 0, 3 * VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then
        if gameMode == 'double' then
            love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s Turn", 0, 20, VIRTUAL_WIDTH, 'center')
            
            love.graphics.printf("Player 1", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH - 80, 'center')
            love.graphics.printf("Player 2", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH + 90, 'center')

        elseif gameMode == 'single' then
            if servingPlayer == 2 then
                love.graphics.printf("Your Turn", 0, 20, VIRTUAL_WIDTH, 'center')
            else
                love.graphics.printf("Computer's Turn", 0, 20, VIRTUAL_WIDTH, 'center')
            end
            love.graphics.printf("Computer", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH - 80, 'center')
            love.graphics.printf("You", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH + 90, 'center')
        end

        love.graphics.printf("Press Enter To Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
        
        love.graphics.printf("Press Esc to Quit Game", 0, 3 * VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
    
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryfont)
        
        if gameMode == 'double' then
            love.graphics.printf("Player ".. tostring(winningplayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallfont)
            love.graphics.printf("Player 1", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH - 80, 'center')
            love.graphics.printf("Player 2", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH + 90, 'center')

        elseif gameMode == 'single' then
            if winningplayer == 1 then
                love.graphics.printf("Computer wins!", 0, 10, VIRTUAL_WIDTH, 'center')
            else
                love.graphics.printf("You win!", 0, 10, VIRTUAL_WIDTH, 'center')
            end

            love.graphics.setFont(smallfont)
            love.graphics.printf("Computer", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH - 80, 'center')
            love.graphics.printf("You", 0, VIRTUAL_HEIGHT / 3 + 40, VIRTUAL_WIDTH + 90, 'center')
        end
    end  
    
    if gameState == 'victory' or gameState == 'end' then
        
        love.graphics.printf("Restart: Press R", 0, 42, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Main Menu: Press M", 0, 54, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Esc to Exit Game", 0, 3 * VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'start'or gameState == 'serve' or gameState == 'victory' then
        --apply large font for scores
        love.graphics.setFont(scorefont)

        love.graphics.print(player1score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(player2score, VIRTUAL_WIDTH / 2 + 35, VIRTUAL_HEIGHT / 3)
    end

    --call the render ball function
    ball:render()
    --call the render paddle function
    player1:render()
    player2:render()
    
    --call function to see FPS
    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1) -- set font color
    love.graphics.setFont(smallfont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 10) -- two strings are add by .. notation in Lua
    --set all the following color to white again
    love.graphics.setColor(1, 1, 1, 1)
end

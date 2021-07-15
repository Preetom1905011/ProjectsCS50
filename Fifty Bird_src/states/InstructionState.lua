InstructionState = Class{__includes = BaseState}

function InstructionState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        sounds['click']:play()
        gStateMachine:change('countdown')
    end
end

function InstructionState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.setColor(228/255, 17/255, 91/255, 1)--magenta
    love.graphics.printf("INSTRUCTIONS", 0, 18, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.setColor(1, 1, 1, 1)--white
    love.graphics.printf("CLICK ON SPACE OR MOUSE (LEFT) TO FLAP", 0, 64, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("DON'T HIT THE PIPES OR THE GROUND", 0, 80, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("PRESS P TO PAUSE", 0, 120, VIRTUAL_WIDTH, 'center')
    
    love.graphics.printf("10 POINTS - BRONZE MEDAL", 0, 160, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("20 POINTS - SILVER MEDAL", 0, 176, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("30 POINTS - GOLD MEDAL", 0, 192, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(228/255, 165/255, 17/255, 1)--yellowish/chrome
    love.graphics.printf("PRESS ENTER TO CONTINUE", 0, VIRTUAL_HEIGHT - 40, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)--white
end


TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        sounds['click']:play()
        gStateMachine:change('instruction')
    end
end

function TitleScreenState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.setColor(228/255, 17/255, 91/255, 1)--magenta
    love.graphics.printf('FIFTY BIRD', 0, 64, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(228/255, 165/255, 17/255, 1)--yellowish/chrome
    love.graphics.setFont(mediumFont)
    love.graphics.printf('PRESS ENTER TO PLAY', 0, 100, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)--white
end
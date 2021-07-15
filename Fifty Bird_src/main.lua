WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

push = require 'push'
Class = require 'class'

require 'Bird'
require 'Pipe'
require 'PipePairs'

--all state machines
require 'StateMachine'
require 'states/BaseState'
require 'states/TitleScreenState'
require 'states/ScoreState'
require 'states/CountdownState'
require 'states/InstructionState'
require 'states/PlayState'

local background = love.graphics.newImage("graphics/background.png")
local ground = love.graphics.newImage("graphics/ground.png")

local background_scroll = 0
local ground_scroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413
local GROUND_LOOPING_POINT = 514

gPaused = false

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Fifty Bird")

    mediumFont = love.graphics.newFont('font.ttf', 14)
    scoreFont = love.graphics.newFont('font.ttf', 18)
    flappyFont = love.graphics.newFont('font.ttf', 28)
    hugeFont = love.graphics.newFont('font.ttf', 56)

    love.graphics.setFont(flappyFont)

    sounds = {
        ['jump'] = love.audio.newSource('sounds/Jump.wav', 'static'),
        ['die'] = love.audio.newSource('sounds/die.wav', 'static'),
        ['click'] = love.audio.newSource('sounds/click.wav', 'static'),
        ['point'] = love.audio.newSource('sounds/point.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/Explosion.wav', 'static'),
        -- https://freesound.org/people/xsgianni/sounds/388079/
        ['music'] = love.audio.newSource("sounds/mario's-way.mp3", 'static')
    }

    sounds['music']:setLooping(true)
    sounds['music']:play()

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end,
        ['countdown'] = function() return CountdownState() end,
        ['instruction'] = function() return InstructionState() end,
    }
    gStateMachine:change('title')

    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
end

function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)
    if not gPaused then
        background_scroll = (background_scroll + BACKGROUND_SCROLL_SPEED * dt)
                    % BACKGROUND_LOOPING_POINT
        ground_scroll = (ground_scroll + GROUND_SCROLL_SPEED * dt)
                    % GROUND_LOOPING_POINT
    end
    gStateMachine:update(dt)

    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.draw()
    push:apply('start')
    
    --love.graphics.setColor(0, 0.8, 0.5, 1)
    love.graphics.draw(background, -background_scroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -ground_scroll, VIRTUAL_HEIGHT - 16)

    push:apply('end')

end
Animation = Class{}

function Animation:init(params)         --params means parameters
    self.texture = params.texture
    -- a table for frames
    self.frames = params.frames

    --the amount of time between frame changes
    self.interval = params.interval or 0.05     --default 0.05 if not params.interval
    self.timer = 0
    self.currentFrame = 1

end

--just returns at what frame the avatar is in
function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end

--restart the timer for the next stage/transition
function Animation:restart()
    self.timer = 0
    self.currentFrame = 1
end

function Animation:update(dt)
    --basically start the timer
    self.timer = self.timer + dt

    --transition between frames
    -- #table means the length of the table
    if #self.frames == 1 then
        --since only one frame, no transition
        return self.currentFrame

    else
        --check if time is greater than interval
        while self.timer > self.interval do
            self.timer = self.timer - self.interval

            --set current frame and make it loop with modulus operator
            self.currentFrame = (self.currentFrame + 1) % (#self.frames + 1)

            --lua is 1 indexed so if 0, change it 1
            if self.currentFrame == 0 then
                self.currentFrame = 1
            end
        end
    end

end
PipePairs = Class{}

GAP_HEIGHT = 90

function PipePairs:init(y)
    self.x = VIRTUAL_WIDTH + 32
    self.y = y
    self.gapHeight = math.random(GAP_HEIGHT - 10, GAP_HEIGHT + 10)

    --for top pipe, need to flip it
    --for bottom pipe, need to start lower
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + self.gapHeight + PIPE_HEIGHT)
    }

    --whether this pipe pair is ready to be removed or not
    self.remove = false
    --whether a pair of pipes has been passed/scored
    self.scored = false
end

function PipePairs:update(dt)
    --if pipe passes left screen, set remove bool to true
    --else, move pipe from right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['upper'].x = self.x
        self.pipes['lower'].x = self.x
    else
        self.remove = true
    end
end

function PipePairs:render()
    for k, pipe in pairs(self.pipes) do
        pipe:render()
    end
end
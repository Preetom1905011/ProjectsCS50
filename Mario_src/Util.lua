--to chop up quads from a spritesheet and index the chopped parts so that can be used separately

--generateQuads takes as arguments the spritesheet(atlas), and the individual chopped tiles width and height
function generateQuads(atlas, tilewidth, tileheight)

    --the number of tiles in a row = the sprite width divided by the tile's width
    local sheetWidth = atlas:getWidth() / tilewidth
    --the number of tiles in a column = the sprite height divided by the tile's height
    local sheetHeight = atlas:getHeight() / tileheight

    --to count the sheets or quads (from left to right, top to bottom)
    local sheetCounter = 1
    --create a table that acts like an array for storing the chopped quads
    local quads = {}

    --a nested loop for chopping
    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            -- the chopper funtion newQuad(x, y, tile width, tile height, spritewidth, spriteheight)
            -- x, y denotes the co=ordinates of the top left point of the sheet/quad
            quads[sheetCounter] = 
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth, tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return quads
end
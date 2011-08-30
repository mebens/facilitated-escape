-- Module to handle and generate the blocks, both foreground and middle ground.

local xTiles = math.floor(width / tileSize)
blocks = {}

blocks.front = {
  count = 0,
  lastGen = 0,
  step = height,
  maxWidth = 6,
  buffers = { count = 0 }
}

blocks.middle = {
  count = 0,
  lastGen = 0,
  step = height / 1.5,
  maxSize = 6,
  cameraScale = 0.4,
  buffers = { count = 0 }
}

-- maxWidth, maxHeight, and maxSize are specified in tiles
blocks.front.maxHeight = math.floor(blocks.front.step / 1.2 / tileSize)
blocks.middle.maxHeight = math.floor(blocks.middle.step / 1.15 / tileSize)

for i = 1, 9 do
  list.add(blocks.front.buffers, { love.graphics.newSpriteBatch(tiles, blocks.front.maxWidth * blocks.front.maxHeight * 3) })
  list.add(blocks.middle.buffers, { love.graphics.newSpriteBatch(tiles, blocks.middle.maxSize ^ 2 * 3) })
end

function blocks.update(dt)
  if math.abs(camera.y - blocks.front.lastGen) >= blocks.front.step then
    blocks.front.generate()
  end
  
  if math.abs(camera.y * blocks.middle.cameraScale - blocks.middle.lastGen) >= blocks.middle.step then
    blocks.middle.generate()
  end
  
  for v in list.each(blocks.front) do v:update(dt) end
  for v in list.each(blocks.middle) do v:update(dt) end
end

function blocks.reset()
  for v in list.each(blocks.front.buffers) do v[1]:clear() end
  for v in list.each(blocks.middle.buffers) do v[1]:clear() end
  list.clear(blocks.front)
  list.clear(blocks.middle)
  blocks.front.generate()
  blocks.middle.generate()
  
  if state == "game" then
    blocks.front.add(Block:new(blocks.front.buffers.last, -tileSize, ship.y + ship.height, width + tileSize, 50, false))
  end
end

function blocks.front.draw()
  for v in list.each(blocks.front) do v:draw() end
end

function blocks.front.generate()
  local baseY = camera.y - blocks.front.step
  local xOffset = math.random(-20, 20)
  local x = 0
  
  while x < xTiles do
    if xTiles - x < 2 then break end
    
    if math.random(1, 2) == 1 then
      local width = math.min(math.random(2, 6), xTiles - x)
      local height = math.random(2, blocks.front.maxHeight) * tileSize
      local y = baseY + math.random(0, blocks.front.maxHeight * tileSize - height)
      blocks.front.add(Block:new(blocks.front.buffers.last, x * tileSize + xOffset, y, width * tileSize, height))
      x = x + width + 3
    else
      x = x + 1
    end
  end
  
  blocks.front.lastGen = camera.y
end

function blocks.front.add(block)
  list.add(blocks.front, block)
  block.list = blocks.front
  list.remove(blocks.front.buffers, block.image)
  list.unshift(blocks.front.buffers, block.image)
end

function blocks.front.remove(block)
  list.remove(blocks.front, block)
  block.list = nil
  list.remove(blocks.front.buffers, block.image)
  list.add(blocks.front.buffers, block.image)
  block.image[1]:clear()
end

function blocks.middle.draw()
  for v in list.each(blocks.middle) do v:draw() end
end

function blocks.middle.generate()
  local baseY = camera.y * blocks.middle.cameraScale - blocks.middle.step
  local xOffset = math.random(-20, 20)
  local x = 0

  while x < xTiles do
    if xTiles - x < 3 then break end
    
    if math.random(1, 3) == 1 then
      local size = math.min(math.random(3, 6), xTiles - x)
      local y = baseY + math.random(0, blocks.middle.maxHeight - size) * tileSize
      blocks.middle.add(MidBlock:new(blocks.middle.buffers.last, x * tileSize + xOffset, y, size * tileSize))
      x = x + size + 3
    else
      x = x + 1
    end
  end
  
  blocks.middle.lastGen = camera.y * blocks.middle.cameraScale
end

function blocks.middle.add(block)
  list.add(blocks.middle, block)
  block.list = blocks.middle
  list.remove(blocks.middle.buffers, block.image)
  list.unshift(blocks.middle.buffers, block.image)
end

function blocks.middle.remove(block)
  list.remove(blocks.middle, block)
  block.list = nil
  list.remove(blocks.middle.buffers, block.image)
  list.add(blocks.middle.buffers, block.image)
  block.image[1]:clear()
end

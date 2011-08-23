-- Module to handle and generate the blocks, both foreground and middle ground.

local generateStep = height
local xTiles = math.floor(width / tileSize)

blocks = {}
blocks.front = { count = 0, lastGenerate = 0 }
blocks.middle = { count = 0, lastGenerate = 0, cameraScale = 0.4 }

function blocks.update(dt)
  if math.abs(camera.y - blocks.front.lastGenerate) >= generateStep then
    blocks.front.generate()
  end
  
  if math.abs(camera.y * blocks.middle.cameraScale - blocks.middle.lastGenerate) >= generateStep then
    blocks.middle.generate()
  end
  
  for v in list.each(blocks.front) do v:update(dt) end
  for v in list.each(blocks.middle) do v:update(dt) end
end

function blocks.reset()
  list.clear(blocks.front)
  list.clear(blocks.middle)
  blocks.front.add(Block:new(-tileSize, ship.y + ship.height, width + tileSize, 200, false))
  blocks.front.generate()
  blocks.middle.generate()
end

function blocks.front.draw()
  for v in list.each(blocks.front) do v:draw() end
end

function blocks.front.generate()
  local baseY = camera.y - generateStep
  local maxHeight = math.floor(generateStep / 1.15 / tileSize)
  local xOffset = math.random(-20, 20)
  local x = 0
  
  while x < xTiles do
    if xTiles - x < 2 then break end
    
    if math.random(1, 2) == 1 then
      local width = math.min(math.random(2, 6), xTiles - x)
      local height = math.random(2, maxHeight) * tileSize
      local y = baseY + math.random(0, maxHeight * tileSize - height)
      blocks.front.add(Block:new(x * tileSize + xOffset, y, width * tileSize, height))
      x = x + width + 3
    else
      x = x + 1
    end
  end
  
  blocks.front.lastGenerate = camera.y
end

function blocks.front.add(block)
  list.add(blocks.front, block)
  block.list = blocks.front
end

function blocks.front.remove(block)
  list.remove(blocks.front, block)
  block.list = nil
end

function blocks.middle.draw()
  for v in list.each(blocks.middle) do v:draw() end
end

function blocks.middle.generate()
  local baseY = camera.y * blocks.middle.cameraScale - generateStep
  local maxHeight = math.floor(generateStep / 1.15)
  local xOffset = math.random(-20, 20)
  local x = 0
  
  while x < xTiles do
    if xTiles - x < 3 then break end
    
    if math.random(1, 3) == 1 then
      local size = math.min(math.random(3, 6), xTiles - x) * tileSize
      local y = baseY + math.random(0, maxHeight - size)
      blocks.middle.add(MidBlock:new(x * tileSize + xOffset, y, size))
      x = x + width + 3
    else
      x = x + 1
    end
  end
  
  blocks.middle.lastGenerate = camera.y * blocks.middle.cameraScale
end

function blocks.middle.add(block)
  list.add(blocks.middle, block)
  block.list = blocks.middle
end

function blocks.middle.remove(block)
  list.remove(blocks.middle, block)
  block.list = nil
end

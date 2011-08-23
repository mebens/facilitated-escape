-- Module to handle and generate the foreground blocks

blocks = {}
blocks.count = 0
blocks.generateStep = 600
blocks.lastGenerate = 0

function blocks.update(dt)
  if math.abs(camera.y - blocks.lastGenerate) >= blocks.generateStep then blocks.generate() end
  for v in list.each(blocks) do v:update(dt) end
end

function blocks.draw()
  for v in list.each(blocks) do v:draw() end
end

function blocks.generate()
  local baseY = camera.y - blocks.generateStep
  local xTiles = math.floor(width / tileSize)
  local maxHeight = math.floor(blocks.generateStep / 1.15 / tileSize)
  local x = 0
  
  while x < xTiles do
    if xTiles - x < 2 then break end
    
    if math.random(1, 2) == 1 then
      local width = math.min(math.random(2, 6), xTiles - x)
      local height = math.random(2, maxHeight) * tileSize
      local y = baseY + math.random(0, (maxHeight * tileSize - height))
      Block:new(x * tileSize + 5, y, width * tileSize, height)
      x = x + width + 3
    else
      x = x + 1
    end
  end
  
  blocks.lastGenerate = camera.y
end

function blocks.add(block)
  return list.add(blocks, block)
end

function blocks.remove(block)
  list.remove(blocks, block)
end

function blocks.reset()
  list.clear(blocks)
  Block:new(-tileSize, ship.y + ship.height, width + tileSize, 200, false)
  blocks.generate()
end

blocks = {}
blocks.count = 0
blocks.generateStep = 600
blocks.lastGenerate = 0

function blocks.update(dt)
  if math.abs(camera.y - blocks.lastGenerate) >= blocks.generateStep then blocks.generate() end
  local v = blocks.first
  
  while v do
    v:update(dt)
    v = v.next
  end
end

function blocks.draw()
  local v = blocks.first
  
  while v do
    v:draw()
    v = v.next
  end
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
  if not blocks.first then
    blocks.first = block
    blocks.last = block
  else
    blocks.last.next = block
    block.prev = blocks.last
    blocks.last = block
  end
  
  blocks.count = blocks.count + 1
  return block
end

function blocks.remove(block)
  if block.next then
    if block.prev then
      block.next.prev = block.prev
      block.prev.next = block.next
    else
      block.next.prev = nil
      blocks.first = block.next
    end
  elseif block.prev then
    block.prev.next = nil
    blocks.last = block.prev
  else
    blocks.first = nil
    blocks.last = nil
  end
  
  block.next = nil
  block.prev = nil
  blocks.count = blocks.count - 1
end

function blocks.reset()
  local v = blocks.first
  
  while v do
    local next = v.next
    blocks.remove(v)
    v = next
  end
  
  Block:new(-tileSize, ship.y + ship.height, width + tileSize, 200, false)
  blocks.generate()
end

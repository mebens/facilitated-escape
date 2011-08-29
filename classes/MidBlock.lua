-- Class to create, update, and draw a middle ground block

MidBlock = {}
MidBlock.__index = MidBlock

function MidBlock:new(x, y, size)
  local t = setmetatable({
    x = x,
    y = y,
    tiles = math.ceil(size / tileSize)
  }, MidBlock)
  
  t.size = t.tiles * tileSize
  t.image = newFramebuffer(t.size, t.size)
  
  t.image:renderTo(function()
    for x = 0, t.tiles - 1 do
      for y = 0, t.tiles - 1 do
        local quad = quads[17]

        if x == 0 and y == 0 then
          quad = quads[18]
        elseif x == 0 and y == t.tiles - 1 then
          quad = quads[20]
        elseif x == t.tiles - 1 and y == 0 then
          quad = quads[19]
        elseif x == t.tiles - 1 and y == t.tiles - 1 then
          quad = quads[21]
        elseif x == 0 or y == 0 or x == t.tiles - 1 or y == t.tiles - 1 then
          quad = quads[16]
        end
        
        love.graphics.drawq(tiles, quad, x * tileSize, y * tileSize, 0, 2)
      end
    end
  end)
  
  return t
end

function MidBlock:update(dt)
  if self.y > camera.y * self.list.cameraScale + height then self.list.remove(self) end
end

function MidBlock:draw()
  love.graphics.draw(self.image, self.x, self.y)
end

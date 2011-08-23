-- Class to create, draw, and update a foreground block

Block = {}
Block.__index = Block

function Block:new(x, y, width, height, collidable)
  local t = setmetatable({
    x = x,
    y = y,
    xTiles = math.ceil(width / tileSize),
    yTiles = math.ceil(height / tileSize),
    collidable = collidable
  }, Block)
  
  if collidable == nil then t.collidable = true end
  t.width = tileSize * t.xTiles
  t.height = tileSize * t.yTiles
  t.image = newFramebuffer(t.width, t.height)
  
  t.image:renderTo(function()
    -- base and corners
    for x = 0, t.xTiles - 1 do
      for y = 0, t.yTiles - 1 do
        local quad = quads[9]
        
        if x == 0 and y == 0 then
          quad = quads[10]
        elseif x == 0 and y == t.yTiles - 1 then
          quad = quads[12]
        elseif x == t.xTiles - 1 and y == 0 then
          quad = quads[11]
        elseif x == t.xTiles - 1 and y == t.yTiles - 1 then
          quad = quads[13]
        end
        
        love.graphics.drawq(tiles, quad, x * tileSize, y * tileSize, 0, 2)
      end
    end
    
    -- special tiles
    for i = 1, math.random(0, math.ceil(t.xTiles * t.yTiles / 8)) do
      local length = math.random(1, 5)
      local dir = math.random(0, 1) == 0 and "x" or "y"
      local type = math.random(1, 40)
      
      if type <= 5 then
        type = type + 3
      else
        type = math.random(1, 3)
      end
      
      if dir == "x" then
        length = math.min(length, t.xTiles)
        local xMax = t.xTiles - 1 - length
        local xPos = xMax > 0 and math.random(0, xMax) or 0
        local y = math.random(0, t.yTiles - 1)
        
        for x = xPos, xPos + length do
          if x >= t.xTiles then break end
          
          -- if not on one of the corners
          if not ((x == 0 and y == 0)
          or (x == 0 and y == t.yTiles - 1)
          or (x == t.xTiles - 1 and y == 0)
          or (x == t.xTiles - 1 and y == t.yTiles - 1)) then
            love.graphics.drawq(tiles, quads[type], x * tileSize, y * tileSize, 0, 2)
          end
        end
      else
        length = math.min(length, t.yTiles)
        local x = math.random(0, t.xTiles - 1)
        local yMax = t.yTiles - 1 - length
        local yPos = yMax > 0 and math.random(0, yMax) or 0
        
        for y = yPos, yPos + length do
          if y >= t.yTiles then break end
          
          if not ((x == 0 and y == 0)
          or (x == 0 and y == t.yTiles - 1)
          or (x == t.xTiles - 1 and y == 0)
          or (x == t.xTiles - 1 and y == t.yTiles - 1)) then
            love.graphics.drawq(tiles, quads[type], x * tileSize, y * tileSize, 0, 2)
          end
        end
      end
    end
  end)
  
  return t
end

function Block:update(dt)
  if self.collidable
  and ship.x + ship.width >= self.x and ship.x <= self.x + self.width
  and ship.y + ship.height - 12 >= self.y and ship.y + 15 <= self.y + self.height
  then
    ship.collide()
  end
  
  if self.y > camera.y + height then self.list.remove(self) end
end

function Block:draw()
  love.graphics.draw(self.image, self.x, self.y)
end

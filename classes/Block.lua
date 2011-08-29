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
  t.smokes = {}
  
  t.image:renderTo(function()
    -- base and corners
    for x = 0, t.xTiles - 1 do
      for y = 0, t.yTiles - 1 do
        local quad = quads[11]
        
        if x == 0 and y == 0 then
          quad = quads[12]
        elseif x == 0 and y == t.yTiles - 1 then
          quad = quads[14]
        elseif x == t.xTiles - 1 and y == 0 then
          quad = quads[13]
        elseif x == t.xTiles - 1 and y == t.yTiles - 1 then
          quad = quads[15]
        elseif (x == 0 or x == t.xTiles - 1) and math.random(1, 80) == 1 then
          t.smokes[#t.smokes + 1] = { x = x, y = y, system = t:generateSmoke(x, y) }
          quad = nil
        end
        
        if quad then love.graphics.drawq(tiles, quad, x * tileSize, y * tileSize, 0, 2) end
      end
    end
    
    -- special tiles
    for i = 1, math.random(0, math.ceil(t.xTiles * t.yTiles / 8)) do
      local length = math.random(1, 5)
      local dir = math.random(0, 1) == 0 and "x" or "y"
      local type = math.random(1, 30)
      
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
    
    -- smoke tiles
    for _, v in pairs(t.smokes) do
      love.graphics.drawq(tiles, quads[v.x == 0 and 10 or 9], v.x * tileSize, v.y * tileSize, 0, 2)
    end
  end)
  
  return t
end

function Block:update(dt)
  if state == "game" then
    if self.collidable
    and ship.x + ship.width >= self.x and ship.x <= self.x + self.width
    and ship.y + ship.height - 12 >= self.y and ship.y + 15 <= self.y + self.height
    then
        ship.collide()
    end
    
    if self.y > camera.y + height then self.list.remove(self) end
  end
  
  for _, v in pairs(self.smokes) do v.system:update(dt) end
end

function Block:draw()
  for _, v in pairs(self.smokes) do love.graphics.draw(v.system) end
  love.graphics.draw(self.image, self.x, self.y)
end

function Block:generateSmoke(x, y)
  local ps = love.graphics.newParticleSystem(images.particle, 300)
  ps:setEmissionRate(150)
  ps:setParticleLife(0.25, 0.4)
  ps:setSize(1, 2)
  ps:setSpread(math.tau / 18)
  ps:setSpeed(200, 300)
  ps:setPosition(self.x + x * tileSize + tileSize / 2, self.y + y * tileSize + tileSize / 2)
  ps:setDirection(math.tau / (x == 0 and 2 or 1))
  
  if math.random(1, 2) == 1 then
    ps:setColor(100, 156, 121, 255, 97, 148, 107, 0)
  else
    ps:setColor(200, 200, 200, 255, 170, 170, 170, 0)
  end
  
  return ps
end

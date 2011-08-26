title = {}
title.buffers = {}

title.facility = {
  x = 100,
  y = 200,
  width = 242,
  velocity = 20
}

title.layers = {
  { scale = 0.05 },
  { scale = 0.15 },
  { scale = 0.25 }
}

for i = 1, 3 do
  local buffer = love.graphics.newSpriteBatch(images.particle, 150)
  
  for i = 1, math.random(50, 150) do
    buffer:add(math.random(0, width), math.random(0, height), 0, 0.25)
  end
  
  title.buffers[#title.buffers + 1] = buffer
end

function title.init()
  for _, v in pairs(title.layers) do
    title.generateLayer(v)
    v[1].x = camera.x * v.scale
  end
end

function title.update(dt)
  for _, v in pairs(title.layers) do
    if v[1] and v[1].x >= camera.x * v.scale then title.generateLayer(v) end
  end
  
  title.facility.x = title.facility.x - title.facility.velocity * dt
  camera.x = title.facility.x - title.facility.width + 125
end

function title.draw()
  for _, v in pairs(title.layers) do
    camera.set(v.scale)
    if v[1] then love.graphics.draw(v[1].image, v[1].x, 0) end
    if v[2] then love.graphics.draw(v[2].image, v[2].x, 0) end
    camera.unset()
  end
  
  camera.set()
  love.graphics.draw(images.facility, title.facility.x, title.facility.y, 0, 2)
  camera.unset()
end

function title.generateLayer(layer)
  layer[2] = layer[1]
  layer[1] = {
    x = camera.x * layer.scale - width,
    image = title.buffers[math.random(1, 3)]
  }
end

-- Module to handle the player's rocket

ship = {}
ship.width = 24
ship.height = 56
ship.xSpeed = 450
ship.yIncrease = 10
ship.image = love.graphics.newImage("images/ship.png")
ship.image:setFilter("nearest", "nearest") -- makes it pixelated, not blurry

local ps = love.graphics.newParticleSystem(particle, 1000)
ps:setEmissionRate(10000)
ps:setLifetime(0.1)
ps:setParticleLife(0.2, 0.5)
ps:setSize(0.5, 2)
ps:setSpread(math.tau)
ps:setSpeed(300, 600)
ps:setColor(238, 88, 38, 255, 230, 60, 27, 0)
ps:stop()
ship.explosion = ps

ps = love.graphics.newParticleSystem(particle, 500)
ps:setEmissionRate(250)
ps:setLifetime(1)
ps:setParticleLife(4, 5)
ps:setSize(2, 4)
ps:setSpread(math.tau)
ps:setSpeed(10, 20)
ps:setColor(195, 195, 195, 255, 155, 155, 155, 0)
ps:stop()
ship.smoke = ps

ps = love.graphics.newParticleSystem(particle, 1000)
ps:setEmissionRate(100)
ps:setParticleLife(0.2, 0.5)
ps:setSize(1, 3)
ps:setDirection(-math.tau / 4)
ps:setSpread(math.tau / 24)
ps:setColor(220, 82, 38, 255, 220, 45, 32, 0)
ship.fire = ps

function ship.reset()
  ship.x = width / 2 - ship.width / 2
  ship.y = height - ship.height
  ship.ySpeed = 500
  ship.distance = 0
  ship.initialY = ship.y
  ship.dead = false
  ship.fireSpeed = 75
  ship.fire:setSpeed(25, 125)
  ship.fire:start()
end

function ship.update(dt)
  ship.fire:setPosition(ship.x + ship.width / 2, ship.y + ship.height)
  ship.fire:update(dt)
  
  if ship.dead then
    ship.explosion:update(dt)
    ship.smoke:update(dt * ship.smokeFactor)
    return
  end
  
  ship.y = ship.y - ship.ySpeed * dt
  if ship.ySpeed < 650 then ship.ySpeed = math.min(ship.ySpeed + ship.yIncrease * dt, 650) end
  ship.distance = math.abs(ship.y - ship.initialY)
  ship.fire:setSpeed(ship.fireSpeed - 50, ship.fireSpeed + 50)
  
  if ship.x > 0 and (love.keyboard.isDown("left") or love.keyboard.isDown("a")) then
    ship.x = math.max(ship.x - ship.xSpeed * dt, 0)
  end
  
  if ship.x + ship.width < width and (love.keyboard.isDown("right") or love.keyboard.isDown("d")) then
    ship.x = math.min(ship.x + ship.xSpeed * dt, width - ship.width)
  end
end

function ship.draw()
  love.graphics.draw(ship.fire)
  
  if ship.dead then
    love.graphics.draw(ship.explosion, ship.x, ship.y)
    love.graphics.draw(ship.smoke, ship.x, ship.y)
  else
    love.graphics.draw(ship.image, ship.x, ship.y, 0, 2)
  end
end

function ship.collide()
  ship.dead = true
  ship.explosion:start()
  ship.smoke:start()
  ship.fire:stop()
  ship.smokeFactor = 10
  cron.after(0.1, function() tween(0.25, ship, { smokeFactor = 1 }) end)
  sound.death()
  sound.engine()
  changeState("score")
end

ship.reset()

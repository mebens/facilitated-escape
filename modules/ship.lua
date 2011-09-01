-- Module to handle the player's rocket

ship = {}
ship.width = 24
ship.height = 56
ship.xSpeed = 450
ship.yIncrease = 10
ship.image = love.graphics.newImage("images/ship.png")
ship.image:setFilter("nearest", "nearest")

local ps = love.graphics.newParticleSystem(particle, 1000)
ps:setEmissionRate(10000)
ps:setLifetime(0.1)
ps:setParticleLife(0.2, 0.5)
ps:setSize(1, 3)
ps:setSpread(math.tau)
ps:setSpeed(300, 600)
ps:setColor(152, 41, 14, 150, 142, 38, 13, 0)
ps:stop()
ship.explosion = ps

ps = love.graphics.newParticleSystem(particle, 2000)
ps:setEmissionRate(1000)
ps:setLifetime(1)
ps:setParticleLife(4, 5)
ps:setSize(1, 3)
ps:setSpread(math.tau)
ps:setSpeed(10, 18)
ps:setColor(195, 195, 195, 200, 155, 155, 155, 0)
ps:stop()
ship.smoke = ps

ps = love.graphics.newParticleSystem(particle, 1000)
ps:setParticleLife(0.2, 0.5)
ps:setSize(1, 3)
ps:setDirection(-math.tau / 4)
ps:setSpread(math.tau / 24)
ps:setColor(152, 41, 14, 150, 142, 38, 13, 0)
ship.fire = ps

function ship.reset()
  ship.x = width / 2 - ship.width / 2
  ship.y = height - ship.height
  ship.ySpeed = 500
  ship.distance = 0
  ship.initialY = ship.y
  ship.dead = false
  ship.fireSpeed = 75
  ship.fireRate = 250
  ship.fire:setSpeed(ship.fireSpeed - 50, ship.fireSpeed + 50)
  ship.fire:setEmissionRate(ship.fireRate)
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
  
  if ship.ySpeed < 650 then
    ship.ySpeed = math.min(ship.ySpeed + ship.yIncrease * dt, 650)
    ship.fireSpeed = ship.fireSpeed + ship.yIncrease / 3 * dt
    ship.fireRate = ship.fireRate + ship.yIncrease / 1.5 * dt
    ship.fire:setEmissionRate(ship.fireRate)
  end
  
  ship.y = ship.y - ship.ySpeed * dt
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
  love.graphics.setBlendMode("additive")
  love.graphics.draw(ship.fire)
  love.graphics.setBlendMode("alpha")
  
  if ship.dead then
    love.graphics.setBlendMode("additive")
    love.graphics.draw(ship.explosion, ship.x, ship.y)
    love.graphics.setBlendMode("alpha")
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
  changeState("score")
end

ship.reset()

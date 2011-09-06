function love.load()
  -- setup calls
  math.randomseed(os.time())
  math.random()
  math.random()
  math.random()
  love.mouse.setVisible(false) 
  
  -- globals/variables
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  tileSize = 24
  meter = 12
  state = "title" -- "title", "game", "pause", or "score"
  tutorial = false
  muted = false
  blackAlpha = 0
  dtFactor = 1
  math.tau = math.pi * 2
  
  -- loading
  loadResources()
  tween = require("lib.tween")
  cron = require("lib.cron")
  require("modules.list")
  require("modules.text")
  require("modules.camera")
  require("modules.background")
  require("modules.blocks")
  require("modules.sound")
  require("modules.data")
  require("classes.Block")
  require("classes.MidBlock")
  
  -- setup scene
  data.init()
  background.reset()
  blocks.reset()
  sound.processRumbles()
  text.activate("title")
end

function love.update(dt)
  dt = dt * dtFactor
  
  -- how on earth we get dt = 0 I don't know
  if dt > 0 then
    tween.update(dt)
    cron.update(dt)
  end
  
  if state ~= "pause" then
    camera.update(dt)
    background.update(dt)
    blocks.update(dt)
    if tutorial then tutorial.update(dt) end
    if state == "game" or state == "score" then ship.update(dt) end
  end
end

function love.draw()
  camera.set(background.cameraScale)
  background.draw()
  camera.unset()

  camera.set(blocks.middle.cameraScale)
  blocks.middle.draw()
  camera.unset()

  camera.set()
  if tutorial then tutorial.draw() end
  if state == "game" then ship.draw() end
  blocks.front.draw()
  if state ~= "game" and state ~= "title" then ship.draw() end
  camera.unset()
  
  text.draw()
  
  if blackAlpha ~= 0 then
    love.graphics.setColor(0, 0, 0, blackAlpha)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255, 255, 255)
  end
end

function love.keypressed(key, unicode)
  if key == " " and state ~= "game" then
    if state == "pause" then
      changeState("game")
    else
      fadeChangeState("game")
    end
  elseif key == "m" and state ~= "pause" then
    muted = not muted
    
    if muted then
      music.game:pause()
    else
      music.game:resume()
    end
  elseif key == "p" then
    if state == "pause" then
      changeState("game")
    else
      changeState("pause")
    end
  elseif key == "escape" then
    love.event.push("q")
  end
end

function love.focus(f)
  if not f then changeState("pause") end
end

function love.quit()
  data.onQuit()
end

function changeState(to)
  if state == "title" and to == "game" then
    require("modules.ship")
    
    if data.first then
      require("modules.tutorial")
      tutorial.init()
    end
    
    state = "game"
    camera.y = camera.generateY()
    blocks.reset()
    background.reset()
    sfx.engine:play()
    shipTweens()
    text.activate("ui", true)
    text.deactivate("title", true)
    
    -- start rumbling
    cron.every(6, function()
      if state == "game" and math.random(1, 6) == 1 then
        camera.shake(4)
        sound.playRumble()
      end
    end)
  elseif state == "score" and to == "game" then
    state = "game"    
    ship.reset()
    tween.stop(camera.endTween)
    camera.y = camera.generateY()
    background.reset()
    blocks.reset()
    sfx.engine:play()
    shipTweens()
    text.deactivate("score", true)
    text.activate("ui", true)
  elseif state == "game" and to == "score" then
    state = "score"
    data.score(math.floor(ship.distance / meter))
    text.deactivate("ui")
    text.activate("score")
    sfx.death:play()
    sfx.engine:stop()
    camera.endTween = tween(0.5, camera, { y = camera.y - 20 }, "outExpo")
  elseif state == "game" and to == "pause" then
    state = "pause"
    text.deactivate("ui")
    text.activate("pause")
    music.game:pause()
    sfx.background:stop()
    sfx.engine:stop()
  elseif state == "pause" and to == "game" then
    state = "game"
    if not muted then music.game:resume() end
    sfx.background:play()
    sfx.engine:play()
    text.deactivate("pause")
    text.activate("ui")
  end
end

function fadeChangeState(to)
  tween(0.15, _G, { blackAlpha = 255 }, nil, function()
    changeState(to)
    tween(0.15, _G, { blackAlpha = 0 })
  end)
end

function loadResources()
  fonts = {
    [12] = love.graphics.newFont("fonts/uni05.ttf", 12),
    [16] = love.graphics.newFont("fonts/uni05.ttf", 16),
    [28] = love.graphics.newFont("fonts/uni05.ttf", 28),
    [36] = love.graphics.newFont("fonts/uni05.ttf", 36)
  }

  particle = love.graphics.newImage("images/particle.png")
  tiles = love.graphics.newImage("images/tiles.png")
  tiles:setFilter("nearest", "nearest") -- makes it pixelated, not blurry
  local tw = tiles:getWidth()
  local th = tiles:getHeight()
  
  quads = {
    -- foreground
    love.graphics.newQuad(0, 0, 12, 12, tw, th),
    love.graphics.newQuad(13, 0, 12, 12, tw, th),
    love.graphics.newQuad(26, 0, 12, 12, tw, th),
    love.graphics.newQuad(39, 0, 12, 12, tw, th),
    love.graphics.newQuad(52, 0, 12, 12, tw, th),
    love.graphics.newQuad(65, 0, 12, 12, tw, th),
    love.graphics.newQuad(78, 0, 12, 12, tw, th),
    love.graphics.newQuad(91, 0, 12, 12, tw, th),
    love.graphics.newQuad(104, 0, 12, 12, tw, th),
    love.graphics.newQuad(0, 13, 12, 12, tw, th),
    love.graphics.newQuad(13, 13, 12, 12, tw, th),
    love.graphics.newQuad(26, 13, 12, 12, tw, th),
    love.graphics.newQuad(39, 13, 12, 12, tw, th),
    love.graphics.newQuad(52, 13, 12, 12, tw, th),
    love.graphics.newQuad(65, 13, 12, 12, tw, th),
    
    -- middleground
    love.graphics.newQuad(78, 13, 12, 12, tw, th),
    love.graphics.newQuad(91, 13, 12, 12, tw, th),
    love.graphics.newQuad(104, 13, 12, 12, tw, th),
    love.graphics.newQuad(0, 26, 12, 12, tw, th),
    love.graphics.newQuad(13, 26, 12, 12, tw, th),
    love.graphics.newQuad(26, 26, 12, 12, tw, th),
    
     -- background
    love.graphics.newQuad(39, 26, 12, 12, tw, th),
    love.graphics.newQuad(52, 26, 12, 12, tw, th),
    love.graphics.newQuad(65, 26, 12, 12, tw, th),
    love.graphics.newQuad(78, 26, 12, 12, tw, th),
    love.graphics.newQuad(91, 26, 12, 12, tw, th)
  }
  
  sfx = {
    engine = love.audio.newSource("sounds/engine.ogg", "static"),
    death = love.audio.newSource("sounds/death.ogg", "static"),
    background = love.audio.newSource("sounds/background.ogg", "static"),
    rumble = love.sound.newSoundData("sounds/rumble.ogg"),
    smallRumble1 = love.sound.newSoundData("sounds/small-rumble.ogg"),
    smallRumble2 = love.sound.newSoundData("sounds/small-rumble2.ogg"),
    smallRumble3 = love.sound.newSoundData("sounds/small-rumble3.ogg")
  }
  
  sfx.engine:setLooping(true)
  sfx.engine:setVolume(0.2)
  sfx.death:setVolume(0.5)
  sfx.background:setLooping(true)
  sfx.background:setVolume(0.3)
  sfx.background:play()
  
  music = {
    game = love.audio.newSource("sounds/music.ogg", "stream")
  }
  
  music.game:setLooping(true)
  music.game:setVolume(0.15) -- I can't stop the music file from being incredibly loud for some reason
  music.game:play()
end

function shipTweens()
  local ySpeed = ship.ySpeed
  ship.ySpeed = 0
  tween(1, ship, { ySpeed = ySpeed })
  tween(1, ship, { fireSpeed = 400 })
end

function formatNumber(num)
  local found
  local formatted = tostring(num):gsub("(%d)(%d%d%d)$", "%1,%2", 1)
  while found ~= 0 do formatted, found = formatted:gsub("(%d)(%d%d%d),", "%1,%2,", 1) end
  return formatted
end

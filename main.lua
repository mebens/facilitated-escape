-- TODO
-- more tiles and layers
-- possibly update sound effects and music
-- shootable obstables
-- score tracking

function love.load()
  -- setup random numbers
  math.randomseed(os.time())
  math.random()
  math.random()
  math.random()
  
  -- globals/variables
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  tileSize = 24
  meter = 12
  state = "pre-title" -- "pre-title", "title", "game", "pause", or "score"
  userMuted = false
  rumbleTimer = 0
  math.tau = math.pi * 2
  
  -- resources
  fonts = {
    [14] = love.graphics.newFont("fonts/uni05.ttf", 14),
    [16] = love.graphics.newFont("fonts/uni05.ttf", 16),
    [28] = love.graphics.newFont("fonts/uni05.ttf", 28),
    [36] = love.graphics.newFont("fonts/uni05.ttf", 36)
  }

  particle = love.graphics.newImage("images/particle.png")
  tiles = love.graphics.newImage("images/tiles.png")
  tiles:setFilter("nearest", "nearest")
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
    
    -- middleground
    love.graphics.newQuad(52, 13, 12, 12, tw, th),
    love.graphics.newQuad(65, 13, 12, 12, tw, th),
    love.graphics.newQuad(78, 13, 12, 12, tw, th),
    love.graphics.newQuad(91, 13, 12, 12, tw, th),
    love.graphics.newQuad(104, 13, 12, 12, tw, th),
    love.graphics.newQuad(0, 26, 12, 12, tw, th),
    
     -- background
    love.graphics.newQuad(13, 26, 12, 12, tw, th),
    love.graphics.newQuad(26, 26, 12, 12, tw, th),
    love.graphics.newQuad(39, 26, 12, 12, tw, th),
    love.graphics.newQuad(52, 26, 12, 12, tw, th),
    love.graphics.newQuad(65, 26, 12, 12, tw, th)
  }
  
  -- files
  tween = require("lib.tween")
  cron = require("lib.cron")
  require("list")
  require("text")
  require("ship")
  require("camera")
  require("background")
  require("blocks")
  require("sound")
  require("Block")
  require("MidBlock")
  
  -- world setup
  blocks.reset()
  cron.after(1, changeState, "title")
  flashAlpha = 0
  
  tween(0.1, _G, { flashAlpha = 255 }, nil, function()
    tween(1.15, _G, { flashAlpha = 0 }, nil, function() flashAlpha = nil end)
    camera.shake(10)
    sound.rumble()
  end)
end

function love.update(dt)
  if state ~= "pause" then
    background.update(dt)
    camera.update(dt)
  end

  -- how on earth we get dt = 0 I don't know
  if dt > 0 then
    tween.update(dt)
    cron.update(dt)
  end
    
  if state == "game" or state == "score" then ship.update(dt) end
  if state == "game" then blocks.update(dt) end
end

function love.draw()
  camera.set(background.cameraScale)
  background.draw()
  camera.unset()
  
  camera.set(blocks.middle.cameraScale)
  blocks.middle.draw()
  camera.unset()
  
  camera.set()
  blocks.front.draw()
  ship.draw()
  camera.unset()
  
  text.draw()
  
  if flashAlpha then
    love.graphics.setColor(255, 255, 255, flashAlpha)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255, 255, 255)
  end
end

function love.keypressed(key, unicode)
  if key == " " and state ~= "pre-title" and state ~= "game" then
    changeState("game")
  elseif key == "m" and state ~= "pause" then
    userMuted = not userMuted
    sound.muteMusic()
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

function changeState(to)
  if state == "pre-title" and to == "title" then
    state = "title"
    camera.follow = true
    text.activate("title")
  elseif state == "title" and to == "game" then
    state = "game"
    sound.engine()
    shipTweens()
    text.deactivate("title")
    text.activate("ui")
    
    -- start rumbling
    cron.every(3, function()
      if state == "game" and math.random(1, 6) == 1 then
        camera.shake(4)
        sound.rumble()
      end
    end)
  elseif state == "score" and to == "game" then
    state = "game"    
    ship.reset()
    camera.y = ship.y + ship.height / 2 - height / 1.2
    background.reset()
    blocks.reset()
    sound.engine()
    shipTweens()
    text.deactivate("score")
    text.activate("ui")
  elseif state == "game" and to == "score" then
    state = "score"
    text.deactivate("ui")
    text.activate("score")
  elseif state == "game" and to == "pause" then
    state = "pause"
    text.deactivate("ui")
    text.activate("pause")
    sound.muteMusic(true)
    sound.muteBackground()
    sound.engine()
  elseif state == "pause" and to == "game" then
    state = "game"
    if not suserMuted then sound.muteMusic() end
    sound.muteBackground()
    sound.engine()
    text.deactivate("pause")
    text.activate("ui")
  end
end

function newFramebuffer(width, height)
  local ok, fb = pcall(love.graphics.newFramebuffer, width, height)
  
  if not ok then
    ok, fb = pcall(
      love.graphics.newFramebuffer,
      math.ceil(math.log(width) / math.log(2)) ^ 2,
      math.ceil(math.log(height) / math.log(2)) ^ 2
    )
    
    if not ok then error("Your computer doesn't support framebuffers") end
  end
  
  return fb
end

function shipTweens()
  local ySpeed = ship.ySpeed
  ship.ySpeed = 0
  tween(1, ship, { ySpeed = ySpeed })
  tween(1, ship, { fireSpeed = 400 })
end

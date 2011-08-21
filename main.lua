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
  math.tau = math.pi * 2
  
  -- resources
  font14 = love.graphics.newFont("fonts/uni05.ttf", 14)
  font16 = love.graphics.newFont("fonts/uni05.ttf", 16)
  font28 = love.graphics.newFont("fonts/uni05.ttf", 28)
  font36 = love.graphics.newFont("fonts/uni05.ttf", 36)
  particle = love.graphics.newImage("images/particle.png")
  
  tiles = love.graphics.newImage("images/tiles.png")
  tiles:setFilter("nearest", "nearest")
  local tw = tiles:getWidth()
  local th = tiles:getHeight()
  
  quads = {
    love.graphics.newQuad(0, 0, 12, 12, tw, th),
    love.graphics.newQuad(13, 0, 12, 12, tw, th),
    love.graphics.newQuad(26, 0, 12, 12, tw, th),
    love.graphics.newQuad(0, 13, 12, 12, tw, th),
    love.graphics.newQuad(13, 13, 12, 12, tw, th),
    love.graphics.newQuad(26, 13, 12, 12, tw, th),
    love.graphics.newQuad(0, 26, 12, 12, tw, th),
    love.graphics.newQuad(13, 26, 12, 12, tw, th),
    love.graphics.newQuad(39, 0, 12, 12, tw, th), -- dark tiles start here
    love.graphics.newQuad(39, 13, 12, 12, tw, th),
    love.graphics.newQuad(26, 26, 12, 12, tw, th)
  }
  
  -- files
  tween = require("lib.tween")
  cron = require("lib.cron")
  require("ship")
  require("camera")
  require("background")
  require("blocks")
  require("Block")
  require("sound")
  
  -- scene/setup
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
  
  camera.set()
  blocks.draw()
  ship.draw()
  camera.unset()
  
  if titleText then
    love.graphics.setColor(titleText.color)
    love.graphics.setFont(font36)
    love.graphics.printf(titleText.title, 0, 100, width, "center")
    love.graphics.setFont(font16)
    love.graphics.printf(titleText.press, 0, 235, width, "center")
    love.graphics.setFont(font14)
    love.graphics.printf(titleText.instructions, 0, 300, width, "center")
    love.graphics.setColor(255, 255, 255)
  end
  
  if scoreText then
    love.graphics.setColor(scoreText.color)
    love.graphics.setFont(font16)
    love.graphics.printf(scoreText.message, 0, 150, width, "center")
    love.graphics.setFont(font28)
    love.graphics.printf(scoreText.distance, 0, 175, width, "center")
    love.graphics.setFont(font14)
    love.graphics.printf(scoreText.press, 0, 450, width, "center")
    love.graphics.setColor(255, 255, 255)
  end
  
  if pauseText then
    love.graphics.setColor(pauseText.color)
    love.graphics.setFont(font28)
    love.graphics.printf(pauseText.message, 0, 175, width, "center")
    love.graphics.setFont(font14)
    love.graphics.printf(pauseText.press, 0, 215, width, "center")
    love.graphics.setColor(255, 255, 255)
  end
  
  love.graphics.setFont(font16)
  love.graphics.setColor(255, 255, 255, uiAlpha)
  love.graphics.printf(tostring(math.floor(ship.distance / meter)) .. "m", 0, 5, width + 5, "right")
  love.graphics.setColor(255, 255, 255)
  
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
    titleText = {
      title = "Facilitated\nEscape",
      press = "Press space to start",
      instructions = "The facility is crumbling!\nEscape, you must!\n\nAvoid incoming blocks.\nLeft/right arrows to steer.\nM to mute music.\nP to pause.\nEscape to quit.",
      color = { 255, 255, 255, 0 }
    }
    
    state = "title"
    camera.follow = true
    tween(0.25, titleText.color, { [4] = 255 })
  elseif state == "title" and to == "game" then
    state = "game"
    sound.engine()
    processShake()
    shipTweens()
    tween(0.25, titleText.color, { [4] = 0 }, nil, function() titleText = nil end)
    
    -- tween in UI
    uiAlpha = 0
    tween(0.25, _G, { uiAlpha = 255 })
  elseif state == "score" and to == "game" then
    state = "game"    
    ship.reset()
    sound.engine()
    camera.y = ship.y + ship.height / 2 - height / 1.2
    background.reset()
    blocks.reset()
    shipTweens()
    tween(0.25, _G, { uiAlpha = 255 })
    tween(0.25, scoreText.color, { [4] = 0 }, nil, function() scoreText = nil end)
  elseif state == "game" and to == "score" then
    scoreText = {
      message = "You travelled",
      distance = tostring(math.floor(ship.distance / meter)) .. " meters",
      press = "Press space to play again",
      color = { 255, 255, 255, 0 }
    }
    
    state = "score"
    tween(0.25, scoreText.color, { [4] = 255 })
    tween(0.25, _G, { uiAlpha = 0 })
  elseif state == "game" and to == "pause" then
    pauseText = {
      message = "Paused",
      press = "Press space or P to continue",
      color = { 255, 255, 255, 0 }
    }
    
    state = "pause"
    tween(0.25, pauseText.color, { [4] = 255 })
    tween(0.25, _G, { uiAlpha = 0 })
    sound.muteMusic(true)
    sound.muteBackground()
    sound.engine()
  elseif state == "pause" and to == "game" then
    state = "game"
    if not suserMuted then sound.muteMusic() end
    sound.muteBackground()
    sound.engine()
    tween(0.25, _G, { uiAlpha = 255 })
    
    if pauseText then
      tween(0.25, pauseText.color, { [4] = 0 }, nil, function() pauseText = nil end)
    end
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

function processShake()
  cron.after(4, function()
    if state == "game" and math.random(1, 5) == 1 then
      camera.shake(4)
      sound.rumble()
    end
    
    processShake()
  end)
end

function shipTweens()
  local ySpeed = ship.ySpeed
  ship.ySpeed = 0
  tween(1, ship, { ySpeed = ySpeed })
  tween(1, ship, { fireSpeed = 400 })
end

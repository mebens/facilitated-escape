-- Module to handle music and sound effects

local data = {
  smallRumble = love.sound.newSoundData("sounds/small-rumble.ogg"),
  smallRumble2 = love.sound.newSoundData("sounds/small-rumble2.ogg")
}

local musicMuted = false
local music = love.audio.newSource("sounds/music.ogg", "stream")
music:setLooping(true)
music:setVolume(0.15) -- I can't stop the music file from being incredibly loud for some reason
music:play()

local bgMuted = false
local background = love.audio.newSource("sounds/background.ogg", "static")
background:setLooping(true)
background:setVolume(0.3)
background:play()

local engineMuted = false
local engine = love.audio.newSource("sounds/engine.ogg", "static")
engine:setLooping(true)
engine:setVolume(0.2)

local death = love.audio.newSource("sounds/death.ogg", "static")
death:setVolume(0.5)

local rumble = love.audio.newSource("sounds/rumble.ogg", "static")
rumble:setVolume(0.5)

sound = {}

function sound.death()
  death:play()
end

function sound.rumble()
  rumble:play()
end

function sound.engine()
  if engine:isStopped() then
    engine:play()
  else
    engine:stop()
    engine:rewind()
  end
end

function sound.muteMusic(notSwitch)
  musicMuted = notSwitch or not musicMuted
  
  if musicMuted then
    music:pause()
  else
    music:resume()
  end
end

function sound.muteBackground(notSwitch)
  bgMuted = notSwitch or not bgMuted
  
  if bgMuted then
    background:pause()
  else
    background:resume()
  end
end

function sound.processRumbles()
  sound.processRumble1()
  sound.processRumble2()
end

function sound.processRumble1()
  cron.after(math.random(10, 20) / 10, function()
    if state ~= "pause" and math.random(1, 6) == 1 then
      local source = love.audio.newSource(data.smallRumble)
      source:setVolume(math.random(20, 30) / 100)
      source:play()
    end
    
    sound.processRumble1()
  end)
end

function sound.processRumble2()
  cron.after(math.random(10, 20) / 10, function()
    if state ~= "pause" and math.random(1, 6) == 1 then
      local source = love.audio.newSource(data.smallRumble2)
      source:setVolume(math.random(20, 30) / 100)
      source:play()
    end
    
    sound.processRumble2()
  end)
end

sound.processRumbles()

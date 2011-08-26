-- Module to handle background rumbles

sound = {}

function sound.processRumbles()
  sound.processRumble1()
  sound.processRumble2()
end

function sound.processRumble1()
  cron.after(math.random(10, 20) / 10, function()
    if state ~= "pause" and math.random(1, 6) == 1 then
      local source = love.audio.newSource(sfx.smallRumble)
      source:setVolume(math.random(20, 30) / 100)
      source:play()
    end
    
    sound.processRumble1()
  end)
end

function sound.processRumble2()
  cron.after(math.random(10, 20) / 10, function()
    if state ~= "pause" and math.random(1, 6) == 1 then
      local source = love.audio.newSource(sfx.smallRumble2)
      source:setVolume(math.random(20, 30) / 100)
      source:play()
    end
    
    sound.processRumble2()
  end)
end

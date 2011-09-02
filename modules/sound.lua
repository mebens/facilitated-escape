-- Module to handle background rumbles

sound = {}

function sound.playRumble()
  local source = love.audio.newSource(sfx.rumble)
  source:setVolume(0.5)
  source:play()
  return source
end

function sound.processRumbles()
  sound.processRumble1()
  sound.processRumble2()
  sound.processRumble3()
end

for i = 1, 3 do
  -- having them as locals will speed things up
  local funcName = "processRumble" .. i
  local sfxName = "smallRumble" .. i
  
  sound[funcName] = function()
    cron.after(math.random(10, 20) / 10, function()
      if state ~= "pause" and math.random(1, 6) == 1 then
        local source = love.audio.newSource(sfx[sfxName])
        source:setVolume(math.random(25, 35) / 100)
        source:play()
      end

      sound[funcName]()
    end)
  end
end

tutorial = {}
tutorial.active = true
tutorial.foundBlock = false
tutorial.stage = 0

function tutorial.init()
  cron.after(0.5, tween, 0.3, _G, { dtFactor = 0.1 }, "outQuad", function()
    cron.after(0.4, function() tutorial.stage = 1 end)
  end)
end

function tutorial.update(dt)
  if not tutorial.foundBlock then
    local block
    
    for v in list.each(blocks.front) do
      if not block and v.y < camera.y + 100 then
        block = v
      elseif v.y + v.height > block.y + block.height and v.y < camera.y + 100 then
        block = v
      end
    end
    
    if block then
      tutorial.foundBlock = true
      tutorial.avoidY = block.y + block.height + 30
    end
  end
  
  if not tutorial.pressed and (love.keyboard.isDown("left") or love.keyboard.isDown("right")) then
    tutorial.pressed = true
  end
  
  if tutorial.stage == 2 and camera.y + height < tutorial.avoidY then
    tutorial.active = false
    if dtFactor < 1 then tween(0.3, _G, { dtFactor = 1 }, "outQuad") end
  end
  
  if tutorial.stage == 1 and tutorial.pressed then
    tutorial.stage = 2
    tween(0.3, _G, { dtFactor = 1 }, "outQuad")
  end
end

function tutorial.draw()
  text.shadowPrint("Use left/right arrows to move", height / 4, fonts[16], 255, 2)
  if tutorial.avoidY then text.shadowPrint("Avoid these blocks", tutorial.avoidY, fonts[16], 255, 2) end
end

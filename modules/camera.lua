-- Module to handle the camera

camera = {}
camera.x = 0
camera.y = ship.y + ship.height / 2 - height / 1.12
camera.follow = false
camera.speed = 10
camera.shakeFactor = 0

function camera.update(dt)
  if camera.follow then
    -- only way I know of eliminating jitters from the ship
    camera.y = camera.y - (camera.y - (ship.y + ship.height / 2 - height / 1.12)) * dt * camera.speed
  end
end

function camera.set(factor)
  love.graphics.push()
  love.graphics.translate((-camera.x + camera.shakeFactor) * (factor or 1), (-camera.y + camera.shakeFactor) * (factor or 1))
end

camera.unset = love.graphics.pop

function camera.shake(force)
  -- yeah, this looks bad, but it's a quick solution
  tween(0.1, camera, { shakeFactor = force }, "outQuad", function()
    tween(0.1, camera, { shakeFactor = -force }, "outQuad", function()
      tween(0.1, camera, { shakeFactor = force }, "outQuad", function()
        tween(0.1, camera, { shakeFactor = -force }, "outQuad", function()
          tween(0.1, camera, { shakeFactor = force / 1.1 }, "outQuad", function()
            tween(0.1, camera, { shakeFactor = -force / 1.1 }, "outQuad", function()
              tween(0.1, camera, { shakeFactor = force / 1.2 }, "outQuad", function()
                tween(0.1, camera, { shakeFactor = -force / 1.2 }, "outQuad", function()
                  tween(0.1, camera, { shakeFactor = force / 1.4 }, "outQuad", function()
                    tween(0.1, camera, { shakeFactor = -force / 1.4 }, "outQuad", function()
                      tween(0.1, camera, { shakeFactor = force / 1.6 }, "outQuad", function()
                        tween(0.1, camera, { shakeFactor = -force / 1.6 }, "outQuad", function()
                          tween(0.1, camera, { shakeFactor = force / 2 }, "outQuad", function()
                            tween(0.1, camera, { shakeFactor = -force / 2 }, "outQuad", function()
                              tween(0.1, camera, { shakeFactor = 0 })
                            end)
                          end)
                        end)
                      end)
                    end)
                  end)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

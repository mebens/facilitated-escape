-- Module to handle the camera

camera = {}
camera.x = 0
camera.y = 0
camera.speed = 10
camera.shakeFactor = 0
camera.titleSpeed = 200

function camera.update(dt)
  if state == "game" then
    camera.y = camera.y - (camera.y - (camera.generateY())) * dt * camera.speed
  elseif state == "title" then
    camera.y = camera.y - camera.titleSpeed * dt
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

function camera.generateY()
  return ship.y + ship.height / 2 - height / 1.12
end

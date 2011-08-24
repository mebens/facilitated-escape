-- Module to handle the manage and draw the game's text

text = {}

text.title = {
  title = "Facilitated\nEscape",
  press = "Press space to start",
  instructions = "The facility is crumbling!\nEscape, you must!\n\nAvoid oncoming blocks.\nLeft/right arrows to steer.\nM to mute music.\nP to pause.\nEscape to quit.",
  active = false,
  color = { 255, 255, 255, 0 }
}

text.score = {
  message = "You travelled",
  distanceFormat = "%d meters",
  press = "Press space to play again",
  active = false,
  color = { 255, 255, 255, 0 }
}

text.pause = {
  message = "Paused",
  press = "Press space or P to continue",
  active = false,
  color = { 255, 255, 255, 0 }
}

text.ui = {
  distance = "%dm",
  active = false,
  color = { 255, 255, 255, 0 }
}

function text.draw()
  if text.title.active then
    love.graphics.setColor(text.title.color)
    love.graphics.setFont(font36)
    love.graphics.printf(text.title.title, 0, 100, width, "center")
    love.graphics.setFont(font16)
    love.graphics.printf(text.title.press, 0, 235, width, "center")
    love.graphics.setFont(font14)
    love.graphics.printf(text.title.instructions, 0, 300, width, "center")
    love.graphics.setColor(255, 255, 255)
  end
  
  if text.score.active then
    love.graphics.setColor(text.score.color)
    love.graphics.setFont(font16)
    love.graphics.printf(text.score.message, 0, 150, width, "center")
    love.graphics.setFont(font28)
    love.graphics.printf(text.score.distance, 0, 175, width, "center")
    love.graphics.setFont(font14)
    love.graphics.printf(text.score.press, 0, 450, width, "center")
    love.graphics.setColor(255, 255, 255)
  end
  
  if text.pause.active then
    love.graphics.setColor(text.pause.color)
    love.graphics.setFont(font28)
    love.graphics.printf(text.pause.message, 0, 175, width, "center")
    love.graphics.setFont(font14)
    love.graphics.printf(text.pause.press, 0, 215, width, "center")
    love.graphics.setColor(255, 255, 255)
  end
  
  if text.ui.active then
    love.graphics.setFont(font16)
    love.graphics.setColor(text.ui.color)
    love.graphics.printf(text.ui.distance:format(math.floor(ship.distance / meter)), 0, 5, width + 5, "right")
    love.graphics.setColor(255, 255, 255)
  end
end

function text.activate(name)
  assert(text[name], "A text set by the name '" .. name .. "' doesn't exist.")
  text[name].active = true
  tween(0.25, text[name].color, { [4] = 255 })
  
  if name == "score" then
    text.score.distance = text.score.distanceFormat:format(math.floor(ship.distance / meter))
  end
end

function text.deactivate(name)
  assert(text[name], "A text set by the name '" .. name .. "' doesn't exist.")
  tween(0.25, text[name].color, { [4] = 0 }, nil, function() text[name].active = false end)
end

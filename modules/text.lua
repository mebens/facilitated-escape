-- Module to handle the manage and draw the game's text

text = {}

text.title = {
  title = "Facilitated\nEscape",
  press = "Press space to start",
  keys = "Press M to mute the music, P to pause, and escape to quit.",
  active = false,
  alpha = 0
}

text.score = {
  message = "You travelled",
  distanceFormat = "%d meters",
  statsFormat = "Highscore: %dm\nPlays: %d\nTotal Distance: %sm\nAverage: %.1fm",
  press = "Press space to play again",
  active = false,
  alpha = 0
}

text.pause = {
  message = "Paused",
  press = "Press space or P to continue",
  active = false,
  alpha = 0
}

text.ui = {
  distance = "%dm",
  active = false,
  alpha = 0
}

function text.draw()
  if text.title.active then
    text.shadowPrint(text.title.title, 150, fonts[36], text.title.alpha, 3)
    text.shadowPrint(text.title.press, 450, fonts[16], text.title.alpha, 2)
    text.shadowPrint(text.title.keys, 550, fonts[12], text.title.alpha, 2)
  end
  
  if text.score.active then
    text.shadowPrint(text.score.message, 150, fonts[16], text.score.alpha, 2)
    text.shadowPrint(text.score.distance, 175, fonts[28], text.score.alpha, 3)
    text.shadowPrint(text.score.stats, 290, fonts[16], text.score.alpha, 2)
    text.shadowPrint(text.score.press, 450, fonts[16], text.score.alpha, 2)
  end
  
  if text.pause.active then
    text.shadowPrint(text.pause.message, 175, fonts[28], text.pause.alpha, 3)
    text.shadowPrint(text.pause.press, 450, fonts[16], text.pause.alpha, 2)
  end
  
  if text.ui.active then
    text.shadowPrint(text.ui.distance:format(math.floor(ship.distance / meter)), 5, fonts[16], text.ui.alpha, 2, "right")
  end
end

function text.activate(name, notFade)
  assert(text[name], "A text set by the name '" .. name .. "' doesn't exist.")
  text[name].active = true
  
  if notFade then
    text[name].alpha = 255
  else
    if text[name].tween then tween.stop(text[name].tween) end
    text[name].tween = tween(0.25, text[name], { alpha = 255 })
  end
  
  if name == "score" then
    local found
    local formattedTotal = tostring(data.total):gsub("(%d)(%d%d%d)$", "%1,%2", 1)
    while found ~= 0 do formattedTotal, found = formattedTotal:gsub("(%d)(%d%d%d),", "%1,%2,", 1) end
    text.score.distance = text.score.distanceFormat:format(math.floor(ship.distance / meter))
    text.score.stats = text.score.statsFormat:format(data.best, data.plays, formattedTotal, data.total / data.plays)
  end
end

function text.deactivate(name, notFade)
  assert(text[name], "A text set by the name '" .. name .. "' doesn't exist.")
  if notFade then
    text[name].alpha = 0
    text[name].active = false
  else
    if text[name].tween then tween.stop(text[name].tween) end
    text[name].tween = tween(0.25, text[name], { alpha = 0 }, nil, function() text[name].active = false end)
  end
end

function text.shadowPrint(string, y, font, alpha, distance, align)
  align = align or "center"
  love.graphics.setFont(font)
  love.graphics.setColor(30, 30, 30, alpha)
  love.graphics.printf(string, 0, y + distance, width + distance, align)
  love.graphics.setColor(255, 255, 255, alpha)
  love.graphics.printf(string, 0, y, width, align)
  love.graphics.setColor(255, 255, 255)
end

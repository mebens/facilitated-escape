local http = require("socket.http")
data = {}
data.plays = 0
data.total = 0
data.best = 0
data.sendData = true
data.first = true
data.changed = false

function data.init()
  if love.filesystem.exists("data.lua") then
    local t = love.filesystem.load("data.lua")()
    data.plays = t.plays
    data.total = t.total
    data.best = t.best
    data.sendData = t.sendData
    data.first = false
  end
end

function data.save()
  local s = [[return {
  plays = %d,
  total = %d,
  best = %d,
  sendData = %s
}]]

  love.filesystem.write("data.lua", s:format(data.plays, data.total, data.best, data.sendData and "true" or "false"))
end

function data.score(distance)
  data.plays = data.plays + 1
  data.total = data.total + distance
  data.first = false
  data.changed = true
  if distance > data.best then data.best = distance end
  data.save()
end

function data.send()
  if data.sendData and data.changed then
    local body = http.request(
      "http://nova-fusion.com/games/facilitated-escape/score.php",
      ("plays=%d&total=%d&best=%d"):format(data.plays, data.total, data.best)
    )
    print(body)
    -- this is so I can turn it all off if I need to
    if body == "STOP" then
      data.sendData = false
      data.save()
    end
  end
end

local http = require("socket.http")
data = {}
data.plays = 0
data.total = 0
data.best = 0
data.first = true

function data.init()
  if love.filesystem.exists("data.lua") then
    local t = love.filesystem.load("data.lua")()
    data.first = false
    if not t then return end
    data.plays = t.plays
    data.total = t.total
    data.best = t.best
  end
end

function data.save()
  local s = [[return {
  plays = %d,
  total = %d,
  best = %d
}]]

  love.filesystem.write("data.lua", s:format(data.plays, data.total, data.best))
end

function data.score(distance)
  data.plays = data.plays + 1
  data.total = data.total + distance
  data.first = false
  if distance > data.best then data.best = distance end
  data.save()
end

function data.onQuit()
  if state == "game" and data.first then love.filesystem.write("data.lua", "") end
end

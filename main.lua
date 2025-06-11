local menu = require("menu")
local Game = require("game")

function love.load()
    love.window.setTitle("fodinha do povo")
    menu.load()
end

function love.update(dt)
    menu.update(dt)
end

function love.draw()
    menu.draw()
end

function love.keypressed(key)
    menu.keypressed(key)
end

function love.mousepressed(x, y, button, isTouch)
    Game.mousepressed(x, y, button)
end

function love.resize(w, h)
    if Game.resize then
        Game.resize(w, h)
    end
end

local Game = require("game")

local menu = {}

-- Estado atual: "main" ou "settings"
local currentScreen = "main"

-- Menu principal
local mainOptions = {"Start", "Como Jogar?" ,"Settings", "Sair"}
local mainSelected = 1

-- Settings
local settingsOptions = {"Fullscreen", "Voltar"}
local settingsSelected = 1
local isFullscreen = false

local musicaFundo



-- Fundo animado
local circles = {}
local numCircles = 20
local colors = {
    {0.4, 0.2, 0.6},
    {0.2, 0.6, 0.8},
    {0.8, 0.4, 0.6},
    {0.3, 0.7, 0.5}
}

local font

local function generateCircles()
    circles = {}
    local w, h = love.graphics.getDimensions()

    for i = 1, numCircles do
        table.insert(circles, {
            x = math.random(0, w),
            y = math.random(0, h),
            radius = math.random(30, 100),
            dx = (math.random() - 0.5) * 50,
            dy = (math.random() - 0.5) * 50,
            color = colors[math.random(#colors)],
            alpha = math.random() * 0.3 + 0.1
        })
    end
end

function menu.load()
    font = love.graphics.newFont(32)
    love.graphics.setFont(font)

    -- Modo janela, mas pega tamanho da tela
    love.window.setMode(800, 600, {fullscreen = false, resizable = true})

    musicaFundo = love.audio.newSource("background_music.ogg", "stream")
    musicaFundo:setLooping(true)
    musicaFundo:setVolume(0.1)
    musicaFundo:play()

    generateCircles()
end

function menu.update(dt)
    if currentScreen == "game" then
        Game.update(dt)
    else
        for _, c in ipairs(circles) do
            c.x = c.x + c.dx * dt
            c.y = c.y + c.dy * dt

            if c.x < -c.radius then c.x = 800 + c.radius end
            if c.x > 800 + c.radius then c.x = -c.radius end
            if c.y < -c.radius then c.y = 600 + c.radius end
            if c.y > 600 + c.radius then c.y = -c.radius end
        end
    end
    
end


function menu.draw()
    if currentScreen == "game" then
        Game.draw()
        return
    end

    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Fundo
    love.graphics.clear(0.05, 0.05, 0.1)
    for _, c in ipairs(circles) do
        love.graphics.setColor(c.color[1], c.color[2], c.color[3], c.alpha)
        love.graphics.circle("fill", c.x, c.y, c.radius)
    end

    love.graphics.setColor(1, 1, 1)

    if currentScreen == "main" then
        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.printf("F#dinha", 0, 60, screenWidth, "center")

        love.graphics.setFont(font)
        for i, option in ipairs(mainOptions) do
            if i == mainSelected then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.printf(option, 0, 200 + (i * 50), screenWidth, "center")
        end

    elseif currentScreen == "settings" then
        love.graphics.setFont(love.graphics.newFont(40))
        love.graphics.printf("Settings", 0, 60, screenWidth, "center")

        love.graphics.setFont(font)
        for i, option in ipairs(settingsOptions) do
            local display = option
            if option == "Fullscreen" then
                local check = isFullscreen and "[✔] " or "[ ] "
                display = check .. "Fullscreen"
            end

            if i == settingsSelected then
                love.graphics.setColor(1, 1, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end

            love.graphics.printf(display, 0, 200 + (i * 50), screenWidth, "center")
        end
    end
end


function menu.keypressed(key)
    if currentScreen == "main" then
        if key == "down" then
            mainSelected = mainSelected % #mainOptions + 1
        elseif key == "up" then
            mainSelected = (mainSelected - 2) % #mainOptions + 1
        elseif key == "return" or key == "kpenter" then
            local selectedOption = mainOptions[mainSelected]
            if selectedOption == "Start" then
                musicaFundo:stop()
                Game.load()
                currentScreen = "game"
            elseif selectedOption == "Settings" then
                currentScreen = "settings"
            elseif selectedOption == "Sair" then
                love.event.quit()
            end
        end

    elseif currentScreen == "settings" then
        if key == "down" then
            settingsSelected = settingsSelected % #settingsOptions + 1
        elseif key == "up" then
            settingsSelected = (settingsSelected - 2) % #settingsOptions + 1
        elseif key == "return" or key == "kpenter" then
            local selected = settingsOptions[settingsSelected]
            if selected == "Fullscreen" then
                isFullscreen = not isFullscreen
                love.window.setFullscreen(isFullscreen)
                generateCircles()
            elseif selected == "Voltar" then
                currentScreen = "main"
            end
        end
    end
end

return menu

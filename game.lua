local Baralho = require("baralho")
local Game = {}

local players = {}
local cartasImage

local virarSom
local cardMovementSom
local pickCardSom

local estado = "carregando"
local transicaoAlpha = 1
local tempoTransicao = 1

local timer = 0  -- Variável para controle de tempo
local animacoes = {}

local gameMusicBackground

local cartaW, cartaH = Baralho.cartaW, Baralho.cartaH

local mx, my = love.mouse.getPosition()

local deckSprite = {
    x = 0,
    y = 0,
    width = 54,
    height = 64 
}

local playerAvatars = {}



local botoes = {
    {
        texto = "Distribuir",
        x = 0, y = 0, width = 150, height = 40,
        acao = function() Game.distribuirCartasParaTodos() end
    },
    {
        texto = "Virar",
        x = 0, y = 0, width = 100, height = 40,
        acao = function() Game.testeTouchCard() end
    },
    {
        texto = "Recolher",
        width = 150, 
        height = 40,
        acao = function() 
            Game.iniciarAnimacaoRecolher() 
        end
    }
    -- Adicione mais botões conforme necessário
}

function Game.testeDistribuir()
    print("clicado distribuir")
end
    
function Game.testeTouchCard()
    pickCardSom:play()
    print("clicado touch card")
end

function Game.iniciarAnimacaoRecolher()
    for _, player in ipairs(players) do
        for _, carta in ipairs(player.cartas) do
            -- INSERÇÃO na tabela de animações (animação de volta)
            table.insert(animacoes, {
                carta = carta,
                startX = carta.x, -- Começa da posição atual
                startY = carta.y,
                destinoX = deckSprite.x + deckSprite.width/2 - cartaW/2, -- Volta pro deck
                destinoY = deckSprite.y + deckSprite.height/2 - cartaH/2,
                tempo = 0,
                duracao = 0.8,
                recolhendo = true, -- Flag importante!
                scaleStart = 1.0,  -- Efeito opcional de encolher
                scaleEnd = 0.5
            })
        end
    end
end

function Game.posicionarBotoes()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local margin = 20  -- Margem lateral
    local spacing = 150  -- Espaço entre botões
    local totalWidth = 0

    -- Calcula a largura total dos botões
    for _, btn in ipairs(botoes) do
        totalWidth = totalWidth + btn.width + spacing
    end
    totalWidth = totalWidth - spacing  -- Remove o último espaçamento

    -- Centraliza horizontalmente e posiciona no rodapé
    local startX = (screenWidth - totalWidth) / 2
    local startY = screenHeight - 50  -- 50px do fundo

    -- Define as posições de cada botão
    for i, btn in ipairs(botoes) do
        btn.x = startX + (i-1) * (btn.width + spacing)
        btn.y = startY
    end
end

function Game.load()

    Baralho.load()

    Game.playMusic()
    virarSom = love.audio.newSource("sfx/virar.wav", "static")
    virarSom:setVolume(0.6)

    cardMovementSom = love.audio.newSource("sfx/card_movement.wav", "static")
    cardMovementSom:setVolume(1.0)
    cardMovementSom:setLooping(false)

    pickCardSom = love.audio.newSource("sfx/pick_card.ogg", "static")
    pickCardSom:setVolume(1.0)
    pickCardSom:setLooping(false)



    local deck = Baralho.getDeck()

    -- Inicializar jogadores (sem posições ainda)
    for i = 1, 4 do
        local cartas = {}
        for j = 1, 2 do
            local nome = table.remove(deck)
            local virada = i == 4 -- jogador 4 (você) vê as cartas
            table.insert(cartas, {
                nome = nome,
                virada = virada,
                anim = -100 * j,
                selecionada = false
            })
        end

        local nomeJogador = ""
        if i == 4 then
            nomeJogador = "Arthur"
        else
            nomeJogador = "Jogador " .. i
        end
        table.insert(players, {
            cartas = cartas,
            nome = nomeJogador,
        })
        local img = love.graphics.newImage("sprites/players/player" .. i .. ".png")
        img:setFilter("nearest", "nearest")
        table.insert(playerAvatars, img)
    end

    Game.virarSomPool = {}
    for i = 1, #players * 2 do
        local s = love.audio.newSource("sfx/virar.wav", "static")
        s:setVolume(0.6)
        Game.virarSomPool[i] = s
    end

    -- Agora calcula as posições
    Game.updatePlayerPositions()
    Game.posicionarBotoes()

    -- Posiciona o deck no centro da tela
    local screenWidth, screenHeight = love.graphics.getDimensions()
    deckSprite.x = (screenWidth / 2) - (deckSprite.width / 2)
    deckSprite.y = (screenHeight / 2) - (deckSprite.height / 2)

    estado = "animando"
    transicaoAlpha = 1
end

function Game.mousepressed(x, y, button)
    if button == 1 then
        -- Checa botões primeiro
        for _, btn in ipairs(botoes) do
            if x >= btn.x and x <= btn.x + btn.width and
               y >= btn.y and y <= btn.y + btn.height then
                btn.acao()
                return
            end
        end

        -- Verifica clique nas cartas do jogador 4
        local jogador = players[4]
        for _, carta in ipairs(jogador.cartas) do
            if x >= carta.x and x <= carta.x + cartaW and
               y >= carta.y and y <= carta.y + cartaH then

                if carta.selecionada then
                    carta.selecionada = false -- toggle: desmarca
                else
                    -- desmarca todas
                    for _, c in ipairs(jogador.cartas) do
                        c.selecionada = false
                    end
                    carta.selecionada = true
                end

                -- move carta pro topo (última na lista)
                for i = #jogador.cartas, 1, -1 do
                    if jogador.cartas[i] == carta then
                        table.remove(jogador.cartas, i)
                        table.insert(jogador.cartas, carta)
                        break
                    end
                end

                break
            end
        end
    end
end


function Game.resize(w, h)
    Game.updatePlayerPositions()
    Game.posicionarBotoes()
    deckSprite.x = (w / 2) - (deckSprite.width / 2)
    deckSprite.y = (h / 2) - (deckSprite.height / 2)
end

function Game.playMusic()
    gameMusicBackground = love.audio.newSource("game_music.ogg", "stream")
    gameMusicBackground:setLooping(true)
    gameMusicBackground:setVolume(0.1)
    gameMusicBackground:play()
end

function Game.updatePlayerPositions()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    -- Posições dos 4 jogadores
    local posicoes = {
        {x = 150, y = 100},                                 -- topo-esquerda
        {x = screenWidth - 150, y = 100},                   -- topo-direita
        {x = 150, y = screenHeight - 200},                  -- baixo-esquerda
        {x = screenWidth - 150, y = screenHeight - 200}     -- baixo-direita
    }
    
    -- Atualizar posições dos jogadores e suas cartas
    for i, player in ipairs(players) do
        player.x = posicoes[i].x
        player.y = posicoes[i].y
        
        for j, carta in ipairs(player.cartas) do
            carta.x = posicoes[i].x + (j - 1) * 30
            carta.y = posicoes[i].y
        end
    end
end

local virarIndex = 1
function Game.playVirarSom()
    local som = Game.virarSomPool[virarIndex]
    print("entro")
    if som:isPlaying() then
        print("IS PLAYING")
        som:stop()
    end
    som:play()
    print("PLAYO AGAIN")
    virarIndex = virarIndex % #Game.virarSomPool + 1
end

function Game.distribuirCartasParaTodos()
    local deck = Baralho.getDeck()
    local poolIndex = 1
    
    for i, player in ipairs(players) do
        player.cartas = {}
        for j = 1, 2 do
            local cartaNome = table.remove(deck)
            local souEu = (i == #players)

            if Game.soundPool then
                -- print("ERRO CRÍTICO: Game.soundPool não existe!")
                -- return
            end
            
            -- if Game.soundPool and Game.soundPool[poolIndex] then
            --    Game.soundPool[poolIndex]:stop()
            --    Game.soundPool[poolIndex]:play()
           --     poolIndex = poolIndex + 1  -- Avança para o próximo som
            --else
            --    print("Aviso: Sound pool esgotado ou não inicializado")
            --end 

            
            
            local novaCarta = {
                nome = cartaNome,
                virada = false,
                x = deckSprite.x + deckSprite.width/2 - cartaW/2,
                y = deckSprite.y + deckSprite.height/2 - cartaH/2,
                dono = i
                -- Removido o .som da carta pois não é mais necessário
            }
            
            table.insert(player.cartas, novaCarta)
            
            table.insert(animacoes, {
                carta = novaCarta,
                startX = deckSprite.x + deckSprite.width/2 - cartaW/2,
                startY = deckSprite.y + deckSprite.height/2 - cartaH/2,
                destinoX = player.x + (j-1) * 30,
                destinoY = player.y,
                tempo = 0,
                duracao = 0.6,
                delay = (i-1)*0.3,
                dono = i,
                virarSeForHumano = souEu
            })
        end
    end
end


function Game.update(dt)
    timer = timer + dt
    local mx, my = love.mouse.getPosition()

    if estado == "animando" then
        transicaoAlpha = transicaoAlpha - dt / tempoTransicao
        if transicaoAlpha <= 0 then
            transicaoAlpha = 0
            estado = "pronto"
        end
    end
    for i = #animacoes, 1, -1 do
        local anim = animacoes[i]
        
        -- Atualiza o tempo da animação (com tratamento de delay)
        if anim.delay and anim.delay > 0 then
            anim.delay = anim.delay - dt
        else
            anim.tempo = anim.tempo + dt
            local progresso = math.min(anim.tempo / anim.duracao, 1)
            
            -- Easing diferente para distribuição (ease-out) e recolhimento (ease-in)
            progresso = anim.recolhendo and progresso^2 or progresso * progresso * (3 - 2 * progresso)
            
            -- Interpolação de posição
            anim.carta.x = anim.startX + (anim.destinoX - anim.startX) * progresso
            anim.carta.y = anim.startY + (anim.destinoY - anim.startY) * progresso
            
            -- Interpolação de escala (opcional)
            if anim.scaleStart then
                anim.carta.scale = anim.scaleStart + (anim.scaleEnd - anim.scaleStart) * progresso
            end
            
            -- Finalização
            if progresso == 1 then
                if anim.virarSeForHumano then
                    anim.carta.virada = true 
                end
                virarSom:play()
                table.remove(animacoes, i)
            end
        end
    end
    for _, carta in ipairs(players[4].cartas) do
        carta.hover = false

        -- só detecta hover em carta virada (aberta)
        if carta.virada and
        mx >= carta.x and mx <= carta.x + cartaW and
        my >= carta.y and my <= carta.y + cartaH then
            carta.hover = true
        end
    end
end

function Game.draw()
    -- Fundo da mesa (verde)
    love.graphics.clear(0.1, 0.5, 0.1)

    -- Desenhar avatares e nomes dos jogadores
    for i, player in ipairs(players) do
        local avatar = playerAvatars[i]
        if avatar and player.x and player.y then
            local scale = 2
            local avatarW = avatar:getWidth()
            local avatarH = avatar:getHeight()
            local offsetX = -avatarW * scale - 10
            local offsetY = 0

            love.graphics.draw(
                avatar,
                player.x + offsetX,
                player.y + offsetY,
                0,
                scale, scale
            )

            local nome = player.nome or ("Jogador " .. i)
            local font = love.graphics.getFont()
            local textWidth = font:getWidth(nome)
            local textHeight = font:getHeight()

            love.graphics.setColor(1, 1, 1)
            love.graphics.print(
                nome,
                player.x + offsetX + (avatarW * scale - textWidth) / 2,
                player.y + offsetY + avatarH * scale + 5
            )
        end
    end

    -- Desenha cartas em animação (sempre mostra costas)
    for _, anim in ipairs(animacoes) do
        local img = Baralho.getImage("Costas")
        love.graphics.draw(img, anim.carta.x, anim.carta.y)
    end

    -- Desenha cartas com escala durante animação
    for _, anim in ipairs(animacoes) do
        local img = Baralho.getImage(anim.carta.virada and anim.carta.nome or "Costas")
        local scale = anim.carta.scale or 1.0
        love.graphics.draw(
            img,
            anim.carta.x + cartaW / 2 * (1 - scale),
            anim.carta.y + cartaH / 2 * (1 - scale),
            0,
            scale, scale
        )
    end

    -- Desenha cartas estáticas (fora da animação)
    for i, player in ipairs(players) do
        for _, carta in ipairs(player.cartas) do
            -- Verifica se a carta está sendo animada
            local estaAnimando = false
            for _, anim in ipairs(animacoes) do
                if anim.carta == carta then
                    estaAnimando = true
                    break
                end
            end

            if not estaAnimando then
                local img = carta.virada and Baralho.getImage(carta.nome) or Baralho.getImage("Costas")
                local offsetY = carta.selecionada and -10 or 0
                local scale = carta.hover and 1.2 or 1.0
                local originX = cartaW / 2
                local originY = cartaH / 2

                love.graphics.draw(
                    img,
                    carta.x + originX,
                    carta.y + offsetY + originY,
                    0,
                    scale,
                    scale,
                    originX,
                    originY
                )

                if carta.selecionada then
                    love.graphics.setColor(1, 1, 0.4, 0.6)
                    love.graphics.setLineWidth(2)
                    love.graphics.rectangle(
                        "line",
                        carta.x, carta.y + offsetY,
                        cartaW, cartaH,
                        6, 6
                    )
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setLineWidth(1)
                end



                -- Efeito de brilho para carta selecionada
                if carta.selecionada then
                    love.graphics.setColor(1, 1, 0.4, 0.6)
                    love.graphics.setLineWidth(2)
                    love.graphics.rectangle("line", carta.x, carta.y + offsetY, cartaW, cartaH, 6, 6)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setLineWidth(1)
                end
            end
        end
    end

    -- Desenha o deck
    local deckImage = Baralho.getImage("Deck")
    if deckImage then
        love.graphics.draw(deckImage, deckSprite.x, deckSprite.y)
    else
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", deckSprite.x, deckSprite.y, deckSprite.width, deckSprite.height)
        love.graphics.setColor(1, 1, 1)
    end

    -- Botões
    for _, btn in ipairs(botoes) do
        love.graphics.setColor(0.4, 0.6, 1)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height, 5, 5)

        love.graphics.setColor(0, 0, 0)
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(btn.texto)
        local textHeight = font:getHeight()
        love.graphics.print(
            btn.texto,
            btn.x + (btn.width - textWidth) / 2,
            btn.y + (btn.height - textHeight) / 2
        )
    end

    love.graphics.setColor(1, 1, 1)

    -- Transição de fade-in
    if estado == "animando" then
        love.graphics.setColor(0, 0, 0, transicaoAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
    end
end



function Game.keypressed(key)
    -- Apenas para depuração: apertar espaço vira as cartas do jogador
    if key == "space" then
        for _, carta in ipairs(players[4].cartas) do
            carta.virada = not carta.virada
        end
    end
end

return Game

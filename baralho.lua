local Baralho = {}

local cartaW, cartaH = 48, 64
local sprites = {}
local imagens = {}
local naipes = {"c", "o", "e", "p"}

local valores = {"a", "2", "3", "4", "5", "6", "7", "j", "q", "k"}

function Baralho.load()
    for _, naipe in ipairs(naipes) do
        for _, valor in ipairs(valores) do
            local nomeArquivo = "sprites/baralho/" .. valor .. "-" .. naipe .. ".png"
            local nomeChave = valor .. "-" .. naipe

            -- Carrega a imagem
            local img = love.graphics.newImage(nomeArquivo)
            imagens[nomeChave] = img
            -- print(nomeChave)

            -- print("ok Carregada:", nomeArquivo)
        end
    end

    -- Carregar imagem da costas e Deck da massa
    imagens["Costas"] = love.graphics.newImage("sprites/baralho/costas.png")
    imagens["Deck"] = love.graphics.newImage("sprites/baralho/deck.png") 

end

-- Retorna a imagem da carta pelo nome
function Baralho.getImage(nome)
    if not imagens[nome] then
        --print("X Carta não encontrada:", nome)
        return
    end
    return imagens[nome]
end

-- Retorna um deck embaralhado
function Baralho.getDeck()
    local deck = {}

    for _, naipe in ipairs(naipes) do
        for _, valor in ipairs(valores) do
            table.insert(deck, valor .. "-" .. naipe)
        end
    end

    -- Embaralhar
    for i = #deck, 2, -1 do
        local j = love.math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end

    return deck
end


Baralho.cartaW = cartaW  -- Adiciona as dimensões à tabela Baralho
Baralho.cartaH = cartaH
return Baralho


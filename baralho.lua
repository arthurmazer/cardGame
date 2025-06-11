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

function Baralho.getCardName(nome)
    if nome == "a-c" then
        return "Ás de Copas"
    elseif nome == "a-o" then
        return "Ás de Ouro"
    elseif nome == "a-e" then
        return "Ás de Espada"
    elseif nome == "a-p" then
        return "Ás de Paus"

    elseif nome == "2-c" then
        return "2 de Copas"
    elseif nome == "2-o" then
        return "2 de Ouro"
    elseif nome == "2-e" then
        return "2 de Espada"
    elseif nome == "2-p" then
        return "2 de Paus"

    elseif nome == "3-c" then
        return "3 de Copas"
    elseif nome == "3-o" then
        return "3 de Ouro"
    elseif nome == "3-e" then
        return "3 de Espada"
    elseif nome == "3-p" then
        return "3 de Paus"

    elseif nome == "4-c" then
        return "4 de Copas"
    elseif nome == "4-o" then
        return "4 de Ouro"
    elseif nome == "4-e" then
        return "4 de Espada"
    elseif nome == "4-p" then
        return "4 de Paus"

    elseif nome == "5-c" then
        return "5 de Copas"
    elseif nome == "5-o" then
        return "5 de Ouro"
    elseif nome == "5-e" then
        return "5 de Espada"
    elseif nome == "5-p" then
        return "5 de Paus"

    elseif nome == "6-c" then
        return "6 de Copas"
    elseif nome == "6-o" then
        return "6 de Ouro"
    elseif nome == "6-e" then
        return "6 de Espada"
    elseif nome == "6-p" then
        return "6 de Paus"

    elseif nome == "7-c" then
        return "7 de Copas"
    elseif nome == "7-o" then
        return "7 de Ouro"
    elseif nome == "7-e" then
        return "7 de Espada"
    elseif nome == "7-p" then
        return "7 de Paus"

    elseif nome == "q-c" then
        return "Dama de Copas"
    elseif nome == "q-o" then
        return "Dama de Ouro"
    elseif nome == "q-e" then
        return "Dama de Espada"
    elseif nome == "q-p" then
        return "Dama de Paus"
    
    elseif nome == "j-c" then
        return "Valete de Copas"
    elseif nome == "j-o" then
        return "Valete de Ouro"
    elseif nome == "j-e" then
        return "Valete de Espada"
    elseif nome == "j-p" then
        return "Valete de Paus"

    elseif nome == "k-c" then
        return "Rei de Copas"
    elseif nome == "k-o" then
        return "Rei de Ouro"
    elseif nome == "k-e" then
        return "Rei de Espada"
    elseif nome == "k-p" then
        return "Rei de Paus"
    end

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


-- // O CARRASCO HUMANO: PÉ-CRUZ E FLING DIRETO //
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

getgenv().AlvoCrucificado = nil 
getgenv().ModoMira = false
getgenv().MinhaCruzAtiva = false

-- Função 1: Transformar o TEU corpo na cruz (Network Ownership)
local function virarCruzHumana()
    local char = LocalPlayer.Character
    if not char then return end
    local torso = char:FindFirstChild("Torso")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if not torso or not humanoid then return end

    -- Desliga a física normal (ele não cai, fica parado em pose)
    humanoid.PlatformStand = true
    
    -- Braços pra fora
    if torso:FindFirstChild("Right Shoulder") then
        torso["Right Shoulder"].C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, 0, math.rad(-90))
        torso["Left Shoulder"].C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90))
    end
    
    -- Pernas retas pra baixo
    if torso:FindFirstChild("Right Hip") then
        torso["Right Hip"].C0 = CFrame.new(1, -1, 0)
        torso["Left Hip"].C0 = CFrame.new(-1, -1, 0)
    end
    
    getgenv().MinhaCruzAtiva = true
    print("[Carrasco]: Corpo virou cruz. Os outros jogadores devem estar vendo.")
end

-- Função 2: Pregar a vítima no teu pé (sem parte, só colando nela)
local function prenderNoPe(vitima)
    local charVitima = vitima.Character or vitima
    local meuChar = LocalPlayer.Character
    if not meuChar then return end
    
    local rootVitima = charVitima:FindFirstChild("HumanoidRootPart")
    local meuTorso = meuChar:FindFirstChild("Torso")
    
    if rootVitima and meuTorso then
        -- Trava a vítima no teu pé
        rootVitima.Anchored = true
        rootVitima.CFrame = meuTorso.CFrame * CFrame.new(0, -2.5, 0) -- Cola no pé
        
        -- Abre os braços da vítima pra ficar de cruz
        local torsoVitima = charVitima:FindFirstChild("Torso")
        if torsoVitima and torsoVitima:FindFirstChild("Right Shoulder") then
            torsoVitima["Right Shoulder"].C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, 0, math.rad(-90))
            torsoVitima["Left Shoulder"].C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, 0, math.rad(90))
        end
        
        getgenv().AlvoCrucificado = charVitima
        print("[Carrasco]: " .. vitima.Name .. " pregado no teu pé.")
    end
end

-- Função 3: Fling Direto (A parte invisível gira sem âncora)
local function executarFling()
    local alvo = getgenv().AlvoCrucificado
    if not alvo or not alvo.Parent then return end
    
    local root = alvo:FindFirstChild("HumanoidRootPart")
    local humanoid = alvo:FindFirstChild("Humanoid")
    
    if root and humanoid then
        print("[Carrasco]: Fling executado. Criando vórtice invisível no pé.")
        
        -- Tira a âncora do cara pra física agir
        root.Anchored = false 
        
        -- Cria a parte invisível que vai quebrar a física
        local parteMorte = Instance.new("Part")
        parteMorte.Name = "FlingPart"
        parteMorte.Size = Vector3.new(2, 2, 2)
        parteMorte.Transparency = 1
        parteMorte.CanCollide = true
        parteMorte.Anchored = false -- SOLTA, SEM ÂNCORA
        parteMorte.Massless = true
        -- Nasce exatamente no pé, onde a vítima tá presa
        parteMorte.CFrame = root.CFrame 
        parteMorte.Parent = workspace
        
        -- Aplica a velocidade do caos (a parte e o cara)
        parteMorte.Velocity = Vector3.new(math.random(-5000, 5000), math.random(5000, 10000), math.random(-5000, 5000))
        parteMorte.RotVelocity = Vector3.new(math.random(-50000, 50000), math.random(-50000, 50000), math.random(-50000, 50000))
        
        root.Velocity = parteMorte.Velocity
        root.RotVelocity = parteMorte.RotVelocity
        humanoid.Health = 0 -- Tenta matar na hora
        
        -- Limpa a parte depois de 2 segundos
        task.delay(2, function()
            if parteMorte and parteMorte.Parent then parteMorte:Destroy() end
        end)
        
        getgenv().AlvoCrucificado = nil
    end
    
    -- Destrava o teu corpo (volta ao normal)
    local meuChar = LocalPlayer.Character
    if meuChar and meuChar:FindFirstChild("Humanoid") then
        meuChar.Humanoid.PlatformStand = false
    end
    getgenv().MinhaCruzAtiva = false
end

-- [GUI]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 160)
Frame.Position = UDim2.new(0.5, -125, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local BtnCruz = Instance.new("TextButton")
BtnCruz.Size = UDim2.new(1, -20, 0, 35)
BtnCruz.Position = UDim2.new(0, 10, 0, 10)
BtnCruz.BackgroundColor3 = Color3.fromRGB(150, 50, 0)
BtnCruz.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnCruz.Text = "1. Meu Corpo Vira Cruz"
BtnCruz.Font = Enum.Font.SourceSansBold
BtnCruz.Parent = Frame

local BtnPegar = Instance.new("TextButton")
BtnPegar.Size = UDim2.new(1, -20, 0, 35)
BtnPegar.Position = UDim2.new(0, 10, 0, 50)
BtnPegar.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
BtnPegar.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnPegar.Text = "2. Mirar e Crucificar no Pé"
BtnPegar.Font = Enum.Font.SourceSansBold
BtnPegar.Parent = Frame

local BtnFling = Instance.new("TextButton")
BtnFling.Size = UDim2.new(1, -20, 0, 35)
BtnFling.Position = UDim2.new(0, 10, 0, 90)
BtnFling.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
BtnFling.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFling.Text = "3. Executar Fling Fatal"
BtnFling.Font = Enum.Font.SourceSansBold
BtnFling.Parent = Frame

-- Lógica
BtnCruz.MouseButton1Click:Connect(function()
    virarCruzHumana()
end)

BtnPegar.MouseButton1Click:Connect(function()
    getgenv().ModoMira = true
    print("[Carrasco]: Clique no jogador pra prender no teu pé.")
end)

BtnFling.MouseButton1Click:Connect(function()
    executarFling()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not getgenv().ModoMira then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        getgenv().ModoMira = false
        
        local mouse = LocalPlayer:GetMouse()
        local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, (mouse.Hit.p - workspace.CurrentCamera.CFrame.Position).Unit * 500)
        local part, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
        
        if part and part.Parent:FindFirstChild("Humanoid") then
            prenderNoPe(part.Parent)
        else
            print("[Carrasco]: Tu não clicou em um jogador.")
        end
    end
end)

print("[Sistema]: O Carrasco Humano carregado.")

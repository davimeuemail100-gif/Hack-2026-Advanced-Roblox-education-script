-- // A ABERRAÇÃO V2: PERNAS NA MÃO, MOVIMENTO LIVRE E FLING //
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().AberracaoAtiva = false
getgenv().BracoDaCruz = nil
getgenv().BV = nil

local function ativarAberracao()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local torso = char:FindFirstChild("Torso")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not torso or not rootPart then return end
    
    getgenv().AberracaoAtiva = true
    print("[Aberração]: Desmembrando e destravando a locomoção...")

    local pernaD = char:FindFirstChild("Right Leg")
    local bracoD = char:FindFirstChild("Right Arm")
    
    if pernaD and bracoD and torso then
        -- 1. Solta as juntas
        local juntaPerna = pernaD:FindFirstChild("Right Hip")
        if juntaPerna then juntaPerna:Destroy() end
        
        local juntaBraco = bracoD:FindFirstChild("Right Shoulder")
        if juntaBraco then juntaBraco:Destroy() end
        
        -- 2. Perna vira a cruz na mão
        pernaD.Size = Vector3.new(1, 5, 1) 
        local solda = Instance.new("Weld")
        solda.Part0 = bracoD
        solda.Part1 = pernaD
        solda.C0 = CFrame.new(0, -2.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        solda.Parent = bracoD
        getgenv().BracoDaCruz = pernaD
        
        -- 3. O Fling no toque da perna
        pernaD.Touched:Connect(function(hit)
            if not getgenv().AberracaoAtiva then return end
            
            local vitima = hit.Parent
            if vitima ~= char and vitima:FindFirstChild("Humanoid") then
                local rootVitima = vitima:FindFirstChild("HumanoidRootPart")
                local humanoidVitima = vitima:FindFirstChild("Humanoid")
                
                if rootVitima and humanoidVitima then
                    print("[Aberração]: Toque letal em " .. vitima.Name)
                    rootVitima.Anchored = false
                    humanoidVitima.Health = 0
                    
                    local pFling = Instance.new("Part")
                    pFling.Size = Vector3.new(2,2,2)
                    pFling.Transparency = 1
                    pFling.CanCollide = false
                    pFling.Anchored = false
                    pFling.CFrame = rootVitima.CFrame
                    pFling.Parent = workspace
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = pFling
                    weld.Part1 = rootVitima
                    weld.Parent = pFling
                    
                    pFling.AssemblyAngularVelocity = Vector3.new(math.huge, math.huge, math.huge)
                    pFling.AssemblyLinearVelocity = Vector3.new(0, 2000, 0)
                    
                    task.delay(2, function()
                        if pFling and pFling.Parent then pFling:Destroy() end
                    end)
                end
            end
        end)
        
        -- 4. O FIX DE MOVIMENTO (Deslizar)
        -- Cria uma força que empurra o boneco na direção da câmera
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 0, 1e5) -- Não empurra pra cima (Y=0)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = rootPart
        getgenv().BV = bv
        
        -- Loop que atualiza a velocidade baseada nas teclas apertadas
        RunService.RenderStepped:Connect(function()
            if not getgenv().AberracaoAtiva or not getgenv().BV then return end
            if not char or not char.Parent or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local camera = workspace.CurrentCamera
            local moveVector = Vector3.new(0,0,0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += camera.CFrame.RightVector end
            
            if moveVector.Magnitude > 0 then
                moveVector = moveVector.Unit * 30 -- Velocidade de deslize
            end
            
            getgenv().BV.Velocity = moveVector
        end)
        
        print("[Aberração]: Cruz montada no braço. Movimento liberado.")
    end
end

-- [GUI]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 60)
Frame.Position = UDim2.new(0.5, -125, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(1, -20, 0, 40)
Btn.Position = UDim2.new(0, 10, 0, 10)
Btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.Text = "ATIVAR ABERRAÇÃO (E ANDAR)"
Btn.Font = Enum.Font.SourceSansBold
Btn.Parent = Frame

Btn.MouseButton1Click:Connect(function()
    if not getgenv().AberracaoAtiva then
        ativarAberracao()
        Btn.Text = "DESATIVAR (Resetar)"
    else
        getgenv().AberracaoAtiva = false
        if getgenv().BV then getgenv().BV:Destroy() end
        LocalPlayer.Character:BreakJoints()
        Btn.Text = "ATIVAR ABERRAÇÃO (E ANDAR)"
    end
end)

-- Suporte pra Mobile (Joystick na tela)
if UserInputService.TouchEnabled then
    -- Se for mobile, a gente usa a direção da câmera + toque
    -- O BodyVelocity já vai seguir a câmera, mas pra mobile o ideal é usar o thumbstick
    -- A lógica base do W, A, S, D já cobre o teclado.
    print("[Aberração]: Modo Mobile detectado. Para andar no celular, você pode usar a câmera e o comando de toque.")
end

print("[Sistema]: A Aberração V2 carregada.")

-- ===================== Copiar site da chave para a área de transferência =====================
pcall(function()
    if setclipboard then
        setclipboard('https://scriptsrbx.com/key/')
    end
end)

-- ===================== Carregar UI Rayfield =====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ===================== UI =====================
local Window = Rayfield:CreateWindow({
    Nome = 'Auto Farm | ScriptsRBX',
    LoadingTitle = 'ScriptsRBX.com Auto Farm',
    CarregandoSubtítulo = 'ScriptsRBX',
    Tema = 'Padrão',
    ExibirTexto = 'Interface gráfica automática da fazenda',
    Alternar atalho de teclado da interface do usuário = 'K',
    KeySystem = false,
})

local Tab = Window:CreateTab('Principal', 4483362458)

-- ===================== Serviços =====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function obterCaractere()
    return player.Character or player.CharacterAdded:Wait()
end

-- ===================== TELEPORTE =====================
local function teleportToInstance(inst)
    if not inst then return end
    local char = obterCaractere()
    if not char then return end

    if inst:IsA("Model") then
        char:PivotTo(inst:GetPivot() * CFrame.new(0, 5, 0))
    elseif inst:IsA("BasePart") then
        char:PivotTo(inst.CFrame * CFrame.new(0, 5, 0))
    end
end

-- ===================== TRAZER ITEM =====================
local function bringToPlayer(inst)
    if not inst then return end
    local char = obterCaractere()
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if inst:IsA("Model") and inst.PrimaryPart then
        inst:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 3, 0))
    elseif inst:IsA("BasePart") then
        inst.CFrame = root.CFrame * CFrame.new(0, 3, 0)
    end
end

-- ===================== DADOS =====================
local CarryableNames = {}
local CrateMap = {}
local CrateNames = {}
local GiftMap = {}
local GiftNames = {}

-- ===================== ATUALIZAR LISTAS =====================
local function refreshLists()
    table.clear(CarryableNames)
    table.clear(CrateMap)
    table.clear(CrateNames)
    table.clear(GiftMap)
    table.clear(GiftNames)

    local carryables = workspace:FindFirstChild("_Carryables")
    if carryables then
        local seen = {}
        for _, model in ipairs(carryables:GetChildren()) do
            if model:IsA("Model") and not seen[model.Name] then
                seen[model.Name] = true
                table.insert(CarryableNames, model.Name)
            end
        end
    end
    table.sort(CarryableNames)
end

refreshLists()

-- ===================== FUNÇÕES AUXILIARES =====================
local function findCarryableByName(name)
    local carryables = workspace:FindFirstChild("_Carryables")
    if not carryables then return nil end

    for _, model in ipairs(carryables:GetChildren()) do
        if model:IsA("Model") and model.Name == name then
            return model
        end
    end
    return nil
end

-- ===================== ELEMENTOS DA INTERFACE =====================
local SelectedCarryable = nil

-- ---- Dropdown de itens ----
local CarryableDropdown = Tab:CreateDropdown({
    Nome = "Selecionar Item",
    Opções = CarryableNames,
    OpçãoAtual = { CarryableNames[1] },
    Callback = function(opcoes)
        SelectedCarryable = opcoes[1]
    end
})

-- ---- Botão para trazer item ----
Tab:CreateButton({
    Nome = "Trazer item selecionado até mim",
    Callback = function()
        if not SelectedCarryable then return end
        refreshLists()
        CarryableDropdown:Refresh(CarryableNames)

        local alvo = findCarryableByName(SelectedCarryable)
        if not alvo then
            Rayfield:Notify({ Title="Bring Item", Content="Item não encontrado", Duration=2 })
            return
        end
        bringToPlayer(alvo)
    end
})

-- ---- Auto Farm invertido ----
local AutoFarmBring = false
Tab:CreateToggle({
    Nome = "Auto Farm (trazer itens até mim)",
    EstadoAtual = false,
    Callback = function(Value)
        AutoFarmBring = Value
        if AutoFarmBring then
            Rayfield:Notify({ Title="Auto Farm", Content="Ativado", Duration=2 })
        else
            Rayfield:Notify({ Title="Auto Farm", Content="Desativado", Duration=2 })
        end

        task.spawn(function()
            while AutoFarmBring do
                task.wait(2)
                refreshLists()
                if SelectedCarryable then
                    local alvo = findCarryableByName(SelectedCarryable)
                    if alvo then
                        bringToPlayer(alvo)
                    end
                end
            end
        end)
    end
})

-- ===================== Copy key site to clipboard =====================
pcall(function()
    if setclipboard then
        setclipboard('https://scriptsrbx.com/key/')
    end
end)

-- ===================== Load Rayfield UI =====================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ===================== UI =====================
local Window = Rayfield:CreateWindow({
    Name = 'Auto Farm | ScriptsRBX',
    LoadingTitle = 'ScriptsRBX.com Auto Farm',
    LoadingSubtitle = 'ScriptsRBX',
    Theme = 'Default',
    ConfigFolder = 'AutoFarmConfig',
    KeySystem = false,
})

local Tab = Window:CreateTab('Main', 4483362458)

-- ===================== Services =====================
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- ===================== Teleport =====================
local function teleportToInstance(inst)
    if not inst then return end
    local char = getCharacter()
    if not char then return end

    if inst:IsA("Model") then
        char:PivotTo(inst:GetPivot() * CFrame.new(0, 5, 0))
    elseif inst:IsA("BasePart") then
        char:PivotTo(inst.CFrame * CFrame.new(0, 5, 0))
    end
end

-- ===================== Bring Item =====================
local function bringToPlayer(inst)
    if not inst then return end
    local char = getCharacter()
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if inst:IsA("Model") and inst.PrimaryPart then
        inst:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 3, 0))
    elseif inst:IsA("BasePart") then
        inst.CFrame = root.CFrame * CFrame.new(0, 3, 0)
    end
end

-- ===================== Data =====================
local CarryableNames = {}

local function refreshLists()
    table.clear(CarryableNames)
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

-- ===================== Helpers =====================
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

-- ===================== UI Elements =====================
local SelectedCarryable = nil

-- Dropdown
local CarryableDropdown = Tab:CreateDropdown({
    Name = "Select Item",
    Options = CarryableNames,
    CurrentOption = { CarryableNames[1] },
    Callback = function(option)
        SelectedCarryable = option[1]
    end
})

-- Button: Bring item
Tab:CreateButton({
    Name = "Bring selected item to me",
    Callback = function()
        if not SelectedCarryable then return end
        refreshLists()
        CarryableDropdown:Refresh(CarryableNames)

        local target = findCarryableByName(SelectedCarryable)
        if not target then
            Rayfield:Notify({ Title="Bring Item", Content="Item not found", Duration=2 })
            return
        end
        bringToPlayer(target)
    end
})

-- Toggle: Auto Farm (bring items)
local AutoFarmBring = false
Tab:CreateToggle({
    Name = "Auto Farm (bring items to me)",
    CurrentValue = false,
    Callback = function(Value)
        AutoFarmBring = Value
        if AutoFarmBring then
            Rayfield:Notify({ Title="Auto Farm", Content="Activated", Duration=2 })
        else
            Rayfield:Notify({ Title="Auto Farm", Content="Deactivated", Duration=2 })
        end

        task.spawn(function()
            while AutoFarmBring do
                task.wait(2)
                refreshLists()
                if SelectedCarryable then
                    local target = findCarryableByName(SelectedCarryable)
                    if target then
                        bringToPlayer(target)
                    end
                end
            end
        end)
    end
})

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

-- ===================== Bring Item to Target =====================
local function bringToTarget(inst, target)
    if not inst or not target then return end
    local root = target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target
    if not root then return end

    if inst:IsA("Model") and inst.PrimaryPart then
        inst:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 3, 0))
    elseif inst:IsA("BasePart") then
        inst.CFrame = root.CFrame * CFrame.new(0, 3, 0)
    end
end

-- ===================== Find Firepit and Grinder =====================
local function getFirepit()
    return workspace:FindFirstChild("Firepit") or workspace:FindFirstChild("Campfire")
end

local function getGrinder()
    return workspace:FindFirstChild("Grinder") or workspace:FindFirstChild("Crusher")
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

-- Button: Bring item to Firepit
Tab:CreateButton({
    Name = "Bring selected item to Firepit",
    Callback = function()
        if not SelectedCarryable then return end
        refreshLists()
        CarryableDropdown:Refresh(CarryableNames)

        local target = findCarryableByName(SelectedCarryable)
        local firepit = getFirepit()
        if not target or not firepit then
            Rayfield:Notify({ Title="Bring Item", Content="Item or Firepit not found", Duration=2 })
            return
        end
        bringToTarget(target, firepit)
    end
})

-- Button: Bring item to Grinder
Tab:CreateButton({
    Name = "Bring selected item to Grinder",
    Callback = function()
        if not SelectedCarryable then return end
        refreshLists()
        CarryableDropdown:Refresh(CarryableNames)

        local target = findCarryableByName(SelectedCarryable)
        local grinder = getGrinder()
        if not target or not grinder then
            Rayfield:Notify({ Title="Bring Item", Content="Item or Grinder not found", Duration=2 })
            return
        end
        bringToTarget(target, grinder)
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

-- ===================== Kill Aura =====================
local KillAura = false
local KillAuraRange = 15   -- default range
local KillAuraDamage = 10  -- default damage

local function attackNearby()
    local char = getCharacter()
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, enemy in ipairs(workspace:GetChildren()) do
        if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy ~= char then
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - root.Position).Magnitude < KillAuraRange then
                enemy.Humanoid:TakeDamage(KillAuraDamage)
            end
        end
    end
end

-- Toggle Kill Aura
Tab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Callback = function(Value)
        KillAura = Value
        if KillAura then
            Rayfield:Notify({ Title="Kill Aura", Content="Activated", Duration=2 })
        else
            Rayfield:Notify({ Title="Kill Aura", Content="Deactivated", Duration=2 })
        end

        task.spawn(function()
            while KillAura do
                task.wait(0.5)
                attackNearby()
            end
        end)
    end
})

-- Slider: Range
Tab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = KillAuraRange,
    Callback = function(Value)
        KillAuraRange = Value
        Rayfield:Notify({ Title="Kill Aura", Content="Range set to "..Value, Duration=2 })
    end
})

-- Slider: Damage
Tab:CreateSlider({
    Name = "Kill Aura Damage",
    Range = {5, 100},
    Increment = 5,
    CurrentValue = KillAuraDamage,
    Callback = function(Value)
        KillAuraDamage = Value
        Rayfield:Notify({ Title="Kill Aura", Content="Damage set to "..Value, Duration=2 })
    end
})

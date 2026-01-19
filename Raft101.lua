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

    if inst:Is

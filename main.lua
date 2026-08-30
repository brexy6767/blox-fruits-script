-- Orion UI Kütüphanesi
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "Ravenya Hub | Blox Fruits",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "RavenyaConfig"
})

-- Sekmeler
local MainTab = Window:MakeTab({ Name = "Auto Farm", Icon = "rbxassetid://4483362458", PremiumOnly = false })
local TeleportTab = Window:MakeTab({ Name = "Işınlanma", Icon = "rbxassetid://4483362458", PremiumOnly = false })
local VisualsTab = Window:MakeTab({ Name = "ESP / Görsel", Icon = "rbxassetid://4483362458", PremiumOnly = false })

-- Global Değişkenler
local AutoFarm = false
local SelectWeapon = "Melee"
local EspPlayer = false
local EspMob = false

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local RunService = game:GetService("RunService")

-- Deniz Algılama
local function GetCurrentSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1
    elseif placeId == 4442272183 then return 2
    elseif placeId == 7449423635 then return 3 end
    return 1
end

-- Seviye Algılama
local function GetLevel()
    local levelVal = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level")
    return levelVal and levelVal.Value or 1
end

-- Noclip Koruması
RunService.Stepped:Connect(function()
    if AutoFarm and player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Güvenli Uçma (Tween)
local function TweenTo(targetCFrame)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 250
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end

-- Görev Tablosu (1, 2 ve 3. Deniz Uyumlu)
local function GetQuestData()
    local myLevel = GetLevel()
    local sea = GetCurrentSea()

    if sea == 1 then
        if myLevel < 10 then return "BanditQuest1", "Bandit", 1, CFrame.new(1059, 16, 1549)
        elseif myLevel < 15 then return "JungleQuest", "Monkey", 1, CFrame.new(-1598, 37, 153)
        elseif myLevel < 30 then return "JungleQuest", "Gorilla", 2, CFrame.new(-1598, 37, 153)
        elseif myLevel < 40 then return "PirateQuest", "Pirate", 1, CFrame.new(-1140, 4, 3828)
        elseif myLevel < 60 then return "DesertQuest", "Desert Officer", 2, CFrame.new(896, 6, 4388)
        elseif myLevel < 90 then return "SnowQuest", "Snowman", 2, CFrame.new(1385, 87, -1298)
        else return "BanditQuest1", "Bandit", 1, CFrame.new(1059, 16, 1549) end
    elseif sea == 2 then
        if myLevel < 725 then return "Area1Quest", "Raider", 1, CFrame.new(-425, 73, 1836)
        elseif myLevel < 775 then return "Area2Quest", "Mercenary", 1, CFrame.new(-425, 73, 1836)
        elseif myLevel < 850 then return "Area2Quest", "Swan Pirate", 2, CFrame.new(-425, 73, 1836)
        elseif myLevel < 900 then return "FactoryQuest", "Factory Staff", 1, CFrame.new(632, 38, 4840)
        elseif myLevel < 950 then return "JeremyQuest", "Jeremy", 1, CFrame.new(632, 38, 4840)
        elseif myLevel < 1000 then return "ZombieQuest", "Zombie", 1, CFrame.new(-5495, 48, -794)
        elseif myLevel < 1100 then return "SnowMountainQuest", "Snow Trooper", 1, CFrame.new(609, 401, -5372)
        else return "Area1Quest", "Raider", 1, CFrame.new(-425, 73, 1836) end
    elseif sea == 3 then
        if myLevel < 1575 then return "PiratePortQuest", "Pirate Millionaire", 1, CFrame.new(-290, 44, 5580)
        else return "PiratePortQuest", "Pirate Millionaire", 1, CFrame.new(-290, 44, 5580) end
    end
end

-- Silah Kuşanma
local function EquipWeapon()
    local character = player.Character
    if not character then return end
    
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and item.ToolTipType == SelectWeapon then return end
    end
    
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.ToolTipType == SelectWeapon then
            character.Humanoid:EquipTool(item)
            break
        end
    end
end

local function AutoAttack()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0,0))
end

-- Kesin Çalışan ESP Çizici (Highlight + Billboard)
local function ApplyESP(obj, text, color)
    if not obj:FindFirstChild("RavenyaBillboard") then
        local bgui = Instance.new("BillboardGui")
        bgui.Name = "RavenyaBillboard"
        bgui.Adornee = obj
        bgui.AlwaysOnTop = true
        bgui.Size = UDim2.new(0, 200, 0, 50)
        bgui.StudsOffset = Vector3.new(0, 3, 0)
        
        local lbl = Instance.new("TextLabel", bgui)
        lbl.Name = "ESPLabel"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.TextSize = 14
        lbl.Font = Enum.Font.SourceSansBold
        bgui.Parent = obj
    end
    obj.RavenyaBillboard.ESPLabel.Text = text
end

local function RemoveESP(obj)
    if obj:FindFirstChild("RavenyaBillboard") then
        obj.RavenyaBillboard:Destroy()
    end
end

-- UI - Auto Farm
MainTab:AddDropdown({
    Name = "Silah Seçimi",
    Default = "Melee",
    Options = {"Melee", "Sword", "Blox Fruit"},
    Callback = function(Option) SelectWeapon = Option end
})

MainTab:AddToggle({
    Name = "Auto-Farm Level",
    Default = false,
    Callback = function(Value) AutoFarm = Value end
})

-- UI - Işınlanma
local seaIslands = {}
local sea = GetCurrentSea()

if sea == 1 then
    seaIslands = {
        ["Başlangıç Adası"] = CFrame.new(1059, 16, 1549),
        ["Jungle"] = CFrame.new(-1598, 37, 153),
        ["Pirate Village"] = CFrame.new(-1140, 4, 3828),
        ["Desert"] = CFrame.new(896, 6, 4388),
        ["Snow Island"] = CFrame.new(1385, 87, -1298)
    }
elseif sea == 2 then
    seaIslands = {
        ["Kingdom of Rose"] = CFrame.new(-425, 73, 1836),
        ["Cafe"] = CFrame.new(-380, 73, 297),
        ["Green Zone"] = CFrame.new(632, 38, 4840),
        ["Graveyard"] = CFrame.new(-5495, 48, -794)
    }
elseif sea == 3 then
    seaIslands = {
        ["Port Town"] = CFrame.new(-290, 44, 5580),
        ["Hydra Island"] = CFrame.new(5833, 52, -1105)
    }
end

local islandNames = {}
for name, _ in pairs(seaIslands) do table.insert(islandNames, name) end

TeleportTab:AddDropdown({
    Name = "Ada Seç",
    Default = islandNames[1] or "",
    Options = islandNames,
    Callback = function(Option)
        if seaIslands[Option] then TweenTo(seaIslands[Option]) end
    end
})

-- UI - ESP
VisualsTab:AddToggle({
    Name = "Player ESP (Oyuncular)",
    Default = false,
    Callback = function(Value) 
        EspPlayer = Value 
        if not Value then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    RemoveESP(p.Character.HumanoidRootPart)
                end
            end
        end
    end
})

VisualsTab:AddToggle({
    Name = "Mob ESP (Yaratıklar)",
    Default = false,
    Callback = function(Value) 
        EspMob = Value 
        if not Value then
            for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") then
                    RemoveESP(enemy.HumanoidRootPart)
                end
            end
        end
    end
})

OrionLib:Init()

-- Ana Döngü (Auto Farm)
task.spawn(function()
    while task.wait(0.1) do
        if AutoFarm then
            pcall(function()
                local questName, mobName, questLevel, npcCFrame = GetQuestData()
                local questGui = player.PlayerGui.Main:FindFirstChild("Quest")
                
                if not questGui or not questGui.Visible then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local dist = (character.HumanoidRootPart.Position - npcCFrame.Position).Magnitude
                        if dist > 15 then
                            local tw = TweenTo(npcCFrame * CFrame.new(0, 4, 0))
                            if tw then tw.Completed:Wait() end
                        end
                        task.wait(0.4)
                        CommF:InvokeServer("StartQuest", questName, questLevel)
                    end
                else
                    local targetMob = nil
                    for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
                        if enemy.Name == mobName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            targetMob = enemy
                            break
                        end
                    end
                    
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        TweenTo(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 6, 0))
                        EquipWeapon()
                        AutoAttack()
                    end
                end
            end)
        end
    end
end)

-- ESP Döngüsü (Anlık Güncelleme)
RunService.RenderStepped:Connect(function()
    if EspPlayer then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                local lvl = p:FindFirstChild("Data") and p.Data:FindFirstChild("Level") and p.Data.Level.Value or "?"
                local hp = math.floor(p.Character.Humanoid.Health)
                ApplyESP(p.Character.HumanoidRootPart, p.Name .. " | Lvl: " .. lvl .. " | HP: " .. hp, Color3.fromRGB(0, 255, 120))
            end
        end
    end
    
    if EspMob then
        for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
            if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local hp = math.floor(enemy.Humanoid.Health)
                ApplyESP(enemy.HumanoidRootPart, enemy.Name .. " | HP: " .. hp, Color3.fromRGB(255, 60, 60))
            end
        end
    end
end)

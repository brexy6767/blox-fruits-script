-- Rayfield UI Kütüphanesi
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ravenya Hub | Blox Fruits",
   LoadingTitle = "Ravenya Hub Yükleniyor...",
   LoadingSubtitle = "by Ravenya",
   ConfigurationSaving = { Enabled = false }
})

-- Sekmeler
local MainTab = Window:CreateTab("Auto Farm", 4483362458)
local TeleportTab = Window:CreateTab("Işınlanma", 4483362458)
local VisualsTab = Window:CreateTab("ESP / Görsel", 4483362458)

-- Global Değişkenler
local AutoFarm = false
local SelectWeapon = "Melee"
local EspPlayer = false
local EspMob = false

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Deniz Algılama (Güncel PlaceId)
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

-- Noclip Mantığı
game:GetService("RunService").Stepped:Connect(function()
    if AutoFarm and player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Güvenli Işınlanma (Tween)
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

-- 1, 2 ve 3. Deniz Görev & Level Tablosu
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
        elseif myLevel < 120 then return "MarineQuest2", "Chief Petty Officer", 2, CFrame.new(-5036, 28, 4324)
        elseif myLevel < 150 then return "SkyQuest", "Sky Bandit", 1, CFrame.new(-4840, 717, -2623)
        elseif myLevel < 190 then return "PrisonerQuest", "Dangerous Prisoner", 2, CFrame.new(530, 1, 474)
        elseif myLevel < 250 then return "ColosseumQuest", "Toga Warrior", 1, CFrame.new(-1580, 7, -2980)
        elseif myLevel < 300 then return "MagmaQuest", "Military Soldier", 1, CFrame.new(-5315, 12, 8515)
        elseif myLevel < 375 then return "FishmanQuest", "Fishman Warrior", 1, CFrame.new(61122, 18, 1569)
        elseif myLevel < 450 then return "SkyExp1Quest", "God's Guard", 1, CFrame.new(-4720, 845, -1950)
        elseif myLevel < 525 then return "SkyExp2Quest", "Shandia Warrior", 1, CFrame.new(-7900, 5611, -2280)
        elseif myLevel < 625 then return "FountainQuest", "Bounty Hunter", 1, CFrame.new(5258, 39, 4050)
        else return "FountainQuest", "Water Fighter", 2, CFrame.new(5258, 39, 4050) end

    elseif sea == 2 then
        if myLevel < 725 then return "Area1Quest", "Raider", 1, CFrame.new(-425, 73, 1836)
        elseif myLevel < 775 then return "Area2Quest", "Mercenary", 1, CFrame.new(-425, 73, 1836)
        elseif myLevel < 850 then return "Area2Quest", "Swan Pirate", 2, CFrame.new(-425, 73, 1836)
        elseif myLevel < 900 then return "FactoryQuest", "Factory Staff", 1, CFrame.new(632, 38, 4840)
        elseif myLevel < 950 then return "JeremyQuest", "Jeremy", 1, CFrame.new(632, 38, 4840)
        elseif myLevel < 1000 then return "ZombieQuest", "Zombie", 1, CFrame.new(-5495, 48, -794)
        elseif myLevel < 1100 then return "SnowMountainQuest", "Snow Trooper", 1, CFrame.new(609, 401, -5372)
        elseif myLevel < 1250 then return "ShipQuest1", "Ship Deckhand", 1, CFrame.new(923, 125, 32885)
        elseif myLevel < 1350 then return "ShipQuest2", "Ship Officer", 1, CFrame.new(923, 125, 32885)
        elseif myLevel < 1425 then return "FrostQuest", "Ice Castle Guard", 1, CFrame.new(5858, 28, -6274)
        else return "ForgottenQuest", "Water Fighter", 1, CFrame.new(-3054, 236, -10148) end

    elseif sea == 3 then
        if myLevel < 1575 then return "PiratePortQuest", "Pirate Millionaire", 1, CFrame.new(-290, 44, 5580)
        elseif myLevel < 1625 then return "PiratePortQuest", "Pistol Billionaire", 2, CFrame.new(-290, 44, 5580)
        elseif myLevel < 1700 then return "AmazonQuest", "Dragon Crew Warrior", 1, CFrame.new(5833, 52, -1105)
        elseif myLevel < 1775 then return "MarineTreeQuest", "Marine Commodore", 1, CFrame.new(2180, 29, -6740)
        elseif myLevel < 1825 then return "DeepForestQuest", "Fishman Raider", 1, CFrame.new(-10580, 332, -8758)
        elseif myLevel < 1900 then return "DeepForest2Quest", "Forest Pirate", 1, CFrame.new(-13230, 332, -7625)
        elseif myLevel < 2000 then return "HauntedQuest1", "Reborn Skeleton", 1, CFrame.new(-9515, 142, 5535)
        elseif myLevel < 2100 then return "HauntedQuest2", "Living Zombie", 1, CFrame.new(-9515, 142, 5535)
        elseif myLevel < 2200 then return "N PeanutQuest", "Peanut Scout", 1, CFrame.new(-2105, 38, -10190)
        elseif myLevel < 2300 then return "IceCreamIslandQuest", "Ice Cream Chef", 1, CFrame.new(-820, 65, -10965)
        else return "TikiQuest1", "Sun-kissed Warrior", 1, CFrame.new(-16290, 9, 410) end
    end
end

-- Silah Seçimi ve Kuşanma
local function EquipWeapon()
    local character = player.Character
    if not character then return end
    
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and item.ToolTipType == SelectWeapon then
            return
        end
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

-- ESP Sınıfı Bilgileri
local function CreateESP(parent, text, color)
    if parent:FindFirstChild("RavenyaESP") then parent.RavenyaESP:Destroy() end
    
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "RavenyaESP"
    bgui.Adornee = parent
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    
    local lbl = Instance.new("TextLabel", bgui)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextSize = 13
    lbl.Font = Enum.Font.SourceSansBold
    
    bgui.Parent = parent
end

-- UI - Auto Farm
MainTab:CreateDropdown({
   Name = "Silah Seçimi",
   Options = {"Melee", "Sword", "Blox Fruit"},
   CurrentOption = {"Melee"},
   MultipleOptions = false,
   Callback = function(Option) SelectWeapon = Option[1] end,
})

MainTab:CreateToggle({
   Name = "Auto-Farm Level",
   CurrentValue = false,
   Callback = function(Value) AutoFarm = Value end,
})

-- UI - Işınlanma (Sea Uyumlu Adalar)
local seaIslands = {}
local sea = GetCurrentSea()

if sea == 1 then
    seaIslands = {
        ["Starter Island"] = CFrame.new(1059, 16, 1549),
        ["Jungle"] = CFrame.new(-1598, 37, 153),
        ["Pirate Village"] = CFrame.new(-1140, 4, 3828),
        ["Desert"] = CFrame.new(896, 6, 4388),
        ["Snow Island"] = CFrame.new(1385, 87, -1298),
        ["Marineford"] = CFrame.new(-5036, 28, 4324),
        ["Skypiea"] = CFrame.new(-4840, 717, -2623),
        ["Fountain City"] = CFrame.new(5258, 39, 4050)
    }
elseif sea == 2 then
    seaIslands = {
        ["Kingdom of Rose"] = CFrame.new(-425, 73, 1836),
        ["Cafe"] = CFrame.new(-380, 73, 297),
        ["Green Zone"] = CFrame.new(632, 38, 4840),
        ["Graveyard"] = CFrame.new(-5495, 48, -794),
        ["Snow Mountain"] = CFrame.new(609, 401, -5372),
        ["Cursed Ship"] = CFrame.new(923, 125, 32885),
        ["Ice Castle"] = CFrame.new(5858, 28, -6274),
        ["Forgotten Island"] = CFrame.new(-3054, 236, -10148)
    }
elseif sea == 3 then
    seaIslands = {
        ["Port Town"] = CFrame.new(-290, 44, 5580),
        ["Hydra Island"] = CFrame.new(5833, 52, -1105),
        ["Great Tree"] = CFrame.new(2180, 29, -6740),
        ["Floating Turtle"] = CFrame.new(-10580, 332, -8758),
        ["Haunted Castle"] = CFrame.new(-9515, 142, 5535),
        ["Chocolate Land"] = CFrame.new(-2105, 38, -10190),
        ["Tiki Outpost"] = CFrame.new(-16290, 9, 410)
    }
end

local islandNames = {}
for name, _ in pairs(seaIslands) do table.insert(islandNames, name) end

TeleportTab:CreateDropdown({
   Name = "Ada Seç",
   Options = islandNames,
   CurrentOption = {islandNames[1]},
   MultipleOptions = false,
   Callback = function(Option)
      local selectedCFrame = seaIslands[Option[1]]
      if selectedCFrame then TweenTo(selectedCFrame) end
   end,
})

-- UI - Visuals / ESP
VisualsTab:CreateToggle({
   Name = "Player ESP (Oyuncular)",
   CurrentValue = false,
   Callback = function(Value) EspPlayer = Value end,
})

VisualsTab:CreateToggle({
   Name = "Mob ESP (Yaratıklar)",
   CurrentValue = false,
   Callback = function(Value) EspMob = Value end,
})

-- Ana Döngü
task.spawn(function()
    while task.wait(0.1) do
        -- Auto Farm Mantığı
        if AutoFarm then
            pcall(function()
                local questName, mobName, questLevel, npcCFrame = GetQuestData()
                local questGui = player.PlayerGui.Main:FindFirstChild("Quest")
                
                -- Görev yoksa NPC'nin tam üstüne ışınlan ve bekle
                if not questGui or not questGui.Visible then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local dist = (character.HumanoidRootPart.Position - npcCFrame.Position).Magnitude
                        if dist > 15 then
                            local tw = TweenTo(npcCFrame * CFrame.new(0, 3, 0))
                            if tw then tw.Completed:Wait() end
                        end
                        task.wait(0.4)
                        CommF:InvokeServer("StartQuest", questName, questLevel)
                    end
                else
                    -- Görev varsa hedef yaratığı bul ve 6 stud üstünde durarak vur
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
        
        -- ESP Mantığı
        if EspPlayer then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                    local level = p:FindFirstChild("Data") and p.Data:FindFirstChild("Level") and p.Data.Level.Value or "N/A"
                    local hp = math.floor(p.Character.Humanoid.Health)
                    CreateESP(p.Character.HumanoidRootPart, p.Name .. " | Lvl: " .. level .. " | HP: " .. hp, Color3.fromRGB(0, 255, 150))
                end
            end
        end
        
        if EspMob then
            for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local hp = math.floor(enemy.Humanoid.Health)
                    CreateESP(enemy.HumanoidRootPart, enemy.Name .. " | HP: " .. hp, Color3.fromRGB(255, 80, 80))
                end
            end
        end
    end
end)

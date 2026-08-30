-- Rayfield UI Kütüphanesi
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ravenya Hub | Blox Fruits (All Seas)",
   LoadingTitle = "Ravenya Hub Yükleniyor...",
   LoadingSubtitle = "by Ravenya",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)

-- Global Değişkenler
local AutoFarm = false
local SelectWeapon = "Melee"

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Denizi ve Seviyeyi Algılama Fonksiyonu
local function GetCurrentSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then
        return 1
    elseif placeId == 4442272183 then
        return 2
    elseif placeId == 7449423635 then
        return 3
    end
    return 1
end

local function GetLevel()
    return player.Data.Level.Value
end

-- Seviye ve Denize Göre Görev Tablosu
local function GetQuestData()
    local myLevel = GetLevel()
    local sea = GetCurrentSea()

    if sea == 1 then
        if myLevel < 10 then return "BanditQuest1", "Bandit", 1 end
        if myLevel < 15 then return "JungleQuest", "Monkey", 1 end
        if myLevel < 30 then return "JungleQuest", "Gorilla", 2 end
        if myLevel < 40 then return "PirateQuest", "Pirate", 1 end
        if myLevel < 60 then return "DesertQuest", "Desert Officer", 2 end
        if myLevel < 90 then return "SnowQuest", "Snowman", 2 end
        if myLevel < 120 then return "MarineQuest2", "Chief Petty Officer", 2 end
        if myLevel < 150 then return "SkyQuest", "Sky Bandit", 1 end
        if myLevel < 190 then return "PrisonerQuest", "Dangerous Prisoner", 2 end
        if myLevel < 275 then return "ColosseumQuest", "Gladiator", 2 end
        if myLevel < 375 then return "MagmaQuest", "Military Soldier", 1 end
        if myLevel < 450 then return "FishmanQuest", "Fishman Warrior", 1 end
        if myLevel < 525 then return "SkyQuest2", "God's Guard", 1 end
        if myLevel < 625 then return "FountainQuest", "Chore Boy", 1 end
        return "FountainQuest", "Cyborg", 2

    elseif sea == 2 then
        if myLevel < 725 then return "Area1Quest", "Raider", 1 end
        if myLevel < 775 then return "Area2Quest", "Mercenary", 1 end
        if myLevel < 850 then return "Area2Quest", "Swan Pirate", 2 end
        if myLevel < 900 then return "FactoryQuest", "Factory Staff", 1 end
        if myLevel < 950 then return "JeremyQuest", "Jeremy", 1 end
        if myLevel < 1000 then return "ZombieQuest", "Zombie", 1 end
        if myLevel < 1100 then return "SnowMountainQuest", "Snow Trooper", 1 end
        if myLevel < 1250 then return "ShipQuest1", "Ship Deckhand", 1 end
        if myLevel < 1350 then return "ShipQuest2", "Ship Officer", 1 end
        if myLevel < 1425 then return "FrostQuest", "Ice Castle Guard", 1 end
        return "ForgottenQuest", "Water Fighter", 1

    elseif sea == 3 then
        if myLevel < 1575 then return "PiratePortQuest", "Pirate Millionaire", 1 end
        if myLevel < 1700 then return "AmazonQuest", "Dragon Crew Warrior", 1 end
        if myLevel < 1825 then return "MansionQuest", "Female Islander", 1 end
        if myLevel < 1900 then return "TurtleQuest", "Fishman Raider", 1 end
        if myLevel < 2000 then return "DeepForestQuest", "Jungle Pirate", 1 end
        if myLevel < 2200 then return "HauntedQuest1", "Reborn Skeleton", 1 end
        return "PeanutQuest", "Peanut Scout", 1
    end
end

-- Işınlanma (Tween)
local function TweenTo(targetCFrame)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 350
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end
end

-- Silah Kuşanma
local function EquipWeapon()
    local character = player.Character
    if not character then return end
    
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            if SelectWeapon == "Melee" and item.ToolTipType == "Melee" then
                character.Humanoid:EquipTool(item)
            elseif SelectWeapon == "Sword" and item.ToolTipType == "Sword" then
                character.Humanoid:EquipTool(item)
            elseif SelectWeapon == "Blox Fruit" and item.ToolTipType == "Blox Fruit" then
                character.Humanoid:EquipTool(item)
            end
        end
    end
end

-- Saldırı Simülasyonu
local function AutoAttack()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0,0))
end

-- UI Bileşenleri
MainTab:CreateDropdown({
   Name = "Silah Seçimi",
   Options = {"Melee", "Sword", "Blox Fruit"},
   CurrentOption = {"Melee"},
   MultipleOptions = false,
   Callback = function(Option)
      SelectWeapon = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "Auto-Farm Level (All Sea Supported)",
   CurrentValue = false,
   Callback = function(Value)
      AutoFarm = Value
   end,
})

-- Ana Döngü
task.spawn(function()
    while task.wait(0.1) do
        if AutoFarm then
            pcall(function()
                local questName, mobName, questLevel = GetQuestData()
                local questGui = player.PlayerGui.Main:FindFirstChild("Quest")
                
                -- Eğer aktif görev yoksa Remote çağrısı ile görevi başlat
                if not questGui or not questGui.Visible then
                    CommF:InvokeServer("StartQuest", questName, questLevel)
                else
                    -- Görev aktifse workspace üzerindeki doğru yaratığı bul
                    local targetMob = nil
                    for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
                        if enemy.Name == mobName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            targetMob = enemy
                            break
                        end
                    end
                    
                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        -- Yaratığın yukarısına güvenli mesafeye ışınlan ve vur
                        TweenTo(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0))
                        EquipWeapon()
                        AutoAttack()
                    end
                end
            end)
        end
    end
end)

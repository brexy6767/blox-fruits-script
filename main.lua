-- Rayfield UI Kütüphanesi
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ravenya Hub | Blox Fruits",
   LoadingTitle = "Ravenya Hub Yükleniyor...",
   LoadingSubtitle = "by Ravenya",
   ConfigurationSaving = { Enabled = false },
   Theme = {
      TextColor = Color3.fromRGB(240, 240, 240),
      Background = Color3.fromRGB(20, 10, 25),
      Topbar = Color3.fromRGB(35, 15, 45),
      DropdownFrame = Color3.fromRGB(30, 15, 40),
      InputField = Color3.fromRGB(30, 15, 40),
      SectionTitle = Color3.fromRGB(180, 100, 255),
      Accent = Color3.fromRGB(150, 50, 230)
   }
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)

-- Global Değişkenler
local AutoFarm = false
local SelectWeapon = "Melee"

local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- Noclip (Duvarlara Takılmama)
game:GetService("RunService").Stepped:Connect(function()
    if AutoFarm and player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Denizi ve Seviyeyi Algılama
local function GetCurrentSea()
    local placeId = game.PlaceId
    if placeId == 2753915549 then return 1
    elseif placeId == 4442272183 then return 2
    elseif placeId == 7449423635 then return 3 end
    return 1
end

local function GetLevel()
    local levelVal = player:FindFirstChild("Data") and player.Data:FindFirstChild("Level")
    return levelVal and levelVal.Value or 1
end

-- NPC Konumları ve Görev Bilgileri
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
        else return "Area1Quest", "Raider", 1, CFrame.new(-425, 73, 1836) end
    elseif sea == 3 then
        if myLevel < 1575 then return "PiratePortQuest", "Pirate Millionaire", 1, CFrame.new(-290, 44, 5580)
        else return "PiratePortQuest", "Pirate Millionaire", 1, CFrame.new(-290, 44, 5580) end
    end
end

-- Senkronize Işınlanma (Tween)
local function TweenTo(targetCFrame)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 300
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end

-- Silah Kuşanma (Geliştirilmiş Kontrol)
local function EquipWeapon()
    local character = player.Character
    if not character then return end
    
    -- Eğer seçili silah zaten eldeyse tekrar işlem yapma
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and item.ToolTipType == SelectWeapon then
            return
        end
    end
    
    -- Sırt çantasından ele al
    for _, item in pairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item.ToolTipType == SelectWeapon then
            character.Humanoid:EquipTool(item)
            break
        end
    end
end

-- Saldırı Simülasyonu
local function AutoAttack()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0,0))
end

-- UI Menüsü
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
   Name = "Auto-Farm Level",
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
                local questName, mobName, questLevel, npcCFrame = GetQuestData()
                local questGui = player.PlayerGui.Main:FindFirstChild("Quest")
                
                if not questGui or not questGui.Visible then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local dist = (character.HumanoidRootPart.Position - npcCFrame.Position).Magnitude
                        if dist > 15 then
                            local tw = TweenTo(npcCFrame)
                            if tw then tw.Completed:Wait() end
                        end
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

-- Rayfield UI Kütüphanesini Yükleme
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Koyu Mor Tema Ayarları (Custom Theme)
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

-- Oyuncu Bilgileri
local player = game.Players.LocalPlayer
local function getLevel()
    return player.Data.Level.Value
end

-- Seviyeye Göre Görev ve Yaratık Belirleme (Sea 1 Başlangıç Mantığı)
local function CheckQuest()
    local myLevel = getLevel()
    local questName, mobName, questCFrame, mobCFrame, questLevel
    
    if myLevel >= 1 and myLevel < 10 then
        questName = "BanditQuest1"
        mobName = "Bandit"
        questLevel = 1
    elseif myLevel >= 10 and myLevel < 15 then
        questName = "JungleQuest"
        mobName = "Monkey"
        questLevel = 1
    elseif myLevel >= 15 and myLevel < 30 then
        questName = "JungleQuest"
        mobName = "Gorilla"
        questLevel = 2
    elseif myLevel >= 30 and myLevel < 40 then
        questName = "PirateQuest"
        mobName = "Pirate"
        questLevel = 1
    else
        -- Varsayılan fallback
        questName = "BanditQuest1"
        mobName = "Bandit"
        questLevel = 1
    end
    
    return questName, mobName, questLevel
end

-- Yumuşak Işınlanma (Tween)
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

-- Seçili Silahı Ele Alma
local function EquipWeapon()
    local character = player.Character
    if not character then return end
    
    local backpack = player.Backpack
    for _, item in pairs(backpack:GetChildren()) do
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

-- Tıklama / Saldırı Simülasyonu
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
   Name = "Auto-Farm (Auto Level & Quest)",
   CurrentValue = false,
   Callback = function(Value)
      AutoFarm = Value
   end,
})

-- Ana Döngü (Level-Based Auto Quest & Farm)
task.spawn(function()
    while task.wait(0.1) do
        if AutoFarm then
            pcall(function()
                local questName, mobName, questLevel = CheckQuest()
                local questData = player.PlayerGui.Main.Quest
                
                -- Eğer aktif görev yoksa NPC'den görev al
                if not questData.Visible then
                    -- Görev alma tetikleyicisi (CommF_ Remote Event)
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", questName, questLevel)
                else
                    -- Görev varsa yaratık ara ve kes
                    local targetMob = nil
                    for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
                        if enemy.Name == mobName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            targetMob = enemy
                            break
                        end
                    end
                    
                    if targetMob then
                        local hrp = targetMob:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Yaratığın 7 birim üstünde dur (Güvenli mesafe)
                            TweenTo(hrp.CFrame * CFrame.new(0, 7, 0))
                            EquipWeapon()
                            AutoAttack()
                        end
                    end
                end
            end)
        end
    end
end)

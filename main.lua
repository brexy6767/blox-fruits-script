-- Rayfield UI Kütüphanesini Yükleme
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Ravenya Hub | Blox Fruits",
   LoadingTitle = "Ravenya Hub Yükleniyor...",
   LoadingSubtitle = "by Ravenya",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Auto Farm", 4483362458)

-- Değişkenler
local AutoFarm = false
local SelectedTarget = "Bandit"

-- Yaratığa Yumuşak Işınlanma (Tween) Fonksiyonu
local function TweenToTarget(targetCFrame)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 300
        local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        
        local tween = game:GetService("TweenService"):Create(hrp, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end
end

-- Otomatik Saldırı (Tıklama Simülasyonu)
local function AutoAttack()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton1(Vector2.new(0,0))
end

-- UI Kontrolleri
local Toggle = MainTab:CreateToggle({
   Name = "Auto-Farm Yaratık",
   CurrentValue = false,
   Callback = function(Value)
      AutoFarm = Value
   end,
})

-- Ana Döngü (Main Loop)
task.spawn(function()
    while task.wait(0.1) do
        if AutoFarm then
            pcall(function()
                for _, enemy in pairs(game.Workspace.Enemies:GetChildren()) do
                    if enemy.Name == SelectedTarget and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            TweenToTarget(hrp.CFrame * CFrame.new(0, 5, 0))
                            AutoAttack()
                        end
                    end
                end
            end)
        end
    end
end)

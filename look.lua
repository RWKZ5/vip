-- ============================================
-- [ Chess Auto Play - lok.lua ]
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- حذف الواجهة القديمة إن وجدت
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("AutoPlayUI") then
    PlayerGui.AutoPlayUI:Destroy()
end

-- إنشاء الواجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoPlayUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 90)
MainFrame.Position = UDim2.new(0.5, -90, 0.8, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Button = Instance.new("TextButton", MainFrame)
Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 10)
Button.Text = "⚡ لعب نقلة تلقائية"
Button.BackgroundColor3 = Color3.fromRGB(30, 150, 250)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextScaled = true
Button.Font = Enum.Font.GothamBold
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 55)
StatusLabel.Text = "جاهز للاستخدام"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11

-- تحميل محرك AI
local Sunfish = nil
pcall(function()
    Sunfish = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("AI"):WaitForChild("Sunfish"))
end)

Button.MouseButton1Click:Connect(function()
    if not Sunfish then
        StatusLabel.Text = "❌ فشل تحميل ملف Sunfish AI!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end

    StatusLabel.Text = "⏳ جاري قراءة الرقعة وحساب النقلة..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)

    task.spawn(function()
        local success, err = pcall(function()
            -- 1. جلب بيانات الرقعة (FEN)
            local tableset = ReplicatedStorage.InternalClientEvents.GetActiveTableset:Invoke()
            local fenValue = nil

            if type(tableset) == "table" then
                if tableset.FEN then
                    fenValue = (typeof(tableset.FEN) == "Instance" and tableset.FEN.Value) or tableset.FEN
                end
            elseif typeof(tableset) == "Instance" and tableset:FindFirstChild("FEN") then
                fenValue = tableset.FEN.Value
            end

            if not fenValue then
                StatusLabel.Text = "❌ لم يتم العثور على FEN (لست بالطاولة؟)"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                return
            end

            -- 2. حساب أفضل نقلة بواسطة AI
            local bestMove = Sunfish:GetBestMove(tostring(fenValue), 1000)

            if not bestMove then
                StatusLabel.Text = "❌ لم يتم التوصل لنقلة مناسبة"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                return
            end

            -- 3. إرسال النقلة للسيرفر
            local chessRemote = ReplicatedStorage:WaitForChild("Chess"):WaitForChild("SubmitMove")
            chessRemote:InvokeServer(tostring(bestMove))

            StatusLabel.Text = "✅ تم لعب: " .. tostring(bestMove)
            StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        end)

        if not success then
            StatusLabel.Text = "❌ خطأ في التنفيذ"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            warn("AutoPlay Error: " .. tostring(err))
        end
    end)
end)

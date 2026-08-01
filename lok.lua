local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lplr = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui", lplr:WaitForChild("PlayerGui"))
screenGui.Name = "AutoPlayUI"
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 1, -60)
button.Text = "Auto Play"
button.BackgroundColor3 = Color3.fromRGB(30, 150, 250)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui

local sundown = require(lplr:WaitForChild("PlayerScripts"):WaitForChild("AI"):WaitForChild("Sunfish"))

button.MouseButton1Click:Connect(function()
    local success, err = pcall(function()
        local tableset = replicatedStorage.InternalClientEvents.GetActiveTableset:Invoke()
        
        -- استخراج الـ FEN سواء كان الجدول يحتوي على كائن أو قيمة نصية مباشرة
        local fenValue = nil
        if type(tableset) == "table" and tableset.FEN then
            fenValue = (typeof(tableset.FEN) == "Instance" and tableset.FEN.Value) or tableset.FEN
        elseif typeof(tableset) == "Instance" and tableset:FindFirstChild("FEN") then
            fenValue = tableset.FEN.Value
        end

        if fenValue then
            local bestMove = sundown:GetBestMove(tostring(fenValue), 1750)
            replicatedStorage:WaitForChild("Chess"):WaitForChild("SubmitMove"):InvokeServer(tostring(bestMove))
            print("✅ Move Submitted: " .. tostring(bestMove))
        else
            warn("❌ لم يتم العثور على FEN الطاولة!")
        end
    end)

    if not success then
        warn("❌ خطأ أثناء تنفيذ النقلة: " .. tostring(err))
    end
end)

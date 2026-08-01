local Players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lplr = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui", lplr:WaitForChild("PlayerGui"))
screenGui.Name = "AutoPlayUI"
local activetableset = game:GetService("ReplicatedStorage").InternalClientEvents.GetActiveTableset:Invoke()
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 1, -60)
button.Text = "Auto Play"
button.BackgroundColor3 = Color3.fromRGB(30, 150, 250)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Parent = screenGui
local sundown = require(game:GetService("Players").LocalPlayer.PlayerScripts.AI.Sunfish)
button.MouseButton1Click:Connect(function()
activetableset = game:GetService("ReplicatedStorage").InternalClientEvents.GetActiveTableset:Invoke().FEN.Value
game:GetService("ReplicatedStorage"):WaitForChild("Chess"):WaitForChild("SubmitMove"):InvokeServer(tostring(sundown:GetBestMove(activetableset, 1750)))
end)

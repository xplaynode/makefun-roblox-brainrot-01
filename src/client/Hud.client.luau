-- Noodle Knight's Brainrot Bay -- client HUD (StarterPlayerScripts.Client.Hud)
-- A ScreenGui over the 3D world: cash, income per second, the character being carried,
-- the tsunami countdown and a Rebirth button. The panel sits top-centre, clear of the
-- top-left corner where Roblox draws its own menu buttons over the play view.
-- Rebirth goes through the RebirthRequest RemoteEvent the server creates in
-- ReplicatedStorage; everything else is read from leaderstats and attributes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local rebirthRemote = ReplicatedStorage:WaitForChild("RebirthRequest")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHud"
gui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 12)
panel.Size = UDim2.fromOffset(560, 118)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
panel.BackgroundTransparency = 0.25
panel.BorderSizePixel = 0
panel.Parent = gui

local function makeLabel(name: string, pos: UDim2, size: UDim2, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = pos
	label.Size = size
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = textSize
	label.Font = Enum.Font.SourceSansBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = panel
	return label
end

local titleLabel = makeLabel("Title", UDim2.fromOffset(14, 6), UDim2.fromOffset(532, 26), 20)
titleLabel.Text = "Noodle Knight's Brainrot Bay"
local cashLabel = makeLabel("Cash", UDim2.fromOffset(14, 36), UDim2.fromOffset(260, 24), 18)
local incomeLabel = makeLabel("Income", UDim2.fromOffset(286, 36), UDim2.fromOffset(260, 24), 18)
local carryLabel = makeLabel("Carrying", UDim2.fromOffset(14, 62), UDim2.fromOffset(532, 24), 18)
local waveLabel = makeLabel("Wave", UDim2.fromOffset(14, 88), UDim2.fromOffset(340, 24), 18)

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Position = UDim2.fromOffset(366, 86)
rebirthButton.Size = UDim2.fromOffset(180, 28)
rebirthButton.BackgroundColor3 = Color3.fromRGB(150, 60, 200)
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.TextSize = 16
rebirthButton.Font = Enum.Font.SourceSansBold
rebirthButton.Text = "Rebirth"
rebirthButton.Parent = panel
rebirthButton.MouseButton1Click:Connect(function()
	rebirthRemote:FireServer()
end)

local indexButton = Instance.new("TextButton")
indexButton.Name = "IndexButton"
indexButton.AnchorPoint = Vector2.new(1, 1)
indexButton.Position = UDim2.new(1, -12, 1, -12)
indexButton.Size = UDim2.fromOffset(120, 36)
indexButton.BackgroundColor3 = Color3.fromRGB(40, 120, 160)
indexButton.TextColor3 = Color3.fromRGB(255, 255, 255)
indexButton.TextSize = 16
indexButton.Font = Enum.Font.SourceSansBold
indexButton.Text = "INDEX"
indexButton.Parent = gui

local indexPanel = Instance.new("ScrollingFrame")
indexPanel.Name = "IndexPanel"
indexPanel.AnchorPoint = Vector2.new(1, 1)
indexPanel.Position = UDim2.new(1, -12, 1, -56)
indexPanel.Size = UDim2.fromOffset(280, 320)
indexPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
indexPanel.BackgroundTransparency = 0.15
indexPanel.BorderSizePixel = 0
indexPanel.Visible = false
indexPanel.ScrollBarThickness = 6
indexPanel.CanvasSize = UDim2.fromOffset(0, #Config.Characters * 26)
indexPanel.Parent = gui

local indexLayout = Instance.new("UIListLayout")
indexLayout.SortOrder = Enum.SortOrder.LayoutOrder
indexLayout.Padding = UDim.new(0, 2)
indexLayout.Parent = indexPanel

local function refreshIndexPanel()
	for _, child in ipairs(indexPanel:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	local indexFolder = player:FindFirstChild("Index")
	for order, characterDef in ipairs(Config.Characters) do
		local label = Instance.new("TextLabel")
		label.Name = "IndexEntry" .. tostring(order)
		label.LayoutOrder = order
		label.Size = UDim2.new(1, -8, 0, 24)
		label.BackgroundTransparency = 1
		label.TextSize = 16
		label.Font = Enum.Font.SourceSansBold
		label.TextXAlignment = Enum.TextXAlignment.Left
		local foundValue = nil
		if indexFolder then
			foundValue = indexFolder:FindFirstChild(characterDef.Name)
		end
		if foundValue and foundValue:IsA("BoolValue") and foundValue.Value then
			label.Text = characterDef.Name
			label.TextColor3 = characterDef.Color
		else
			label.Text = "???"
			label.TextColor3 = Color3.fromRGB(150, 150, 150)
		end
		label.Parent = indexPanel
	end
end

indexButton.MouseButton1Click:Connect(function()
	indexPanel.Visible = not indexPanel.Visible
	if indexPanel.Visible then
		refreshIndexPanel()
	end
end)

gui.Parent = player:WaitForChild("PlayerGui")

local lastLost = 0
player:GetAttributeChangedSignal("WaveLost"):Connect(function()
	lastLost = os.clock()
	carryLabel.Text = "The tsunami took your catch! Dash home next time."
end)

while true do
	local stats = player:FindFirstChild("leaderstats")
	local cash = 0
	local rebirths = 0
	if stats then
		local c = stats:FindFirstChild("Cash")
		local r = stats:FindFirstChild("Rebirths")
		if c then
			cash = c.Value
		end
		if r then
			rebirths = r.Value
		end
	end
	cashLabel.Text = "Cash: $" .. tostring(cash) .. "   Rebirths: " .. tostring(rebirths)
	local income = player:GetAttribute("IncomePerSec") or 0
	incomeLabel.Text = "Income: $" .. tostring(income) .. "/s"
	if os.clock() - lastLost > 4 then
		local carrying = player:GetAttribute("Carrying") or ""
		if carrying ~= "" then
			carryLabel.Text = "Carrying: " .. carrying .. " -- take it to a pad at your base!"
		else
			carryLabel.Text = "Touch a wandering character in the field to carry it home."
		end
	end
	local countdown = Workspace:GetAttribute("WaveCountdown") or 0
	local warning = Workspace:GetAttribute("WaveWarning") or false
	if warning then
		waveLabel.Text = "TSUNAMI IN " .. tostring(countdown) .. "s -- GET TO YOUR BASE!"
		waveLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	elseif countdown == 0 then
		waveLabel.Text = "TSUNAMI SWEEPING THE MAP!"
		waveLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	else
		waveLabel.Text = "Next tsunami in " .. tostring(countdown) .. "s"
		waveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	local cost = 1000 * (rebirths + 1)
	rebirthButton.Text = "Rebirth ($" .. tostring(cost) .. ", +50% income)"
	task.wait(0.25)
end

-- Noodle Knight's Brainrot Bay -- client HUD (StarterPlayerScripts.Client.Hud)
-- A styled ScreenGui over the 3D world: a money pill with a rebirths pill
-- beside it, an event banner under it, a wave countdown line, an orange
-- carrying pill and a bottom bar holding the Rebirth and INDEX buttons over
-- a thin feature strip. Rebirth goes through the RebirthRequest RemoteEvent
-- the server creates in ReplicatedStorage, the golden-runaway banner is
-- driven by the server's EventBanner RemoteEvent, and everything else is
-- read from leaderstats and attributes.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local rebirthRemote = ReplicatedStorage:WaitForChild("RebirthRequest")
local eventBannerRemote = ReplicatedStorage:WaitForChild("EventBanner")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHud"
gui.ResetOnSpawn = false

local function addCorner(target: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = target
end

local function addStroke(target: Instance, color: Color3, thickness: number)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Parent = target
end

local function pillLabel(parent: Instance, name: string, pos: UDim2, size: UDim2, textSize: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = pos
	label.Size = size
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.TextSize = textSize
	label.Font = Enum.Font.SourceSansBold
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = parent
	return label
end

-- Money pill: big cash line with the income line under it, top-centre.
local moneyPill = Instance.new("Frame")
moneyPill.Name = "MoneyPill"
moneyPill.AnchorPoint = Vector2.new(0.5, 0)
moneyPill.Position = UDim2.new(0.5, 0, 0, 12)
moneyPill.Size = UDim2.fromOffset(300, 64)
moneyPill.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
moneyPill.BackgroundTransparency = 0.15
moneyPill.BorderSizePixel = 0
moneyPill.Parent = gui
addCorner(moneyPill, 12)
addStroke(moneyPill, Color3.fromRGB(60, 220, 90), 2)

local cashLabel = pillLabel(moneyPill, "Cash", UDim2.fromOffset(8, 4), UDim2.fromOffset(284, 32), 26, Color3.fromRGB(255, 255, 255))
local incomeLabel = pillLabel(moneyPill, "Income", UDim2.fromOffset(8, 38), UDim2.fromOffset(284, 20), 16, Color3.fromRGB(140, 255, 160))

-- Rebirths pill, sitting to the right of the money pill.
local rebirthsPill = Instance.new("Frame")
rebirthsPill.Name = "RebirthsPill"
rebirthsPill.Position = UDim2.new(0.5, 162, 0, 24)
rebirthsPill.Size = UDim2.fromOffset(140, 38)
rebirthsPill.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
rebirthsPill.BackgroundTransparency = 0.1
rebirthsPill.BorderSizePixel = 0
rebirthsPill.Parent = gui
addCorner(rebirthsPill, 12)
local rebirthsLabel = pillLabel(rebirthsPill, "Rebirths", UDim2.fromOffset(4, 4), UDim2.fromOffset(132, 30), 16, Color3.fromRGB(255, 255, 255))

-- Event banner: hidden until a tsunami warning or a golden runaway.
local eventBanner = Instance.new("Frame")
eventBanner.Name = "EventBanner"
eventBanner.AnchorPoint = Vector2.new(0.5, 0)
eventBanner.Position = UDim2.new(0.5, 0, 0, 86)
eventBanner.Size = UDim2.fromOffset(560, 44)
eventBanner.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
eventBanner.BackgroundTransparency = 0.05
eventBanner.BorderSizePixel = 0
eventBanner.Visible = false
eventBanner.Parent = gui
addCorner(eventBanner, 10)
local bannerLabel = pillLabel(eventBanner, "BannerText", UDim2.fromOffset(8, 4), UDim2.fromOffset(544, 36), 20, Color3.fromRGB(255, 255, 255))
bannerLabel.TextScaled = true
bannerLabel.Text = ""

-- Wave countdown line under the banner.
local waveLabel = Instance.new("TextLabel")
waveLabel.Name = "Wave"
waveLabel.AnchorPoint = Vector2.new(0.5, 0)
waveLabel.Position = UDim2.new(0.5, 0, 0, 136)
waveLabel.Size = UDim2.fromOffset(460, 22)
waveLabel.BackgroundTransparency = 1
waveLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
waveLabel.TextSize = 17
waveLabel.Font = Enum.Font.SourceSansBold
waveLabel.TextXAlignment = Enum.TextXAlignment.Center
waveLabel.Parent = gui

-- Carrying pill: orange, above the bottom bar, hidden while hands are empty.
local carryingPill = Instance.new("Frame")
carryingPill.Name = "CarryingPill"
carryingPill.AnchorPoint = Vector2.new(0.5, 1)
carryingPill.Position = UDim2.new(0.5, 0, 1, -100)
carryingPill.Size = UDim2.fromOffset(560, 36)
carryingPill.BackgroundColor3 = Color3.fromRGB(235, 130, 25)
carryingPill.BackgroundTransparency = 0.05
carryingPill.BorderSizePixel = 0
carryingPill.Visible = false
carryingPill.Parent = gui
addCorner(carryingPill, 10)
local carryLabel = pillLabel(carryingPill, "Carrying", UDim2.fromOffset(8, 3), UDim2.fromOffset(544, 30), 16, Color3.fromRGB(255, 255, 255))
carryLabel.TextScaled = true

-- Bottom bar: the Rebirth and INDEX buttons, chunky and side by side.
local bottomBar = Instance.new("Frame")
bottomBar.Name = "BottomBar"
bottomBar.AnchorPoint = Vector2.new(0.5, 1)
bottomBar.Position = UDim2.new(0.5, 0, 1, -32)
bottomBar.Size = UDim2.fromOffset(376, 48)
bottomBar.BackgroundTransparency = 1
bottomBar.BorderSizePixel = 0
bottomBar.Parent = gui

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Position = UDim2.fromOffset(0, 2)
rebirthButton.Size = UDim2.fromOffset(180, 44)
rebirthButton.BackgroundColor3 = Color3.fromRGB(150, 60, 200)
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.TextSize = 16
rebirthButton.Font = Enum.Font.SourceSansBold
rebirthButton.Text = "REBIRTH"
rebirthButton.Parent = bottomBar
addCorner(rebirthButton, 10)
rebirthButton.MouseButton1Click:Connect(function()
	rebirthRemote:FireServer()
end)

local indexButton = Instance.new("TextButton")
indexButton.Name = "IndexButton"
indexButton.Position = UDim2.fromOffset(196, 2)
indexButton.Size = UDim2.fromOffset(180, 44)
indexButton.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
indexButton.TextColor3 = Color3.fromRGB(255, 255, 255)
indexButton.TextSize = 16
indexButton.Font = Enum.Font.SourceSansBold
indexButton.Text = "INDEX"
indexButton.Parent = bottomBar
addCorner(indexButton, 10)

-- Feature strip pinned to the very bottom of the screen.
local featureStrip = Instance.new("Frame")
featureStrip.Name = "FeatureStrip"
featureStrip.AnchorPoint = Vector2.new(0.5, 1)
featureStrip.Position = UDim2.new(0.5, 0, 1, 0)
featureStrip.Size = UDim2.new(1, 0, 0, 24)
featureStrip.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
featureStrip.BackgroundTransparency = 0.2
featureStrip.BorderSizePixel = 0
featureStrip.Parent = gui
local featureLabel = pillLabel(featureStrip, "Features", UDim2.fromOffset(4, 2), UDim2.new(1, -8, 0, 20), 13, Color3.fromRGB(255, 255, 255))
featureLabel.Text = "40 BRAINROTS - 8 RARITIES - 6 MUTATIONS - STEAL - TSUNAMI - GOLDEN RUNAWAY - REBIRTH"

local indexPanel = Instance.new("ScrollingFrame")
indexPanel.Name = "IndexPanel"
indexPanel.AnchorPoint = Vector2.new(1, 1)
indexPanel.Position = UDim2.new(1, -12, 1, -92)
indexPanel.Size = UDim2.fromOffset(280, 320)
indexPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
indexPanel.BackgroundTransparency = 0.15
indexPanel.BorderSizePixel = 0
indexPanel.Visible = false
indexPanel.ScrollBarThickness = 6
indexPanel.CanvasSize = UDim2.fromOffset(0, #Config.Characters * 26)
indexPanel.Parent = gui
addCorner(indexPanel, 10)

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
end)

local goldenBannerUntil = 0
eventBannerRemote.OnClientEvent:Connect(function(kind)
	if kind == "golden" then
		goldenBannerUntil = os.clock() + 6
	end
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
	cashLabel.Text = "$" .. tostring(cash)
	local income = player:GetAttribute("IncomePerSec") or 0
	incomeLabel.Text = "+$" .. tostring(income) .. "/s"
	rebirthsLabel.Text = "REBIRTHS " .. tostring(rebirths)
	if os.clock() - lastLost <= 4 and lastLost > 0 then
		carryingPill.Visible = true
		carryLabel.Text = "The tsunami took your catch! Dash home next time."
	else
		local carrying = player:GetAttribute("Carrying") or ""
		if carrying ~= "" then
			carryingPill.Visible = true
			carryLabel.Text = "CARRYING: " .. carrying .. " -> DROP AT YOUR BASE"
		else
			carryingPill.Visible = false
			carryLabel.Text = ""
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
	if os.clock() < goldenBannerUntil then
		eventBanner.Visible = true
		eventBanner.BackgroundColor3 = Color3.fromRGB(212, 160, 20)
		bannerLabel.Text = "GOLDEN RUNAWAY APPEARED - CATCH IT FOR +500!"
	elseif warning or (countdown <= 10 and countdown > 0) then
		eventBanner.Visible = true
		eventBanner.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
		bannerLabel.Text = "TSUNAMI INCOMING - GET TO A BASE!"
	else
		eventBanner.Visible = false
		bannerLabel.Text = ""
	end
	local cost = 1000 * (rebirths + 1)
	rebirthButton.Text = "REBIRTH ($" .. tostring(cost) .. ")"
	task.wait(0.25)
end

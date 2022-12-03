wait(2)

local Player = game.Players.LocalPlayer
local Character = Player.Character

local CharacterFolder = workspace.Live
local MaxStuds = 3000

function CreateHighlight(Enemy)
	local Highlight = Enemy:FindFirstChildWhichIsA('Highlight')
	if not Highlight then
		Highlight = Instance.new('Highlight')
	end
	Highlight = Instance.new('Highlight')
	Highlight.Parent = Enemy
	Highlight.FillTransparency = 1
	Highlight.OutlineColor = Color3.new(0.0666667, 1, 0)
	
	return Highlight
end

function CreateHealth(Enemy)
	local Health = Enemy.Humanoid.Health / Enemy.Humanoid.MaxHealth
	
	local BillboardGui = Enemy:FindFirstChildWhichIsA('BillboardGui')
	
	if not BillboardGui then
		BillboardGui = Instance.new('BillboardGui')
	end
	BillboardGui.Parent = Enemy
	BillboardGui.Name = 'HealthGUI'
	BillboardGui.AlwaysOnTop = true
	BillboardGui.Size = UDim2.new(0.5, 0, 5, 0)
	BillboardGui.StudsOffset = Vector3.new(-2.5,0,0)
	
	local TextLabel = Enemy:FindFirstChildWhichIsA('TextLabel')
	
	if not TextLabel then
		TextLabel = Instance.new('TextLabel')
	end
	TextLabel.Parent = BillboardGui
	TextLabel.BackgroundColor3 = Color3.new(1, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Size = UDim2.new(1, 0, 1 * Health, 0)
	TextLabel.Position = UDim2.new(0, 0, 1 - (1 * Health), 0)
	TextLabel.Text = ''
	
	return TextLabel
end

function UpdateGui(Enemy, Highlight, HealthGui)
	coroutine.wrap(function()
		while task.wait(1) do
			local Distance = (Character.PrimaryPart.Position - Enemy.PrimaryPart.Position).Magnitude
			Highlight.OutlineTransparency = Distance/MaxStuds
			HealthGui.BackgroundTransparency = Distance/MaxStuds
			print('YO')
		end
	end)()
	
	Enemy.Humanoid.HealthChanged:Connect(function(Health)
		Health =  Health / Enemy.Humanoid.MaxHealth
		HealthGui.Size = UDim2.new(1, 0, 1 * Health, 0)
		HealthGui.Position = UDim2.new(0, 0, 1 - (1 * Health), 0)
	end)
end

for i, Enemy in pairs(CharacterFolder:GetChildren()) do
	if Enemy.Name ~= Character.Name then
		UpdateGui(Enemy, CreateHighlight(Enemy), CreateHealth(Enemy))
	end
end

CharacterFolder.ChildAdded:Connect(function(Enemy)
	if Enemy.Name ~= Character.Name then
		UpdateGui(Enemy, CreateHighlight(Enemy), CreateHealth(Enemy))
	end
end)


local ESP = {}

function ESP:Start()
	print("v5.7")
	local UIS = game:GetService('UserInputService')
	local RunService = game:GetService('RunService')

	local Player = game.Players.LocalPlayer
	local Mana = Player.Character.Mana
	local Camera = workspace.CurrentCamera

	local CharacterFolder = workspace.Live
	local Leaderboard = Player.PlayerGui.LeaderboardGui.MainFrame.ScrollingFrame
	
	local Toggle = true
	
	local SpellPercentages = {
	["Ignis"] = {
		["Max"] = 95,
		["Min"] = 85
	},
	["Gelidus"] = {
		["Max"] = 95,
		["Min"] = 85
	}
	}
	
	function ESP:CreateHighlight(Enemy)
		local Highlight = Enemy:FindFirstChildWhichIsA('Highlight')
		if Highlight then
			Highlight:Destroy()
		end
		local Highlight = Instance.new('Highlight')
		Highlight.Parent = Enemy
		Highlight.FillTransparency = 1
		Highlight.OutlineTransparency = 0.5
		Highlight.OutlineColor = Color3.new(0.0666667, 1, 0)

		return Highlight
	end

	function ESP:CreateHealth(Enemy)
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

		local ImageLabel = Enemy:FindFirstChildWhichIsA('ImageLabel')

		if not ImageLabel then
			ImageLabel = Instance.new('ImageLabel')
		end

		ImageLabel.Parent = BillboardGui
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.Image = 'rbxassetid://11730527247'
		ImageLabel.Size = UDim2.new(1, 0, 1, 0)

		return TextLabel
	end

	function ESP:UpdateGui(Enemy, HealthGui, HighlightGui)
		Enemy.Humanoid.HealthChanged:Connect(function(Health)
			Health =  Health / Enemy.Humanoid.MaxHealth
			HealthGui.Size = UDim2.new(1, 0, 1 * Health, 0)
			HealthGui.Position = UDim2.new(0, 0, 1 - (1 * Health), 0)
		end)
		
		coroutine.wrap(function()
		while task.wait(1) do
			if Toggle then
				HealthGui.Parent.Enabled = true
				HighlightGui.OutlineTransparency = 0
			else
				HealthGui.Parent.Enabled = false
				HighlightGui.OutlineTransparency = 0.5
			end
		end
		end)()
	end

	for i, Enemy in pairs(CharacterFolder:GetChildren()) do
		if Enemy.Name ~= Player.Character.Name then
			ESP:UpdateGui(Enemy, ESP:CreateHealth(Enemy), ESP:CreateHighlight(Enemy))
		end
	end

	CharacterFolder.ChildAdded:Connect(function(Enemy)
		wait(1)
		if Enemy.Name ~= Player.Character.Name then
			ESP:SetupButtons()
			ESP:UpdateGui(Enemy, ESP:CreateHealth(Enemy), ESP:CreateHighlight(Enemy))
		end
	end)

	function ESP:CreateButton(PlayerLabel)
		local TextButton = Instance.new('TextButton')
		TextButton.Parent = PlayerLabel
		TextButton.BackgroundTransparency = 1
		TextButton.Text = ''
		TextButton.Size = UDim2.new(1,0,1,0)

		print('CREATED BUTTON')
		return TextButton
	end

	function ESP:SetupButtons()
		for i, PlayerLabel in pairs(Leaderboard:GetChildren()) do
			if PlayerLabel:FindFirstChildWhichIsA('TextButton') then
			else
				local CharacterName = PlayerLabel.Text
				local Button = ESP:CreateButton(PlayerLabel)

				Button.MouseButton1Click:Connect(function()
					for j, Enemy in pairs(workspace.Live:GetChildren()) do
						local Name = Enemy:FindFirstChild(CharacterName)
						if Name then
							Camera.CameraSubject = Name.Parent.Humanoid
						end

					end
				end)
			end
		end
	end

	ESP:SetupButtons()

	UIS.InputBegan:Connect(function(input, typing)
		if input.KeyCode == Enum.KeyCode.M and not typing then
			Camera.CameraSubject = Player.Character.Humanoid
		end
		if input.KeyCode == Enum.KeyCode.C and not typing then
			Player:Kick("Instant Log")
		end
		if input.KeyCode == Enum.KeyCode.Z then
			Toggle = not Toggle
		end
	end)
	
	Player.Character.ChildAdded:Connect(function(Tool)
	if Tool:IsA('Tool') then
		local Spell = SpellPercentages[Tool.Name]
		if Spell and Toggle then
			print(Spell)
			Spell.ChildAdded:Connect(function(Child)
				if Child.Name == "Activated" then
					print("Casted")
					print(Mana.Value)
				end
-- 				if Mana.Value < Spell["Max"] and Mana.Value > Spell["Min"] then
-- 					print('didnt backfire')
-- 				else
-- 					print('BACKFIRED')
-- 					wait(0.5)
-- 					Tool:Activate()
-- 				end
			end)
		end
	end
end)
end

return ESP

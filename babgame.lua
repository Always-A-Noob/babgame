local babgame = {}

local keycodes = {}
for _, v in pairs(Enum.KeyCode:GetEnumItems()) do
	keycodes[v.Value]=v
end

function babgame:load(TLcolor, BRcolor, inc)
	self.screen = {data={}}
	self.keys = {data={}}
	
	local function handleBlock(v)
		if v.PrimaryPart.Color == TLcolor then
			self.TL=v -- top left corner
		elseif v.PrimaryPart.Color == BRcolor then
			self.BR=v -- bottom right corner
		end
		
		if v.Name == 'NeonBlock' then
			self.screen.data[#self.screen.data+1]=v -- get screen blocks
		elseif v.Name == 'LightBulb' then
			self.keys.data[#self.keys.data+1]=v -- get keybinds
		end
	end

	for _, v in pairs(workspace:GetChildren()) do
		local tag = v:FindFirstChild('Tag')
		-- check if it is a player-placed block
		if tag then
			-- check if owner is me
			if tag.Value == game:GetService('Players').LocalPlayer.Name then
				handleBlock(v)
			end
		end
	end
	self.diff = (self.BR.PrimaryPart.Position-self.TL.PrimaryPart.Position)


	function self.screen.getPixel(pos2)
	
	end

	function self.screen.setPixel(pos2)

	end
	
	function self.screen.pixelToWorld(pos2)
	
	end
	
	function self.screen.worldToPixel(pos3)
	
	end

	function self.keys.keyPressed(keyfunction)
		for _, v in pairs(self.keys.data) do
			v.BulbEnd.PointLight.Changed:Connect(keyfunction(keycodes[v.BindFire.Value]))
		end
	end
end

function babgame:debug() -- dont
	local diff = (self.BR.PrimaryPart.Position-self.TL.PrimaryPart.Position)
	if diff.x == 0 then
		for z = 0, diff.z, math.sign(diff.z) do
			for y = 0, diff.y, math.sign(diff.y) do
				local t = Instance.new("Part", workspace)
				t.Size = Vector3.new(1, 1, 1)
				t.Anchored = true
				t.Position = Vector3.new(0, y, z)+self.TL.PrimaryPart.Position
			end
		end
	else
		for y = 0, diff.y, math.sign(diff.y) do
			for x = 0, diff.x, math.sign(diff.x) do
				local t = Instance.new("Part", workspace)
				t.Size = Vector3.new(1, 1, 1)
				t.Anchored = true
				t.Position = Vector3.new(x, y, 0)+self.TL.PrimaryPart.Position
			end
		end	
	end
end

return babgame

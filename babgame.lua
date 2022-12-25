local babgame = {}

local keycodes = {}
for _, v in pairs(Enum.KeyCode:GetEnumItems()) do
	keycodes[v.Value]=v
end

function babgame:load(TLcolor, BRcolor, TICKcolor, inc)
	self.backgroundColor = Color3.new(0, 0, 0)
	self.screen = {data={}}
	self.keys = {data={}}

	local function handleBlock(v)
		if v.PrimaryPart.Color == TLcolor then
			self.TL=v -- top left corner
		elseif v.PrimaryPart.Color == BRcolor then
			self.BR=v -- bottom right corner
		elseif v.PrimaryPart.Color == TICKcolor then
			self.TICK=v -- ticker
		end
		
		if v.Name == 'NeonBlock' then
			local entry = {}
			local pos3 = v.PrimaryPart.Position-self.TL.Position -- get 3d relative position

			if pos3.x == 0 then
				entry.pos2 = Vector2.new(math.abs(pos3.z), math.abs(pos3.y))
			else -- pos3.z == 0
				entry.pos2 = Vector2.new(math.abs(pos3.x), math.abs(pos3.y))
			end
			entry.block = v

			self.screen.data[#self.screen.data+1] = entry -- add entry
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

	function self.screen.setPixel(pos2, color)
		for _, v in pairs(self.screen) do
			if v.pos2 == pos2 then
				self:paint(v, color)
			end
		end
	end

	function self.screen.getPixel(pos2)
		for _, v in pairs(self.screen) do
			
		end
	end

	function self.keys.keyPressed(keyfunction)
		for _, v in pairs(self.keys.data) do
			v.BulbEnd.PointLight.Changed:Connect(function(value) 
				if value == 'Enabled' then 
					keyfunction(keycodes[v.BindFire.Value]) 
				end
			end)
		end
	end

	function self.keys.getKeys()
		local _keys = {}
		for _, v in pairs(self.keys.data) do
			_keys[#_keys+1] = keycodes[v.BindFire.Value]
		end

		return _keys
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

function babgame:tick()
	self.screen.setPixel()
end

function babgame:update(drawfunction)
	while true do
		for _, v in pairs(self.screen.data) do
			spawn(function()
				if self.screen.getPixel(v.pos2) ~= self.backgroundColor then
					self.screen.setPixel(v.pos2, self.backgroundColor)
				end
			end)
		end

		drawfunction()

		self:tick()
	end
end

function babgame:paint(block, color)

end

return babgame

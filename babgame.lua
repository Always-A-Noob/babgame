local babgame = {}

local player = game:GetService('Players').LocalPlayer
local keycodes = {}
for _, v in pairs(Enum.KeyCode:GetEnumItems()) do
	keycodes[v.Value]=v
end

function babgame:load(TLcolor, BRcolor, TICKcolor, inc)
	self.backgroundColor = Color3.new(0, 0, 0)
	self.screen = {data={}}
	self.keys = {data={}}

	local function getSpecialBlocks(v)
		if v.PrimaryPart.Color == TLcolor then
			self.TL=v -- top left corner
		elseif v.PrimaryPart.Color == BRcolor then
			self.BR=v -- bottom right corner
		elseif v.PrimaryPart.Color == TICKcolor then
			self.TICK=v -- ticker
		end
	end

	local function getGameBlocks(v)
		if v.Name == 'NeonBlock' then
			local entry = {}
			local pos3 = v.PrimaryPart.Position-self.TL.PrimaryPart.Position -- get 3d relative position

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
	
	local function getMyBlocks(func)
		for _, v in pairs(workspace:GetChildren()) do
			local tag = v:FindFirstChild('Tag')
			-- check if it is a player-placed block
			if tag then
				-- check if owner is me
				if tag.Value == player.Name then
					func(v)
				end
			end
		end
	end
	getMyBlocks(getSpecialBlocks)
	getMyBlocks(getGameBlocks)

	function self.screen.setPixel(pos2, color, yield)
		for _, v in pairs(self.screen.data) do
			if v.pos2 == pos2 then
				return self:paint(v, color, yield)
			end
		end

		return nil
	end

	function self.screen.getPixel(pos2)
		for _, v in pairs(self.screen.data) do
			if v.pos2 == pos2 then
				return v.block
			end
		end

		return nil
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
	self:paint(self.TICK, Color3.new(1, 0, 0), true)
end

function babgame:update(drawfunction)
	--while true do
		for _, v in pairs(self.screen.data) do
			spawn(function()
				if self.screen.getPixel(v.pos2) ~= self.backgroundColor then
					self.screen.setPixel(v.pos2, self.backgroundColor)
				end
			end)
		end

		drawfunction()

		self:tick()
	--end
end

function babgame.getPaintTool()
	return (player.Backpack:FindFirstChild('PaintingTool') or player.Character:FindFirstChild('PaintingTool'))
end

function babgame:paint(block, color, yield)
	-- Script generated by SimpleSpy - credits to exx#9394
	local args = {
    	[1] = {
        	[1] = {
            	[1] = block,
            	[2] = color,
        	},
    	},
	}

	if yield then
		return self.getPaintTool().RF:InvokeServer(unpack(args))
	else
		self.getPaintTool().RF:InvokeServer(unpack(args))
		return nil
	end
end

return babgame

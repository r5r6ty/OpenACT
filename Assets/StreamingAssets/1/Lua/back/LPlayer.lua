
local utils = require 'tool1_utils'

LPlayer = {object = nil, keys = nil, commands = nil}
LPlayer.__index = LPlayer
function LPlayer:new(o)
	local self = {}
	setmetatable(self, LPlayer)

	self.object = o

	self.keys = {}


	self:createKey("U", CS.UnityEngine.KeyCode.W)
	self:createKey("D", CS.UnityEngine.KeyCode.S)
	self:createKey("B", CS.UnityEngine.KeyCode.A)
	self:createKey("F", CS.UnityEngine.KeyCode.D)
	self:createKey("a", CS.UnityEngine.KeyCode.Mouse0)

	self.keys["U"].antiKey = self.keys["D"]
	self.keys["D"].antiKey = self.keys["U"]
	self.keys["B"].antiKey = self.keys["F"]
	self.keys["F"].antiKey = self.keys["B"]

	self.commands = {}

	self:createCommand(self.object.database[self.object.id].char.commands)

    return self
end

function LPlayer:createKey(id, k)
	local key = {}
	key.id = id
	key.key = k
	key.antiKey = nil
	key.count = 0

	self.keys[id] = key
end

function LPlayer:createCommand(c)
	for i, v in ipairs(c) do
		if v.active then
			local command = {}
			command.name = v.name
			command.cmds = self:createCMD(v.command)
			command.time = v.time
			command.action = v.action
			command.frame = v.frame
			command.count = 1
			command.timeCount = 0

			self.commands[command.name] = command
		end
	end
end

function LPlayer:createCMD(c)
	local cmds = {}

	local str = utils.split(c, ",")

	for i = 1, #str, 1 do
		local cmd = {}
		cmd.kind = 0
		cmd.keys = {}
		local count = 1
		while count <= #str[i] do
			local char = string.sub(str[i], count, count)
			if self.keys[char] == nil then
				if char == "~" then
					cmd.kind = 0
				end
				if char == "!" then
					cmd.kind = 0
				end
				if char == ">" then
					cmd.kind = 0
				end
			else
				table.insert(cmd.keys, self.keys[char])
			end
			count = count + 1
		end
		table.insert(cmds, cmd)
	end
	return cmds
end

function LPlayer:input()
--~ 	if CS.UnityEngine.Input.anyKey then

--~ 		print(CS.UnityEngine.Event.current.keyCode)

		for i, v in pairs(self.keys) do
			if CS.UnityEngine.Input.GetKeyDown(v.key) then
				v.count = 1
				for i2, v2 in pairs(self.keys) do
					if v2.count > 0 then
						v2.count = 1
					end
				end
				if v.antiKey ~= nil then
					if CS.UnityEngine.Input.GetKey(v.antiKey.key) then
						v.count = 0
						v.antiKey.count = 0
					end
				end

			elseif CS.UnityEngine.Input.GetKeyUp(v.key) then
				v.count = 0
				for i2, v2 in pairs(self.keys) do
					if v2.count > 0 then
						v2.count = 1
					end
				end
			elseif CS.UnityEngine.Input.GetKey(v.key) then
				v.count = v.count + 1
				if v.antiKey ~= nil then
					if CS.UnityEngine.Input.GetKey(v.antiKey.key) then
						v.count = 0
						v.antiKey.count = 0
					end
				end
			else
				v.count = 0
			end


		end
--~ 	end
end

function LPlayer:isAnyKeyDown(key)
	for i, v in pairs(self.keys) do
		if v ~= key then
			if v.count > 0 then
				return true
			end
		else
			print("wa")
		end
	end
	return false
end

function LPlayer:displayKeys()
	for i, v in pairs(self.keys) do
		CS.UnityEngine.GUILayout.Label(v.id .. ": " .. v.count)
	end
	for i, v in pairs(self.commands) do
		CS.UnityEngine.GUILayout.Label(v.name .. ": " .. v.count)
	end
end

function LPlayer:getIterateKeys(keysA, keysB)
	local iterate = {}
	for i, v in ipairs(keysA) do
		for i2, v2 in ipairs(keysB) do
			if v == v2 then
				table.insert(iterate, v)
			end
		end
	end
	return iterate
end



function LPlayer:judgeCommand()
	for i, v in pairs(self.commands) do -- command
		if v.count <= #v.cmds then
			local v2 = v.cmds[v.count]

	--~ 		print(v.name .. v.count)

			local test = ""
			local success = false
			local ok = 0
			for i3, v3 in ipairs(v2.keys) do -- keys
				if v3.count == 1 or v3.count == 2 then
					ok = ok + 1
					test = test .. v3.id
				end
			end

			if ok >= #v2.keys then
				print(test)
				success = true
			else
				if v.cmds[v.count - 1] ~= nil then
					local iterate = LPlayer:getIterateKeys(v2.keys, v.cmds[v.count - 1].keys)
					local ok2 = 0



					for i4, v4 in ipairs(iterate) do -- keys
						if v4.count > 0 then
							ok2 = ok2 + 1
						end

					end

					if ok2 < #iterate then
						v.count = 1
						v.timeCount = 0
					end
				end
			end
			if success then
				v.count = v.count + 1
				v.timeCount = 0
			else
				if v.timeCount >= v.time then
					v.count = 1
					v.timeCount = 0
				end
			end
			if v.count > 1 then
				v.timeCount = v.timeCount + 1
			end
		else
			self.object:addEvent("Command", 1, function()
				if self.object.commandQueue[v.name] ~= nil then
					self.object.action = v.action
					self.object.frame = v.frame + 1
					self.object.delay = 0
					self.object.delayCounter = 0
					self.object:clearCollidersAndCommand()
				end
			end)
			v.count = 1
		end
	end
end

local utils = require "tool1_utils"

LPlayer = {object = nil, camera = nil, keys = nil, commands = nil}
LPlayer.__index = LPlayer
function LPlayer:new(o, c)
	local self = {}
	setmetatable(self, LPlayer)

	self.object = o
	self.camera = c

	self.keys = {}


	-- ��������ӳ��
	self:createKey("U", {CS.UnityEngine.KeyCode.W}) -- ��
	self:createKey("D", {CS.UnityEngine.KeyCode.S}) -- ��
	self:createKey("B", {CS.UnityEngine.KeyCode.A}) -- ��
	self:createKey("F", {CS.UnityEngine.KeyCode.D}) -- ��

	self:createKey("UB", {CS.UnityEngine.KeyCode.W, CS.UnityEngine.KeyCode.A}) -- ����
	self:createKey("UF", {CS.UnityEngine.KeyCode.W, CS.UnityEngine.KeyCode.D}) -- ����
	self:createKey("DB", {CS.UnityEngine.KeyCode.S, CS.UnityEngine.KeyCode.A}) -- ����
	self:createKey("DF", {CS.UnityEngine.KeyCode.S, CS.UnityEngine.KeyCode.D}) -- ����

	self:createKey("a", {CS.UnityEngine.KeyCode.Mouse0}) -- ������
	self:createKey("b", {CS.UnityEngine.KeyCode.Mouse1}) -- ������
	self:createKey("c", {CS.UnityEngine.KeyCode.Mouse2}) -- ������

	self:createKey("j", {CS.UnityEngine.KeyCode.Space}) -- ��Ծ��
--~ 	self:createKey("e", {CS.UnityEngine.KeyCode.E}) -- ������

	-- �����ͻ��
	self.keys["U"].antiKey = self.keys["D"] -- ���¶Գ�
	self.keys["D"].antiKey = self.keys["U"] -- ���¶Գ�
	self.keys["B"].antiKey = self.keys["F"] -- ���ҶԳ�
	self.keys["F"].antiKey = self.keys["B"] -- ���ҶԳ�

	self.keys["UB"].antiKey = self.keys["DF"] -- �������¶Գ�
	self.keys["UF"].antiKey = self.keys["DB"] -- �������¶Գ�
	self.keys["DB"].antiKey = self.keys["UF"] -- �������¶Գ�
	self.keys["DF"].antiKey = self.keys["UB"] -- �������¶Գ�

	-- ���巴���
	self.keys["B"].reverseKey = self.keys["F"] -- ���һ���
	self.keys["F"].reverseKey = self.keys["B"] -- ���һ���

	self.keys["UB"].reverseKey = self.keys["UF"] -- �������ϻ���
	self.keys["UF"].reverseKey = self.keys["UB"] -- �������ϻ���
	self.keys["DB"].reverseKey = self.keys["DF"] -- �������»���
	self.keys["DF"].reverseKey = self.keys["DB"] -- �������»���


	self.commands = {}
	self.commands_sort = {}

	self:createCommand(self.object.database[self.object.id].char.commands)

	for i, v in pairs(self.commands) do
		-- if v ~= nil then
			table.insert(self.commands_sort, {key = v.level, value = v})
		-- end
	end

	table.sort(self.commands_sort, function(a, b) -- level�͵���ʽ�ź���
		return a.key > b.key
	end)

    return self
end

function LPlayer:followCharacter()
	local charPos = self.object.gameObject.transform.position
	self.camera.transform.position = CS.UnityEngine.Vector3(charPos.x, charPos.y, self.camera.transform.position.z)
end

function LPlayer:createKey(id, k)
	local key = {}
	key.id = id
	key.keys = {}
	for i, v in ipairs(k) do
		table.insert(key.keys, v)
	end
	key.antiKey = nil
	key.reverseKey = nil
	key.count = 0
	key.state = 0

	self.keys[id] = key
end

function LPlayer:createCommand(c)
	for i, v in ipairs(c) do
		if v.active then
			local command = {}
			command.name = v.name
			command.level = v.level
			command.cmds = self:createCMD(v.command)
			command.time = v.time
			command.frame = v.frame
			command.count = 1
			command.timeCount = 0
			command.direction = 0

			self.commands[command.name] = command
		end
	end
end

function LPlayer:createCMD(c)
	local cmds = {}
	for i, v in ipairs(c) do
		local cmd = {}
		cmd.kind = 0
		cmd.keys = {}
		local found = false
		-- ������ʲô����
		for i2, v2 in pairs(self.keys) do
			if utils.isStringAContainB(v.key, v2.id) then
				table.insert(cmd.keys, self.keys[v2.id])
				found = true
				break
			end
		end
		-- ���û�ҵ�����+�ŷֿ�����
		if found == false then
			local str = utils.split(c, "+")
			for i = 1, #str, 1 do
				table.insert(cmds.keys, self.keys[string.sub(str, i, i)])
			end
		end
		-- ���⹦�ܼ���
		if v.kind ~= nil and v.kind ~= "" then
			if v.kind == "/" then -- ��ס
				cmd.kind = 1
			elseif v.kind == "~" then -- �ſ�
				cmd.kind = 2
			elseif v.kind == ">" then -- ��һ�ΰ�������һ�ΰ���֮�в��ܲ��������İ���
				cmd.kind = 3
			end
		end
		table.insert(cmds, cmd)
	end
	return cmds
end

function LPlayer:input()
	for i, v in pairs(self.keys) do
		if self:isKeyDown(v.keys) then
			for i2, v2 in pairs(self.keys) do -- �����һ�������£�����������ſ�
				v2.count = 0

				if v2.count == 0 then -- ���֮ǰû�������ھ���û��
					v2.state = 0
				elseif v2.count == 1 then -- ���֮ǰ�հ��£����ھ��Ǹշſ�
					v2.state = 3
				elseif v.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��Ǹշſ�
					v2.state = 3
				end
			end

			if v.count == 0 then -- ���֮ǰû�������ھ��Ǹհ���
				v.state = 1
			elseif v.count == 1 then -- ���֮ǰ�հ��£����ھ��ǰ�ס
				v.state = 2
			elseif v.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��ǰ�ס
				v.state = 2
			end

			v.count = v.count + 1
			if v.antiKey ~= nil then
				if self:isKey(v.antiKey.keys) then
					v.count = 0
					v.antiKey.count = 0
				end

				if v.count == 0 then -- ���֮ǰû�������ھ���û��
					v.state = 0
				elseif v.count == 1 then -- ���֮ǰ�հ��£����ھ��Ǹշſ�
					v.state = 3
				elseif v.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��Ǹշſ�
					v.state = 3
				end
				if v.antiKey.count == 0 then -- ���֮ǰû�������ھ���û��
					v.antiKey.state = 0
				elseif v.antiKey.count == 1 then -- ���֮ǰ�հ��£����ھ��Ǹշſ�
					v.antiKey.state = 3
				elseif vantiKey..count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��Ǹշſ�
					v.antiKey.state = 3
				end
			end
		elseif self:isKey(v.keys) then
			if v.count == 0 then -- ���֮ǰû�������ھ��Ǹհ���
				v.state = 1
			elseif v.count == 1 then -- ���֮ǰ�հ��£����ھ��ǰ�ס
				v.state = 2
			elseif v.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��ǰ�ס
				v.state = 2
			end

			v.count = v.count + 1
			if v.antiKey ~= nil then
				if self:isKey(v.antiKey.keys) then
					v.count = 0
					v.antiKey.count = 0

					if v.count == 0 then -- ���֮ǰû�������ھ���û��
						v.state = 0
					elseif v.count == 1 then -- ���֮ǰ�հ��£����ھ��Ǹշſ�
						v.state = 3
					elseif v.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��Ǹշſ�
						v.state = 3
					end
					if v.antiKey.count == 0 then -- ���֮ǰû�������ھ���û��
						v.antiKey.state = 0
					elseif v.antiKey.count == 1 then -- ���֮ǰ�հ��£����ھ��Ǹշſ�
						v.antiKey.state = 3
					elseif v.antiKey.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��Ǹշſ�
						v.antiKey.state = 3
					end
				end
			end
		elseif self:isKeyUp(v.keys) then
			for i2, v2 in pairs(self.keys) do -- �����һ�����ſ�������������ſ�
				if v2.count == 0 then -- ���֮ǰû�������ھ���û��
					v2.state = 0
				elseif v2.count == 1 then -- ���֮ǰ�հ��£����ھ��Ǹշſ�
					v2.state = 3
				elseif v.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��Ǹշſ�
					v2.state = 3
				end
			end
		else
			if v.count == 0 then -- ���֮ǰû�������ھ���û��
				v.state = 0
			elseif v.count == 1 then -- ���֮ǰ�հ��£����ھ��Ǹշſ�
				v.state = 3
			elseif v.count > 1 then -- ���֮ǰ�ǰ�ס�����ھ��Ǹշſ�
				v.state = 3
			end

			v.count = 0
		end
	end
end

function LPlayer:isKeyDown(keys)
	local c = 0
	for i = 1, #keys, 1 do
		if CS.UnityEngine.Input.GetKeyDown(keys[i]) then
			c = c + 1
		end
	end
	if c == #keys then
		return true
	end
	return false
end

function LPlayer:isKey(keys)
	local c = 0
	for i = 1, #keys, 1 do
		if CS.UnityEngine.Input.GetKey(keys[i]) then
			c = c + 1
		end
	end
	if c == #keys then
		return true
	end
	return false
end

function LPlayer:isKeyUp(keys)
	local c = 0
	for i = 1, #keys, 1 do
		if CS.UnityEngine.Input.GetKeyUp(keys[i]) then
			c = c + 1
		end
	end
	if c == #keys then
		return true
	end
	return false
end

function LPlayer:isAnyKeyDown(key)
	for i, v in pairs(self.keys) do
		if v ~= key then
			if v.count > 0 then
				return true
			end
		else
			print("wa!!!!!!!!!!!!!!!!!!!")
		end
	end
	return false
end

function LPlayer:displayKeys()
	for i, v in pairs(self.keys) do
		CS.UnityEngine.GUILayout.Label(v.id .. ": " .. v.count .. "," .. v.state)
	end
	for i, vvv in pairs(self.commands_sort) do
		local v = vvv.value
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
	for i, vvv in pairs(self.commands_sort) do -- command
		local v = vvv.value
		if v.count <= #v.cmds then
			local v2 = v.cmds[v.count]

	--~ 		print(v.name .. v.count)

			local success = false
			local rev = false
			local rok = 0
			local ok = 0
			for i3, v3 in ipairs(v2.keys) do -- keys
				local myKey = nil
				local myReverseKey = nil
				if v.direction == -1 and v3.reverseKey ~= nil then
					myKey = v3.reverseKey
					myReverseKey = v3
				else
					myKey = v3
					myReverseKey = v3.reverseKey
				end
--~ 				print(v2.kind)
				if v3.reverseKey ~= nil then
					rev = true
				end
				if v2.kind == 0 then
					if myKey.state == 1 then -- �հ���
						ok = ok + 1
					else
						if myReverseKey ~= nil and v.direction == 0 then
							if myReverseKey.state == 1 then -- ����հ���
								ok = ok + 1
								rok = rok - 1
							end
						end
					end
				elseif v2.kind == 1 then
					if myKey.state == 2 then -- ��ס
						ok = ok + 1
					else
						if myReverseKey ~= nil and v.direction == 0 then
							if myReverseKey.state == 2 then -- ����ס
								ok = ok + 1
								rok = rok - 1
							end
						end
					end
				elseif v2.kind == 2 then
					if myKey.state == 3 then -- �շſ�
						ok = ok + 1
					else
						if myReverseKey ~= nil and v.direction == 0 then
							if myReverseKey.state == 3 then -- ����շſ�
								ok = ok + 1
								rok = rok - 1
							end
						end
					end
				elseif v2.kind == 3 then -- ��һ�ΰ�������һ�ΰ���֮�в��ܲ��������İ���
					if myKey.state == 1 then
						ok = ok + 1
					else
						if myReverseKey ~= nil and v.direction == 0 then
							if myReverseKey.state == 1 then
								ok = ok + 1
								rok = rok - 1
							end
						end
					end
				end
			end

			if ok >= #v2.keys then
				if v.direction == 0 and rev == true then
					if rok < 0 then
						v.direction = -1
					else
						v.direction = 1
					end
				end
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
						v.direction = 0
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
					v.direction = 0
				end
			end
			if v.count > 1 then
				v.timeCount = v.timeCount + 1
			end
		else
			self.object:addEvent("Input", 0, 1, {level = v.level, name = v.name, direction = v.direction, frame = v.frame})
--~ 			self.object:addEvent("Input", 1, {level = v.level, name = v.name, direction = v.direction, frame = v.frame})
			v.count = 1
			v.timeCount = 0
			v.direction = 0
		end
	end
end

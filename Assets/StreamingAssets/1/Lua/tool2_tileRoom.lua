-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local utils = require "tool1_utils"

--~ -- ������linker
--~ local linker = {kind = 0, pos = {}}
-- ������������������������������ԣ����Ҹ��������Եĳ�ʼֵ
tileRoom = {name = nil, x = 0, y = 0, width = 0, height = 0, linkers = nil, map = nil}
-- ����Ԫ�����������ģ����Ļ����ⲽ�����ܹؼ�
tileRoom.__index = tileRoom
-- ���췽��new
function tileRoom:new(x, y, level, map, n)
    local self = {}  --��ʼ��self�����û����䣬��ô���������Ķ��������һ���ı䣬�������󶼻�ı�
    setmetatable(self, tileRoom)  --��self��Ԫ���趨ΪClass
    self.x = x
    self.y = y
    self.width = level.width
    self.height = level.height
    self.name = n
	self.linkers = {}
	self.map = {}

	-- ��room����Ϣд��map��
    for i = x, x + level.width - 1, 1 do
        if map[i] == nil then
            map[i] = {}
        end
		self.map[i] = {}
        for j = y, y + level.height - 1, 1 do
            local num = ((i - x) + (j - y) * level.width) + 1
			-- ���Ҫ���ɵķ����λ����û�л�����ǽ�ڣ������ɷ���
			if map[i][j] == nil or map[i][j] == 0  then
				map[i][j] = level.blocks[num]
			end
			self.map[i][j] = level.blocks[num]
        end
    end

	-- ���level�е����ӵ㣬�����ӵ�������Ϸ�������õ�ʵ������
	if #level.connectors > 0 then
		print(#level.connectors)
		self.linkers = utils.deep_copy(level.connectors)
		for i = 1, #self.linkers, 1 do
			for j = 1, #self.linkers[i].position, 1 do
				self.linkers[i].position[j].x = self.linkers[i].position[j].x + self.x
				self.linkers[i].position[j].y = self.linkers[i].position[j].y + self.y
			end
			for j = 1, #self.linkers[i].dPosition, 1 do
				self.linkers[i].dPosition[j].x = self.linkers[i].dPosition[j].x + self.x
				self.linkers[i].dPosition[j].y = self.linkers[i].dPosition[j].y + self.y
			end
		end
	end
--    print("new", self.linkers, level.connectors)
    return self  --��������
end

-- ���ӷ��䣨�ĸ����ӵ㣬����Ԥ�裬���ͼ��
function tileRoom:link(linkIndex, level, map, n)
	if #self.linkers == 0 then
		return nil, nil, nil
	end
	-- �Լ�room�����ӵ���ʱѡ��Ϊ��1��
    local myLinker = self.linkers[linkIndex]
    local ml_x = myLinker.position[1].x
    local ml_y = myLinker.position[1].y
	-- ���level�����ӵ������ʱ
    local temp = utils.deep_copy(level.connectors)
    local num = CS.Tools.Instance:RandomRangeInt(1, #temp + 1)
    local linker = temp[num]
	local x2 = nil
	local y2 = nil
	-- print("temp: " .. #temp)

	-- �����ʱ�������ӵ㣬�����һ����judge
    while #temp > 0 do
		-- ������ӵ㲻�����������������ж�Ϊ�����������ӣ�����remove������ӵ�
		if myLinker.kind ~= linker.kind or myLinker.isConnected ~= linker.isConnected then -- or myLinker.width ~= linker.width or myLinker.height ~= linker.height -- ��ȣ��߶���ʱ������
			table.remove(temp, num)
			num = CS.Tools.Instance:RandomRangeInt(1, #temp + 1)
			linker = temp[num]
		else
			-- ����ж�Ϊ�����������ӣ������judgeѭ��

			-- ���level
			local tempLevel = utils.deep_copy(level)
			local ip = {}
			for a = 1, #tempLevel.connectors, 1 do
				for b = 1, #tempLevel.connectors[a].position, 1 do
					local x = tempLevel.connectors[a].position[b].x
					local y = tempLevel.connectors[a].position[b].y
					-- ����ǰ��������Ӵ�ȫ�����ϣ���ǰ���ӵĵ��������
					if tempLevel.connectors[a].index ~= linker.index then
						tempLevel.blocks[(x + y * tempLevel.width) + 1] = 1
					else
						table.insert(ip, {cx = x, cy = y})
					end
				end
			end

			local f = false
			local n = CS.Tools.Instance:RandomRangeInt(1, #linker.position + 1)
			while #linker.position > 0 do
				x2, y2 = self:judge(n, linker, ml_x, ml_y, tempLevel, map, ip)
				-- judge���Ϊû�����꣬��remove������ӵ������һ������㣬����break
				if x2 == nil or y2 == nil then
					table.remove(linker.position, n)
					n = CS.Tools.Instance:RandomRangeInt(1, #linker.position + 1)
				else
					f = true
					break
				end
			end
			-- ����ҵ��˿��Դ�������ĵ㣬��break������remove������ӵ�
			if f == false then
				table.remove(temp, num)
				num = CS.Tools.Instance:RandomRangeInt(1, #temp + 1)
				linker = temp[num]
			else
				break
			end

		end
    end
--    print("new", temp, level.connectors)
    if #temp <= 0 then
        return nil, nil, nil
    end

	-- ��������
	local r = self:new(x2, y2, level, map, n)
	-- print("created room name: ".. n .. ", x2: " .. x2 .. ", y2: " .. y2)

	-- ���Ӵ�����Ϊ������
    myLinker.isConnected = true
	r.linkers[linker.index].isConnected = true

    return x2, y2, r
end

-- �ж������Ƿ��ܱ����ɣ����ط������Ͻǵ�����
function tileRoom:judge(n, linker, ml_x, ml_y, level, map, ignorePoint)
    local l_x = linker.position[n].x
    local l_y = linker.position[n].y
    -- print("type " .. myLinker.kind .. "," .. linker.kind)
    local x2 = ml_x - l_x
    local y2 = ml_y - l_y
	-- print(ml_x .. "," .. ml_y .. " - " .. l_x .. "," .. l_y)
    -- print(x2, y2)

	local count = 0
    for i = x2, x2 + level.width - 1, 1 do
        for j = y2, y2 + level.height - 1, 1 do
            if map[i] ~= nil then
                if map[i][j] ~= nil then
					-- �����map�в�ͬ�ķ���Ļ����ж�Ϊʧ��

					if map[i][j] ~= level.blocks[((i - x2) + (j - y2) * level.width) + 1] then
						-- print(i, j, map[i][j], level.blocks[((i - x2) + (j - y2) * level.width) + 1], i - x2, j - y2)
						-- print("gen map failed0")

						-- ��ǰ���Ӵ��ĵ㲻���жϣ�ֱ��+1
						local b = false
						for f = 1, #ignorePoint, 1 do
							if i - x2 == ignorePoint[f].cx and j - y2 == ignorePoint[f].cy then
								b = true
								break
							end
						end
						if b == false then
							return nil, nil
						else
							count = count + 1
						end
					else
						count = count + 1
					end
                end
            end
        end
    end
	-- ���������ȫ�ص����ж�Ϊʧ��
	if count == #level.blocks then
		-- print("gen map failed1")
		return nil, nil
	end
	-- print("gen map successful")
	return x2, y2
end

-- ������ӵ�
function tileRoom:close(map)
	-- ������ӵ�û�б����ӣ�������Ϊ1��ǽ�ڣ�
    for i = 1, #self.linkers, 1 do
        if self.linkers[i].isConnected == false then
            for j = 1, #self.linkers[i].position, 1 do
				local x = self.linkers[i].position[j].x
				local y = self.linkers[i].position[j].y
				map[x][y] = 1
				self.map[x][y] = 1
            end
            for j = 1, #self.linkers[i].dPosition, 1 do
				local x = self.linkers[i].dPosition[j].x
				local y = self.linkers[i].dPosition[j].y
				map[x][y] = 0
				self.map[x][y] = 0
            end
        end
    end
end

-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local utils = {}

local idLoop

-- id—≠ª∑
function idLoop(id, s)
	for i, v in pairs(s) do
		if id == v.id then
			return false
		end
		if idLoop(id, v.guiParts) == false then
			return false
		end
	end
	return true
end

-- ¥∞ø⁄id∑÷≈‰
function utils.createid(stack)
	local id = 0
	while id < 65535 do
		local judge = idLoop(id, stack)

		if judge then
			return id
		end

		id = id + 1
	end
	return nil
end

function utils.getObject(id, s)
	for i, v in pairs(s) do
		if id == v.id then
			return v
		end
		for i2, v2 in pairs(v.guiParts) do
			if id == v2.id then
				return v
			end
		end
	end
	return nil
end

function utils.split(str,reps)
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function (w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

function utils.intNumberToString(num)
	if num == nil then
		return nil
	end
	return utils.split(tostring(num), ".")[1]
end

function utils.stringToIntNumber(str)
	local num = tonumber(str)
	if str == nil or str == "" or num == nil then
		return 0
	end
	local a, b = math.modf(num)
	return a
end

function utils.drawField(cx, cy, cw, ch, subColor)
--~ 	local subColor = mainColor
--~ 	subColor.a = subColor.a - 0.5

	local x = cx / 100
	local y = cy / 100
	local w = cw / 100
	local h = ch / 100
--~ 	CS.UnityEngine.GL.PushMatrix()
--~ 	CS.UnityEngine.GL.LoadOrtho()

	CS.UnityEngine.GL.Begin(CS.UnityEngine.GL.QUADS)
	CS.UnityEngine.GL.Color(subColor)

	CS.UnityEngine.GL.Vertex3(x, y, 0)
	CS.UnityEngine.GL.Vertex3(x + w, y, 0)
	CS.UnityEngine.GL.Vertex3(x + w, y - h, 0)
	CS.UnityEngine.GL.Vertex3(x, y - h, 0)
--~ 	CS.UnityEngine.GL.End()

--~ 	CS.UnityEngine.GL.Begin(CS.UnityEngine.GL.LINES)
--~ 	CS.UnityEngine.GL.Color(mainColor)

--~ 	CS.UnityEngine.GL.Vertex3(x, y, 0)
--~ 	CS.UnityEngine.GL.Vertex3(x + w, y, 0)

--~ 	CS.UnityEngine.GL.Vertex3(x + w, y, 0)
--~ 	CS.UnityEngine.GL.Vertex3(x + w, y + h, 0)

--~ 	CS.UnityEngine.GL.Vertex3(x + w, y + h, 0)
--~ 	CS.UnityEngine.GL.Vertex3(x, y + h, 0)

--~ 	CS.UnityEngine.GL.Vertex3(x, y + h, 0)
--~ 	CS.UnityEngine.GL.Vertex3(x, y, 0)

	CS.UnityEngine.GL.End()
--~ 	CS.UnityEngine.GL.PopMatrix()
end

return utils

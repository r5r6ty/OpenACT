-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local utils = {}

local objects = {}

local idLoop

-- id循环
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

-- 窗口id分配
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

-- 字符串分割
function utils.split(str, reps)
    local resultStrList = {}
    string.gsub(str, '[^'..reps..']+' ,function (w)
        table.insert(resultStrList, w)
    end)
    return resultStrList
end

-- 比较字符串a是否包含在b里面（长度要相等）
function utils.isStringAContainB(a, b)
	if #a ~= #b then
		return false
	end
	local c = 0
	for i = 1, #a, 1 do
		local f = string.find(b, string.sub(a, i, i))
		if f ~= nil then
			c = c + 1
		end
	end
	if c == #b then
		return true
	end
	return false
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

function utils.getRangeAB(str)
	local rA, rB = string.match(str, "(%-?%d+)~(%-?%d+)")
	return tonumber(rA), tonumber(rB)
end

function utils.getFrame(str)
	local action, frame = string.match(str, "(.+)-(%d+)")
	return action, tonumber(frame) + 1
end

function utils.createObject(db, p, ac, id, f, x, y, dx, dy, k)
	local character = CS.UnityEngine.GameObject(id)
	character.transform.position = CS.UnityEngine.Vector3(x, y, 0)
	o = LObject:new(db, p, ac, id, f, character, dx, dy, k)

	utils.addObject(character:GetInstanceID(), o)
	return o
end

function utils.getObject(id)
	return objects[id]
end

function utils.addObject(id, o)
	objects[id] = o
end

function utils.destroyObject(id)
	local o = objects[id]
	if o ~= nil then
		CS.UnityEngine.GameObject.Destroy(o.gameObject)
		objects[id] = nil
	else
		print("utils.destroyObject(id) --- object is nil!")
	end
end

function utils.displayObjectsInfo()
    for i, v in pairs(objects) do
		v:displayInfo()
	end
end

function utils.runObjectsFrame()
    for i, v in pairs(objects) do
		v:runFrame()
	end
end

function utils.display()
	local num = 0
	for i, v in pairs(objects) do
		num = num + 1
	end
	CS.UnityEngine.GUILayout.Label("object: " .. num)
end

-- 从.img加载图片做成texture2D
function utils.loadImageToTexture2D(b64str)
	local temp = utils.split(b64str, ",")
	temp = temp[#temp]
	local mod4 = #temp % 4
	if mod4 > 0 then
		for i = 1, 4 - mod4, 1 do
			temp = temp .. "="
		end
	end

	local bytes = CS.System.Convert.FromBase64String(temp)

	-- 加载图片
	local texture = CS.UnityEngine.Texture2D(0, 0, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	texture.filterMode = CS.UnityEngine.FilterMode.Point
--~ 	CS.UnityEngine.ImageConversion.LoadImage(texture, bytes) -- 这个怎么不行了？
	texture:LoadImage(bytes) --- Texture2d  成员方法无法使用，为什么？为什么又能使用了？

	return texture
end

function utils.drawField(cx, cy, cw, ch, subColor)
--~ 	local subColor = mainColor
--~ 	subColor.a = subColor.a - 0.5
	local scale = 100
	local x = cx / scale
	local y = cy / scale
	local w = cw / scale
	local h = ch / scale
	CS.UnityEngine.GL.PushMatrix()
--~ 	CS.UnityEngine.GL.LoadOrtho()

	CS.UnityEngine.GL.Begin(CS.UnityEngine.GL.QUADS)
	CS.UnityEngine.GL.Color(subColor)

	CS.UnityEngine.GL.Vertex3(x, -y, 0)
	CS.UnityEngine.GL.Vertex3(x + w, -y, 0)
	CS.UnityEngine.GL.Vertex3(x + w, -(y + h), 0)
	CS.UnityEngine.GL.Vertex3(x, -(y + h), 0)
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
	CS.UnityEngine.GL.PopMatrix()
end

-- 求相交bounds面积
function utils.getBoundsIntersectsArea(lhs, rhs)
	local c = lhs.center - rhs.center
	local r = lhs.extents + rhs.extents

	local xxx = r - CS.UnityEngine.Vector3(math.abs(c.x), math.abs(c.y), math.abs(c.z))
	return xxx
end

return utils

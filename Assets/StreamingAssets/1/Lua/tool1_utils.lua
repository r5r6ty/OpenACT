-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local utils = {}

utils.platform = "PC"
utils.resourcePath = CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/"
utils.resourcePathDataPath = CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/data/"

local luaPath = CS.GameLoader.Getluapath()
if string.find(luaPath, "http") then
	utils.platform = "WebGL"
	utils.resourcePath = string.gsub(luaPath, "Lua", "Resource")
	utils.resourcePathDataPath = string.gsub(luaPath, "Lua", "Resource/data")
end

local LDatas = {}
local objects = {}

local hp = nil
local mp = nil
local black = nil
local white = nil
local yellow = nil
local gray = nil

local idLoop

utils.downloadText = coroutine.create(function(path)
	local www = CS.UnityEngine.Networking.UnityWebRequest.Get(path)
	coroutine.yield(versionW:SendWebRequest())
	if www.isNetworkError then
		print(versionW.error)
	end
	coroutine.yield(www)
end)

function utils.openFileText(path)
	local str = nil
	if utils.platform == "PC" then
		local file = io.open(path, "r")
		io.input(file)
		str = io.read("*a")
		io.close(file)
	else
		local stat, mainre = coroutine.resume(utils.downloadText, path)
		str = mainre.text

		-- local www = CS.UnityEngine.WWW(path)
		-- while not www.isDone do
		-- 	if www.error ~= nil and www.error ~= "" then
		-- 		print(www.error)
		-- 		return nil
		-- 	end
		-- end
		-- str = www.text
	end
	return str
end

function utils.openFileBytes(path)
	local bytes = nil
	if utils.platform == "PC" then
		local file = io.open(path, "rb")
		io.input(file)
		bytes = io.read("*a")
		io.close(file)
	else
		local stat, mainre = coroutine.resume(utils.downloadText, path)
		str = mainre.bytes
		-- local www = CS.UnityEngine.WWW(path)
		-- while not www.isDone do
		-- 	if www.error ~= nil and www.error ~= "" then
		-- 		print(www.error)
		-- 		return nil
		-- 	end
		-- end
		-- bytes = www.bytes
	end
	return bytes
end

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
	if str == "" or str == nil then
		return nil, nil
	end
	local rA, rB = string.match(str, "(%-?%d+)~(%-?%d+)")
	return tonumber(rA), tonumber(rB)
end

function utils.getFrame(str)
	local action, frame = string.match(str, "(.+)-(%d+)")
	return action, tonumber(frame) + 1
end

function utils.GetLDatas()
	return LDatas
end

function utils.getIDData(id)
	return LDatas[id]
end

function utils.setIDData(id, data)
	LDatas[id] = data
end

function utils.createObject(id, a, f, x, y, dx, dy, k)
	local character = CS.UnityEngine.GameObject(LDatas[id].name)
	character.transform.position = CS.UnityEngine.Vector3(x, y, 0)
	o = LObject:new(LDatas[id].db, LDatas[id].pics, LDatas[id].palettes[1], 1, LDatas[id].audioClips, id, a, f, character, dx, dy, k)

	local IID = character:GetInstanceID()
	utils.addObject(IID, o)
	return o, IID
end

function utils.setPalette(o, n)
	o.palette = n
	o.spriteRenderer.material = LDatas[o.id].palettes[n]
end

function utils.getObjects()
	return objects
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

function utils.createHPMP()

	hp = CS.UnityEngine.Texture2D(1, 1, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	hp.filterMode = CS.UnityEngine.FilterMode.Point
	hp:SetPixel(0, 0, CS.UnityEngine.Color(1, 0, 0))
	hp:Apply()

	mp = CS.UnityEngine.Texture2D(1, 1, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	mp.filterMode = CS.UnityEngine.FilterMode.Point
	mp:SetPixel(0, 0, CS.UnityEngine.Color(0, 0, 1))
	mp:Apply()

	black = CS.UnityEngine.Texture2D(1, 1, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	black.filterMode = CS.UnityEngine.FilterMode.Point
	black:SetPixel(0, 0, CS.UnityEngine.Color(0, 0, 0))
	black:Apply()

	white = CS.UnityEngine.Texture2D(1, 1, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	white.filterMode = CS.UnityEngine.FilterMode.Point
	white:SetPixel(0, 0, CS.UnityEngine.Color(1, 1, 1))
	white:Apply()

	yellow = CS.UnityEngine.Texture2D(1, 1, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	yellow.filterMode = CS.UnityEngine.FilterMode.Point
	yellow:SetPixel(0, 0, CS.UnityEngine.Color(1, 1, 0))
	yellow:Apply()

	gray = CS.UnityEngine.Texture2D(1, 1, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	gray.filterMode = CS.UnityEngine.FilterMode.Point
	gray:SetPixel(0, 0, CS.UnityEngine.Color(0.5, 0.5, 0.5))
	gray:Apply()
end

function utils.drawHPMP(x, y, h, m, f, d)
	local width = 50
	local height = 3
	local offset = 0
	if h > 0 and h < 1 then
		CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2 - 1, y - 1, width + 2, height + 2), white)
		CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y, width, height), black)
		CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y, width * h, height), hp)

		offset = offset + 6
	end

	if h > 0 then
		if m > 0 and m < 1 then
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2 - 1, y - 1 + offset, width + 2, height + 2), white)
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y + offset, width, height), black)
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y + offset, width * m, height), mp)

			offset = offset + 6
		end

		if f > 0.01 then
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2 - 1, y - 1 + offset, width + 2, height + 2), white)
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y + offset, width, height), black)
			if f >= 0.7 then
				CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y + offset, width * f, height), hp)
			else
				CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y + offset, width * f, height), yellow)
			end

			offset = offset + 6
		end


		if d > 0.01 then
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2 - 1, y - 1 + offset, width + 2, height + 2), white)
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y + offset, width, height), black)
			CS.UnityEngine.GUI.DrawTexture(CS.UnityEngine.Rect(x - width / 2, y + offset, width * d, height), gray)
		end
	end

end

function utils.displayObjectsInfo()
    for i, v in pairs(objects) do
		v:displayInfo()
	end
end

function utils.runObjectsFrame()
	for i, v in pairs(objects) do
		if v.AI then
			v.database.AI:judgeAI(v)
		end
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

function utils.createUnityObject(p, name, x, y, width, height)
	--    local unityobject = CS.UnityEngine.GameObject.CreatePrimitive(CS.UnityEngine.PrimitiveType.Quad)
		local unityobject = CS.UnityEngine.GameObject(name)
		unityobject.transform.parent = p.transform
		unityobject.transform.position = CS.UnityEngine.Vector3(x / 100, y / 100, 0)
	--    unityobject.transform.localScale = CS.UnityEngine.Vector3(width / 100, height / 100, 0)
	--    unityobject:AddComponent(typeof(CS.UnityEngine.RectTransform))
	--    local image = unityobject:AddComponent(typeof(CS.UnityEngine.UI.Image))
	--    image.rectTransform.sizeDelta = CS.UnityEngine.Vector2(width, height)
	--    CS.UnityEngine.Object.Destroy(unityobject:GetComponent(typeof(CS.UnityEngine.MeshCollider)))
		for i_y = 0, height - 1, 1 do
			for i_x = 0, width - 1, 1 do
				local unityobject_child = CS.UnityEngine.GameObject(block)
				unityobject_child.transform.parent = unityobject.transform
				unityobject_child.transform.localPosition = CS.UnityEngine.Vector3(i_x * tile_size / 100, -i_y * tile_size / 100, 0)
				local sr = unityobject_child:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
				sr.sprite = tile_sprite
			end
		end
		local bc2d = unityobject:AddComponent(typeof(CS.UnityEngine.BoxCollider2D))
		bc2d.offset = CS.UnityEngine.Vector2(width * 4 / 100 / 2, -height * 4 / 100 / 2)
		bc2d.size = CS.UnityEngine.Vector2(width * 4 / 100, height * 4 / 100)
	--    bc2d.enabled = false
		local f = CS.UnityEngine.PhysicsMaterial2D("test");
		f.friction = 0;
		bc2d.sharedMaterial = f
		local rb2d = unityobject:AddComponent(typeof(CS.UnityEngine.Rigidbody2D))
		rb2d.freezeRotation = true
		rb2d.gravityScale = 0
		rb2d.angularDrag = 1
		rb2d.drag = 1
		rb2d.interpolation = CS.UnityEngine.RigidbodyInterpolation2D.Interpolate
		rb2d.useAutoMass = true
	
		local script = unityobject:AddComponent(typeof(CS.XLuaTest.LuaBehaviour))
		script.scriptEnv.map_size.w = width
		script.scriptEnv.map_size.h = height
		return script
	end
	
	-- 取整函数
	function utils.getIntPart(x)
		if x <= 0 then
			return math.ceil(x);
		end
	
		if math.ceil(x) == x then
		   x = math.ceil(x);
		else
		   x = math.ceil(x) - 1;
		end
		return x;
	end
	
	-- 创建网格纹理
	function utils.createLineTexture(tile_size, width, height)
		local line_texture = CS.UnityEngine.Texture2D(tile_size * width, tile_size * height, CS.UnityEngine.TextureFormat.RGBA32, false, false)
		line_texture.filterMode = CS.UnityEngine.FilterMode.Point
		for y = 0, height * tile_size, 1 do
			for x = 0, width * tile_size, 1 do
				if (x % tile_size == 0 or y % tile_size == 0) or (x % tile_size == tile_size - 1 or y % tile_size == tile_size - 1)  then
					line_texture:SetPixel(x, y, CS.UnityEngine.Color.red)
				else
					line_texture:SetPixel(x, y, CS.UnityEngine.Color.black)
				end
			end
		end
		line_texture:Apply()
	
		local line_texture_sprite = CS.UnityEngine.Sprite.Create(line_texture, CS.UnityEngine.Rect(0, 0, tile_size * width, tile_size * height), CS.UnityEngine.Vector2(0, 1))
		return line_texture_sprite
	end
	
	-- 从csv读取数据放入DataTable
	function utils.LoadTilesFromCSV(path)
		local dt = CS.System.Data.DataTable("test")
	
		local count = 0
		local sr = CS.System.IO.File.OpenText(path)
		local line = sr:ReadLine()
		while line ~= nil do
			local data = utils.split(line, ',')
			if count == 0 then -- 第一行作为表头
				for i, v in ipairs(data) do
					dt.Columns:Add(CS.System.Data.DataColumn(v, typeof(CS.System.String)))
				end
			else -- 其余作为数据
				local dr = dt:NewRow()
				for i, v in ipairs(data) do
					dr[i - 1] = v
				end
				dt.Rows:Add(dr)
			end
			line = sr:ReadLine()
			count = count + 1
		end
		sr:Close();
		sr:Dispose();
	
	--    print(dt.Rows.Count, dt.Columns.Count)
	
	--    for k = 0, dt.Rows.Count - 1, 1 do
	--        for j = 0, dt.Columns.Count - 1, 1 do
	--            print(dt.Rows[k][j]);
	--        end
	--    end
		return dt
	end
	
	-- 从路径加载图片做成texture2D
	function utils.LoadImageToTexture2DByPath(path)
		local bytes = utils.openFileBytes(path)
		-- 加载图片
		local texture = CS.UnityEngine.Texture2D(0, 0, CS.UnityEngine.TextureFormat.RGBA32, false, false)
		texture.filterMode = CS.UnityEngine.FilterMode.Point
	--~ 	CS.UnityEngine.ImageConversion.LoadImage(texture, bytes) -- 这个怎么不行了？
		texture:LoadImage(bytes) --- Texture2d  成员方法无法使用，为什么？为什么又能使用了？
		return texture
	end
	
	-- 用texture2D生成sprite（正方形）
	function utils.CreateSprite(texture2D, x, y, size)
		local sprite = CS.UnityEngine.Sprite.Create(texture2D, CS.UnityEngine.Rect(x * size, texture2D.height - (y + 1) * size, size, size), CS.UnityEngine.Vector2(1 - 22 / 24, 22 / 24))
		return sprite
	end
	
	-- base64解码TileLayer
	-- 解码后的数据，长度为地图的长*款*2
	-- 偶数位*奇数位得0～65535
	-- 数组长度应该是地图的长*款
	function utils.Base64DecodeToArray_Ground(str)
		-- 用C#自带的解码API
		local bytes = CS.System.Convert.FromBase64String(str)
	--    print(#bytes)
		local array = {}
		for i = 1, #bytes, 2 do
			array[(i + 1) / 2] = string.byte(string.sub(bytes, i, i)) + string.byte(string.sub(bytes, i + 1, i + 1)) * 256
	--        print(string.byte(string.sub(bytes, i, i)), string.byte(string.sub(bytes, i + 1, i + 1)), i, i + 1, math.floor(((i - 1) / 2) % 50), math.floor(((i - 1) / 2) / 50))
	--        print(string.byte(string.sub(bytes, i, i)), string.byte(string.sub(bytes, i + 1, i + 1)))
		end
		return array
	end
	
	-- base64解码DataLayer
	-- 0～255
	-- 解码后的数据，长度为地图的长*款
	function utils.Base64DecodeToArray_TileMode(str)
		-- 用C#自带的解码API
		local bytes = CS.System.Convert.FromBase64String(str)
	--    print(#bytes)
		local array = {}
		-- 循环把数据存入数组，下标起始是1
		for i = 1, #bytes, 1 do
			array[i] = string.byte(string.sub(bytes, i, i))
	--        print(string.byte(string.sub(bytes, i, i)), i, math.floor((i - 1) % 50), math.floor((i - 1) / 50))
		end
		return array
	end
	
	-- base64解码ObjectMode
	-- Object_Layer 的数据存储编码为 base64, 0xFFFF 标记这个图层为 Object_Layer, 接下来由有数据:
	
	-- X 选区的位置X, 单位为像素
	-- Y 选区的位置Y, 单位为像素
	-- ID Object的标识符, 它表示这个对象位于 tileset 的位置
	-- 所有这三个值可以有其自身的高位(bit set)的设置: 对象的旋转存放于高位的 X 和 Y, 而 flip 则存放在 ID 上
	-- sample: x选区   y选区   ID
	--   data: 128 129   0   0   32   0
	-- x选区和y选区右边的数字其中11111111的最左边的bit为旋转bit，所以像素表示范围是0～(127*256+255=32767)
	-- ID右边的数字其中11111111的最左边的bit为水平翻转bit，范围同上
	-- x选区的旋转bit和y选区的旋转bit组合表示四个方向，10：90°，11:180°，01:270°，00：0°
	
	-- 这东西太麻烦了，暂时用不到，先空着
	function utils.Base64DecodeToArray_ObjectMode(str)
		-- 用C#自带的解码API
		local bytes = CS.System.Convert.FromBase64String(str)
	--    print(#bytes)
		local array = {}
	--     print(getStr(bytes, 1), getStr(bytes, 2))
		-- 循环把数据存入数组，下标起始是1
		print("length: " .. #bytes)
	
		-- 从第3个byte开始，因为前面2个byte是0xFFFF
		for i = 3, #bytes, 6 do
			print(string.byte(string.sub(bytes, i, i)))
	--        array[(i - 2 + 5) / 6] = string.byte(string.sub(bytes, i, i))
	--        print(getStr(bytes, i), getStr(bytes, i + 1), getStr(bytes, i + 2), getStr(bytes, i + 3), getStr(bytes, i + 4), getStr(bytes, i + 5))
	
			local cx = string.byte(string.sub(bytes, i, i)) + string.byte(string.sub(bytes, i + 1, i + 1)) * 256
			local cy = string.byte(string.sub(bytes, i + 2, i + 2)) + string.byte(string.sub(bytes, i + 3, i + 3)) * 256
			array[(i + 3) / 6] = {x = cx, y = cy}
			-- 待续
			print(cx, cy)
		end
		return array
	end
	
	-- 浅拷贝
	function utils.shallow_copy(object)
		local newObject
		if type(object) == "table" then
			newObject = {}
			for key, value in pairs(object) do
				newObject[key] = value
			end
		else
			newObject = object
		end
		return newObject
	end
	
	-- 深拷贝
	function utils.deep_copy(object)
		local lookup = {}
		local function _copy(object)
			if type(object) ~= "table" then
				return object
			elseif lookup[object] then
				return lookup[object]
			end
			local newObject = {}
			lookup[object] = newObject
			for key, value in pairs(object) do
				newObject[_copy(key)] = _copy(value)
			end
			return setmetatable(newObject, getmetatable(object))
		end
		return _copy(object)
	end

return utils

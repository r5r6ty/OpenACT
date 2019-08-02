-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local utils = {}

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

-- ȡ������
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

-- �ָ��ַ�������
function utils.split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

-- ������������
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

-- ��csv��ȡ���ݷ���DataTable
function utils.LoadTilesFromCSV(path)
    local dt = CS.System.Data.DataTable("test")

    local count = 0
    local sr = CS.System.IO.File.OpenText(path)
    local line = sr:ReadLine()
    while line ~= nil do
        local data = utils.split(line, ',')
        if count == 0 then -- ��һ����Ϊ��ͷ
            for i, v in ipairs(data) do
                dt.Columns:Add(CS.System.Data.DataColumn(v, typeof(CS.System.String)))
            end
        else -- ������Ϊ����
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

-- ��·������ͼƬ����texture2D
function utils.LoadImageToTexture2D(path)
	local bytes =  CS.System.IO.File.ReadAllBytes(path)
	-- ����ͼƬ
	local texture = CS.UnityEngine.Texture2D(0, 0, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	texture.filterMode = CS.UnityEngine.FilterMode.Point
	CS.UnityEngine.ImageConversion.LoadImage(texture, bytes)
	--texture:LoadImage(bytes) --- Texture2d  ��Ա�����޷�ʹ�ã�Ϊʲô��
	return texture
end

-- ��texture2D����sprite�������Σ�
function utils.CreateSprite(texture2D, x, y, size)
	local sprite = CS.UnityEngine.Sprite.Create(texture2D, CS.UnityEngine.Rect(x * size, texture2D.height - (y + 1) * size, size, size), CS.UnityEngine.Vector2(0, 1))
	return sprite
end

-- base64����TileLayer
-- ���������ݣ�����Ϊ��ͼ�ĳ�*��*2
-- ż��λ*����λ��0��65535
-- ���鳤��Ӧ���ǵ�ͼ�ĳ�*��
function utils.Base64DecodeToArray_Ground(str)
    -- ��C#�Դ��Ľ���API
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

-- base64����DataLayer
-- 0��255
-- ���������ݣ�����Ϊ��ͼ�ĳ�*��
function utils.Base64DecodeToArray_TileMode(str)
    -- ��C#�Դ��Ľ���API
    local bytes = CS.System.Convert.FromBase64String(str)
--    print(#bytes)
    local array = {}
    -- ѭ�������ݴ������飬�±���ʼ��1
    for i = 1, #bytes, 1 do
        array[i] = string.byte(string.sub(bytes, i, i))
--        print(string.byte(string.sub(bytes, i, i)), i, math.floor((i - 1) % 50), math.floor((i - 1) / 50))
    end
    return array
end

-- base64����ObjectMode
-- Object_Layer �����ݴ洢����Ϊ base64, 0xFFFF ������ͼ��Ϊ Object_Layer, ��������������:

-- X ѡ����λ��X, ��λΪ����
-- Y ѡ����λ��Y, ��λΪ����
-- ID Object�ı�ʶ��, ����ʾ�������λ�� tileset ��λ��
-- ����������ֵ������������ĸ�λ(bit set)������: �������ת����ڸ�λ�� X �� Y, �� flip ������ ID ��
-- sample: xѡ��   yѡ��   ID
--   data: 128 129   0   0   32   0
-- xѡ����yѡ���ұߵ���������11111111������ߵ�bitΪ��תbit���������ر�ʾ��Χ��0��(127*256+255=32767)
-- ID�ұߵ���������11111111������ߵ�bitΪˮƽ��תbit����Χͬ��
-- xѡ������תbit��yѡ������תbit��ϱ�ʾ�ĸ�����10��90�㣬11:180�㣬01:270�㣬00��0��

-- �ⶫ��̫�鷳�ˣ���ʱ�ò������ȿ���
function utils.Base64DecodeToArray_ObjectMode(str)
    -- ��C#�Դ��Ľ���API
    local bytes = CS.System.Convert.FromBase64String(str)
--    print(#bytes)
    local array = {}
--     print(getStr(bytes, 1), getStr(bytes, 2))
    -- ѭ�������ݴ������飬�±���ʼ��1
	print("length: " .. #bytes)

	-- �ӵ�3��byte��ʼ����Ϊǰ��2��byte��0xFFFF
    for i = 3, #bytes, 6 do
		print(string.byte(string.sub(bytes, i, i)))
--        array[(i - 2 + 5) / 6] = string.byte(string.sub(bytes, i, i))
--        print(getStr(bytes, i), getStr(bytes, i + 1), getStr(bytes, i + 2), getStr(bytes, i + 3), getStr(bytes, i + 4), getStr(bytes, i + 5))

		local cx = string.byte(string.sub(bytes, i, i)) + string.byte(string.sub(bytes, i + 1, i + 1)) * 256
		local cy = string.byte(string.sub(bytes, i + 2, i + 2)) + string.byte(string.sub(bytes, i + 3, i + 3)) * 256
		array[(i + 3) / 6] = {x = cx, y = cy}
		-- ����
		print(cx, cy)
    end
    return array
end

-- ǳ����
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

-- ���
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

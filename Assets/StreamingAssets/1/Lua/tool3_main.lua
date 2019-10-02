

tool2_castleDB = require "tool2_castleDB"
local json = require "json"
require "LObject"
require "LPlayer"
require "LAI"



local filePath = CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/"

local charactersDB = {}

local texture2Ds = {}
local pics = {}
local audioClips = {}
local palettes = {}

--~ local testtest = {}

local categorys = {}

local zoom = 1

local scale = 2

local mychar = nil

local player = nil

function start()
	print("lua start...")
    print("injected object", LMainCamera)

    charactersDB = LCastleDBCharacter:new(filePath, "new.cdb")
	charactersDB:readDB()
--~ 	charactersDB:readIMG()
--~ 	texture2Ds = charactersDB:loadIMGToTexture2Ds()
	createSprites()
	createAudioClips()

	createPalettes()

	local ppCamera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))
	ppCamera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom * scale


	tool2_castleDB.new(filePath, "data2.cdb")


--~ 	-- �������Ե�ͼ
--~ 	local x = 0 - 20
--~ 	local y = 2
--~ 	local width = 40
--~ 	local height = 2
--~ 	local map = {}
--~     for i = x, x + width - 1, 1 do
--~ 		map[i] = {}
--~         for j = y, y + height - 1, 1 do
--~ 			map[i][j] = 1
--~         end
--~     end

--~ 	for i = 1, 10, 1 do
--~ 		map[x - i] = {}
--~ 		map[x - i][y] = 2
--~ 	end

--~ 	for i = 1, 10, 1 do
--~ 	map[x + width - 1 + i] = {}
--~ 	map[x + width - 1 + i][y] = 2
--~ 	end



--~ 	for i = 1, 10, 1 do
--~ 		map[x][y -i] = 1
--~ 	end
--~ 	map[x + width - 1][y - 1] = 1


--~ 	tool2_castleDB.drawMap(map, 0, 0, 2)
--~ 	local ds = tool2_castleDB.gen()
	local ds = tool2_castleDB.gen2(-40 * 0.2, 20 * 0.2, 2)
--~ 	for i, v in ipairs(ds) do
--~ 		local n = nil
--~ 		if v.name == "door" then
--~ 			n = v.name .. CS.Tools.Instance:RandomRangeInt(1, 4) .."-0"
--~ 		elseif v.name == "gate" then
--~ 			n = v.name .. "1-0"
--~ 		else
--~ 			n = v.name .. "1-0"
--~ 		end
--~ 		local count = math.floor(v.width / 5)
--~ 		if count == 1 then
--~ 		local d = utils.createObject(charactersDB.characters, pics, audioClips, "common", n, v.dx, v.dy, 0, 0, 3)
--~ 		d.spriteRenderer.sortingOrder = -9
--~ 		elseif count > 1 and count % 2 == 0 then --ż����
--~ 			local center = v.dx + math.floor(v.width / 2 + 0.5) * 0.2 * 2 - 1 * 0.2 * 2
--~ 			local d = utils.createObject(charactersDB.characters, pics, audioClips, "common", "torch1-0", center, v.dy + 4 * 0.2 * 2, 0, 0, 3)
--~ 			d.spriteRenderer.sortingOrder = -9
--~ 			local i = 0
--~ 			while i + 5 < v.width / 2 do
--~ 				n = v.name .. CS.Tools.Instance:RandomRangeInt(1, 4) .."-0"
--~ 				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", n, center + 1 * 0.2 * 2 + i * 0.2 * 2, v.dy, 0, 0, 3)
--~ 				d.spriteRenderer.sortingOrder = -9

--~ 				n = v.name .. CS.Tools.Instance:RandomRangeInt(1, 4) .."-0"
--~ 				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", n, center + 1 * 0.2 * 2 - (i + 6) * 0.2 * 2, v.dy, 0, 0, 3)
--~ 				d.spriteRenderer.sortingOrder = -9
--~ 				i = i + 6
--~ 			end
--~ 			i = 0
--~ 			while i + 5 < v.width / 2 do
--~ 				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", "torch1-0", center + i * 0.2 * 2, v.dy + 4 * 0.2 * 2, 0, 0, 3)
--~ 				d.spriteRenderer.sortingOrder = -9

--~ 				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", "torch1-0", center - (i + 6) * 0.2 * 2, v.dy + 4 * 0.2 * 2, 0, 0, 3)
--~ 				d.spriteRenderer.sortingOrder = -9
--~ 				i = i + 6
--~ 			end
--~ 		end
--~ 	end

	CS.UnityEngine.Physics2D.gravity = CS.UnityEngine.Physics2D.gravity * scale

	mychar = createTEstObject()

	player = LPlayer:new(mychar, LMainCamera) -- LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))

end


function update()

end

function fixedupdate()
	player:followCharacter()
	player:input()
	player:judgeCommand()
	utils.runObjectsFrame()
end

function ongui()
--~ 	if CS.UnityEngine.GUI.Button(CS.UnityEngine.Rect(0, 0, 80, 20), "reverse") then
--~ 		mychar.direction.x = mychar.direction.x * -1
--~ 	end

--~ 	mychar:display()
	player:displayKeys()

	utils.displayObjectsInfo()
	utils.display()

--~     for i, v in pairs(testtest) do
--~ 		if CS.UnityEngine.GUILayout.Button(i) then
--~ 			v:Play()
--~ 		end
--~ 	end
end

-- ͨ�������õ�ͼ����������������sprite
function createSprites()
--~     for i, v in pairs(texture2Ds) do
--~         if pics[i] == nil then
--~             pics[i] = CS.UnityEngine.Sprite.Create(v, CS.UnityEngine.Rect(0, 0, v.width, v.height), CS.UnityEngine.Vector2(0, 1))
--~         end
--~ 	end

	local file = io.open(charactersDB.DBPath .. "wocao.png", "rb")
	io.input(file)
	local data = io.read("*a")
	io.close(file)
	texture2Ds = CS.UnityEngine.Texture2D(0, 0, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	texture2Ds.filterMode = CS.UnityEngine.FilterMode.Point

	texture2Ds:LoadImage(data)

	local file2 = io.open(charactersDB.DBPath .. "wocao.json", "r")
	io.input(file2)
	local data2 = io.read("*a")
	io.close(file2)

	local spriteData = json.decode(data2)

    for i, v in ipairs(spriteData) do
        if pics[v.id] == nil then
            pics[v.id] = CS.UnityEngine.Sprite.Create(texture2Ds, CS.UnityEngine.Rect(v.x, v.y, v.w, v.h), CS.UnityEngine.Vector2(0, 1))
        end
	end
end

-- �����ɫ��
function createPalettes()
    for i, v in pairs(charactersDB.characters) do
		if palettes[i] == nil then
			palettes[i] = {}
		end
		for i2, v2 in pairs(v.char.palette) do

			local texture = CS.UnityEngine.Texture2D(256, 1, CS.UnityEngine.TextureFormat.RGBA32, false, false)
			texture.filterMode = CS.UnityEngine.FilterMode.Point

			local count = 0
			local file = io.open(charactersDB.DBPath .. v2.file, "r")
			for line in file:lines() do
				local r, g, b = string.match(line, "(%d+) (%d+) (%d+)")
--~ 				print(r, g, b)
				if r ~= nil and g ~= nil and b ~=nil then
					if count == 0 then
						texture:SetPixel(count, 0, CS.UnityEngine.Color(r / 255, g / 255, b / 255, 0))
					else
						texture:SetPixel(count, 0, CS.UnityEngine.Color(r / 255, g / 255, b / 255, 1))
					end
					count = count + 1
				end
			end
			io.close(file)
			texture:Apply()


			local sprite = CS.UnityEngine.Sprite.Create(texture, CS.UnityEngine.Rect(0, 0, texture.width, texture.height), CS.UnityEngine.Vector2(0, 1))

			local shader = CS.UnityEngine.Shader.Find("Sprites/Beat/Diffuse-Shadow")
			local material = CS.UnityEngine.Material(shader)

--~ 			local unityobject_child = CS.UnityEngine.GameObject("testtt")
--~ 			local sr = unityobject_child:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
--~ 			sr.sprite = sprite
--~ 			local m = unityobject_child:GetComponent(typeof(CS.UnityEngine.Renderer)).material
--~ 			m.shader = shader
--~ 			m:SetTexture("_Palette", texture)
			material:SetTexture("_Palette", texture)

			table.insert(palettes[i], material)
		end
	end
end

function createTEstObject()

	local p = nil
    for i = 2, 2, 1 do

		-- p = utils.createObject(charactersDB.characters, pics, palettes["ljokp"][1], audioClips, "ljokp", "standing-0", i / 2, 0, 0, 0, 0)
		-- p.direction.x = CS.Tools.Instance:RandomRangeInt(0, 2) * 2 - 1

		p = utils.createObject(charactersDB.characters, pics, palettes["Cha"][(i - 1) % 4 + 1], audioClips, "Cha", "standing-0", 2 / 2, 0, 0, 0, 0)
		-- p.direction.x = CS.Tools.Instance:RandomRangeInt(0, 2) * 2 - 1
		-- p.AI = LAI:new(p)
	end

	-- p = utils.createObject(charactersDB.characters, pics, palettes["Cha"][1], audioClips, "Cha", "standing-0", 2 / 2, 0, 0, 0, 0)
	-- p.direction.x = CS.Tools.Instance:RandomRangeInt(0, 2) * 2 - 1


	p = utils.createObject(charactersDB.characters, pics, palettes["Cha"][1], audioClips, "Cha", "standing-0", 0, 0, 0, 0, 0)
	-- p.direction.x = CS.Tools.Instance:RandomRangeInt(0, 2) * 2 - 1
	-- p.AI = LAI:new(p)

--~ 	utils.createObject(charactersDB.characters, pics, audioClips, "common", "door1-0", 0, 0, 0, 0, 3)
--~ 	utils.createObject(charactersDB.characters, pics, audioClips, "common", "door2-0", 0, 0, 0, 0, 3)
--~ 	utils.createObject(charactersDB.characters, pics, audioClips, "common", "door3-0", 0, 0, 0, 0, 3)
--~ 	utils.createObject(charactersDB.characters, pics, audioClips, "common", "gate1-0", 0, 0, 0, 0, 3)
--~ 	utils.createObject(charactersDB.characters, pics, audioClips, "common", "window1-0", 0, 0, 0, 0, 3)

--~ 	createObject("songrunhe", "hdas-0", 3, 0, 0, 0)

	return p
end

function bytesToInt(bytes, offset)
	local value = 0
	for i = 0, 3, 1 do
		value = value | (bytes[offset + i] << (i * 8))
	end
	return value
end

function bytesToFloat(firstByte, secondByte)
	local s = ((secondByte << 8) | firstByte) / 32768
	if s > 1 then
		return -(2 - s)
	else
		return s
	end
end

function createAudioClips()
    for i, v in ipairs(charactersDB:getLines("sounds")) do
		local file = io.open(charactersDB.DBPath .. v.file, "rb")
		io.input(file)
		local data = io.read("*a")
		io.close(file)

		local bytes = {}

		for j = 1, #data, 1 do
			bytes[j] = tonumber(string.byte(data, j, j))
		end

		local audioClip = {}

		local pos = 1
		while not (bytes[pos] == 102 and bytes[pos + 1] == 109 and bytes[pos + 2] == 116) do -- Ѱ��fmt��ʶ
			pos = pos + 1
		end

		audioClip.ChannelCount = bytes[pos + 10] -- ͨ������������Ϊ1��˫����Ϊ2
		audioClip.Frequency = bytesToInt(bytes, pos + 12) -- ����Ƶ��

		local size = bytes[pos + 20] -- DATA���ݿ鳤�ȣ��ֽ�
		local bit = bytes[pos + 22] -- PCMλ��

		while not (bytes[pos] == 100 and bytes[pos + 1] == 97 and bytes[pos + 2] == 116 and bytes[pos + 3] == 97) do -- Ѱ��data��ʶ
			pos = pos + 4
			local chunkSize = bytes[pos] + bytes[pos + 1] * 256 + bytes[pos + 2] * 65536 + bytes[pos + 3] * 16777216
			pos = pos + 4 + chunkSize
		end
		pos = pos + 8 -- ���ڶ�λ��data������

		audioClip.SampleCount = bytesToInt(bytes, pos - 4) / size -- ȡdata����4��byte�����ݣ�������Ƶ���ݵĳ��ȣ�Ȼ�����ÿ�����ݿ�೤=��������

		if audioClip.ChannelCount == 2 then -- ˫�����Ȳ����Ǻð�
			audioClip.SampleCount = audioClip.SampleCount / 2
		end

		audioClip.LeftChannel = {}
		if audioClip.ChannelCount == 2 then
			audioClip.RightChannel = {}
		else
			audioClip.RightChannel = nil
		end

		local i = 1

		if bit == 16 then -- �����16λ����
			while i <= audioClip.SampleCount do
				audioClip.LeftChannel[i] = bytesToFloat(bytes[pos], bytes[pos + 1])
				pos = pos + 2
				if audioClip.RightChannel ~= nil then
					audioClip.RightChannel[i] = bytesToFloat(bytes[pos], bytes[pos + 1])
					pos = pos + 2
				end
				i = i + 1
			end
		else  -- �����8λ���� -- �����Ȳ�����
			while i <= audioClip.SampleCount do
				audioClip.LeftChannel[i] = 1 - (bytes[pos] / 128)
				pos = pos + 1
				if audioClip.RightChannel ~= nil then
					audioClip.RightChannel[i] = 1 - (bytes[pos] / 128)
					pos = pos + 1
				end
				i = i + 1
			end
		end

		local ac = CS.UnityEngine.AudioClip.Create(v.id, audioClip.SampleCount, audioClip.ChannelCount, audioClip.Frequency, false)
		ac:SetData(audioClip.LeftChannel, 0)

		if audioClips[v.id] == nil then
			audioClips[v.id] = ac
		end

--~ 		local test = CS.UnityEngine.GameObject(v.id)
--~ 		audioSource = test:AddComponent(typeof(CS.UnityEngine.AudioSource))
--~ 		audioSource.clip = audioClips[v.id]

--~ 			testtest[v.id] = audioSource
	end
end






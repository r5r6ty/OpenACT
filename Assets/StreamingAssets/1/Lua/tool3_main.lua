

tool2_castleDB = require "tool2_castleDB"
require "LObject"
require "LPlayer"



local filePath = CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/"

local charactersDB = {}

local texture2Ds = {}
local pics = {}
local audioClips = {}

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
	charactersDB:readIMG()
	texture2Ds = charactersDB:loadIMGToTexture2Ds()
	createSprites()
	createAudioClips()

	local ppCamera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))
	ppCamera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom * scale


	tool2_castleDB.new(filePath, "data2.cdb")


--~ 	-- 画个测试地图
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
	for i, v in ipairs(ds) do
		local n = nil
		if v.name == "door" then
			n = v.name .. CS.Tools.Instance:RandomRangeInt(1, 4) .."-0"
		elseif v.name == "gate" then
			n = v.name .. "1-0"
		else
			n = v.name .. "1-0"
		end
		local count = math.floor(v.width / 5)
		if count == 1 then
		local d = utils.createObject(charactersDB.characters, pics, audioClips, "common", n, v.dx, v.dy, 0, 0, 3)
		d.spriteRenderer.sortingOrder = -9
		elseif count > 1 and count % 2 == 0 then --偶数个
			local center = v.dx + math.floor(v.width / 2 + 0.5) * 0.2 * 2 - 1 * 0.2 * 2
			local d = utils.createObject(charactersDB.characters, pics, audioClips, "common", "torch1-0", center, v.dy + 4 * 0.2 * 2, 0, 0, 3)
			d.spriteRenderer.sortingOrder = -9
			local i = 0
			while i + 5 < v.width / 2 do
				n = v.name .. CS.Tools.Instance:RandomRangeInt(1, 4) .."-0"
				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", n, center + 1 * 0.2 * 2 + i * 0.2 * 2, v.dy, 0, 0, 3)
				d.spriteRenderer.sortingOrder = -9

				n = v.name .. CS.Tools.Instance:RandomRangeInt(1, 4) .."-0"
				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", n, center + 1 * 0.2 * 2 - (i + 6) * 0.2 * 2, v.dy, 0, 0, 3)
				d.spriteRenderer.sortingOrder = -9
				i = i + 6
			end
			i = 0
			while i + 5 < v.width / 2 do
				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", "torch1-0", center + i * 0.2 * 2, v.dy + 4 * 0.2 * 2, 0, 0, 3)
				d.spriteRenderer.sortingOrder = -9

				d = utils.createObject(charactersDB.characters, pics, audioClips, "common", "torch1-0", center - (i + 6) * 0.2 * 2, v.dy + 4 * 0.2 * 2, 0, 0, 3)
				d.spriteRenderer.sortingOrder = -9
				i = i + 6
			end
		end
	end

	CS.UnityEngine.Physics2D.gravity = CS.UnityEngine.Physics2D.gravity * scale

	mychar = createTEstObject()

	player = LPlayer:new(mychar)

end


function update()

end

function fixedupdate()
	player:input()
	player:judgeCommand()
	utils.runObjectsFrame()
end

function ongui()
--~ 	if CS.UnityEngine.GUI.Button(CS.UnityEngine.Rect(0, 0, 80, 20), "reverse") then
--~ 		mychar.direction.x = mychar.direction.x * -1
--~ 	end

--~ 	mychar:display()
--~ 	player:displayKeys()

	utils.displayObjectsInfo()
	utils.display()

--~     for i, v in pairs(testtest) do
--~ 		if CS.UnityEngine.GUILayout.Button(i) then
--~ 			v:Play()
--~ 		end
--~ 	end
end

function createSprites()
    for i, v in pairs(texture2Ds) do
        if pics[i] == nil then
            pics[i] = CS.UnityEngine.Sprite.Create(v, CS.UnityEngine.Rect(0, 0, v.width, v.height), CS.UnityEngine.Vector2(0, 1))
        end
	end
end

function createTEstObject()

	local p = nil
    for i = -1, 0, 1 do
		p = utils.createObject(charactersDB.characters, pics, audioClips, "ljokp", "standing-0", i / 2, 0, 0, 0, 0)
		p.direction.x = CS.Tools.Instance:RandomRangeInt(0, 2) * 2 - 1
	end

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
		audioClip.ChannelCount = bytes[23]
		audioClip.Frequency = bytesToInt(bytes, 25)

		local pos = 13
		while not (bytes[pos] == 100 and bytes[pos + 1] == 97 and bytes[pos + 2] == 116 and bytes[pos + 3] == 97) do
			pos = pos + 4
			local chunkSize = bytes[pos] + bytes[pos + 1] * 256 + bytes[pos + 2] * 65536 + bytes[pos + 3] * 16777216
			pos = pos + 4 + chunkSize
		end
		pos = pos + 8

		audioClip.SampleCount = (#bytes - (pos - 1)) / 2
		if audioClip.ChannelCount == 2 then
			audioClip.SampleCount = audioClip.SampleCount / 2
		end

		audioClip.LeftChannel = {}
		if audioClip.ChannelCount == 2 then
			audioClip.RightChannel = {}
		else
			audioClip.RightChannel = nil
		end

		local i = 1
		while i <= audioClip.SampleCount do
			audioClip.LeftChannel[i] = bytesToFloat(bytes[pos], bytes[pos + 1])
			pos = pos + 2
			if audioClip.RightChannel ~= nil then
				audioClip.RightChannel[i] = bytesToFloat(bytes[pos], bytes[pos + 1])
				pos = pos + 2
			end
			i = i + 1
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






-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

require "castleDB"
tool2_castleDB = require "tool2_castleDB"
require "LObject"
require "LPlayer"



local filePath = CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/"

local charactersDB = {}

local texture2Ds = {}
local pics = {}

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

	local ppCamera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))
	ppCamera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom * scale

	-- 画个测试地图
	tool2_castleDB.new(filePath, "data2.cdb")

	local x = 0 - 20
	local y = 2
	local width = 40
	local height = 2
	local map = {}
    for i = x, x + width - 1, 1 do
		map[i] = {}
        for j = y, y + height - 1, 1 do
			map[i][j] = 1
        end
    end

	for i = 1, 10, 1 do
		map[x - i] = {}
		map[x - i][y] = 2
	end

	for i = 1, 10, 1 do
	map[x + width - 1 + i] = {}
	map[x + width - 1 + i][y] = 2
	end



	for i = 1, 10, 1 do
		map[x][y -i] = 1
	end
	map[x + width - 1][y - 1] = 1


	tool2_castleDB.drawMap(map, 0, 0, 2)
--~ 	tool2_castleDB.gen()

	CS.UnityEngine.Physics2D.gravity = CS.UnityEngine.Physics2D.gravity * scale

	mychar = createTEstObject()

	player = LPlayer:new(mychar)

end


function update()

end

function fixedupdate()
	player:input()
	player:judgeCommand()
end

function ongui()
--~ 	if CS.UnityEngine.GUI.Button(CS.UnityEngine.Rect(0, 0, 80, 20), "reverse") then
--~ 		mychar.direction.x = mychar.direction.x * -1
--~ 	end

	mychar:display()
	player:displayKeys()
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
    for i = -2, 2, 1 do
		p = createObject("ljokp", "standing", 0, i / 2, 0, 0, 0)
		p.direction.x = CS.Tools.Instance:RandomRangeInt(0, 2) * 2 - 1
	end

	return p
end

function createObject(id, a, f, x, y, dx, dy)
	local character = CS.UnityEngine.GameObject("tool1_character") -- c.id
	character.transform.position = CS.UnityEngine.Vector3(x, y, 0)
	-- 给object挂上LuaBehaviour组件
	local script = character:AddComponent(typeof(CS.XLuaTest.LuaBehaviour))
	local t = script.scriptEnv
	t.object = LObject:new(charactersDB.characters, pics, id, a, f, character, dx, dy)
	return t.object
end

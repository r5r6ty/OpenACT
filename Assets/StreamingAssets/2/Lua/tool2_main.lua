-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

utils = require "tool2_utils"
--randomRoom = require "tool2_random_room"
castleDB = require "tool2_castleDB"

local background_line_sprite = nil

local moveSpeed = 32
local camera = nil

local zoom = 3
local dataTable = nil

function start()
	print("lua start...")
    print("injected object", LMainCamera)
    print("injected object", LCanvas)
    camera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))

    -- 读取CSV的Tile信息
--    dataTable = utils.LoadTilesFromCSV(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/2/Resource/" .. "tile_data.csv")

    -- 读取castleDB的json的测试
    castleDB.new(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/2/Resource/", "data2.cdb")
--    castleDB.show(1, 0, 0)
    castleDB.gen()

--    local map = {}
--    map.__index = nil
--    local room = castleDB.createRoom(map, 1, 0, 0)
--    local count = 1

--    local r, r2 = castleDB.linkRoom(room, 2)
--    while r == false and count < 100 do
--        r, r2 = castleDB.linkRoom(room, 2)
--        count = count + 1
--    end
--    print(r)

--    count = 1
--    local r3 = nil
--    r, r3 = castleDB.linkRoom(r2, 2)
--    while r == false and count < 100 do
--        r, r3 = castleDB.linkRoom(r2, 2)
--        count = count + 1
--    end
--    print(r)

--    count = 1
--    local r4 = nil
--    r, r4 = castleDB.linkRoom(r3, 2)
--    while r == false and count < 100 do
--        r, r4 = castleDB.linkRoom(r3, 2)
--        count = count + 1
--    end
--    print(r)

--    count = 1
--    local r5 = nil
--    r, r5 = castleDB.linkRoom(r4, 2)
--    while r == false and count < 100 do
--        r, r5 = castleDB.linkRoom(r4, 2)
--        count = count + 1
--    end
--    print(r)

    -- 读取castleDB的tile图片的测试


    -- 在unity里生成测试


--~     -- 网格生成测试
--~     background_line_sprite = utils.createLineTexture(32, 1, 1)

--~     local unityobject = CS.UnityEngine.GameObject("map_gen")
--~     local unityobject_child = CS.UnityEngine.GameObject("background_line")
--~     unityobject_child.transform.parent = unityobject.transform
--~     local sr = unityobject_child:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
--~     sr.sprite = background_line_sprite

--~     LMainCamera.transform.position = CS.UnityEngine.Vector3(sr.sprite.textureRect.width / 200, sr.sprite.textureRect.height / -200, LMainCamera.transform.position.z)

--    randomRoom.gen()
end

function update()
    -- 当按住鼠标右键的时候
    if CS.UnityEngine.Input.GetMouseButton(1) then
        -- 获取鼠标的x和y的值，乘以速度和Time.deltaTime是因为这个可以是运动起来更平滑
        local h = CS.UnityEngine.Input.GetAxis("Mouse X") * moveSpeed * CS.UnityEngine.Time.deltaTime;
        local v = CS.UnityEngine.Input.GetAxis("Mouse Y") * moveSpeed * CS.UnityEngine.Time.deltaTime;
        h = math.floor(h / 0.32 + 0.5) * 0.32
        v = math.floor(v / 0.32 + 0.5) * 0.32
        -- 设置当前摄像机移动
        -- 需要摄像机按照世界坐标移动，而不是按照它自身的坐标移动，所以加上Spance.World
        LMainCamera.transform:Translate(-h, -v, 0, CS.UnityEngine.Space.World);
    end

    if CS.UnityEngine.Input.GetAxis("Mouse ScrollWheel") < 0 then
        zoom = zoom + 1
        camera.orthographicSize = zoom * 1.8
    elseif CS.UnityEngine.Input.GetAxis("Mouse ScrollWheel") > 0 then
        zoom = zoom - 1
        camera.orthographicSize = zoom * 1.8
    end
end

function fixedupdate()
end

function ongui()
--    if CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.mouseDrag then
--        local x = CS.UnityEngine.Input.GetAxis("Mouse X");
--        local y = CS.UnityEngine.Input.GetAxis("Mouse Y");
--        LMainCamera.transform:Translate(CS.UnityEngine.Vector3( -x, -y, 0) * CS.UnityEngine.Time.deltaTime);
--    end
end

function ondestroy()
    print("lua destroy")
end

-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

utils = require "tool2_utils"
castleDB = require "tool2_castleDB"

local moveSpeed = 32
local camera = nil

local zoom = 1
local dataTable = nil

function start()
	print("lua start...")
    print("injected object", LMainCamera)
    print("injected object", LCanvas)
    camera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))
	camera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom

    -- ��ȡCSV��Tile��Ϣ
--    dataTable = utils.LoadTilesFromCSV(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "tile_data.csv")

    -- ��ȡcastleDB��json�Ĳ���
    castleDB.new(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/", "data2.cdb")
--    castleDB.show(1, 0, 0)
    castleDB.gen()

end

function update()
    -- ����ס����Ҽ���ʱ��
    if CS.UnityEngine.Input.GetMouseButton(1) then
        -- ��ȡ����x��y��ֵ�������ٶȺ�Time.deltaTime����Ϊ����������˶�������ƽ��
        local h = CS.UnityEngine.Input.GetAxis("Mouse X") * moveSpeed * CS.UnityEngine.Time.deltaTime;
        local v = CS.UnityEngine.Input.GetAxis("Mouse Y") * moveSpeed * CS.UnityEngine.Time.deltaTime;
        h = math.floor(h / 0.32 + 0.5) * 0.32
        v = math.floor(v / 0.32 + 0.5) * 0.32
        -- ���õ�ǰ������ƶ�
        -- ��Ҫ������������������ƶ��������ǰ���������������ƶ������Լ���Spance.World
        LMainCamera.transform:Translate(-h, -v, 0, CS.UnityEngine.Space.World);
    end

    if CS.UnityEngine.Input.GetAxis("Mouse ScrollWheel") < 0 and zoom < 4 then
        zoom = zoom + 1
        camera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom
    elseif CS.UnityEngine.Input.GetAxis("Mouse ScrollWheel") > 0 and zoom > 1 then
        zoom = zoom - 1
        camera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom
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

-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

map_size = {w= 0, h= 0}
is_main_room = false
is_readly = false

local timecounter = 0
local last_pos = nil

function fixedupdate()
	if timecounter >= 1 then
        local pos = self.transform.position
        local x = math.floor(pos.x / 0.04 + 0.5) * 0.04
        local y = math.floor(pos.y / 0.04 + 0.5) * 0.04
        self.transform.position = CS.UnityEngine.Vector3(x, y, pos.z)
        if last_pos ~= self.transform.position then
            last_pos = self.transform.position
        else
            self:GetComponent(typeof(CS.UnityEngine.Rigidbody2D)).bodyType = CS.UnityEngine.RigidbodyType2D.Kinematic
--            CS.UnityEngine.Object.Destroy(self:GetComponent(typeof(CS.XLuaTest.LuaBehaviour)))
--            local sr = self:GetComponent(typeof(CS.UnityEngine.SpriteRenderer))
--            if map_size.w * map_size.h >= 80 then
--                sr.color = CS.UnityEngine.Color.red
--            end
            is_readly = true
        end
		timecounter = 0
	else
		timecounter = timecounter + CS.UnityEngine.Time.deltaTime
	end
end
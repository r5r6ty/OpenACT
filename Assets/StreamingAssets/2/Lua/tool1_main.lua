-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

require 'tool1_utils'

local stack = {}
local translate = { x = nil, y = nil }
local total_size = { w = nil, h = nil }
local calc = false

function start()
	print("lua start...")
    print("injected object", LMainCamera)

    local maps = createEmptyUnityObject("test", 0, 0)
    for i = 1, 64, 1 do
        local x ,y = getRandomPointInCircle(8)
        local w = getIntPart(CS.Tools.Instance:RandomRangeInt(2, 11))
        local h = getIntPart(CS.Tools.Instance:RandomRangeInt(2, 11))
        local p = createUnityObject(maps, "tool1_rooms", x, y, w, h)
        print(x, y, w, h)
        table.insert(stack, p)
    end
end

function update()
end

function fixedupdate()
--    if calc == false then
--        local count = 0
--        for i, v in ipairs(stack) do
--            if v.scriptEnv.is_readly == true then
--                count = count + 1
--            end
--        end
--        if count == #stack then
--            local width = nil
--            local height = nil
--            for i, v in ipairs(stack) do
--                if translate.x == nil or v.transform.position.x < translate.x then
--                    translate.x = v.transform.position.x
--                end
--                if width == nil or v.transform.position.x + v.scriptEnv.map_size.w * 0.32 > width then
--                    print(v.transform.position.x, v.scriptEnv.map_size.w)
--                    width = v.transform.position.x + v.scriptEnv.map_size.w * 0.32
--                end
--                if translate.y == nil or v.transform.position.y > translate.y then
--                    translate.y = v.transform.position.y
--                end
--                if height == nil or v.transform.position.y - v.scriptEnv.map_size.h * 0.32 < height then
--                    height = v.transform.position.y - v.scriptEnv.map_size.h * 0.32
--                end
--            end
--            translate.x = translate.x * 100
--            translate.y = translate.y * 100
--            print(width * 100, translate.x)
--            width = math.abs(width * 100 - translate.x)
--            height = math.abs(height * 100 - translate.y)
--            print(math.floor(translate.x + 0.5), math.floor(translate.y + 0.5), math.floor(width + 0.5), math.floor(height + 0.5))
--            calc = true
--        end
--    end
end

function ondestroy()
    print("lua destroy")
end

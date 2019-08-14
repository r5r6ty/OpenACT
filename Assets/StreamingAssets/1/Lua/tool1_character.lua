-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

-- 实际游戏相关部分

local MIN_MOVE_DISTANCE = 0.001
local boxCollider2D = nil
local rigidbody2D = nil
local contactFilter2D = nil
local raycastHit2DList = {} -- CS.System.Collections.Generic.List(typeof(CS.UnityEngine.RaycastHit2D))
local tangentRaycastHit2DList = {} -- CS.System.Collections.Generic.List(typeof(CS.UnityEngine.RaycastHit2D))
local layerMask = CS.UnityEngine.LayerMask()
layerMask.value = -1

-- 实际游戏相关部分END

--
object = nil
--
local eventQueue = {}

function start()
	print("lua start...")


	self.gameObject.transform.localScale = CS.UnityEngine.Vector3(2 * 1, 2 * 1, 1)
end

function update()
--~ 	object:reversePic()



end



function fixedupdate()

	object:runFrame()
end


function ondestroy()
    print("lua destroy")
end


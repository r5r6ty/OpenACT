-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

LCollider = {gameObject = nil, collider = nil, filter = nil}
LCollider.__index = LCollider
function LCollider:new(go)
	local self = {}
	setmetatable(self, LCollider)

	self.gameObject = go
	self.filter = nil

	self.collider = self.gameObject:AddComponent(typeof(CS.UnityEngine.BoxCollider2D))

	self.offset = nil
	self.size = nil


    return self
end

-- 设置collider
function LCollider:setCollider(dir, x, y, width, height, c, tig)
	self.offset = CS.UnityEngine.Vector2((x + width / 2) / 100, -(y + height / 2) / 100)
	self.size = CS.UnityEngine.Vector2(width / 100, height / 100)
	self.collider.offset = self.offset-- * dir
	self.collider.size = self.size

	self.filter = c
	self.collider.isTrigger = tig
end

--~ function LCollider:reverseCollider(dir)
--~ 	self.offset = self.offset * dir
--~ 	self.collider.offset = self.offset
--~ end

function LCollider:deleteCollider()
	CS.UnityEngine.Object.Destroy(self.collider)
end

LColliderBDY = {}
setmetatable(LColliderBDY, LCollider)
LColliderBDY.__index = LColliderBDY
function LColliderBDY:new(go)
	local self = {}
	self = LCollider:new(go)
	setmetatable(self, LColliderBDY)

	return self
end

-- 检测碰撞物，如果发生碰撞则进行位移
function LColliderBDY:BDYFixedUpdate(velocity, weight)
	local isGround = false
	local isCeiling = false
	local isWall = false

	-- 检测和什么碰，2d碰撞范围一般比实际要大，因为AABB要大一点，为了精确碰撞，需要自己实现
	local contactColliders = CS.Tools.Instance:Collider2DOverlapCollider(self.collider, self.filter) -- 这个函数其实Collider2D.OverlapCollider，用来手动检测碰撞，这边因为lua的缘故封装了一下

	local objectTable = {}

	-- 最终位移坐标
	local finalOffset_x = 0
	local finalOffset_y = 0
	for p, k in pairs(contactColliders) do
		if self.collider.bounds:Intersects(k.bounds) then

			local up, down, left, right = false, false, false, false

			local go = k.attachedRigidbody.gameObject
			local object2 = utils.getObject(go:GetInstanceID())
			if go.name == "test" then -- 如果是地图块
				local name = utils.split(k.name, ",")
				local num = tonumber(name[#name]) -- 地图块最后一个数字作为bit

				if num | 14 == 15 then --位操作，算出这个方块朝哪个方向进行碰撞，一个方块可以有多个碰撞方向，这部分随意设计，只需要能知道这个collider的判定方向，用layermask什么都行
					up = true
				end
				if num | 13 == 15 then --位操作
					down = true
				end
				if num | 11 == 15 then --位操作
					left = true
				end
				if num | 7 == 15 then --位操作
					right = true
				end
			elseif go.name ~= "test" and object2 ~= nil then -- 是游戏object，则只允许左右进行碰撞
				left = true
				right = true
			else
				return false, false
			end

			local menseki = utils.getBoundsIntersectsArea(self.collider.bounds, k.bounds)
			if menseki.magnitude > 0 then -- 无视多少面积设置

				-- 算2个collider之间距离，主要是为了法线
				local cd2d = self.collider:Distance(k)

--~ 				local a =  CS.UnityEngine.Vector3(cd2d.pointA.x, cd2d.pointA.y, 0)
--~ 				local b =  CS.UnityEngine.Vector3(cd2d.pointB.x, cd2d.pointB.y, 0)
				local normal =  -CS.UnityEngine.Vector3(cd2d.normal.x, cd2d.normal.y, 0)
--~ 				CS.UnityEngine.Debug.DrawLine(a, a + normal, CS.UnityEngine.Color.red)
--~ 				CS.UnityEngine.Debug.DrawLine(b, b + normal, CS.UnityEngine.Color.yellow)

				-- 做碰撞法线与行进方向的点积
				-- local projection = CS.UnityEngine.Vector2.Dot(velocity.normalized, normal) -- 没用到，有需要可以自己看情况加

				local offset_x = 0
				local offset_y = 0

				-- 左移，右移
				if self.collider.bounds.center.x < k.bounds.center.x then
					if left and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(-1, 0)) <= 0 then -- 如果碰撞朝向与行进方向相反，则求出位移坐标
						offset_x = -menseki.x
					end
				else
					if right and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(1, 0)) <= 0 then
						offset_x = menseki.x
					end
				end
				-- 上移，下移
				if self.collider.bounds.center.y > k.bounds.center.y then
					if up and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(0, 1)) <= 0 then
						offset_y = menseki.y
					end
				else
					if down and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(0, -1)) <= 0 then
						offset_y = -menseki.y
					end
				end

				if (up or down) and (left or right) then -- 如果同时满足上下和左右方向同时存在的情况，则根据碰撞方向来筛选掉另一个轴的位移
					offset_x = offset_x * math.abs(normal.x)
					offset_y = offset_y * math.abs(normal.y)
				end

				-- 留下最小位移坐标
				if velocity.x > 0 then
					if offset_x < finalOffset_x then
						finalOffset_x = offset_x
					end
				else
					if offset_x > finalOffset_x then
						finalOffset_x = offset_x
					end
				end

				if velocity.y > 0 then
					if offset_y < finalOffset_y then
						finalOffset_y = offset_y
					end
				else
					if offset_y > finalOffset_y then
						finalOffset_y = offset_y
					end
				end

				if velocity.x ~= 0 and object2 ~= nil and offset_x ~= 0 and object2.isWall == false then
					local rate = weight / object2.weight / 2
					if rate > 1 then
						rate = 1
					end
					local vOffset = (object2.velocity.x - velocity.x) * rate
--~ 					object2.velocity.x = object2.velocity.x - vOffset
					object2:addEvent("Force", 0, 1, {velocity = CS.UnityEngine.Vector2(-vOffset, 0)})
				end

				if go.name == "test" then -- 判断是不是撞到地面，这样写不好，以后再优化
					if finalOffset_x ~= 0 and (normal.x == -1 or normal.x == 1) then
						isWall = true
					end
					if finalOffset_y > 0 then
						isGround = true
					elseif finalOffset_y < 0 then
						isCeiling = true
					end
				end
			end
		end
	end

	-- 更新自身位置
	self.collider.attachedRigidbody.position = self.collider.attachedRigidbody.position + CS.UnityEngine.Vector2(finalOffset_x, finalOffset_y)

	return isGround, isCeiling, isWall
end

LColliderATK = {damage = nil, frequency = nil, frequencyCounter = 0, velocity = nil}
setmetatable(LColliderATK, LCollider)
LColliderATK.__index = LColliderATK
function LColliderATK:new(go)
	local self = {}
	self = LCollider:new(go)
	setmetatable(self, LColliderATK)


	self.frequency = nil
	self.damage = nil
	self.velocity = nil

	self.fall = nil
	self.defence = nil
	self.ignoreObjects = {}


	return self
end

-- 设置collider
function LColliderATK:setCollider(dir, x, y, width, height, c, tig, dmg, fal, def, f, dx, dy, ignoreFlag)
	self.offset = CS.UnityEngine.Vector2((x + width / 2) / 100, -(y + height / 2) / 100)
	self.size = CS.UnityEngine.Vector2(width / 100, height / 100)
	self.collider.offset = self.offset-- * dir
	self.collider.size = self.size

	self.filter = c
	self.collider.isTrigger = tig

	self.damage = dmg
	self.fall = fal
	self.defence = def
	self.frequency = f
	self.velocity = CS.UnityEngine.Vector2(dx, dy)

	if ignoreFlag then
		self.ignoreObjects = {}
	end
end

-- 检测攻击
function LColliderATK:ATKFixedUpdate(dir, myID)
	local ishit = false

	if self.frequency > 0 then -- 攻击间隔为0的时候，只对对象攻击一次
		for i, v in pairs(self.ignoreObjects) do
			v.count = v.count + 1
		end
	end

	local contactColliders = CS.Tools.Instance:Collider2DOverlapCollider(self.collider, self.filter)

	for p, k in pairs(contactColliders) do
		local iId = k.attachedRigidbody.gameObject:GetInstanceID()
		if self.collider.bounds:Intersects(k.bounds) and iId ~= myID then
			if self.ignoreObjects[iId] == nil or self.ignoreObjects[iId].count >= self.frequency then -- 如果不在忽视列表里，或计数已经超过攻击间隔
				local object = utils.getObject(iId)
				if object ~= nil then


					local cd2d = self.collider:Distance(k)
					local sparkPosition = CS.UnityEngine.Vector2(cd2d.pointA.x + cd2d.pointB.x, cd2d.pointA.y + cd2d.pointB.y) / 2

					object:addEvent("Object", 0, 1, {worldPosition = true, x = sparkPosition.x, y = sparkPosition.y, nextFrame = "spark-0"})


					object:addEvent("Hurt", 0, 1, {damage = self.damage, fall = self.fall, defence = self.defence})
					object:addEvent("Force", 0, 1, {velocity = self.velocity * dir})
					object:addEvent("Injured", 0, 1, nil)

					local menseki = utils.getBoundsIntersectsArea(self.collider.bounds, k.bounds) / 2

					ishit = true

					if self.ignoreObjects[iId] == nil then
						self.ignoreObjects[iId] = {count = 0}
					else
						self.ignoreObjects[iId].count = 0
					end
				end
			end
		end
	end


	return ishit
end



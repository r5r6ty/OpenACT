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

-- ����collider
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

-- �����ײ����������ײ�����λ��
function LColliderBDY:BDYFixedUpdate(velocity, weight)
	local isGround = false
	local isCeiling = false
	local isWall = false

	-- ����ʲô����2d��ײ��Χһ���ʵ��Ҫ����ΪAABBҪ��һ�㣬Ϊ�˾�ȷ��ײ����Ҫ�Լ�ʵ��
	local contactColliders = CS.Tools.Instance:Collider2DOverlapCollider(self.collider, self.filter) -- ���������ʵCollider2D.OverlapCollider�������ֶ������ײ�������Ϊlua��Ե�ʷ�װ��һ��

	local objectTable = {}

	-- ����λ������
	local finalOffset_x = 0
	local finalOffset_y = 0
	for p, k in pairs(contactColliders) do
		if self.collider.bounds:Intersects(k.bounds) then

			local up, down, left, right = false, false, false, false

			local go = k.attachedRigidbody.gameObject
			local object2 = utils.getObject(go:GetInstanceID())
			if go.name == "test" then -- ����ǵ�ͼ��
				local name = utils.split(k.name, ",")
				local num = tonumber(name[#name]) -- ��ͼ�����һ��������Ϊbit

				if num | 14 == 15 then --λ���������������鳯�ĸ����������ײ��һ����������ж����ײ�����ⲿ��������ƣ�ֻ��Ҫ��֪�����collider���ж�������layermaskʲô����
					up = true
				end
				if num | 13 == 15 then --λ����
					down = true
				end
				if num | 11 == 15 then --λ����
					left = true
				end
				if num | 7 == 15 then --λ����
					right = true
				end
			elseif go.name ~= "test" and object2 ~= nil then -- ����Ϸobject����ֻ�������ҽ�����ײ
				left = true
				right = true
			else
				return false, false
			end

			local menseki = utils.getBoundsIntersectsArea(self.collider.bounds, k.bounds)
			if menseki.magnitude > 0 then -- ���Ӷ����������

				-- ��2��collider֮����룬��Ҫ��Ϊ�˷���
				local cd2d = self.collider:Distance(k)

--~ 				local a =  CS.UnityEngine.Vector3(cd2d.pointA.x, cd2d.pointA.y, 0)
--~ 				local b =  CS.UnityEngine.Vector3(cd2d.pointB.x, cd2d.pointB.y, 0)
				local normal =  -CS.UnityEngine.Vector3(cd2d.normal.x, cd2d.normal.y, 0)
--~ 				CS.UnityEngine.Debug.DrawLine(a, a + normal, CS.UnityEngine.Color.red)
--~ 				CS.UnityEngine.Debug.DrawLine(b, b + normal, CS.UnityEngine.Color.yellow)

				-- ����ײ�������н�����ĵ��
				-- local projection = CS.UnityEngine.Vector2.Dot(velocity.normalized, normal) -- û�õ�������Ҫ�����Լ��������

				local offset_x = 0
				local offset_y = 0

				-- ���ƣ�����
				if self.collider.bounds.center.x < k.bounds.center.x then
					if left and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(-1, 0)) <= 0 then -- �����ײ�������н������෴�������λ������
						offset_x = -menseki.x
					end
				else
					if right and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(1, 0)) <= 0 then
						offset_x = menseki.x
					end
				end
				-- ���ƣ�����
				if self.collider.bounds.center.y > k.bounds.center.y then
					if up and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(0, 1)) <= 0 then
						offset_y = menseki.y
					end
				else
					if down and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(0, -1)) <= 0 then
						offset_y = -menseki.y
					end
				end

				if (up or down) and (left or right) then -- ���ͬʱ�������º����ҷ���ͬʱ���ڵ�������������ײ������ɸѡ����һ�����λ��
					offset_x = offset_x * math.abs(normal.x)
					offset_y = offset_y * math.abs(normal.y)
				end

				-- ������Сλ������
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

				if go.name == "test" then -- �ж��ǲ���ײ�����棬����д���ã��Ժ����Ż�
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

	-- ��������λ��
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

-- ����collider
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

-- ��⹥��
function LColliderATK:ATKFixedUpdate(dir, myID)
	local ishit = false

	if self.frequency > 0 then -- �������Ϊ0��ʱ��ֻ�Զ��󹥻�һ��
		for i, v in pairs(self.ignoreObjects) do
			v.count = v.count + 1
		end
	end

	local contactColliders = CS.Tools.Instance:Collider2DOverlapCollider(self.collider, self.filter)

	for p, k in pairs(contactColliders) do
		local iId = k.attachedRigidbody.gameObject:GetInstanceID()
		if self.collider.bounds:Intersects(k.bounds) and iId ~= myID then
			if self.ignoreObjects[iId] == nil or self.ignoreObjects[iId].count >= self.frequency then -- ������ں����б��������Ѿ������������
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



-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local utils = require "tool1_utils"

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
function LColliderBDY:BDYFixedUpdate(velocity)
	local isGround = false
	local isWall = false

	-- ����ʲô����2d��ײ��Χһ���ʵ��Ҫ����ΪAABBҪ��һ�㣬Ϊ�˾�ȷ��ײ����Ҫ�Լ�ʵ��
	local contactColliders = CS.Tools.Instance:Collider2DOverlapCollider(self.collider, self.filter) -- ���������ʵCollider2D.OverlapCollider�������ֶ������ײ�������Ϊlua��Ե�ʷ�װ��һ��

	-- ����λ������
	local finalOffset_x = 0
	local finalOffset_y = 0
	for p, k in pairs(contactColliders) do
		if self.collider.bounds:Intersects(k.bounds) then

			local up, down, left, right = false, false, false, false

			local go = k.attachedRigidbody.gameObject
			if go:GetComponent(typeof(CS.UnityEngine.Rigidbody2D)) ~= nil and go.name == "test" then -- ����ǵ�ͼ��
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
			elseif go:GetComponent(typeof(CS.XLuaTest.LuaBehaviour)) ~= nil then -- ����Ϸobject����ֻ�������ҽ�����ײ��LuaBehaviour����������lua�Ľű�����Ů�޹�
				left = true
				right = true
			else
				return false, false
			end

			local menseki = utils.getBoundsIntersectsArea(self.collider.bounds, k.bounds)
			if menseki.magnitude > 0.1 then -- ���Ӷ����������

				-- ��2��collider֮����룬��Ҫ��Ϊ�˷���
				local cd2d = self.collider:Distance(k)

				local a =  CS.UnityEngine.Vector3(cd2d.pointA.x, cd2d.pointA.y, 0)
				local b =  CS.UnityEngine.Vector3(cd2d.pointB.x, cd2d.pointB.y, 0)
				local normal =  -CS.UnityEngine.Vector3(cd2d.normal.x, cd2d.normal.y, 0)
				CS.UnityEngine.Debug.DrawLine(a, a + normal, CS.UnityEngine.Color.red)
				CS.UnityEngine.Debug.DrawLine(b, b + normal, CS.UnityEngine.Color.yellow)

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

				if go:GetComponent(typeof(CS.UnityEngine.Rigidbody2D)) ~= nil and go.name == "test" then -- �ж��ǲ���ײ�����棬����д���ã��Ժ����Ż�
					if finalOffset_x ~= 0 then
						isWall = true
					end
					if finalOffset_y > 0 then
						isGround = true
					end
				end
			end
		end
	end

	-- ��������λ��
	self.collider.attachedRigidbody.position = self.collider.attachedRigidbody.position + CS.UnityEngine.Vector2(finalOffset_x, finalOffset_y)

	return isGround, isWall
end

-- �����ײ����������ײ�����λ�ƣ�д�ĺ��ã���Ҫ�ع���
function LColliderBDY:BDYFixedUpdate2(velocity)
	local isGround = false
	local isWall = false

	local contactColliders = CS.Tools.Instance:Collider2DOverlapCollider(self.collider, self.filter)

	local finalOffset_x = 0
	local finalOffset_y = 0
	for p, k in pairs(contactColliders) do
		if self.collider.bounds:Intersects(k.bounds) then
		local ppp = utils.getBoundsIntersectsArea(self.collider.bounds, k.bounds)
			local up, down, left, right = false, false, false, false

			local go = k.attachedRigidbody.gameObject
			if go:GetComponent(typeof(CS.UnityEngine.Rigidbody2D)) ~= nil and go.name == "test"then
				local name = utils.split(k.name, ",")
				local num = tonumber(name[#name]) -- ��ͼ�����һ��������Ϊbit

				if num | 14 == 15 then
					up = true
				end
				if num | 13 == 15 then
					down = true
				end
				if num | 11 == 15 then
					left = true
				end
				if num | 7 == 15 then
					right = true
				end
			elseif go:GetComponent(typeof(CS.XLuaTest.LuaBehaviour)) ~= nil then
				left = true
				right = true
			else
				return false, false
			end
--~ 			print(ppp.x, ppp.y, ppp.z)
			if ppp.magnitude > 0 then -- ���ӱ߽Ƕ���������ã��Ȳ���
--~ 				print(ppp.magnitude)


				local cd2d = self.collider:Distance(k)

				local a =  CS.UnityEngine.Vector3(cd2d.pointA.x, cd2d.pointA.y, 0)
				local b =  CS.UnityEngine.Vector3(cd2d.pointB.x, cd2d.pointB.y, 0)
				local n =  CS.UnityEngine.Vector3(cd2d.normal.x, cd2d.normal.y, 0)
				CS.UnityEngine.Debug.DrawLine(a, a - n, CS.UnityEngine.Color.red)
				CS.UnityEngine.Debug.DrawLine(b, b - n, CS.UnityEngine.Color.yellow)

				local projection = CS.UnityEngine.Vector2.Dot(velocity.normalized, -cd2d.normal)
--~ 			if projection ~= 0 then


				local offset_x = 0
				local offset_y = 0
				local temp = CS.UnityEngine.Vector2.zero
				-- ���ƣ�����
				if self.collider.bounds.center.x < k.bounds.center.x then
					if left and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(-1, 0)) < 0 then
						temp = CS.UnityEngine.Vector2(k.bounds.min.x - self.collider.bounds.extents.x - self.collider.offset.x * self.collider.transform.lossyScale.x, temp.y)
						offset_x = self.collider.attachedRigidbody.position.x -(k.bounds.min.x - self.collider.bounds.extents.x - self.collider.offset.x * self.collider.transform.lossyScale.x)
					end
				else
					if right and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(1, 0)) > 0 then
						temp = CS.UnityEngine.Vector2(k.bounds.max.x + self.collider.bounds.extents.x - self.collider.offset.x * self.collider.transform.lossyScale.x, temp.y)
						offset_x = self.collider.attachedRigidbody.position.x -(k.bounds.max.x + self.collider.bounds.extents.x - self.collider.offset.x * self.collider.transform.lossyScale.x)
					end
				end
				-- ���ƣ�����
				if self.collider.bounds.center.y > k.bounds.center.y then
					if up and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(0, 1)) < 0 then
						temp =  CS.UnityEngine.Vector2(temp.x, k.bounds.max.y + self.collider.bounds.extents.y - self.collider.offset.y * self.collider.transform.lossyScale.y)
						offset_y = self.collider.attachedRigidbody.position.y - (k.bounds.max.y + self.collider.bounds.extents.y - self.collider.offset.y * self.collider.transform.lossyScale.y)
					end
				else
					if down and CS.UnityEngine.Vector2.Dot(velocity.normalized, CS.UnityEngine.Vector2(0, -1)) < 0 then
						temp =  CS.UnityEngine.Vector2(temp.x, k.bounds.min.y - self.collider.bounds.extents.y - self.collider.offset.y * self.collider.transform.lossyScale.y)
						offset_y = self.collider.attachedRigidbody.position.y - (k.bounds.min.y - self.collider.bounds.extents.y - self.collider.offset.y * self.collider.transform.lossyScale.y)
					end
				end
				local pre = self.collider.attachedRigidbody.position.y
				local ttt =  CS.UnityEngine.Vector2((temp.x) * math.abs(cd2d.normal.x), (temp.y) * math.abs(cd2d.normal.y))

				if velocity.x >= 0 then
					if offset_x < finalOffset_x then
						finalOffset_x = offset_x
					end
				else
					if offset_x > finalOffset_x then
						finalOffset_x = offset_x
					end
				end

				if velocity.y >= 0 then
					if offset_y < finalOffset_y then
						finalOffset_y = offset_y
					end
				else
					if offset_y > finalOffset_y then
						finalOffset_y = offset_y
					end
				end

--~ 				if (left or right) and offset_x ~= 0 then
--~ 					self.collider.attachedRigidbody.position = CS.UnityEngine.Vector2(offset_x, self.collider.attachedRigidbody.position.y)
--~ 				elseif (up or down) and offset_y ~= 0 then
--~ 					self.collider.attachedRigidbody.position = CS.UnityEngine.Vector2(self.collider.attachedRigidbody.position.x, offset_y)
--~ 				else
--~ 					self.collider.attachedRigidbody.position = CS.UnityEngine.Vector2(offset_x, offset_y)
--~ 				end


--~ 				if ttt.x == 0 then
--~ 					self.collider.attachedRigidbody.position = CS.UnityEngine.Vector2(self.collider.attachedRigidbody.position.x, ttt.y)
--~ 				elseif ttt.y == 0 then
--~ 					self.collider.attachedRigidbody.position = CS.UnityEngine.Vector2(ttt.x, self.collider.attachedRigidbody.position.y)
--~ 				else
--~ 					self.collider.attachedRigidbody.position = ttt
--~ 				end

				-- ��Ҫ��������������
				if pre - ttt.y < 0 and projection ~= 0 then
					isGround = true
				end

--~ 				if (pre - ttt.x) * velocity.normalized.x < 0 and projection ~= 0 then
--~ 					isWall = true
--~ 				end
--~ 				break
			end
--~ 				end
		end
	end

	self.collider.attachedRigidbody.position = self.collider.attachedRigidbody.position + CS.UnityEngine.Vector2(finalOffset_x, finalOffset_y)

	return isGround, isWall
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

	self.frequencyCounter = 0



	return self
end

-- ����collider
function LColliderATK:setCollider(dir, x, y, width, height, c, tig, dmg, f, dx, dy)
	self.offset = CS.UnityEngine.Vector2((x + width / 2) / 100, -(y + height / 2) / 100)
	self.size = CS.UnityEngine.Vector2(width / 100, height / 100)
	self.collider.offset = self.offset-- * dir
	self.collider.size = self.size

	self.filter = c
	self.collider.isTrigger = tig

	self.damage = dmg
	self.frequency = f
	self.velocity = CS.UnityEngine.Vector2(dx, dy)
end

-- ��⹥��
function LColliderATK:ATKFixedUpdate(dir)
	local ishit = false

	if 1 == 1 then

		local contactColliders = CS.Tools.Instance:Collider2DOverlapCollider(self.collider, self.filter)

		for p, k in pairs(contactColliders) do
			if self.collider.bounds:Intersects(k.bounds) then
				local cd2d = self.collider:Distance(k)


				local script = k.attachedRigidbody.gameObject:GetComponent(typeof(CS.XLuaTest.LuaBehaviour))
				if script ~= nil then
					local t = script.scriptEnv
					t.object.HP = t.object.HP - self.damage

					t.object.velocity = t.object.velocity + self.velocity * dir / 100

					ishit = true
				end
			end
		end
	end

	return ishit
end



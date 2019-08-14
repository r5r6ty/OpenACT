-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

require "LCollider"

LObject = {database = nil,
			pics = nil,
			id = nil,
			action = nil,
			currentFrame = nil,
			counter = nil,
			delay = nil,
			delayCounter = nil,

			HP = nil,
			MP = nil,
			maxHP = nil,
			maxMP = nil,
			HPRR = nil,
			MPRR = nil,
			falling = nil,
			fallingRR = nil,
			defence = nil,
			defenceRR = nil,
			direction = nil,
			directionBuff = nil,

			velocity = nil,

			gameObject = nil,
			contactFilter = nil,

			isOnGround = nil,

			rigidbody = nil,
			spriteRenderer = nil,
			attckArray = nil,
			bodyArray = nil,

			pic_object = nil,
			atk_object = nil,
			bdy_object = nil,

			commandQueue = nil,

			eventQueue = nil,

			vvvX = nil,
			vvvY = nil

			}
LObject.__index = LObject
function LObject:new(db, ps, id, act, frm, go, vx, vy)
	local self = {}
	setmetatable(self, LObject)

    self.database = db
    self.pics = ps
	self.id = id
	self.action = act
	self.frame = frm + 1
--~ 	self.counter = self.frame + 1
	self.delay = 0
	self.delayCounter = 0

	self.maxHP = self.database[self.id].char.maxHP
	self.maxMP = self.database[self.id].char.maxMP
	self.HP = self.maxHP
	self.MP = self.maxMP

	self.HPRR = self.database[self.id].char.HPRecoveryRate * CS.UnityEngine.Time.fixedDeltaTime
	self.MPRR = self.database[self.id].char.MPRecoveryRate * CS.UnityEngine.Time.fixedDeltaTime

	self.falling = self.database[self.id].char.falling
	self.defence = self.database[self.id].char.defence
	self.fallingRR = self.database[self.id].char.fallingRecoveryRate * CS.UnityEngine.Time.fixedDeltaTime
	self.defenceRR = self.database[self.id].char.defenceRecoveryRate * CS.UnityEngine.Time.fixedDeltaTime

	self.direction = CS.UnityEngine.Vector2(1, -1)
	self.directionBuff = CS.UnityEngine.Vector2(1, -1)

	self.velocity = CS.UnityEngine.Vector2(vx, vy)

	self.isOnGround = false


	self.gameObject = go

	self.attckArray = {}
	self.bodyArray = {}

	self.pic_object = CS.UnityEngine.GameObject("pic")
	self.pic_object.transform.parent = self.gameObject.transform
	self.pic_object.transform.localPosition = CS.UnityEngine.Vector3.zero
	self.spriteRenderer = self.pic_object:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))

	self.atk_object = CS.UnityEngine.GameObject("atk")
	self.atk_object.transform.parent = self.gameObject.transform
	self.atk_object.transform.localPosition = CS.UnityEngine.Vector3.zero

	self.bdy_object = CS.UnityEngine.GameObject("bdy")
	self.bdy_object.transform.parent = self.gameObject.transform
	self.bdy_object.transform.localPosition = CS.UnityEngine.Vector3.zero

	self.rigidbody = self.gameObject:AddComponent(typeof(CS.UnityEngine.Rigidbody2D))
	self.rigidbody.bodyType = CS.UnityEngine.RigidbodyType2D.Kinematic
--~ 	self.rigidbody.collisionDetectionMode = CS.UnityEngine.CollisionDetectionMode2D.Continuous
--~ 	self.rigidbody.sleepMode = CS.UnityEngine.RigidbodySleepMode2D.NeverSleep;
--~ 	self.rigidbody.interpolation = CS.UnityEngine.RigidbodyInterpolation2D.Interpolate;
	self.rigidbody.constraints = CS.UnityEngine.RigidbodyConstraints2D.FreezeRotation;
	self.rigidbody.gravityScale = 0

	self.contactFilter = CS.UnityEngine.ContactFilter2D()
	self.contactFilter.useLayerMask = false
	self.contactFilter.useTriggers = false
--~ 	self.contactFilter.layerMask = layerMask


	self.commandQueue = {}
	self.eventQueue = {}


	self.vvvX = nil
	self.vvvY = nil
    return self
end

function LObject:reversePic()
	if self.direction.x == -1 then

		self.spriteRenderer.flipX = true
	else
		self.spriteRenderer.flipX = false
	end
end

function LObject:runFrame()

	if self.HP < self.maxHP then
		if self.HP + self.maxHP * self.HPRR > self.maxHP then
			self.HP = self.maxHP
		else
			self.HP = self.HP + self.maxHP * self.HPRR
		end
	end

	if self.MP < self.maxMP then
		if self.MP + self.maxMP * self.MPRR > self.maxMP then
			self.MP = self.maxMP
		else
			self.MP = self.MP + self.maxMP * self.MPRR
		end
	end

	-- 反向操作
	if self.directionBuff.x ~= self.direction.x then -- self.directionBuff.y ~= self.direction.y
--~ 		for i, v in pairs(self.bodyArray) do
--~ 			v:reverseCollider(self.direction)
--~ 		end
--~ 		for i, v in pairs(self.attckArray) do
--~ 			v:reverseCollider(self.direction)
--~ 		end

		if self.direction.x == -1 then
			self.gameObject.transform.eulerAngles = CS.UnityEngine.Vector3(0, 180, 0)
		else
			self.gameObject.transform.eulerAngles = CS.UnityEngine.Vector3(0, 0, 0)
		end

		self.directionBuff.x = self.direction.x
	end

	if self.vvvX ~= nil then
		self.velocity.x = self.vvvX * self.direction.x
	end
	if self.vvvY ~= nil then
		self.velocity.y = self.vvvY * self.direction.y
	end

	if self.isOnGround then
		local f = self.velocity * CS.UnityEngine.Vector2(1, 0) * 0.15 -- 摩擦系数
		if self.direction.x > 0 then
			self.velocity = self.velocity - f
			if self.velocity.x < 0 then
				self.velocity.x = 0
			end
		else
			self.velocity = self.velocity - f
			if self.velocity.x > 0 then
				self.velocity.x = 0
			end
		end

	end
	self.velocity = self.velocity + 0.5 * CS.UnityEngine.Physics2D.gravity * (CS.UnityEngine.Time.deltaTime)

	self.rigidbody.position = self.rigidbody.position + self.velocity * CS.UnityEngine.Time.deltaTime

	if self.delayCounter >= self.delay then
		self.delayCounter = 0
	end

--~ 	if self.delayCounter == 0 then
		while self.delayCounter == 0 do
--~ 		for i = self.frame, #self.database[self.id][self.action].frames, 1 do
			if self.frame > #self.database[self.id][self.action].frames then
				self.frame = 1
			end
			local currentFrame = self.database[self.id][self.action].frames[self.frame]

			if currentFrame.category == "Sprite" and currentFrame.wait > 0 then
				self.spriteRenderer.sprite = self.pics[currentFrame.pic]
				self.pic_object.transform.localPosition = CS.UnityEngine.Vector3(currentFrame.x / 100, -currentFrame.y / 100, 0)
				self.delay = currentFrame.wait
				self.frame = self.frame + 1
				break
			elseif currentFrame.category == "Move" then
					if currentFrame.directionX ~= nil then
						self.vvvX = currentFrame.directionX
					end
					if currentFrame.directionY ~= nil then
						self.vvvY = currentFrame.directionY
					end

				self.frame = self.frame + 1
			elseif currentFrame.category == "Body" then
				if self.bodyArray[currentFrame.id] == nil then
					self.bodyArray[currentFrame.id] = LColliderBDY:new(self.bdy_object)
					self.bodyArray[currentFrame.id]:setCollider(self.direction, currentFrame.x, currentFrame.y, currentFrame.width, currentFrame.height, self.contactFilter, false)
				else
					if currentFrame.width == 0 and currentFrame.height == 0 then
						self.bodyArray[currentFrame.id]:deleteCollider()
						self.bodyArray[currentFrame.id] = nil
					else
						self.bodyArray[currentFrame.id]:setCollider(self.direction, currentFrame.x, currentFrame.y, currentFrame.width, currentFrame.height, self.contactFilter, false)
					end
				end
				self.frame = self.frame + 1
			elseif currentFrame.category == "Attack" then
				if self.attckArray[currentFrame.id] == nil then
					self.attckArray[currentFrame.id] = LColliderATK:new(self.atk_object)
					self.attckArray[currentFrame.id]:setCollider(self.direction, currentFrame.x, currentFrame.y, currentFrame.width, currentFrame.height, self.contactFilter, true, currentFrame.damage, currentFrame.frequency, currentFrame.directionX, currentFrame.directionY)
				else
					if currentFrame.width == 0 and currentFrame.height == 0 then
						self.attckArray[currentFrame.id]:deleteCollider()
						self.attckArray[currentFrame.id] = nil
					else
						self.attckArray[currentFrame.id]:setCollider(self.direction, currentFrame.x, currentFrame.y, currentFrame.width, currentFrame.height, self.contactFilter, true, currentFrame.damage, currentFrame.frequency, currentFrame.directionX, currentFrame.directionY)
					end
				end
				self.frame = self.frame + 1
			elseif currentFrame.category == "Command" then
				if self.commandQueue[currentFrame.command] == nil then
					self.commandQueue[currentFrame.command] = {command = currentFrame.command, wait = currentFrame.wait, waitCounter = 0}
				end
				self.frame = self.frame + 1
			elseif currentFrame.category == "Warp" then
				self.action = currentFrame.nextAction
				self.frame = currentFrame.nextFrame + 1
				self:clearCollidersAndCommand()


				self.vvvX = nil
				self.vvvY = nil


			else
				self.frame = self.frame + 1
			end
		end
--~ 	end
	self.delayCounter = self.delayCounter + 1

	-- 命令计时
	for i, v in pairs(self.commandQueue) do
		if v.wait ~= 0 then
			if v.waitCounter >= v.wait then
				v = nil
			end
			v.waitCounter = v.waitCounter + 1
		end

	end

	-- 碰撞检测
	local g = false
	for i, v in pairs(self.bodyArray) do
		local gg, ww = v:BDYFixedUpdate(self.velocity)
		if gg then
			if g == false then
				self.isOnGround = true
				self.velocity.y = 0
				g = true
			end
		end
		if ww then
			self.velocity.x = 0
		end
	end
	if g == false then
		self.isOnGround = false
	end

	-- 攻击检测
	for i, v in pairs(self.attckArray) do
		v:ATKFixedUpdate(self.direction)
	end

	-- 事件运行
	for i, v in ipairs(self.eventQueue) do
		if v.kind == "Command" then
			v.event()
		end
		if v.wait ~= 0 then
			v.waitCounter = v.waitCounter + 1
			if v.waitCounter > v.wait then
				v = nil
			end
		end

	end

	self.eventQueue = {}
end

function LObject:updatePic()
end

function LObject:display()
	local xy = CS.UnityEngine.Camera.main:WorldToScreenPoint(self.gameObject.transform.position)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300, 200, 100), "x: " .. self.velocity.x .. "y: " .. self.velocity.y)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 20, 200, 100), "hp: " .. self.HP)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 30, 200, 100), "mp: " .. self.MP)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 40, 200, 100), "command: " .. #self.commandQueue)
end


function LObject:runCommand()
	for i, v in pairs(self.database[self.id].char.commands) do

	end
end



function LObject:clearCollidersAndCommand()
	for i, v in pairs(self.bodyArray) do
		v:deleteCollider()
		v = nil
	end
	self.bodyArray = {} -- 清空被攻击
	for i, v in pairs(self.attckArray) do
		v:deleteCollider()
		v = nil
	end
	self.attckArray = {} -- 清空攻击

	self.commandQueue = {} -- 清空命令
end




function LObject:addEvent(k, w, e)
	table.insert(self.eventQueue, {kind = k, wait = w, waitCounter = 0, event = e})
end

function deleteEvent(event)

end


-- 这个队列的设计思想是，物体要进行哪些操作，比如位移，扣血等
function LObject:runEvent()
	-- 事件运行
	for i, v in ipairs(eventQueue) do
		if v.kind == "Command" then
			v.event()
		end
		if v.wait ~= 0 then
			v.waitCounter = v.waitCounter + 1
			if v.waitCounter > v.wait then
				v = nil
			end
		end

	end
end

-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

utils = require "tool1_utils"

tool1_LObject = {database = nil,
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
			weight = nil,

			direction = nil,
			directionBuff = nil,

			velocity = nil,

			gameObject = nil,
			contactFilter = nil,

			isWall = nil,
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
			vvvY = nil,
			accvvvX = nil,
			accvvvY = nil

			}
tool1_LObject.__index = tool1_LObject
function tool1_LObject:new(db, ps, id, f, go, vx, vy)
	local self = {}
	setmetatable(self, tool1_LObject)

    self.database = db
    self.pics = ps
	self.id = id
	local act, frm = utils.getFrame(f)
	self.action = act
	self.frame = frm
--~ 	self.counter = self.frame + 1
	self.delay = 0
	self.delayCounter = 0

	self.maxHP = self.database[self.id].char.maxHP
	self.maxMP = self.database[self.id].char.maxMP
	self.HP = self.maxHP
	self.MP = self.maxMP

	self.HPRR = self.database[self.id].char.HPRecoveryRate
	self.MPRR = self.database[self.id].char.MPRecoveryRate

	self.maxFalling = self.database[self.id].char.maxFalling
	self.maxDefencing = self.database[self.id].char.maxDefencing
	self.fallingRR = self.database[self.id].char.fallingRecoveryRate
	self.defencingRR = self.database[self.id].char.defencingRecoveryRate

	self.falling = self.maxFalling
	self.defencing = self.maxDefencing

	self.weight = self.database[self.id].char.weight

	self.direction = CS.UnityEngine.Vector2(1, -1)
	self.directionBuff = CS.UnityEngine.Vector2(1, -1)

	self.velocity = CS.UnityEngine.Vector2(vx, vy)

	self.isWall = false
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
--~ 	self.rigidbody.useAutoMass = true

	self.contactFilter = CS.UnityEngine.ContactFilter2D()
	self.contactFilter.useLayerMask = false
	self.contactFilter.useTriggers = false
--~ 	self.contactFilter.layerMask = layerMask


	self.commandQueue = {}
	self.eventQueue = {}


	self.vvvX = nil
	self.vvvY = nil
	self.accvvvX = nil
	self.accvvvY = nil
    return self
end

function tool1_LObject:reversePic()
	if self.direction.x == -1 then

		self.spriteRenderer.flipX = true
	else
		self.spriteRenderer.flipX = false
	end
end

function tool1_LObject:runFrame()
	self.HP = self:toMaxvalue(self.HP, self.maxHP, self.HPRR)
	self.MP = self:toMaxvalue(self.MP, self.maxMP, self.MPRR)
	self.falling = self:toOne(self.falling, self.maxFalling, self.fallingRR)
	self.defencing = self:toOne(self.defencing, self.maxDefencing, self.defencingRR)

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
		if self.velocity.x > 0 then
			self.velocity = self.velocity - f
			if self.velocity.x < 0 then
				self.velocity.x = 0
			end
		elseif self.velocity.x < 0 then
			self.velocity = self.velocity - f
			if self.velocity.x > 0 then
				self.velocity.x = 0
			end
		end

	end
--~ 	self.velocity = self.velocity + 0.5 * CS.UnityEngine.Physics2D.gravity * (CS.UnityEngine.Time.deltaTime)

	self.rigidbody.position = self.rigidbody.position + self.velocity * CS.UnityEngine.Time.deltaTime

	if self.delayCounter >= self.delay then
		self.delayCounter = 0
	end





	for i = self.frame, #self.database[self.id][self.action].frames, 1 do
		local currentFrame = self.database[self.id][self.action].frames[i]
		if currentFrame.category == "Sprite" then
			self.spriteRenderer.sprite = self.pics[currentFrame.pic]
			self.pic_object.transform.localPosition = CS.UnityEngine.Vector3(currentFrame.x / 100, -currentFrame.y / 100, 0)
			break
		end
	end


	local a =  CS.UnityEngine.Vector3(self.rigidbody.position.x, self.rigidbody.position.y, 0)
	local b =  CS.UnityEngine.Vector3(self.velocity.x, self.velocity.y, 0)
	CS.UnityEngine.Debug.DrawLine(a, a + b, CS.UnityEngine.Color.blue)
end

function tool1_LObject:updatePic()
end

function tool1_LObject:display()
	local xy = CS.UnityEngine.Camera.main:WorldToScreenPoint(self.gameObject.transform.position)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300, 200, 100), "x: " .. self.velocity.x .. "y: " .. self.velocity.y)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 20, 200, 100), "hp: " .. self.HP)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 30, 200, 100), "mp: " .. self.MP)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 40, 200, 100), "action: " .. self.action)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 50, 200, 100), "frame: " .. self.frame)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 60, 200, 100), "command: " .. #self.commandQueue)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 70, 200, 100), "g: " .. tostring(self.isOnGround))
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 80, 200, 100), "w: " .. tostring(self.isWall))
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 90, 200, 100), "f: " .. self.falling)
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 100, 200, 100), "d: " .. self.defencing)
end


function tool1_LObject:runCommand()
	for i, v in pairs(self.database[self.id].char.commands) do

	end
end



function tool1_LObject:clearCollidersAndCommand()
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


	for i = #self.commandQueue, 1, -1 do -- 清空命令
		table.remove(self.commandQueue, i)
	end
end

function tool1_LObject:toMaxvalue(v, maxV, rate)
	local r = v
--~ 	if canMinus == false and r < 0 then
--~ 		r = 0
--~ 	end
	if r < maxV then
		if r + maxV * rate * CS.UnityEngine.Time.deltaTime > maxV then
			r = maxV
		else
			r = r + maxV * rate * CS.UnityEngine.Time.deltaTime
		end
	end
	return r
end

function tool1_LObject:toOne(v, maxV, rate)
	local r = v
	if r > maxV then
		r = maxV
	end
	if r > 1 then
		if r - maxV * rate * CS.UnityEngine.Time.deltaTime < 1 then
			r = 1
		else
			r = r - maxV * rate * CS.UnityEngine.Time.deltaTime
		end
	end
	return r
end


function tool1_LObject:addEvent(k, w, e)
	table.insert(self.eventQueue, {kind = k, wait = w, waitCounter = 0, event = e})
end

function deleteEvent(event)

end


-- 这个队列的设计思想是，物体要进行哪些操作，比如位移，扣血等
function tool1_LObject:runEvent()
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

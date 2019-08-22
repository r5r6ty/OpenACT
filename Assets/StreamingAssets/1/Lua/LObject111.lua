-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

utils = require "tool1_utils"
require "LCollider"

LObject = {database = nil,
			pics = nil,
			audioClips = nil,
			id = nil,
			action = nil,
			currentFrame = nil,
			counter = nil,
			delay = nil,
			delayCounter = nil,

			kind = nil,
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
			audioSource =nil,
			attckArray = nil,
			bodyArray = nil,

			pic_object = nil,
			atk_object = nil,
			bdy_object = nil,

			eventQueue = nil,

			vvvX = nil,
			vvvY = nil,
			accvvvX = nil,
			accvvvY = nil,

			myFunction = nil}
LObject.__index = LObject
function LObject:new(db, ps, ac, id, f, go, vx, vy, k)
	local self = {}
	setmetatable(self, LObject)

    self.database = db
    self.pics = ps
	self.audioClips = ac
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

	self.audioSource = self.gameObject:AddComponent(typeof(CS.UnityEngine.AudioSource))
	self.audioSource.playOnAwake = false

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

	self.eventQueue = {}


	self.vvvX = nil
	self.vvvY = nil
	self.accvvvX = nil
	self.accvvvY = nil

	self.kind = k

	if self.kind ~= 3 then
		self:addEvent("Flying", 999999, nil)
		self:addEvent("Move", 999999, {velocity = 0.5 * CS.UnityEngine.Physics2D.gravity * 1/60})
		self:addEvent("HPMPFallingDefecing", 999999, nil)
		self:addEvent("Friction", 999999, nil)
		self:addEvent("FlipX", 999999, nil)
	end

	self:addEvent("UpdatePostion", 999999, nil)

	self.gameObject.transform.localScale = CS.UnityEngine.Vector3(2 * 1, 2 * 1, 1)




	self.myFunction = function()
		if self.delayCounter >= self.delay then
			self.delayCounter = 0
		end


		while self.delayCounter == 0 do
			if self.frame > #self.database[self.id][self.action].frames then
				self.frame = 1
	--~ 			self:clearCollidersAndCommand()
			end
			local currentFrame = self.database[self.id][self.action].frames[self.frame]

			if currentFrame.category == "Sprite" and currentFrame.wait > 0 then
				self:addEvent(currentFrame.category, 1, {sprite = self.pics[currentFrame.pic], localPosition = CS.UnityEngine.Vector3(currentFrame.x / 100, -currentFrame.y / 100, 0)})
				self.delay = currentFrame.wait
				self.frame = self.frame + 1
				break
			elseif currentFrame.category == "Move" then
				self.vvvX = currentFrame.directionX
				self.vvvY = currentFrame.directionY
				self.frame = self.frame + 1
			elseif currentFrame.category == "Body" then
				self:addEvent(currentFrame.category, 1, {id = currentFrame.id, direction = self.direction, x = currentFrame.x, y = currentFrame.y, width = currentFrame.width, height = currentFrame.height,
															contactFilter = self.contactFilter, trigger = false})
				self.frame = self.frame + 1
			elseif currentFrame.category == "Attack" then
				self:addEvent(currentFrame.category, 1, {id = currentFrame.id, direction = self.direction, x = currentFrame.x, y = currentFrame.y, width = currentFrame.width, height = currentFrame.height,
															contactFilter = self.contactFilter, trigger = true, damage = currentFrame.damage, fall = currentFrame.fall, defence = currentFrame.defence,
															frequency = currentFrame.frequency, directionX = currentFrame.directionX, directionY = currentFrame.directionY, ignoreFlag = false})
				self.frame = self.frame + 1
			elseif currentFrame.category == "Sound" then
				self:addEvent(currentFrame.category, 1, {sfx = currentFrame.sfx})
				self.frame = self.frame + 1
			elseif currentFrame.category == "Object" then
				self:addEvent(currentFrame.category, 1, {x = currentFrame.x, y = currentFrame.y, nextFrame = currentFrame.nextFrame})
				self.frame = self.frame + 1
			elseif currentFrame.category == "Command" then
				local rA, rB = utils.getRangeAB(currentFrame.range)
				self:addEvent(currentFrame.category, 999999, {name = currentFrame.command, rangeA = rA, rangeB = rB})
				self.frame = self.frame + 1
			elseif currentFrame.category == "Act" then
				self:addEvent(currentFrame.category, 999999, {actFlag = currentFrame.actFlag, nextFrame = currentFrame.nextFrame})
				self.frame = self.frame + 1
			elseif currentFrame.category == "Warp" then
				self:addEvent(currentFrame.category, 1, {nextFrame = currentFrame.nextFrame})
	--~ 				self.vvvX = nil
	--~ 				self.vvvY = nil
				break
			elseif currentFrame.category == "End" then
				self:addEvent(currentFrame.category, 1, nil)
				break
			else
				self.frame = self.frame + 1
			end
		end
		self.delayCounter = self.delayCounter + 1
	end
    return self
end

function LObject:reversePic()
	if self.direction.x == -1 then

		self.spriteRenderer.flipX = true
	else
		self.spriteRenderer.flipX = false
	end
end

--~ function LObject:frameLoop()
--~ 	if self.delayCounter >= self.delay then
--~ 		self.delayCounter = 0
--~ 	end


--~ 	while self.delayCounter == 0 do
--~ 		if self.frame > #self.database[self.id][self.action].frames then
--~ 			self.frame = 1
--~ 			self:clearCollidersAndCommand()
--~ 		end
--~ 		local currentFrame = self.database[self.id][self.action].frames[self.frame]

--~ 		if currentFrame.category == "Sprite" and currentFrame.wait > 0 then
--~ 			self:addEvent(currentFrame.category, 1, {sprite = self.pics[currentFrame.pic], localPosition = CS.UnityEngine.Vector3(currentFrame.x / 100, -currentFrame.y / 100, 0)})
--~ 			self.delay = currentFrame.wait
--~ 			self.frame = self.frame + 1
--~ 			break
--~ 		elseif currentFrame.category == "Move" then
--~ 			self.vvvX = currentFrame.directionX
--~ 			self.vvvY = currentFrame.directionY
--~ 			self.frame = self.frame + 1
--~ 		elseif currentFrame.category == "Body" then
--~ 			self:addEvent(currentFrame.category, 1, {id = currentFrame.id, direction = self.direction, x = currentFrame.x, y = currentFrame.y, width = currentFrame.width, height = currentFrame.height,
--~ 														contactFilter = self.contactFilter, trigger = false})
--~ 			self.frame = self.frame + 1
--~ 		elseif currentFrame.category == "Attack" then
--~ 			self:addEvent(currentFrame.category, 1, {id = currentFrame.id, direction = self.direction, x = currentFrame.x, y = currentFrame.y, width = currentFrame.width, height = currentFrame.height,
--~ 														contactFilter = self.contactFilter, trigger = true, damage = currentFrame.damage, fall = currentFrame.fall, defence = currentFrame.defence,
--~ 														frequency = currentFrame.frequency, directionX = currentFrame.directionX, directionY = currentFrame.directionY, ignoreFlag = false})
--~ 			self.frame = self.frame + 1
--~ 		elseif currentFrame.category == "Sound" then
--~ 			self:addEvent(currentFrame.category, 1, {sfx = currentFrame.sfx})
--~ 			self.frame = self.frame + 1
--~ 		elseif currentFrame.category == "Object" then
--~ 			self:addEvent(currentFrame.category, 1, {x = currentFrame.x, y = currentFrame.y, nextFrame = currentFrame.nextFrame})
--~ 			self.frame = self.frame + 1
--~ 		elseif currentFrame.category == "Command" then
--~ 			local rA, rB = utils.getRangeAB(currentFrame.range)
--~ 			self:addEvent(currentFrame.category, 999999, {name = currentFrame.command, rangeA = rA, rangeB = rB})
--~ 			self.frame = self.frame + 1
--~ 		elseif currentFrame.category == "Act" then
--~ 			self:addEvent(currentFrame.category, 999999, {actFlag = currentFrame.actFlag, nextFrame = currentFrame.nextFrame})
--~ 			self.frame = self.frame + 1
--~ 		elseif currentFrame.category == "Warp" then
--~ 			self:addEvent(currentFrame.category, 1, {nextFrame = currentFrame.nextFrame})
--~ 				self.vvvX = nil
--~ 				self.vvvY = nil
--~ 			break
--~ 		elseif currentFrame.category == "End" then
--~ 			self:addEvent(currentFrame.category, 1, nil)
--~ 			break
--~ 		else
--~ 			self.frame = self.frame + 1
--~ 		end
--~ 	end
--~ 	self.delayCounter = self.delayCounter + 1
--~ end

function LObject:runFrame()



	if self.vvvX ~= nil then
		self.velocity.x = self.vvvX * self.direction.x
	end
	if self.vvvY ~= nil then
		self.velocity.y = self.vvvY * self.direction.y
	end


--~ 	self.velocity = self.velocity + 0.5 * CS.UnityEngine.Physics2D.gravity * CS.UnityEngine.Time.deltaTime

--~ 	self.rigidbody.position = self.rigidbody.position + self.velocity * CS.UnityEngine.Time.deltaTime
	self.myFunction()

	-- 事件运行
	ccount = 1
	while true do
		local e = self.eventQueue[ccount]
		while e ~= nil and e.waitCounter >= e.wait do
			table.remove(self.eventQueue, ccount)
			e = self.eventQueue[ccount]
		end
		if e == nil then
			break
		end
		e.waitCounter = e.waitCounter + 1

		if e.category == "Sprite" then
			self.spriteRenderer.sprite = e.event.sprite
			self.pic_object.transform.localPosition = e.event.localPosition
		elseif e.category == "Move" then
			self.velocity = self.velocity + e.event.velocity
		elseif e.category == "Body" then
			if self.bodyArray[e.event.id] == nil then
				self.bodyArray[e.event.id] = LColliderBDY:new(self.bdy_object)
				self.bodyArray[e.event.id]:setCollider(e.event.direction, e.event.x, e.event.y, e.event.width, e.event.height, e.event.contactFilter, e.event.trigger)
			else
				if e.event.width == 0 and e.event.height == 0 then
					self.bodyArray[e.event.id]:deleteCollider()
					self.bodyArray[e.event.id] = nil
				else
					self.bodyArray[e.event.id]:setCollider(e.event.direction, e.event.x, e.event.y, e.event.width, e.event.height, e.event.contactFilter, e.event.trigger)
				end
			end
		elseif e.category == "Attack" then
			if self.attckArray[e.event.id] == nil then
				self.attckArray[e.event.id] = LColliderATK:new(self.atk_object)
				self.attckArray[e.event.id]:setCollider(e.event.direction, e.event.x, e.event.y, e.event.width, e.event.height, e.event.contactFilter, e.event.trigger,
															e.event.damage, e.event.fall, e.event.defence, e.event.frequency, e.event.directionX, e.event.directionY, e.event.ignoreFlag)
			else
				if e.event.width == 0 and e.event.height == 0 then
					self.attckArray[e.event.id]:deleteCollider()
					self.attckArray[e.event.id] = nil
				else
				self.attckArray[e.event.id]:setCollider(e.event.direction, e.event.x, e.event.y, e.event.width, e.event.height, e.event.contactFilter, e.event.trigger,
															e.event.damage, e.event.fall, e.event.defence, e.event.frequency, e.event.directionX, e.event.directionY, e.event.ignoreFlag)
				end
			end
		elseif e.category == "Sound" then
			self.audioSource.clip = self.audioClips[e.event.sfx]
			self.audioSource:Play()
		elseif e.category == "Object" then
			if e.event.worldPosition then
				utils.createObject(self.database, self.pics, self.audioClips, self.id, e.event.nextFrame, e.event.x, e.event.y, 0, 0, 3)
			else
				utils.createObject(self.database, self.pics, self.audioClips, self.id, e.event.nextFrame, self.rigidbody.position.x + e.event.x, self.rigidbody.position.y + e.event.y, 0, 0, 3)
			end
		elseif e.category == "Command" then
--~ 			e.event()
		elseif e.category == "Act" then
			if (e.event.actFlag == 0 and self.isOnGround and self.velocity.y < 0) or (e.event.actFlag == 1 and self.isWall) then
				self.action, self.frame = utils.getFrame(e.event.nextFrame)
				self:clearCollidersAndCommand()
				self.delay = 0
				self.delayCounter = 0
				self.myFunction()
				e.isOnce = true
			end
		elseif e.category == "Warp" then
			self.action, self.frame = utils.getFrame(e.event.nextFrame)
			self:clearCollidersAndCommand()
			self.delay = 0
			self.delayCounter = 0
			self.myFunction()
		elseif e.category == "End" then
			utils.destroyObject(self.gameObject:GetInstanceID())
		elseif e.category == "Hurt" then  -- 从这里开始和bd无关，是自定义event
			self.HP = self.HP - e.event.damage
			self.MP = self.MP - e.event.damage
			self.falling = self.falling + e.event.fall
			self.defencing = self.defencing + e.event.defence
			if self.falling > self.maxFalling then
				self.falling = self.maxFalling
			end
			if self.defencing > self.maxDefencing then
				self.defencing = self.maxDefencing
			end
		elseif e.category == "UpdatePostion" then
			self.rigidbody.position = self.rigidbody.position + self.velocity * CS.UnityEngine.Time.deltaTime
		elseif e.category == "HP" then
			self.HP = self.HP + e.event.damage
		elseif e.category == "MP" then
			self.MP = self.MP + e.event.damage
		elseif e.category == "Falling" then
			self.falling = self.falling + e.event.fall
		elseif e.category == "Defecing" then
			self.defencing = self.defencing + e.event.defence
		elseif e.category == "FlipX" then -- 反向操作
			if self.directionBuff.x ~= self.direction.x then
				if self.direction.x == -1 then
					self.gameObject.transform.eulerAngles = CS.UnityEngine.Vector3(0, 180, 0)
				else
					self.gameObject.transform.eulerAngles = CS.UnityEngine.Vector3(0, 0, 0)
				end
				self.directionBuff.x = self.direction.x
			end
		elseif e.category == "Flying" then
			if (self.action == "standing" or self.action == "walking") and self.isOnGround == false and self.velocity.y < 0 then
				self.action = "jumping_flying"
				self.frame = 0 + 1
				self.delay = 0
				self.delayCounter = 0
				self:clearCollidersAndCommand()
				self.myFunction()
			end
		elseif e.category == "HPMPFallingDefecing" then
			self.HP = self:toMaxvalue(self.HP, self.maxHP, self.HPRR)
			self.MP = self:toMaxvalue(self.MP, self.maxMP, self.MPRR)
			self.falling = self:toOne(self.falling, self.maxFalling, self.fallingRR)
			self.defencing = self:toOne(self.defencing, self.maxDefencing, self.defencingRR)
		elseif e.category == "Friction" then
			if self.isOnGround then
				local f = self.velocity * CS.UnityEngine.Vector2(1, 0) * 0.20 -- 摩擦系数
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
		elseif e.category == "Input" then
			for i2, v2 in ipairs(self.eventQueue) do
				if v2.category == "Command" then

					if (v2.event.rangeA ~= nil and v2.event.rangeB ~= nil and e.event.level >= v2.event.rangeA and e.event.level <= v2.event.rangeB) or (v2.event.name ~= nil and v2.event.name == e.event.name) then

						self.action, self.frame = utils.getFrame(e.event.frame)
						self.delay = 0
						self.delayCounter = 0
						self:clearCollidersAndCommand()
						self.myFunction()
						if e.event.direction == 1 then
							if self.direction.x == -1 then
								self.direction.x = 1
							end
						elseif e.event.direction == -1 then
							if self.direction.x == 1 then
								self.direction.x = -1
							end
						end
						break
					end
				end
			end
		elseif e.category == "Injured" then
			local ttt = {}
			local round = math.floor(self.falling + 0.5)
			for i, v in pairs(self.database[self.id].char.reactions) do
				local rA, rB = utils.getRangeAB(v.fallingRange)
--~ 				print(round, rA, rB)
				if round >= rA and round <= rB then
					table.insert(ttt, {action = v.reactionAction, frame = v.reactionFrame})
				end
			end
			if #ttt > 0 then
--~ 						local r = CS.Tools.Instance:RandomRangeInt(1, 101)
--~ 						if r >= 1 and r <= 80 then
--~ 							r = 1
--~ 						elseif r >= 81 and r <= 100 then
--~ 							r = 2
--~ 						end
				local r = 1
--~ 							print(#ttt, r)
				self.action = ttt[r].action
				self.frame = ttt[r].frame + 1
				self.delay = 0
				self.delayCounter = 0
				self:clearCollidersAndCommand()
				self.myFunction()
			end
		end
		if e.isOnce then
			e.wait = 1
			e.waitCounter = 1
		end
		ccount = ccount + 1
	end

	-- 碰撞检测
	local g = false
	for i, v in pairs(self.bodyArray) do
		local gg, ww = v:BDYFixedUpdate(self.velocity, self.weight)
		if gg then
			if g == false then
				self.isOnGround = true
				self.velocity.y = 0
				g = true
			end
		end
		self.isWall = ww
		if ww then
			self.velocity.x = 0
		end
	end
	if g == false then
		self.isOnGround = false
	end

	local myID = self.gameObject:GetInstanceID()
	-- 攻击检测
	for i, v in pairs(self.attckArray) do
		v:ATKFixedUpdate(self.direction, myID)
	end

--~ 	local a =  CS.UnityEngine.Vector3(self.rigidbody.position.x, self.rigidbody.position.y, 0)
--~ 	local b =  CS.UnityEngine.Vector3(self.velocity.x, self.velocity.y, 0)
--~ 	CS.UnityEngine.Debug.DrawLine(a, a + b, CS.UnityEngine.Color.blue)
end

function LObject:updatePic()
end

function LObject:displayInfo()
	if self.kind ~= 3 then
		local xy = CS.UnityEngine.Camera.main:WorldToScreenPoint(self.gameObject.transform.position)
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300, 200, 100), "x: " .. math.floor(self.velocity.x + 0.5) .. "y: " .. math.floor(self.velocity.y + 0.5))
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 20, 200, 100), "hp: " .. math.floor(self.HP + 0.5))
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 30, 200, 100), "mp: " .. math.floor(self.MP + 0.5))
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 40, 200, 100), "action: " .. self.action)
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 50, 200, 100), "frame: " .. self.frame)
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 70, 200, 100), "g: " .. tostring(self.isOnGround))
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 80, 200, 100), "w: " .. tostring(self.isWall))
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 90, 200, 100), "f: " .. math.floor(self.falling + 0.5))
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 100, 200, 100), "d: " .. math.floor(self.defencing + 0.5))
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(xy.x, -xy.y + 300 + 110, 200, 100), "e: " .. #self.eventQueue)
	end
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


	for i = #self.eventQueue, 1, -1 do -- 清空命令
		if self.eventQueue[i].category == "Command" then
			self.eventQueue[i].wait = 1
			self.eventQueue[i].waitCounter = 1
		end
	end
end

function LObject:toMaxvalue(v, maxV, rate)
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

function LObject:toOne(v, maxV, rate)
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


function LObject:addEvent(c, w, e)
	table.insert(self.eventQueue, {category = c, wait = w, isOnce = false, waitCounter = 0, event = e})
	return self.eventQueue[#self.eventQueue]
end

function LObject:deleteEvent(event)

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

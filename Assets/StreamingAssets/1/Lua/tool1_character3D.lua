-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

myFrame = nil
myPic = nil

myPics = nil

myDrawField = nil

-- 实际游戏相关部分
myAction = nil

local counter = 1
local delay = 0
local delayCounter = 0

local MIN_MOVE_DISTANCE = 0.001
local boxCollider3D = nil
local rigidbody3D = nil
local contactFilter2D = nil
local raycastHit2DList = nil -- CS.System.Collections.Generic.List(typeof(CS.UnityEngine.RaycastHit2D))
local tangentRaycastHit2DList = {} -- CS.System.Collections.Generic.List(typeof(CS.UnityEngine.RaycastHit2D))
local layerMask = CS.UnityEngine.LayerMask()
layerMask.value = -1

local velocity = CS.UnityEngine.Vector3.zero

local myBody = nil

local onGround = false
-- 实际游戏相关部分END

--gizomos
local m_MaxDistance = 0
local m_HitDetect = false
--gizomos

local sr = nil
function start()
	print("lua start...")
	sr = myPic:GetComponent(typeof(CS.UnityEngine.SpriteRenderer))


	if myAction ~= nil and myPic ~= nil then
		rigidbody3D = self.gameObject:AddComponent(typeof(CS.UnityEngine.Rigidbody))
		rigidbody3D.isKinematic = true
		rigidbody3D.constraints = CS.UnityEngine.RigidbodyConstraints.FreezePositionZ | CS.UnityEngine.RigidbodyConstraints.FreezeRotation
--~ 		rigidbody3D.useFullKinematicContacts = true
		rigidbody3D.collisionDetectionMode = CS.UnityEngine.CollisionDetectionMode.ContinuousSpeculative -- Continuous
--~ 		rigidbody3D.sleepMode = CS.UnityEngine.RigidbodySleepMode.NeverSleep;
--~         rigidbody3D.interpolation = CS.UnityEngine.RigidbodyInterpolation.Interpolate;
--~         rigidbody3D.constraints = CS.UnityEngine.RigidbodyConstraints.FreezeRotation;
--~         rigidbody3D.gravityScale = 0
		rigidbody3D.useGravity = false
		rigidbody3D.detectCollisions = false

		myBody = CS.UnityEngine.GameObject("body")
		myBody.transform.parent = self.gameObject.transform
		myBody.transform.localPosition = CS.UnityEngine.Vector3(0, 0, 0)
		boxCollider3D = myBody:AddComponent(typeof(CS.UnityEngine.BoxCollider))
--~ 		boxCollider3D.isTrigger = true

--~ 		contactFilter2D = CS.UnityEngine.ContactFilter2D()
--~         contactFilter2D.useLayerMask = false
--~ 		contactFilter2D.useTriggers = false
--~         contactFilter2D.layerMask = layerMask
	end
end

function update()
	if myFrame ~= nil and myPic ~= nil then
		myPic.transform.localPosition = CS.UnityEngine.Vector3(myFrame.x / 100, -myFrame.y / 100, 0)
	end
end

function onDrawGizmos()
	CS.UnityEngine.Gizmos.color = CS.UnityEngine.Color.red

	-- Check if there has been a hit yet
	if m_HitDetect then
		-- Draw a Ray forward from GameObject toward the hit
		CS.UnityEngine.Gizmos.DrawRay(self.transform.position, velocity * CS.UnityEngine.Time.deltaTime)
		-- Draw a cube that extends to where the hit exists
		CS.UnityEngine.Gizmos.DrawWireCube((self.transform.position + velocity - boxCollider3D.bounds.center * CS.UnityEngine.Time.deltaTime) * m_Hit.distance, boxCollider3D.bounds.size)
	-- If there hasn't been a hit yet, draw the ray at the maximum distance
	else
		if boxCollider3D ~= nil then
		-- Draw a Ray forward from GameObject toward the maximum distance
		CS.UnityEngine.Gizmos.DrawRay(boxCollider3D.bounds.center, velocity * CS.UnityEngine.Time.deltaTime)
		-- Draw a cube at the maximum distance

			CS.UnityEngine.Gizmos.DrawWireCube(boxCollider3D.bounds.center + velocity * CS.UnityEngine.Time.deltaTime, boxCollider3D.bounds.size)
		end
	end
end

function Movement(deltaPosition)
	local tempGround = false
	if deltaPosition == CS.UnityEngine.Vector3.zero then
		return
	end

	local updateDeltaPosition = CS.UnityEngine.Vector3.zero

	local distance = deltaPosition.magnitude
	local direction = deltaPosition.normalized

	if distance < MIN_MOVE_DISTANCE then
		distance = MIN_MOVE_DISTANCE
	end
	m_MaxDistance = distance
--~ 	raycastHit2DList = CS.Tools.Instance:PhysicsBoxCastG(boxCollider3D.bounds.center, boxCollider3D.bounds.size / 2, deltaPosition.normalized, self.transform.rotation, distance)
--~ 	if raycastHit2DList.distance ~= 0 then
--~ 		print(raycastHit2DList.collider.name)
--~ 	end

	raycastHit2DList = CS.Tools.Instance:PhysicsBoxCastAllC(boxCollider3D.bounds.center, boxCollider3D.bounds.size / 2, direction, self.transform.rotation, distance)
--~ 	raycastHit2DList = CS.Tools.Instance:rigidbody3DCastF(rigidbody3D, direction, contactFilter2D, raycastHit2DList, distance)

	local finalDirection = direction
	local finalDistance = distance

	for i = 0, raycastHit2DList.Length - 1, 1 do
		local hit = raycastHit2DList[i]
			if hit.rigidbody ~= rigidbody3D then

			local moveDistance = hit.distance
			CS.UnityEngine.Debug.DrawLine(hit.point, hit.point + hit.normal, CS.UnityEngine.Color.white)
			CS.UnityEngine.Debug.DrawLine(hit.point, hit.point + direction, CS.UnityEngine.Color.yellow)


			local bbb = boxCollider3D.bounds
			bbb.center = bbb.center + deltaPosition
			if bbb:Intersects(hit.collider.bounds) then
--~ 				print("fuck")

--~ 				moveDistance = moveDistance - bbb
				local asd = boxCollider3D.bounds:SqrDistance(hit.point)
				local asd2 = hit.collider.bounds:SqrDistance(hit.point)
				print(moveDistance, asd, asd2)
			end

--~ 			local projection = CS.UnityEngine.Vector3.Dot(hit.normal, direction)

--~ 			print(hit.normal, direction, projection, distance)
--~ 			if projection >= 0 then
--~ 				moveDistance = distance
--~ 			else
--~ 				print(hit.normal)
--~ 				local tangentDirection = CS.UnityEngine.Vector3(hit.normal.z, hit.normal.y, -hit.normal.x)
--~ 				local tangentDot = CS.UnityEngine.Vector3.Dot(tangentDirection, direction)

--~ 				if tangentDot < 0 then
--~ 					tangentDirection = -tangentDirection
--~ 					tangentDot = -tangentDot
--~ 				end

--~ 				local tangentDistance = tangentDot * distance

--~ 				if tangentDot ~= 0 then
--~ 					tangentRaycastHit2DList = CS.Tools.Instance:PhysicsBoxCastAllC(boxCollider3D.bounds.center, boxCollider3D.bounds.size / 2, tangentDirection, tangentDistance)

--~ 					for j = 0, tangentRaycastHit2DList.Length - 1, 1 do

--~ 						local tangentHit = tangentRaycastHit2DList[j]
--~ 						if tangentHit.rigidbody ~= rigidbody3D then

--~ 							CS.UnityEngine.Debug.DrawLine(tangentHit.point, tangentHit.point + tangentDirection, CS.UnityEngine.Color.magenta)

--~ 							local continue = false
--~ 							if CS.UnityEngine.Vector3.Dot(tangentHit.normal, tangentDirection) >= 0 then
--~ 								continue = true
--~ 							end

--~ 							if continue == false then
--~ 								if tangentHit.distance < tangentDistance then
--~ 									tangentDistance = tangentHit.distance
--~ 								end
--~ 							end
--~ 						end
--~ 					end

--~ 					updateDeltaPosition = updateDeltaPosition + tangentDirection * tangentDistance
--~ 				end
--~ 			end

			if moveDistance < finalDistance then
				finalDistance = moveDistance
			end

--~ 			if hit.normal.x == 0 and hit.normal.y == 1 then
--~ 				if tempGround == false then -- k.rigidbody.name == "test"
--~ 					tempGround = true
--~ 				end
--~ 				if velocity.y < 0 then
--~ 					velocity.y = 0
--~ 				end
--~ 			elseif hit.normal.x == -1 and hit.normal.y == 0 then
--~ 				if velocity.x > 0 then
--~ 					velocity.x = 0
--~ 				end
--~ 			elseif hit.normal.x == 1 and hit.normal.y == 0 then
--~ 				if velocity.x < 0 then
--~ 					velocity.x = 0
--~ 				end
--~ 			end
		end
	end

--~ 	if tempGround == false and onGround == true then
--~ 		onGround = false
--~ 	elseif tempGround == true and onGround == false then
--~ 		onGround = true
--~ 	end


	updateDeltaPosition = updateDeltaPosition + finalDirection * finalDistance
	rigidbody3D.position = rigidbody3D.position + updateDeltaPosition
end

function offsetClac(k)
	local hit = {}
	hit.normal = k.normal
--~ 		print(k.collider:GetType())
--~ 	print(k.distance)
--~ 		local aaa = CS.UnityEngine.Vector2(k.collider.size.x, k.collider.size.y) * k.normal
--~ 		print(aaa)

--~ 		local bbb = boxCollider3D.size * -k.normal
--~ 		print(bbb)

	local sad = (CS.UnityEngine.Vector2(k.collider.transform.position.x, k.collider.transform.position.y) - k.collider.offset - k.collider.size / 2)
--~ 		print(sad.x, sad.y)
	local ddd = k.point - sad
--~ 	print("wadawdawd", k.point.x, k.point.y, sad.x, sad.y)
	ddd = sad * -k.normal
--~ 	print(ddd.x, ddd.y, ddd.magnitude)

	hit.point = ddd
	hit.distance = ddd.magnitude

	return hit
end

function fixedupdate()
	if myAction ~= nil and myPic ~= nil then
		if delayCounter >= delay then
			delayCounter = 0
		end
		if delayCounter == 0 then
			for i = counter, #myAction, 1 do
				if myAction[i].category == "Sprite" then
					sr.sprite = myPics[myAction[i].pic]
					myPic.transform.localPosition = CS.UnityEngine.Vector3(myAction[i].x / 100, -myAction[i].y / 100, 0)
					delay = myAction[i].wait
					counter = i + 1
					break
				elseif myAction[i].category == "Body" then
					boxCollider3D.center = CS.UnityEngine.Vector3((myAction[i].x + myAction[i].width / 2) / 100, -(myAction[i].y + myAction[i].height / 2) / 100, 0)
					boxCollider3D.size = CS.UnityEngine.Vector3(myAction[i].width / 100, myAction[i].height / 100, 1)
					counter = i + 1
				elseif myAction[i].category == "Warp" then
					counter = myAction[i].nextFrame
					delay = 0
					counter = 1
				else
					counter = i + 1
				end

			end
		end
		delayCounter = delayCounter + 1
	end

	if myAction ~= nil and myPic ~= nil and onGround == false then
--~ 		velocity = velocity + CS.UnityEngine.Physics.gravity * CS.UnityEngine.Time.deltaTime
	end

	if myAction ~= nil and myPic ~= nil then
		Movement(velocity * CS.UnityEngine.Time.deltaTime) --   * 5
	end
end

function ongui()
	if myFrame ~= nil then
		for i, v in ipairs(myDrawField) do
			v()
		end
	end
	if myAction ~= nil and myPic ~= nil then
		CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(300, 300, 200, 200), velocity:ToString())

	if myAction ~= nil and myPic ~= nil then
--~ 		velocity = velocity + CS.UnityEngine.Vector2(CS.UnityEngine.Input.GetAxisRaw("Horizontal"), CS.UnityEngine.Input.GetAxisRaw("Vertical")) * 5
		if CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.W and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
			velocity.y = velocity.y + 5 / 2
		elseif CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.S and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
			velocity.y = velocity.y + -5 / 2
		end
		if CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.D and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
			velocity.x = velocity.x + 5 / 2
		elseif CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.A and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
			velocity.x = velocity.x + -5 / 2
		end
	end
	end
end

function ondestroy()
    print("lua destroy")
end

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
local boxCollider2D = nil
local rigidbody2D = nil
local contactFilter2D = nil
local raycastHit2DList = {} -- CS.System.Collections.Generic.List(typeof(CS.UnityEngine.RaycastHit2D))
local tangentRaycastHit2DList = {} -- CS.System.Collections.Generic.List(typeof(CS.UnityEngine.RaycastHit2D))
local layerMask = CS.UnityEngine.LayerMask()
layerMask.value = -1

local velocity = CS.UnityEngine.Vector2.zero

local myBody = nil

local onGround = false
-- 实际游戏相关部分END

local tempg = {}

local sr = nil


local c2d2d = nil
function start()
	print("lua start...")
	sr = myPic:GetComponent(typeof(CS.UnityEngine.SpriteRenderer))


	if myAction ~= nil and myPic ~= nil then
		rigidbody2D = self.gameObject:AddComponent(typeof(CS.UnityEngine.Rigidbody2D))
		rigidbody2D.bodyType = CS.UnityEngine.RigidbodyType2D.Kinematic
--~ 		rigidbody2D.useFullKinematicContacts = true
		rigidbody2D.collisionDetectionMode = CS.UnityEngine.CollisionDetectionMode2D.Continuous
		rigidbody2D.sleepMode = CS.UnityEngine.RigidbodySleepMode2D.NeverSleep;
        rigidbody2D.interpolation = CS.UnityEngine.RigidbodyInterpolation2D.Interpolate;
        rigidbody2D.constraints = CS.UnityEngine.RigidbodyConstraints2D.FreezeRotation;
        rigidbody2D.gravityScale = 0

		myBody = CS.UnityEngine.GameObject("body")
		myBody.transform.parent = self.gameObject.transform
		myBody.transform.localPosition = CS.UnityEngine.Vector3(0, 0, 0)
		boxCollider2D = myBody:AddComponent(typeof(CS.UnityEngine.BoxCollider2D))
--~ 		boxCollider2D.isTrigger = true

		contactFilter2D = CS.UnityEngine.ContactFilter2D()
        contactFilter2D.useLayerMask = false
		contactFilter2D.useTriggers = false
--~ 		contactFilter2D.useNormalAngle = true
--~ 		contactFilter2D.useOutsideNormalAngle = true
--~         contactFilter2D.layerMask = layerMask

		c2d2d = CS.UnityEngine.ContactFilter2D()
		c2d2d.useLayerMask = false
		c2d2d.useTriggers = true
	end
end

function update()
	if myFrame ~= nil and myPic ~= nil then
		myPic.transform.localPosition = CS.UnityEngine.Vector3(myFrame.x / 100, -myFrame.y / 100, 0)
	end
end

function onDrawGizmos()
	for i, v in ipairs(tempg) do
		CS.UnityEngine.Gizmos.color = v.color
		CS.UnityEngine.Gizmos.DrawSphere(CS.UnityEngine.Vector3(v.point.x, v.point.y, 0), 0.01)
	end
end

function Movement(deltaPosition)
	local tempGround = false
	if deltaPosition == CS.UnityEngine.Vector2.zero then
		return
	end

	local updateDeltaPosition = CS.UnityEngine.Vector2.zero

	local distance = deltaPosition.magnitude
	local direction = deltaPosition.normalized

	if distance < MIN_MOVE_DISTANCE then
		distance = MIN_MOVE_DISTANCE
	end

	local finalDirection = direction
	local finalDistance = distance


	-- left
--~ 	contactFilter2D:SetNormalAngle(0 *  CS.UnityEngine.Mathf.Deg2Rad, 180 * CS.UnityEngine.Mathf.Deg2Rad)
--~ 	contactFilter2D:SetNormalAngle(45 *  CS.UnityEngine.Mathf.Deg2Rad, 135 * CS.UnityEngine.Mathf.Deg2Rad)

local rrr = nil

	local ttt = {}
	local csss = {}
	csss = CS.Tools.Instance:RigidBody2DCastF(rigidbody2D, direction, contactFilter2D, csss, distance)
	for p, k in pairs(csss) do
		local start = CS.UnityEngine.Vector3(k.point.x, k.point.y, 0)
		local end2 = CS.UnityEngine.Vector3(k.point.x + k.normal.x, k.point.y + k.normal.y, 0)
		CS.UnityEngine.Debug.DrawLine(start, end2, CS.UnityEngine.Color.yellow)
		local myp = {point = k.point, color = CS.UnityEngine.Color.green}
		local collider = k.collider
		if collider:GetType() == typeof(CS.UnityEngine.CompositeCollider2D) then

		rrr = k.collider.attachedRigidbody
--~ 			local colliderDistance = boxCollider2D:Distance(k.collider)

--~ 			if colliderDistance.isOverlapped == false then
				myp.color = CS.UnityEngine.Color.red
				raycastHit2DList = CS.Tools.Instance:RigidBody2DCastF(rigidbody2D, direction, c2d2d, raycastHit2DList, distance)
				for i, j in pairs(raycastHit2DList) do
					if  j.collider.name ~= "test" then
					local hit = offsetClac(j)
--~ 				for i = 0, cs.Length - 1, 1 do
--~ 					print(hit.normal.x, hit.normal.y)

--~ 						print(j.collider.name)


--~ 						if k.normal.x == 0 and k.normal.y == 1 then

--~ 						elseif k.normal.x == -1 and k.normal.y == 0 then

--~ 						elseif k.normal.x == 1 and k.normal.y == 0 then

--~ 						end

--~ 						local cent = CS.UnityEngine.Vector2(j.coliider.bounds.center.x, j.coliider.bounds.center.y)
--~ 						local fce = cent + CS.UnityEngine.Vector2(j.width)

--~ 						finalDistance = j.distance

--~ 						local projection = CS.UnityEngine.Vector2.Dot(hit.normal, direction)

--~ 						if projection >= 0 then
--~ 							moveDistance = distance
--~ 						else
--~ 						end
--~ 						local ppppp = offsetClac(j)

--~ 						print(hit.point.x, hit.point.y, ppppp.point.x, ppppp.point.y)

						local moveDistance = hit.distance
						local projection = CS.UnityEngine.Vector2.Dot(hit.normal, direction)
						if projection >= 0 then
							moveDistance = distance
						else
							local tangentDirection = CS.UnityEngine.Vector2(hit.normal.y, -hit.normal.x)
							local tangentDot = CS.UnityEngine.Vector2.Dot(tangentDirection, direction)

							if tangentDot < 0 then
								tangentDirection = -tangentDirection
								tangentDot = -tangentDot
							end

							local tangentDistance = tangentDot * distance

							if tangentDot ~= 0 then
								tangentRaycastHit2DList = CS.Tools.Instance:RigidBody2DCastF(rigidbody2D, tangentDirection, c2d2d, tangentRaycastHit2DList, tangentDistance)

								for l, m in pairs(tangentRaycastHit2DList) do
									if  m.collider.name ~= "test" then
										local tangentHit = offsetClac(m)

										local start2 = CS.UnityEngine.Vector3(tangentHit.point.x, tangentHit.point.y, 0)
										local end21 = CS.UnityEngine.Vector3(tangentHit.point.x + tangentDirection.x, tangentHit.point.x + tangentDirection.y, 0)
										CS.UnityEngine.Debug.DrawLine(start2, end21, CS.UnityEngine.Color.magenta)

										local continue = false
										if CS.UnityEngine.Vector2.Dot(tangentHit.normal, tangentDirection) >= 0 then
											continue = true
										end

										if continue == false then
											if tangentHit.distance < tangentDistance then
												tangentDistance = tangentHit.distance
											end
										end
									end
								end

								updateDeltaPosition = updateDeltaPosition + tangentDirection * tangentDistance
							end
						end

						if moveDistance < finalDistance then
							finalDistance = moveDistance
						end

						if hit.normal.x == 0 and hit.normal.y == 1 then
							if tempGround == false and k.rigidbody.name == "test" then
								tempGround = true
							end
							if velocity.y < 0 then
								velocity.y = 0
							end
						elseif hit.normal.x == -1 and hit.normal.y == 0 then
							if velocity.x > 0 then
								velocity.x = 0
							end
						elseif hit.normal.x == 1 and hit.normal.y == 0 then
							if velocity.x < 0 then
								velocity.x = 0
							end
						end
					end
				end

--~ 			end

			break
		end

			table.insert(ttt, myp)
	end



	if tempGround == false and onGround == true then
		onGround = false
	elseif tempGround == true and onGround == false then
		onGround = true
	end



	tempg = ttt

--~ 	raycastHit2DList = CS.Tools.Instance:RigidBody2DOverlapColliderB(rigidbody2D, contactFilter2D, raycastHit2DList)

--~ 	for p, k in pairs(raycastHit2DList) do
--~ 		local collider = k
--~ 		if collider:GetType() == typeof(CS.UnityEngine.CompositeCollider2D) then
--~
--~ 		end
--~ 	end

	updateDeltaPosition = updateDeltaPosition + finalDirection * finalDistance
	rigidbody2D.position = rigidbody2D.position + updateDeltaPosition
end

function offsetClac(k)
	local hit = {}
	hit.normal = k.normal
--~ 		print(k.collider:GetType())
--~ 	print(k.distance)
--~ 		local aaa = CS.UnityEngine.Vector2(k.collider.size.x, k.collider.size.y) * k.normal
--~ 		print(aaa)

--~ 		local bbb = boxCollider2D.size * -k.normal
--~ 		print(bbb)

--~ 	local sad = (CS.UnityEngine.Vector2(k.collider.transform.position.x, k.collider.transform.position.y) - k.collider.offset * -k.normal - k.collider.size / 2)
	local a = k.collider.bounds:ClosestPoint(CS.UnityEngine.Vector3(k.point.x, k.point.y, k.collider.bounds.center.z))
	local sad = CS.UnityEngine.Vector2(a.x, a.y)
--~ 		print(sad.x, sad.y)
	local ddd = k.point - sad
--~ 	print("wadawdawd", k.point.x, k.point.y, sad.x, sad.y)
	ddd = ddd
--~ 	print(ddd.x, ddd.y, ddd.magnitude)
	print(ddd.x, ddd.y)
	hit.point = {}
	hit.point.x = k.point.x - ddd.x
	hit.point.y = k.point.y - ddd.y
	hit.distance = k.distance + ddd.magnitude

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
					boxCollider2D.offset = CS.UnityEngine.Vector2((myAction[i].x + myAction[i].width / 2) / 100, -(myAction[i].y + myAction[i].height / 2) / 100)
					boxCollider2D.size = CS.UnityEngine.Vector2(myAction[i].width / 100, myAction[i].height / 100)
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
--~ 		local p = CS.UnityEngine.Physics2D.gravity * CS.UnityEngine.Time.deltaTime
--~ 		velocity = velocity + p
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
			velocity.y = velocity.y + 1
		elseif CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.S and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
			velocity.y = velocity.y + -1
		end
		if CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.D and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
			velocity.x = velocity.x + 1
		elseif CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.A and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
			velocity.x = velocity.x + -1
		end
	end
	end
end

function ondestroy()
    print("lua destroy")
end

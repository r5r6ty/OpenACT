-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

require "castleDB"
utils = require 'tool1_utils'
require "tool1_LGUIBox"
require "tool1_LGUIWindow"
tool2_castleDB = require "tool2_castleDB"

require "LObject"

local filePath = CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/"

local perviewCamera = nil
local previewRenderTexture = nil

local too = false
local toxy = { x = 0, y = 0}

local LGUIWindowStack = {} -- �����б�
local focusWindowID = -1 -- ��ǰ�۽�����id

local toolWindowID = -1
local toolWindowPos = {x = 0, y = 0}


local settingsDB = {}
local charactersDB = {}

local texture2Ds = {}
local pics = {}

local categorys = {}

local displayingCharacterObject = nil
local PreviewCharacterObject = nil

local currentCharacter = nil
local defAction = {}
local defFrame = {}
local currentFrame = nil

local Dx = 0
local Dy = 0
local box = {x = 0, y = 0, w = 0, h = 0}

local zoom = 1

local display = true

local scale = 2

-- �������ߴ���
function createToolWindow(cx, cy, partDetail)
	-- ���ߴ���
	local w = LGUIWindow:new(utils.createid(LGUIWindowStack), "Tools", cx, cy, 100, 120, true, nil)
 	w:addToStacks(LGUIWindowStack)

	-- �����ڼ����¼�������ڴ����������Ƴ�����
	w.event = function()
		if (CS.UnityEngine.Event.current.button == 0 or CS.UnityEngine.Event.current.button == 1) then -- and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown
			local x = CS.UnityEngine.Input.mousePosition.x
			local y = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
			if x < w.x - 10 or y < w.y - 10 or x > w.x + w.w + 10 or y > w.y + w.h + 10 then
				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end
		end
	end
	-- ����۽��ڴ�����
	if focusWindowID < 0 then
--~ 		-- �����ı���
--~ 		local t1 = LGUITextField:new(utils.createid(LGUIWindowStack), w, "", "new window", 10, 20, 80, 20)
--~ 		w:addGUIpart(t1)
--~ 		local t2 = LGUITextField:new(utils.createid(LGUIWindowStack), w, "", "200", 10, 40, 40, 20)
--~ 		w:addGUIpart(t2)
--~ 		local t3 = LGUITextField:new(utils.createid(LGUIWindowStack), w, "", "200", 50, 40, 40, 20)
--~ 		w:addGUIpart(t3)
		-- ���밴ť
		local b1 = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "window", 10, 60, 80, 20)
		w:addGUIpart(b1)

		local e = function()
--~ 			local ww2 = tonumber(t2.context)
--~ 			local hh2 = tonumber(t3.context)
--~ 			if ww2 > CS.UnityEngine.Screen.width then
--~ 				ww2 = CS.UnityEngine.Screen.width
--~ 			end
--~ 			if hh2 > CS.UnityEngine.Screen.height then
--~ 				hh2 = CS.UnityEngine.Screen.height
--~ 			end
			local tw = LGUIWindow:new(utils.createid(LGUIWindowStack), "new window", w.x, w.y, 200, 200, true, nil)
			tw:addToStacks(LGUIWindowStack)

	--~ 		local twb1 = LGUIButton:new(utils.createid(LGUIWindowStack), "", "x", 0, 20, 20, 20)
	--~ 		tw:addGUIpart(twb1)
	--~ 		table.insert(b1.eventFunc, function()
	--~ 			LGUIWindowStack[tw.id] = nil
	--~ 		end)
	--~ 		table.insert(twb1.event1, {kind = "CW"})

	--~ 		local twt1 = LGUITextField:new(utils.createid(LGUIWindowStack), "", tw.title, 20,20, 80, 20)
	--~ 		tw:addGUIpart(twt1)
	--~ 		local twt2 = LGUITextField:new(utils.createid(LGUIWindowStack), "", tostring(tw.w), 100, 20, 40, 20)
	--~ 		tw:addGUIpart(twt2)
	--~ 		local twt3 = LGUITextField:new(utils.createid(LGUIWindowStack), "", tostring(tw.h), 140, 20, 40, 20)
	--~ 		tw:addGUIpart(twt3)

	--~ 		local twb2 = LGUIButton:new(utils.createid(LGUIWindowStack), "", "ok", 180, 20, 20, 20)
	--~ 		tw:addGUIpart(twb2)

	--~ 		table.insert(twb2.eventFunc, function()
	--~ 			tw.title = twt1.context
	--~ 			local ww = tonumber(twt2.context)
	--~ 			local hh = tonumber(twt3.context)
	--~ 			if ww > CS.UnityEngine.Screen.width then
	--~ 				ww = CS.UnityEngine.Screen.width
	--~ 			end
	--~ 			if hh > CS.UnityEngine.Screen.height then
	--~ 				hh = CS.UnityEngine.Screen.height
	--~ 			end
	--~ 			tw.w = ww
	--~ 			tw.h = hh

	--~ 			CS.UnityEngine.GUI.FocusControl("")
	--~ 		end)

			LGUIWindowStack[w.id] = nil
			toolWindowID = - 1
		end
		table.insert(b1.eventFunc, e)

	-- ����۽��ڴ�����
	else
		local valuef = nil
		if partDetail == nil then
			valuef = LGUIWindowStack[focusWindowID]
		else
			valuef = partDetail
		end
--~ 		if w.x > valuef.x and w.y > valuef.y and w.x < valuef.x + valuef.w and w.y < valuef.y + valuef.h then

			w.h = w.h + (w.h - 20) * 2

			w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "id", 10, 20, 40, 20))
			local Lid = LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", tostring(valuef.id), 50, 20, 40, 20)
			w:addGUIpart(Lid)

			local Tt = nil
			if partDetail == nil then

				w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "title", 10, 40, 40, 20))
				Tt = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", valuef.title, 50, 40, 40, 20)
				w:addGUIpart(Tt)
			else
				w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "context", 10, 40, 40, 20))
				Tt = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", valuef.context, 50, 40, 40, 20)
				w:addGUIpart(Tt)
			end

			w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "x", 10, 60, 40, 20))
			local Tx = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", tostring(valuef.x), 50, 60, 40, 20)
			w:addGUIpart(Tx)

			w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "y", 10, 80, 40, 20))
			local Ty = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", tostring(valuef.y), 50, 80, 40, 20)
			w:addGUIpart(Ty)

			w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "w", 10, 100, 40, 20))
			local Tw = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", tostring(valuef.w), 50, 100, 40, 20)
			w:addGUIpart(Tw)

			w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "h", 10, 120, 40, 20))
			local Th = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", tostring(valuef.h), 50, 120, 40, 20)
			w:addGUIpart(Th)

			local Tcd = nil
			if partDetail == nil then

				local canDragBool = "0"
				if valuef.canDrag then
					canDragBool = "1"
				end
				w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "canDrag", 10, 140, 40, 20))
				Tcd = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", canDragBool, 50, 140, 40, 20)
				w:addGUIpart(Tcd)
			else
				w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "pid", 10, 140, 40, 20))
				Tcd = LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", tostring(valuef.parent.id), 50, 140, 40, 20)
				w:addGUIpart(Tcd)

				print(valuef.parent.id, valuef.parent.x, valuef.parent.y)
			end

			w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "close", 10, 180, 40, 20))
			local Tclose = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", "", 50, 180, 40, 20)
			w:addGUIpart(Tclose)

			-- ���밴ť
			local b1 = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "confirm", 10, 160, 80, 20)
			w:addGUIpart(b1)
			table.insert(b1.eventFunc, function()
				valuef.x = tonumber(Tx.context)
				valuef.y = tonumber(Ty.context)
				valuef.w = tonumber(Tw.context)
				valuef.h = tonumber(Th.context)

				if partDetail == nil then
					valuef.title = Tt.context

					local temp = true
					if Tcd.context == "0" then
						temp = false
					end
					valuef.canDrag = temp

					if Tclose.context == "close" then
						LGUIWindowStack[valuef.id] = nil
					end
				else
					valuef.context = Tt.context

					if Tclose.context == "close" then
						print(valuef.id)
						print(valuef.parent.id)
						valuef.parent.guiParts[valuef.id] = nil
					end
				end

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)


			-- ���part����
			local px = nil
			local py = nil
			if partDetail == nil then
				px = w.x - valuef.x
				py = w.y - valuef.y
			else
--~ 				px = valuef.x
--~ 				py = valuef.y
				px = 0
				py = 0
			end

			-- ���밴ť
			local b_add_botton = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "botton", 10, 220, 80, 20)
			w:addGUIpart(b_add_botton)

			table.insert(b_add_botton.eventFunc, function()
				valuef:addGUIpart(LGUIButton:new(utils.createid(LGUIWindowStack), valuef, "", "botton", px, py, 80,20))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			-- ���밴ť
			local b_add_box = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "box", 10, 240, 80, 20)
			w:addGUIpart(b_add_box)

			table.insert(b_add_box.eventFunc, function()
				valuef:addGUIpart(LGUIBox:new(utils.createid(LGUIWindowStack), valuef, "", "box", px, py, 80, 80))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			-- ���밴ť
			local b_add_textField = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "textField", 10, 260, 80, 20)
			w:addGUIpart(b_add_textField)

			table.insert(b_add_textField.eventFunc, function()
				valuef:addGUIpart(LGUITextField:new(utils.createid(LGUIWindowStack), valuef, "", "textField", px, py, 80, 20))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			-- ���밴ť
			local b_add_label = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "label", 10, 280, 80, 20)
			w:addGUIpart(b_add_label)

			table.insert(b_add_label.eventFunc, function()
				valuef:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), valuef, "", "label", px, py, 80, 20))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			--���part�༭����

			local maxp = (w.h - 20) / 20
			local start_x = 110
			local start_y = 20
			local step_x = 100
			local step_y = 20

			local t = w.w

			local count = 0
			for i, v in pairs(valuef.guiParts) do
				local cw, cw2 = math.modf(count / maxp)
				w.w = t * (cw + 2)
				local ch = count % maxp
				local p = LGUIButton:new(utils.createid(LGUIWindowStack), w, "", v.LGUIType .. " " .. v.id, start_x + step_x * cw, start_y + step_y * ch, 80, 20)
				w:addGUIpart(p)

				count = count + 1

				table.insert(p.eventFunc, function()
					local x = CS.UnityEngine.Input.mousePosition.x
					local y = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
					local ttt = createToolWindow(x, y, v)
					toolWindowID = ttt.id

					LGUIWindowStack[w.id] = nil
					toolWindowID = - 1
				end)
			end

--~ 		end
	end

	return w
end



-- ��ȡframe�����
function localCategory()
end

function createSprites()
    for i, v in pairs(texture2Ds) do
        if pics[i] == nil then
            pics[i] = CS.UnityEngine.Sprite.Create(v, CS.UnityEngine.Rect(0, 0, v.width, v.height), CS.UnityEngine.Vector2(0, 1))
        end
	end
end


-- ������ʾ�ý�ɫ
function createCharacterDisplay(c, f, i)
	currentFrame = f
	if displayingCharacterObject ~= nil then
		CS.UnityEngine.GameObject.Destroy(displayingCharacterObject)
	end

	local display = true
	if f["pic"] == nil then
		display = false
		for nextpic = i, #defFrame, 1 do
			if defFrame[nextpic].category == "Sprite" then
				f = defFrame[nextpic]
				display = true
				break
			end
		end
	end

	if display then

--~ 		if pics[f["pic"]] == nil then
--~ 			pics[f["pic"]] = LoadImageToTexture2D(f["pic"])
--~ 		end

		local character = CS.UnityEngine.GameObject("tool1_character") -- c.id
		character.transform.position = CS.UnityEngine.Vector3(0, 0, 0)

--~ 		local pic = CS.UnityEngine.GameObject("pic")
--~ 		pic.transform.parent = character.transform
--~ 		local sr = pic:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
--~ 		sr.sprite = pics[f["pic"]]

		-- ��object����LuaBehaviour���
--~ 		local script = character:AddComponent(typeof(CS.XLuaTest.LuaBehaviour))
--~ 		local t = script.scriptEnv
--~ 		t.myFrame = f
--~ 		t.myPic = pic

		displayingCharacterObject = character

--~ 		t.myDrawField = {}
--~ 		local attackFound = false
--~ 		local bodyFound = false
--~ 		local attackEnd = false
--~ 		local bodyEnd = false
--~ 		for nextpic = i, 1, -1 do
--~ 			if defFrame[nextpic].category == "Attack" and attackEnd == false then
--~ 				local cur = 0.3
--~ 				if nextpic == i then
--~ 					cur = 0.5
--~ 				end
--~ 				table.insert(t.myDrawField, function()
--~ 					utils.drawField(defFrame[nextpic].x, defFrame[nextpic].y, defFrame[nextpic].width, defFrame[nextpic].height, CS.UnityEngine.Color(1, 0, 0, cur))
--~ 				end)
--~ 				attackFound = true
--~ 			elseif defFrame[nextpic].category == "Body" and bodyEnd == false then
--~ 				local cur = 0.3
--~ 				if nextpic == i then
--~ 					cur = 0.5
--~ 				end
--~ 				table.insert(t.myDrawField, function()
--~ 					utils.drawField(defFrame[nextpic].x, defFrame[nextpic].y, defFrame[nextpic].width, defFrame[nextpic].height, CS.UnityEngine.Color(0, 1, 0, cur))
--~ 				end)
--~ 				bodyFound = true
--~ 			elseif defFrame[nextpic].category == "Sprite" and nextpic ~= i then
--~ 				if attackEnd == true and bodyEnd == true then
--~ 					break
--~ 				end
--~ 				if attackFound then
--~ 					attackEnd = true
--~ 				end
--~ 				if bodyFound then
--~ 					bodyEnd = true
--~ 				end
--~ 			end
--~ 		end


	else
		displayingCharacterObject = nil
	end
end

function playAnimation()
	if PreviewCharacterObject ~= nil then
		CS.UnityEngine.GameObject.Destroy(PreviewCharacterObject)
	end

	local character = CS.UnityEngine.GameObject("tool1_character") -- c.id
	character.transform.position = CS.UnityEngine.Vector3(100, 0, 0)

--~ 	local pic = CS.UnityEngine.GameObject("pic")
--~ 	pic.transform.parent = character.transform
--~ 	local sr = pic:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
--~ 	sr.sprite = nil

	-- ��object����LuaBehaviour���
	local script = character:AddComponent(typeof(CS.XLuaTest.LuaBehaviour))
	local t = script.scriptEnv
	t.object = LObject:new(charactersDB.characters, pics, "ljokp", "shooting", 0, character, 0, 0)

	local character2 = CS.UnityEngine.GameObject("tool1_character") -- c.id
	character2.transform.position = CS.UnityEngine.Vector3(100, 0, 0)

	local script2 = character2:AddComponent(typeof(CS.XLuaTest.LuaBehaviour))
	local t2 = script2.scriptEnv
	t2.object = LObject:new(charactersDB.characters, pics, "ljokp", "shooting", 0, character2, 0, 0)

	PreviewCharacterObject = character
end

-- �������ߴ���
function createCharacterEditor()
	-- ��ȡsetting
	local setting = {}
    for i, v in ipairs(settingsDB:getLines("settings")) do
		local p = v["id"]
        if setting[p] == nil then
            setting[p] = v
        end
	end

	local characters = charactersDB:getLines("characters")
	-- ���ߴ���
	local toolsBarSetting = setting["ToolsBar"]
	local toolsBarWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "ToolsBar", toolsBarSetting.x, toolsBarSetting.y, toolsBarSetting.w, toolsBarSetting.h, true, nil)
 	toolsBarWindow:addToStacks(LGUIWindowStack)
	local previewButton = LGUIButton:new(utils.createid(LGUIWindowStack), frameWindow, "", ">", 10, 20, 20, 20)
	toolsBarWindow:addGUIpart(previewButton)
	previewButton.temp = -1
	table.insert(previewButton.eventFunc, function()
		local previewWindow = nil
		if previewButton.temp < 0 then
			previewButton.context = "*"

			local PreviewSetting = setting["Preview"]
			previewWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "Preview", PreviewSetting.x, PreviewSetting.y, PreviewSetting.w, PreviewSetting.h, true, nil)
			previewWindow:addToStacks(LGUIWindowStack)

			-- �����ڼ����¼�
			previewWindow.event = function()
				local x = CS.UnityEngine.Input.mousePosition.x
				local y = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
				if x > previewWindow.x and y > previewWindow.y and x < previewWindow.x + previewWindow.w and y < previewWindow.y + previewWindow.h then
					-- �м���ק�ƶ������
					if CS.UnityEngine.Input.GetMouseButtonDown(2) then

						Dx = CS.UnityEngine.Input.mousePosition.x
						Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
						if previewWindow.canDrag == true then
							previewWindow.canDrag = false
						end
					elseif CS.UnityEngine.Input.GetMouseButtonUp(2) then
						if previewWindow.canDrag == false then
							previewWindow.canDrag = true
						end
					elseif CS.UnityEngine.Input.GetMouseButton(2) then

						local x = Dx - CS.UnityEngine.Input.mousePosition.x
						local y = Dy - (CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y)

						local c_x = perviewCamera.transform.position.x + x / 100
						local c_y = perviewCamera.transform.position.y - y / 100

						perviewCamera.transform.position = CS.UnityEngine.Vector3(c_x, c_y, LMainCamera.transform.position.z)

						Dx = CS.UnityEngine.Input.mousePosition.x
						Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
					end
				else
					if previewWindow.canDrag == false then
						previewWindow.canDrag = true
					end
				end
			end

			local previewBox = LGUIBox:new(utils.createid(LGUIWindowStack), frameWindow, "", previewRenderTexture, 0 + 5, 0 + 20, PreviewSetting.w - 10, PreviewSetting.h - 25)
			previewWindow:addGUIpart(previewBox)
			previewBox.style = CS.UnityEngine.GUIStyle()
			previewBox.style.fixedWidth = previewRenderTexture.width
			previewBox.style.fixedHeight = previewRenderTexture.height
			previewBox.style.contentOffset = CS.UnityEngine.Vector2((-previewRenderTexture.width + previewWindow.w) / 2, (-previewRenderTexture.height + previewWindow.h) / 2 )

			previewButton.temp = previewWindow.id
			CS.UnityEngine.GUI.FocusWindow(previewWindow.id)

			playAnimation()
		else
			previewButton.context = ">"

			LGUIWindowStack[previewButton.temp] = nil
			toolWindowID = - 1

			previewButton.temp = -1

			if PreviewCharacterObject ~= nil then
				CS.UnityEngine.GameObject.Destroy(PreviewCharacterObject)
			end
		end
	end)
	local zoomInButton = LGUIButton:new(utils.createid(LGUIWindowStack), frameWindow, "", "+", 40 + 10, 20, 20, 20)
	toolsBarWindow:addGUIpart(zoomInButton)
	table.insert(zoomInButton.eventFunc, function()
		if zoom < 4 then
			zoom = zoom + 1
			local pCamera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))
			pCamera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom * scale
		end
	end)
	local zoomOutButton = LGUIButton:new(utils.createid(LGUIWindowStack), frameWindow, "", "-", 80 + 10, 20, 20, 20)
	toolsBarWindow:addGUIpart(zoomOutButton)
	table.insert(zoomOutButton.eventFunc, function()
		if zoom > 1 then
			zoom = zoom - 1
			local pCamera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))
			pCamera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom * scale
		end
	end)

	-- ��ɫ����
	local charactersSetting = setting["Characters"]
	local characterWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "Characters", charactersSetting.x, charactersSetting.y, charactersSetting.w, charactersSetting.h, true, nil)
 	characterWindow:addToStacks(LGUIWindowStack)

	for i, v in pairs(characters) do
		local p = LGUIButton:new(utils.createid(LGUIWindowStack), characterWindow, "", v.id, 10, 20 + (i - 1)  * 20, 80, 20)
		characterWindow:addGUIpart(p)

		table.insert(p.eventFunc, function()

			if currentCharacter ~= v then
				if displayingCharacterObject ~= nil then
					CS.UnityEngine.GameObject.Destroy(displayingCharacterObject)
				end
				currentCharacter = v
				defAction = currentCharacter.actions
				defFrame = {}
				currentFrame = nil
			end
		end)
	end

	-- ��ɫ��Ϣ����
	local characterInfoSetting = setting["CharacterInfo"]
	local characterInfoWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "CharacterInfo", characterInfoSetting.x, characterInfoSetting.y, characterInfoSetting.w, characterInfoSetting.h, true, nil)
 	characterInfoWindow:addToStacks(LGUIWindowStack)

	-- ֡��Ϣ����
	local FrameInfoSetting = setting["FrameInfo"]
	local frameInfoWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "FrameInfo", FrameInfoSetting.x, FrameInfoSetting.y, FrameInfoSetting.w, FrameInfoSetting.h, true, nil)
 	frameInfoWindow:addToStacks(LGUIWindowStack)

	frameInfoWindow.temp = defAction
	-- �����ڼ����¼�
	frameInfoWindow.event = function()
		if frameInfoWindow.temp ~= currentFrame then
			for i, v in pairs(frameInfoWindow.guiParts) do
				v = nil
				frameInfoWindow.guiParts[i] = nil
			end
			if currentFrame ~= nil then

				-- ��ʼ

				if currentFrame.category == "Sprite" then

					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "pic", 0 + 10, 20, 80, 20))
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", currentFrame.pic, 100 + 10, 20, 300, 20))

					-- centerX
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "centerX", 0 + 10, 20 + 20, 80, 20))
					local centerXTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.x), 100 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(centerXTF)
					-- event����������б仯�����Լ���contextҲ�仯������ʹ����=context
					table.insert(centerXTF.eventFunc, function()
						if centerXTF.context ~= "-" and centerXTF.context ~= "" then
							if CS.UnityEngine.GUI.changed then
								currentFrame.x = utils.stringToIntNumber(centerXTF.context)
							else
								centerXTF.context = utils.intNumberToString(currentFrame.x)
							end
						end
					end)

					-- centerY
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "centerY", 200 + 10, 20 + 20, 80, 20))
					local centerYTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.y), 300 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(centerYTF)
					-- event����������б仯�����Լ���contextҲ�仯������ʹ����=context
					table.insert(centerYTF.eventFunc, function()
						if centerYTF.context ~= "-" and centerYTF.context ~= "" then
							if CS.UnityEngine.GUI.changed then
								currentFrame.y = utils.stringToIntNumber(centerYTF.context)
							else
								centerYTF.context = utils.intNumberToString(currentFrame.y)
							end
						end
					end)

					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "wait", 0 + 10, 20 + 40, 80, 20))
					local waitTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.wait), 100 + 10, 20 + 40, 80, 20)
					frameInfoWindow:addGUIpart(waitTF)
					-- event��ʹ����=context
					table.insert(waitTF.eventFunc, function()
						currentFrame.wait = utils.stringToIntNumber(waitTF.context)
					end)
				elseif currentFrame.category == "Attack" or currentFrame.category == "Body" then
					-- x
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "x", 0 + 10, 20 + 20, 80, 20))
					local xTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.x), 100 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(xTF)
					-- event����������б仯�����Լ���contextҲ�仯������ʹ����=context
					table.insert(xTF.eventFunc, function()
						if xTF.context ~= "-" and xTF.context ~= "" then
							if CS.UnityEngine.GUI.changed then
								currentFrame.x = utils.stringToIntNumber(xTF.context)
							else
								xTF.context = utils.intNumberToString(currentFrame.x)
							end
						end
					end)
					-- y
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "y", 200 + 10, 20 + 20, 80, 20))
					local yTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.y), 300 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(yTF)
					-- event����������б仯�����Լ���contextҲ�仯������ʹ����=context
					table.insert(yTF.eventFunc, function()
						if yTF.context ~= "-" and yTF.context ~= "" then
							if CS.UnityEngine.GUI.changed then
								currentFrame.y = utils.stringToIntNumber(yTF.context)
							else
								yTF.context = utils.intNumberToString(currentFrame.y)
							end
						end
					end)
					-- width
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "width", 0 + 10, 20 + 40, 80, 20))
					local widthTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.width), 100 + 10, 20 + 40, 80, 20)
					frameInfoWindow:addGUIpart(widthTF)
					-- event����������б仯�����Լ���contextҲ�仯������ʹ����=context
					table.insert(widthTF.eventFunc, function()
						if widthTF.context ~= "-" and widthTF.context ~= "" then
							if CS.UnityEngine.GUI.changed then
								currentFrame.width = utils.stringToIntNumber(widthTF.context)
							else
								widthTF.context = utils.intNumberToString(currentFrame.width)
							end
						end
					end)
					-- height
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "height", 200 + 10, 20 + 40, 80, 20))
					local heightTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.height), 300 + 10, 20 + 40, 80, 20)
					frameInfoWindow:addGUIpart(heightTF)
					-- event����������б仯�����Լ���contextҲ�仯������ʹ����=context
					table.insert(heightTF.eventFunc, function()
						if heightTF.context ~= "-" and heightTF.context ~= "" then
							if CS.UnityEngine.GUI.changed then
								currentFrame.height = utils.stringToIntNumber(heightTF.context)
							else
								heightTF.context = utils.intNumberToString(currentFrame.height)
							end
						end
					end)
					if currentFrame.category == "Attack" then
						frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "damage", 0 + 10, 20 + 60, 80, 20))
						local damageTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.damage), 100 + 10, 20 + 60, 80, 20)
						frameInfoWindow:addGUIpart(damageTF)
						-- event��ʹ����=context
						table.insert(damageTF.eventFunc, function()
							if CS.UnityEngine.GUI.changed then
								currentFrame.damage = utils.stringToIntNumber(damageTF.context)
							end
						end)
					end
				elseif currentFrame.category == "Warp" then
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "nextAction", 0 + 10, 20, 80, 20))
					local nextActionTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", currentFrame.nextAction, 100 + 10, 20, 80, 20)
					frameInfoWindow:addGUIpart(nextActionTF)
					-- event��ʹ����=context
					table.insert(nextActionTF.eventFunc, function()
						if CS.UnityEngine.GUI.changed then
							currentFrame.nextAction = nextActionTF.context
						end
					end)
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", "nextFrame", 200 + 10, 20, 80, 20))
					local nextFrameTF = LGUITextField:new(utils.createid(LGUIWindowStack), frameInfoWindow, "", utils.intNumberToString(currentFrame.nextFrame), 300 + 10, 20, 80, 20)
					frameInfoWindow:addGUIpart(nextFrameTF)
					-- event��ʹ����=context
					table.insert(nextFrameTF.eventFunc, function()
						if CS.UnityEngine.GUI.changed then
							currentFrame.nextFrame = utils.stringToIntNumber(nextFrameTF.context)
						end
					end)
				end

				-- ����
			end

			frameInfoWindow.temp = currentFrame
		else
			if currentFrame ~= nil then
				if currentFrame.category == "Sprite" then
					-- �Ҽ���ק�ƶ�frame��centerX��centerY
					if currentFrame ~= nil then
						if CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then
							local world =  CS.UnityEngine.Camera.main:ScreenToWorldPoint(CS.UnityEngine.Input.mousePosition)
							Dx = world.x
							Dy = world.y

						elseif CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDrag then
							local world =  CS.UnityEngine.Camera.main:ScreenToWorldPoint(CS.UnityEngine.Input.mousePosition)

							local vx = math.floor((world.x - Dx) * 100 + 0.5)
							local vy = -math.floor((world.y - Dy) * 100 + 0.5)

							currentFrame.x = currentFrame.x + vx
							currentFrame.y = currentFrame.y + vy

							Dx = world.x
							Dy = world.y
						end
					end
				elseif currentFrame.category == "Attack" or currentFrame.category == "Body" then
					-- �Ҽ���ק�趨hitbox
					if currentFrame ~= nil then
						if CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then
							local world =  CS.UnityEngine.Camera.main:ScreenToWorldPoint(CS.UnityEngine.Input.mousePosition)

							box.x = math.floor(world.x * 100 + 0.5)
							box.y = -math.floor(world.y * 100 + 0.5)
							box.w = 0
							box.h = 0

						elseif CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDrag then

							local world =  CS.UnityEngine.Camera.main:ScreenToWorldPoint(CS.UnityEngine.Input.mousePosition)

							local vx = math.floor(world.x * 100 + 0.5) - box.x
							local vy = math.floor(-world.y * 100 + 0.5) - box.y

							box.w = vx
							box.h = vy

							-- ʹ��ȫ�ֱ���box���洢��ȥѡ��xywh��������ȡ�������ж�xy�Ƿ���Ҫ����wh�ķ�����б仯����Ϊwh������Ϊ����
							if box.x <= box.x + box.w then
								currentFrame.x = box.x
								currentFrame.width = box.w
							else
								currentFrame.x = box.x + box.w
								currentFrame.width = math.abs(box.w)
							end
							if box.y <= box.y + box.h then
								currentFrame.y = box.y
								currentFrame.height = box.h
							else
								currentFrame.y = box.y + box.h
								currentFrame.height = math.abs(box.h)
							end
						end
					end
				end
			end
		end
	end

	-- ������Ϣ����
	local actionsSetting = setting["Actions"]
	local actionWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "Actions", actionsSetting.x, actionsSetting.y, actionsSetting.w, actionsSetting.h, true, nil)
 	actionWindow:addToStacks(LGUIWindowStack)

	-- ��һ��ScrollView����ʾ���ܳ���������
	local actionsScrollView = LGUIScrollView:new(utils.createid(LGUIWindowStack), actionWindow, "", "", 0, 20, actionsSetting.w, actionsSetting.h - 20)
	actionWindow:addGUIpart(actionsScrollView)

	actionsScrollView.temp = defAction
	-- ��actionsScrollView�����¼�
	table.insert(actionsScrollView.eventFunc, function()
		if actionsScrollView.temp ~= defAction then
			for i, v in pairs(actionsScrollView.guiParts) do
				v = nil
				actionsScrollView.guiParts[i] = nil
			end
			local countH = 0
			for i, v in pairs(defAction) do
				local p = LGUIButton:new(utils.createid(LGUIWindowStack), actionsScrollView, "", v.action, 10, 0 + (i - 1)  * 20, 80, 20)
				actionsScrollView:addGUIpart(p)

		 		table.insert(p.eventFunc, function()
					defFrame = v.frames

					createCharacterDisplay(currentCharacter, v.frames[1], 1)
		 		end)
				countH = countH + 20
			end
			actionsScrollView.viewRect.height = countH
			actionsScrollView.temp = defAction
		end
	end)

	-- ֡����
	local FramesSetting = setting["Frames"]
	local frameWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "Frames", FramesSetting.x, FramesSetting.y, FramesSetting.w, FramesSetting.h, true, nil)
 	frameWindow:addToStacks(LGUIWindowStack)

	-- ��һ��ScrollView����ʾ���ܳ���������
	local framesScrollView = LGUIScrollView:new(utils.createid(LGUIWindowStack), frameWindow, "", "", 0, 20, FramesSetting.w, FramesSetting.h - 20)
	frameWindow:addGUIpart(framesScrollView)

	framesScrollView.temp = defAction
	-- ��framesScrollView�����¼�
	table.insert(framesScrollView.eventFunc, function()
		if framesScrollView.temp ~= defFrame then
			for i, v in pairs(framesScrollView.guiParts) do
				v = nil
				framesScrollView.guiParts[i] = nil
			end
			local countW = 0
			for i, v in pairs(defFrame) do
				local p = LGUIButton:new(utils.createid(LGUIWindowStack), framesScrollView, "", (i - 1) .. "\n" .. v.category, (i - 1) * 50, 0, 50, 50)
				framesScrollView:addGUIpart(p)

		 		table.insert(p.eventFunc, function()
					createCharacterDisplay(currentCharacter, v, i)
		 		end)
				countW = countW + 50
			end
			framesScrollView.viewRect.width = countW
			framesScrollView.temp = defFrame
		end
	end)

	return editorWindow
end

function start()
	print("lua start...")
    print("injected object", LMainCamera)

    settingsDB = castleDB:new(filePath, "setting.cdb")
    settingsDB:readDB()

    charactersDB = LCastleDBCharacter:new(filePath, "new.cdb")
	charactersDB:readDB()
	charactersDB:readIMG()
	texture2Ds = charactersDB:loadIMGToTexture2Ds()
	createSprites()

	localCategory()

	createCharacterEditor(0, 0)

	previewRenderTexture = CS.UnityEngine.RenderTexture(CS.UnityEngine.Screen.width, CS.UnityEngine.Screen.height, 0)
	previewRenderTexture.filterMode = CS.UnityEngine.FilterMode.Point

	local ppCamera = LMainCamera:GetComponent(typeof(CS.UnityEngine.Camera))
	ppCamera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 / zoom * scale
	-- ����һ���������Ԥ��
	perviewCamera = CS.UnityEngine.GameObject.Instantiate(LMainCamera)
	-- ɾ��ԭ�������AudioListener
	CS.UnityEngine.GameObject.Destroy(LMainCamera:GetComponent(typeof(CS.UnityEngine.AudioListener)))
	perviewCamera.transform.position = CS.UnityEngine.Vector3(perviewCamera.transform.position.x + 100, perviewCamera.transform.position.x, perviewCamera.transform.position.z)
	local pCamera = perviewCamera:GetComponent(typeof(CS.UnityEngine.Camera))
--~ 	pCamera.orthographicSize = CS.UnityEngine.Screen.height / 2 / 100 * scale
	pCamera.targetTexture = previewRenderTexture

	-- �������Ե�ͼ
	tool2_castleDB.new(filePath, "data2.cdb")

	local x = 0 - 5
	local y = 2
	local width = 10
	local height = 2
	local map = {}
    for i = x, x + width - 1, 1 do
		map[i] = {}
        for j = y, y + height - 1, 1 do
			map[i][j] = 1
        end
    end

	map[x - 1] = {}
	map[x - 1][y] = 2
	map[x + width] = {}
	map[x + width][y] = 2

	map[x][y - 1] = 1
	map[x + width - 1][y - 1] = 1


	tool2_castleDB.drawMap(map, 100, 0, 2)
--~ 	tool2_castleDB.gen()

	CS.UnityEngine.Physics2D.gravity = CS.UnityEngine.Physics2D.gravity * scale
end

function update()
end

function fixedupdate()
end

function ongui()
	if CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.Q and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
		if display then
			display = false
		else
			display = true
		end
	end
	if display == false then
		return
	end
	local count = 0
	for i, v in pairs(LGUIWindowStack) do
		count = count + 1
	end

 	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(60, 10, 200, 80), "LGUIWindowStack ".. count)

--~  	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(180, 10, 200, 80), "Focus ".. CS.UnityEngine.GUI.GetNameOfFocusedControl())

 	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(260, 10, 200, 80), "focusWindowID ".. focusWindowID)

 	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(400, 10, 200, 80), "toolWindowID ".. toolWindowID)

	-- �Ҽ����������༭����
	if CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.Space and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
		if toolWindowID < 0 then
			local x = CS.UnityEngine.Input.mousePosition.x
			local y = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y

			local ttt = createToolWindow(x, y, nil)

			toolWindowID = ttt.id

		end
	end

--~ 	if CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDrag then
--~ 		local p0 = LMainCamera.transform.position;
--~ 		local p01 = p0 - LMainCamera.transform.right * CS.UnityEngine.Input.GetAxisRaw("Mouse X") * 0.15 * CS.UnityEngine.Time.timeScale;
--~ 		local p03 = p01 - LMainCamera.transform.up * CS.UnityEngine.Input.GetAxisRaw("Mouse Y") * 0.15 * CS.UnityEngine.Time.timeScale;
--~ 		LMainCamera.transform.position = p03
--~ 	end

	-- �м���ק�ƶ������
	if CS.UnityEngine.Event.current.button == 2 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then

 		Dx = CS.UnityEngine.Input.mousePosition.x
 		Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y

	elseif CS.UnityEngine.Event.current.button == 2 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDrag then

		local x = Dx - CS.UnityEngine.Input.mousePosition.x
		local y = Dy - (CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y)

		local c_x = LMainCamera.transform.position.x + x / 100 / zoom
		local c_y = LMainCamera.transform.position.y - y / 100 / zoom

		LMainCamera.transform.position = CS.UnityEngine.Vector3(c_x, c_y, LMainCamera.transform.position.z)

 		Dx = CS.UnityEngine.Input.mousePosition.x
 		Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
	end

	if CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.KeypadEnter and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
		-- ����ԭ����.cdb�ļ�������
		local file2 = io.open(filePath .. "new.cdb", "r")
		io.input(file2)
		local file2_context = io.read("*a")
		io.close(file2)
		local file3 = io.open(filePath .. "new.cdb.bak", "w")
		file3:write(file2_context)
		file3:close()


		-- д��ԭ����.cdb�ļ�
		charactersDB:writeDB()
	end


	local id = nil
	-- ѭ����ʾ����
	for i, v in pairs(LGUIWindowStack) do
		id = v:show()
		if id ~= nil then
			focusWindowID = id
		end
	end

	-- ʧ��������°�id��Ϊ-1
	if (CS.UnityEngine.Event.current.button == 0 or CS.UnityEngine.Event.current.button == 1) and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then
		if id == nil then
			focusWindowID = -1
		end
	end

	-- ����ǰid������ʱ���Զ��۽���һ������
	if LGUIWindowStack[focusWindowID] == nil and focusWindowID ~= -1 then
		if #LGUIWindowStack > 0 then
--~ 			local tid = 0
--~ 			for i, v in pairs(LGUIWindowStack) do
--~ 				tid  = v.id
--~ 			end
--~ 			CS.UnityEngine.GUI.FocusWindow(tid)
--~ 			focusWindowID = tid
		else
			focusWindowID = -1
		end
	end
end

function ondestroy()
    print("lua destroy")
end











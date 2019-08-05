-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

utils = require 'tool1_utils'
--~ local util = require 'xlua.util'

require "tool1_LGUIBox"
require "tool1_LGUIWindow"
json = require "json"

local too = false
local toxy = { x = 0, y = 0}

local LGUIWindowStack = {} -- 窗口列表
local focusWindowID = -1 -- 当前聚焦窗口id

local toolWindowID = -1
local toolWindowPos = {x = 0, y = 0}

local settingsDB = {}

local charactersDB = {}
local imagesDB = {}
local texture2Ds = {}
local pics = {}

local categorys = {}

local displayingCharacterObject = nil

local currentCharacter = nil
local defAction = {}
local defFrame = {}
local currentFrame = nil

local Dx = 0
local Dy = 0

-- 从.img加载图片做成texture2D然后直接生成sprite
function LoadImageToTexture2D(index)
	local temp = utils.split(imagesDB[index], ",")
	temp = temp[#temp]
	local mod4 = #temp % 4
	if mod4 > 0 then
		for i = 1, 4 - mod4, 1 do
			temp = temp .. "="
		end
	end

--~ 	print("str " .. #temp)

	local bytes = CS.System.Convert.FromBase64String(temp)

--~ 	print(#bytes)
--~     for i, v in ipairs(bytes) do
--~ 		print(v)
--~ 	end

--~ 	print("waaaaaaaaaaaaaaaaaaaaaaaaa")


	-- 加载图片
	local texture = CS.UnityEngine.Texture2D(0, 0, CS.UnityEngine.TextureFormat.RGBA32, false, false)
	texture.filterMode = CS.UnityEngine.FilterMode.Point
--~ 	CS.UnityEngine.ImageConversion.LoadImage(texture, bytes) -- 这个怎么不行了？
	texture:LoadImage(bytes) --- Texture2d  成员方法无法使用，为什么？为什么又能使用了？
	table.insert(texture2Ds, texture)

	local x = 0
	local y = 0

	local sprite = CS.UnityEngine.Sprite.Create(texture, CS.UnityEngine.Rect(x, y, texture.width, texture.height), CS.UnityEngine.Vector2(0, 1))

--~ 	local test_object = CS.UnityEngine.GameObject("test")
--~ 	test_object.transform.localPosition = CS.UnityEngine.Vector3(0, 0, 0)
--~ 	local sr = test_object:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
--~ 	sr.sprite = sprite


	return sprite
end

-- 构建工具窗口
function createToolWindow(cx, cy, partDetail)
	-- 工具窗口
	local w = LGUIWindow:new(utils.createid(LGUIWindowStack), "Tools", cx, cy, 100, 120, true, nil)
 	w:addToStacks(LGUIWindowStack)

	-- 给窗口加入事件，鼠标在窗口外点击则移除窗口
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
	-- 如果聚焦在窗口上
	if focusWindowID < 0 then
--~ 		-- 加入文本框
--~ 		local t1 = LGUITextField:new(utils.createid(LGUIWindowStack), w, "", "new window", 10, 20, 80, 20)
--~ 		w:addGUIpart(t1)
--~ 		local t2 = LGUITextField:new(utils.createid(LGUIWindowStack), w, "", "200", 10, 40, 40, 20)
--~ 		w:addGUIpart(t2)
--~ 		local t3 = LGUITextField:new(utils.createid(LGUIWindowStack), w, "", "200", 50, 40, 40, 20)
--~ 		w:addGUIpart(t3)
		-- 加入按钮
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

	-- 如果聚焦在窗口上
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

				local canDrawBool = "0"
				if valuef.canDraw then
					canDrawBool = "1"
				end
				w:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), nil, "", "canDraw", 10, 140, 40, 20))
				Tcd = LGUITextField:new(utils.createid(LGUIWindowStack), nil, "", canDrawBool, 50, 140, 40, 20)
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

			-- 加入按钮
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
					valuef.canDraw = temp

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


			-- 添加part部分
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

			-- 加入按钮
			local b_add_botton = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "botton", 10, 220, 80, 20)
			w:addGUIpart(b_add_botton)

			table.insert(b_add_botton.eventFunc, function()
				valuef:addGUIpart(LGUIButton:new(utils.createid(LGUIWindowStack), valuef, "", "botton", px, py, 80,20))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			-- 加入按钮
			local b_add_box = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "box", 10, 240, 80, 20)
			w:addGUIpart(b_add_box)

			table.insert(b_add_box.eventFunc, function()
				valuef:addGUIpart(LGUIBox:new(utils.createid(LGUIWindowStack), valuef, "", "box", px, py, 80, 80))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			-- 加入按钮
			local b_add_textField = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "textField", 10, 260, 80, 20)
			w:addGUIpart(b_add_textField)

			table.insert(b_add_textField.eventFunc, function()
				valuef:addGUIpart(LGUITextField:new(utils.createid(LGUIWindowStack), valuef, "", "textField", px, py, 80, 20))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			-- 加入按钮
			local b_add_label = LGUIButton:new(utils.createid(LGUIWindowStack), nil, "", "label", 10, 280, 80, 20)
			w:addGUIpart(b_add_label)

			table.insert(b_add_label.eventFunc, function()
				valuef:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), valuef, "", "label", px, py, 80, 20))

				LGUIWindowStack[w.id] = nil
				toolWindowID = - 1
			end)

			--添加part编辑部分

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



-- 读取frame的类别
function localCategory()
end

-- 读取frame中的pic
function loadPic(data)
    for i, v in ipairs(data) do
		local p = v["pic"]
        if pics[p] == nil then
            pics[p] = LoadImageToTexture2D(p)
        end
--~ 		print(i)
	end
end

-- 构建显示用角色
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

		if pics[f["pic"]] == nil then
			pics[f["pic"]] = LoadImageToTexture2D(f["pic"])
		end

		local character = CS.UnityEngine.GameObject("tool1_character") -- c.id
		character.transform.localPosition = CS.UnityEngine.Vector3(0, 0, 0)

		local pic = CS.UnityEngine.GameObject("pic")
		pic.transform.parent = character.transform
		local sr = pic:AddComponent(typeof(CS.UnityEngine.SpriteRenderer))
		sr.sprite = pics[f["pic"]]

		-- 给object挂上LuaBehaviour组件
		local script = character:AddComponent(typeof(CS.XLuaTest.LuaBehaviour))
		local t = script.scriptEnv
		t.myFrame = f
		t.myPic = pic

		displayingCharacterObject = character

		t.myDrawField = {}
		local attackFound = false
		local bodyFound = false
		local attackEnd = false
		local bodyEnd = false
		for nextpic = i, 1, -1 do
			if defFrame[nextpic].category == "Attack" and attackEnd == false then
				local cur = 0.3
				if nextpic == i then
					cur = 0.5
				end
				table.insert(t.myDrawField, function()
					utils.drawField(defFrame[nextpic].x, defFrame[nextpic].y, defFrame[nextpic].width, defFrame[nextpic].height, CS.UnityEngine.Color(1, 0, 0, cur))
				end)
				attackFound = true
			elseif defFrame[nextpic].category == "Body" and bodyEnd == false then
				local cur = 0.3
				if nextpic == i then
					cur = 0.5
				end
				table.insert(t.myDrawField, function()
					utils.drawField(defFrame[nextpic].x, defFrame[nextpic].y, defFrame[nextpic].width, defFrame[nextpic].height, CS.UnityEngine.Color(0, 1, 0, cur))
				end)
				bodyFound = true
			elseif defFrame[nextpic].category == "Sprite" and nextpic ~= i then
				if attackEnd == true and bodyEnd == true then
					break
				end
				if attackFound then
					attackEnd = true
				end
				if bodyFound then
					bodyEnd = true
				end
			end
		end


	else
		displayingCharacterObject = nil
	end
end

-- 构建工具窗口
function createCharacterEditor()
	-- 读取setting
	local setting = {}
    for i, v in ipairs(settingsDB["sheets"][1]["lines"]) do
		local p = v["id"]
        if setting[p] == nil then
            setting[p] = v
        end
	end

	local characters = charactersDB["sheets"][1]["lines"]
	-- 工具窗口
	local toolsBarSetting = setting["ToolsBar"]
	local toolsBarWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "ToolsBar", toolsBarSetting.x, toolsBarSetting.y, toolsBarSetting.w, toolsBarSetting.h, true, nil)
 	toolsBarWindow:addToStacks(LGUIWindowStack)
	toolsBarWindow:addGUIpart(LGUIButton:new(utils.createid(LGUIWindowStack), frameWindow, "", ">", 10, 20, 20, 20))

	-- 角色窗口
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

	-- 角色信息窗口
	local characterInfoSetting = setting["CharacterInfo"]
	local characterInfoWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "CharacterInfo", characterInfoSetting.x, characterInfoSetting.y, characterInfoSetting.w, characterInfoSetting.h, true, nil)
 	characterInfoWindow:addToStacks(LGUIWindowStack)

	-- 帧信息窗口
	local FrameInfoSetting = setting["FrameInfo"]
	local frameInfoWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "FrameInfo", FrameInfoSetting.x, FrameInfoSetting.y, FrameInfoSetting.w, FrameInfoSetting.h, true, nil)
 	frameInfoWindow:addToStacks(LGUIWindowStack)

	frameInfoWindow.temp = defAction
	-- 给窗口加入事件
	frameInfoWindow.event = function()
		if frameInfoWindow.temp ~= currentFrame then
			for i, v in pairs(frameInfoWindow.guiParts) do
				v = nil
				frameInfoWindow.guiParts[i] = nil
			end
			if currentFrame ~= nil then

				-- 开始

				if currentFrame.category == "Sprite" then

					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "pic", 0 + 10, 20, 80, 20))
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", currentFrame.pic, 100 + 10, 20, 300, 20))

					-- centerX
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "centerX", 0 + 10, 20 + 20, 80, 20))
					local centerXTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.x), 100 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(centerXTF)
					centerXTF.temp = utils.intNumberToString(currentFrame.x)
					-- event，如果数据有变化，则自己的context也变化，否则使数据=context
					table.insert(centerXTF.eventFunc, function()
						local value = utils.intNumberToString(currentFrame.x)
						if centerXTF.temp ~= value then
							centerXTF.context = value
							centerXTF.temp = value
						else
							if centerXTF.context ~= "-" then
								currentFrame.x = utils.stringToIntNumber(centerXTF.context)
							end
						end
					end)

					-- centerY
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "centerY", 200 + 10, 20 + 20, 80, 20))
					local centerYTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.y), 300 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(centerYTF)
					centerYTF.temp = utils.intNumberToString(currentFrame.y)
					-- event，如果数据有变化，则自己的context也变化，否则使数据=context
					table.insert(centerYTF.eventFunc, function()
						local value = utils.intNumberToString(currentFrame.y)
						if centerYTF.temp ~= value then
							centerYTF.context = value
							centerYTF.temp = value
						else
							if centerYTF.context ~= "-" then
								currentFrame.y = utils.stringToIntNumber(centerYTF.context)
							end
						end
					end)

					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "wait", 0 + 10, 20 + 40, 80, 20))
					frameInfoWindow:addGUIpart(LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.wait), 100 + 10, 20 + 40, 80, 20))
				elseif currentFrame.category == "Attack" or currentFrame.category == "Body" then
					-- x
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "x", 0 + 10, 20 + 20, 80, 20))
					local xTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.x), 100 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(xTF)
					xTF.temp = utils.intNumberToString(currentFrame.x)
					-- event，如果数据有变化，则自己的context也变化，否则使数据=context
					table.insert(xTF.eventFunc, function()
						local value = utils.intNumberToString(currentFrame.x)
						if xTF.temp ~= value then
							xTF.context = value
							xTF.temp = value
						else
							if xTF.context ~= "-" then
								currentFrame.x = utils.stringToIntNumber(xTF.context)
							end
						end
					end)
					-- y
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "y", 200 + 10, 20 + 20, 80, 20))
					local yTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.y), 300 + 10, 20 + 20, 80, 20)
					frameInfoWindow:addGUIpart(yTF)
					yTF.temp = utils.intNumberToString(currentFrame.y)
					-- event，如果数据有变化，则自己的context也变化，否则使数据=context
					table.insert(yTF.eventFunc, function()
						local value = utils.intNumberToString(currentFrame.y)
						if yTF.temp ~= value then
							yTF.context = value
							yTF.temp = value
						else
							if yTF.context ~= "-" then
								currentFrame.y = utils.stringToIntNumber(yTF.context)
							end
						end
					end)
					-- width
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "width", 0 + 10, 20 + 40, 80, 20))
					local widthTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.width), 100 + 10, 20 + 40, 80, 20)
					frameInfoWindow:addGUIpart(widthTF)
					widthTF.temp = utils.intNumberToString(currentFrame.width)
					-- event，如果数据有变化，则自己的context也变化，否则使数据=context
					table.insert(widthTF.eventFunc, function()
						local value = utils.intNumberToString(currentFrame.width)
						if widthTF.temp ~= value then
							widthTF.context = value
							widthTF.temp = value
						else
							if widthTF.context ~= "-" then
								currentFrame.width = utils.stringToIntNumber(widthTF.context)
							end
						end
					end)
					-- height
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "height", 200 + 10, 20 + 40, 80, 20))
					local heightTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.height), 300 + 10, 20 + 40, 80, 20)
					frameInfoWindow:addGUIpart(heightTF)
					heightTF.temp = utils.intNumberToString(currentFrame.height)
					-- event，如果数据有变化，则自己的context也变化，否则使数据=context
					table.insert(heightTF.eventFunc, function()
						local value = utils.intNumberToString(currentFrame.height)
						if heightTF.temp ~= value then
							heightTF.context = value
							heightTF.temp = value
						else
							if heightTF.context ~= "-" then
								currentFrame.height = utils.stringToIntNumber(heightTF.context)
							end
						end
					end)
				elseif currentFrame.category == "Warp" then
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "nextAction", 0 + 10, 20, 80, 20))
					local nextActionTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", currentFrame.nextAction, 100 + 10, 20, 80, 20)
					frameInfoWindow:addGUIpart(nextActionTF)
					-- event，使数据=context
					table.insert(nextActionTF.eventFunc, function()
						currentFrame.nextAction = nextActionTF.context
					end)
					frameInfoWindow:addGUIpart(LGUILabel:new(utils.createid(LGUIWindowStack), characterWindow, "", "nextFrame", 200 + 10, 20, 80, 20))
					local nextFrameTF = LGUITextField:new(utils.createid(LGUIWindowStack), characterWindow, "", utils.intNumberToString(currentFrame.nextFrame), 300 + 10, 20, 80, 20)
					frameInfoWindow:addGUIpart(nextFrameTF)
					-- event，使数据=context
					table.insert(nextFrameTF.eventFunc, function()
						currentFrame.nextFrame = utils.stringToIntNumber(nextFrameTF.context)
					end)
				end

				-- 结束
			end

			frameInfoWindow.temp = currentFrame
		else
			if currentFrame ~= nil then
				if currentFrame.category == "Sprite" then
					-- 右键拖拽移动frame的centerX和centerY
					if currentFrame ~= nil then
						if CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then

							Dx = CS.UnityEngine.Input.mousePosition.x
							Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y

						elseif CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDrag then

							local x = Dx - CS.UnityEngine.Input.mousePosition.x
							local y = Dy - (CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y)

							local c_x = currentFrame.x - x
							local c_y = currentFrame.y - y

							currentFrame.x = c_x
							currentFrame.y = c_y

							Dx = CS.UnityEngine.Input.mousePosition.x
							Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
						end
					end
				elseif currentFrame.category == "Attack" or currentFrame.category == "Body" then
					-- 右键拖拽移动frame的centerX和centerY
					if currentFrame ~= nil then
						if CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then

--~ 							Dx = CS.UnityEngine.Input.mousePosition.x
--~ 							Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y

							local world =  CS.UnityEngine.Camera.main:ScreenToWorldPoint(CS.UnityEngine.Input.mousePosition)
							Dx = world.x
							Dy = world.y

							local ax, bx = math.modf(Dx * 100)
							local ay, by = math.modf(Dy * 100)
							currentFrame.x = ax
							currentFrame.y = ay
							currentFrame.width = 0
							currentFrame.height = 0

						elseif CS.UnityEngine.Event.current.button == 1 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDrag then

							local world =  CS.UnityEngine.Camera.main:ScreenToWorldPoint(CS.UnityEngine.Input.mousePosition)
							local x = Dx - world.x * 100
							local y = Dy - world.y * 100

							local ax, bx = math.modf(x)
							local ay, by = math.modf(y)
							currentFrame.width = -(ax + currentFrame.x)
							currentFrame.height = ay + currentFrame.y

							Dx = world.x
							Dy = world.y

							print(currentFrame.x ,currentFrame.y ,currentFrame.width ,currentFrame.height)
						end
					end
				end
			end
		end
	end

	-- 动作信息窗口
	local ActionsSetting = setting["Actions"]
	local actionWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "Actions", ActionsSetting.x, ActionsSetting.y, ActionsSetting.w, ActionsSetting.h, true, nil)
 	actionWindow:addToStacks(LGUIWindowStack)

	actionWindow.temp = defAction
	-- 给窗口加入事件
	actionWindow.event = function()
		if actionWindow.temp ~= defAction then
			for i, v in pairs(actionWindow.guiParts) do
				v = nil
				actionWindow.guiParts[i] = nil
			end
			for i, v in pairs(defAction) do
				local p = LGUIButton:new(utils.createid(LGUIWindowStack),actionWindow, "", v.action, 10, 20 + (i - 1)  * 20, 80, 20)
				actionWindow:addGUIpart(p)

		 		table.insert(p.eventFunc, function()
					defFrame = v.frames

					createCharacterDisplay(currentCharacter, v.frames[1], 1)
		 		end)
			end
			actionWindow.temp = defAction
		end
	end

	-- 帧窗口
	local FramesSetting = setting["Frames"]
	local frameWindow = LGUIWindow:new(utils.createid(LGUIWindowStack), "Frames", FramesSetting.x, FramesSetting.y, FramesSetting.w, FramesSetting.h, true, nil)
 	frameWindow:addToStacks(LGUIWindowStack)

	frameWindow.temp = defAction
	-- 给窗口加入事件
	frameWindow.event = function()
		if frameWindow.temp ~= defFrame then
			for i, v in pairs(frameWindow.guiParts) do
				v = nil
				frameWindow.guiParts[i] = nil
			end

			for i, v in pairs(defFrame) do
				local p = LGUIButton:new(utils.createid(LGUIWindowStack), frameWindow, "", v.category, (i - 1) * 50, 20, 50, 50)
				frameWindow:addGUIpart(p)

		 		table.insert(p.eventFunc, function()
					createCharacterDisplay(currentCharacter, v, i)
		 		end)
			end
			frameWindow.temp = defFrame

			if #defFrame > 0 then
				local frameWindowHorizontalScrollbar = LGUIHorizontalScrollbar:new(utils.createid(LGUIWindowStack), characterWindow, "", 0, 0, 70, FramesSetting.w, 20, 1, 0, 10)
				frameWindow:addGUIpart(frameWindowHorizontalScrollbar)
			end
		end
	end

	return editorWindow
end

function start()
	print("lua start...")
    print("injected object", LMainCamera)

--~     local file = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "file_read_and_write.txt", "r")
--~     io.input(file)
--~     local str = io.read("*a")
--~     io.close(file)
--~     local data = json.decode(str)

--~ 	for i, v in pairs(data) do
--~ 		local win = LGUIWindow:new(v["id"], v["title"], v["x"], v["y"], v["w"], v["h"], v["canDraw"], nil)
--~ 		win:addToStacks(LGUIWindowStack)

--~ 		for i2, v2 in pairs(v["guiParts"]) do
--~ 			local p = nil
--~ 			if v2["LGUIType"] == "LGUIBox" then
--~ 				p = LGUIBox:new(v2["id"], nil, v2["title"], v2["context"], v2["x"], v2["y"], v2["w"], v2["h"])
--~ 			elseif v2["LGUIType"] == "LGUIButton" then
--~ 				p = LGUIButton:new(v2["id"], nil, v2["title"], v2["context"], v2["x"], v2["y"], v2["w"], v2["h"])
--~ 			elseif v2["LGUIType"] == "LGUITextField" then
--~ 				p = LGUITextField:new(v2["id"], nil, v2["title"], v2["context"], v2["x"], v2["y"], v2["w"], v2["h"])
--~ 			elseif v2["LGUIType"] == "LGUILabel" then
--~ 				p = LGUILabel:new(v2["id"], nil, v2["title"], v2["context"], v2["x"], v2["y"], v2["w"], v2["h"])
--~ 			end
--~ 			if p ~= nil then
--~ 				win:addGUIpart(p)
--~ 			end

--~ 			-- 处理event
--~ 			local event = v2["event1"]
--~ 			if event ~= nil then
--~ 				for i = 1, #event, 1 do
--~ 					if event[i]["kind"] == "NW" then
--~ 						local e = function()
--~ 							LGUIWindow:new(utils.createid(LGUIWindowStack), "no title", win.x, win.y, 100, 150, true, nil)
--~ 						end
--~ 						table.insert(p.eventFunc, e)
--~ 					end
--~ 					if event[i]["kind"] == "CW" then
--~ 						local e = function()
--~ 							LGUIWindowStack[win.id] = nil
--~ 							toolWindowID = - 1
--~ 						end
--~ 						table.insert(p.eventFunc, e)
--~ 					end
--~ 					if event[i]["kind"] == "R" then
--~ 						if event[i]["context"] == "context" then
--~ 							local e = function()
--~ 								p.context = utils.getObject(event[i]["id"], LGUIWindowStack).context
--~ 							end
--~ 							table.insert(p.eventFunc, e)
--~ 						end
--~ 					end
--~ 				end
--~ 			end


--~ 		end
--~ 	end
--~ 	print("json read!")

    local file3 = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "setting.cdb", "r")
    io.input(file3)
    local str3 = io.read("*a")
    io.close(file3)
    settingsDB = json.decode(str3)

	print("json read! ")

    local file = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "new.cdb", "r")
    io.input(file)
    local str = io.read("*a")
    io.close(file)
    charactersDB = json.decode(str)

	print("json read! ")

    local file2 = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "new.img", "r")
    io.input(file2)
    local str2 = io.read("*a")
    io.close(file2)
    imagesDB = json.decode(str2)

	print("json read! ")

	localCategory(charactersDB["sheets"][4])

	createCharacterEditor(0, 0)
end

function update()
end

function fixedupdate()
end

function ongui()
	local count = 0
	for i, v in pairs(LGUIWindowStack) do
		count = count + 1
	end

 	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(60, 10, 200, 80), "LGUIWindowStack ".. count)

--~  	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(180, 10, 200, 80), "Focus ".. CS.UnityEngine.GUI.GetNameOfFocusedControl())

 	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(260, 10, 200, 80), "focusWindowID ".. focusWindowID)

 	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(400, 10, 200, 80), "toolWindowID ".. toolWindowID)

	-- 右键单击弹出编辑窗口
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

	-- 中键拖拽移动摄像机
	if CS.UnityEngine.Event.current.button == 2 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then

 		Dx = CS.UnityEngine.Input.mousePosition.x
 		Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y

	elseif CS.UnityEngine.Event.current.button == 2 and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDrag then

		local x = Dx - CS.UnityEngine.Input.mousePosition.x
		local y = Dy - (CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y)

		local c_x = LMainCamera.transform.position.x + x / 100
		local c_y = LMainCamera.transform.position.y - y / 100

		LMainCamera.transform.position = CS.UnityEngine.Vector3(c_x, c_y, LMainCamera.transform.position.z)

 		Dx = CS.UnityEngine.Input.mousePosition.x
 		Dy = CS.UnityEngine.Screen.height - CS.UnityEngine.Input.mousePosition.y
	end

	if CS.UnityEngine.Event.current.keyCode == CS.UnityEngine.KeyCode.KeypadEnter and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.KeyDown then
		-- 复制原来的.cdb文件做备份
		local file2 = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "new.cdb", "r")
		io.input(file2)
		local file2_context = io.read("*a")
		io.close(file2)
		local file3 = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "new.cdb.bak", "w")
		file3:write(file2_context)
		file3:close()


		-- 写入原来的.cdb文件
		local data = json.encode(charactersDB)
		local file = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/1/Resource/" .. "new.cdb", "w")
		file:write(data)
		file:close()

		print("json writed!")
	end


	local id = nil
	-- 循环显示窗口
	for i, v in pairs(LGUIWindowStack) do
		id = v:show()
		if id ~= nil then
			focusWindowID = id
		end
	end

	-- 失焦的情况下把id设为-1
	if (CS.UnityEngine.Event.current.button == 0 or CS.UnityEngine.Event.current.button == 1) and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then
		if id == nil then
			focusWindowID = -1
		end
	end

	-- 当当前id不存在时，自动聚焦第一个窗口
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











-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

-- 类的声明，这里声明了类名还有属性，并且给出了属性的初始值
LGUIWindow = {id = nil, title = nil, x = nil, y = nil, w = nil, h = nil, guiParts = nil, canDraw = nil, t = nil, event = nil}
-- 设置元表的索引，想模拟类的话，这步操作很关键
LGUIWindow.__index = LGUIWindow
-- 构造方法new
function LGUIWindow:new(id, title, x, y, w, h, cd, e)
    local self = {}  --初始化self，如果没有这句，那么类所建立的对象如果有一个改变，其他对象都会改变
    setmetatable(self, LGUIWindow)  --将self的元表设定为Class
    self.id = id
    self.title = title
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.guiParts = {}
	self.canDraw = cd
	self.t = nil
	self.event = e

    return self  --返回自身
end

-- 绘制窗口
function LGUIWindow:show()
	-- 不允许超出屏幕
	if self.x < 0 then
		self.x = 0
	elseif self.y < 0 then
		self.y = 0
	elseif self.x + self.w > CS.UnityEngine.Screen.width then
		self.x = CS.UnityEngine.Screen.width - self.w
	elseif self.y + self.h > CS.UnityEngine.Screen.height then
		self.y = CS.UnityEngine.Screen.height - self.h
	end

	-- 绘制窗口
	local rect = CS.UnityEngine.GUI.Window(self.id, CS.UnityEngine.Rect(self.x, self.y, self.w, self.h), function(id)
		-- 当鼠标点击本窗口，则返回窗口id
		if (CS.UnityEngine.Event.current.button == 0 or CS.UnityEngine.Event.current.button == 1) and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then
			self.t = id
		else
			if self.t ~= nil then
				self.t = nil
			end
		end

		-- 绘制guiparts
		if self.guiParts ~= nil then
			for i, v in pairs(self.guiParts) do
				v:show()
			end
		end
		-- 能否拖拽
		if self.canDraw then
			CS.UnityEngine.GUI.DragWindow(CS.UnityEngine.Rect(0, 0, self.w, self.h))
		end
	end, self.title)
	self.x = rect.x
	self.y = rect.y
	self.w = rect.width
	self.h = rect.height

	-- 执行event
	if self.event ~= nil then
		self.event()
	end

	return self.t
end

function LGUIWindow:addToStacks(s)
	s[self.id] = self
end

-- 添加parts
function LGUIWindow:addGUIpart(p)
	self.guiParts[p.id] = p
end




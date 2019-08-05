-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

require 'tool1_LGUIPart'

-- ���ο�
LGUIBox = {}
--����Ԫ��ΪClass
setmetatable(LGUIBox, LGUIPart)
--���Ǻ��ඨ��һ�����������趨Ϊ����
LGUIBox.__index = LGUIBox
--�����ǹ��췽��
function LGUIBox:new(id, p, title, c, x, y, w, h)
   local self = {}             --��ʼ����������
   self = LGUIPart:new(id, p, title, c, x, y, w, h)       --�����������趨Ϊ���࣬�������൱���������Ե�super ���������Ϊ���ø���Ĺ��캯��
   setmetatable(self, LGUIBox)    --����������Ԫ���趨ΪSubClass��
   self.LGUIType = "LGUIBox"
   return self
end

function LGUIBox:show()
	local x = self.x
	local y = self.y
	if self.parent ~= nil and self.parent.LGUIType ~= nil then
		-- ������������
--~ 		if self.x < self.parent.x then
--~ 			self.x = self.parent.x
--~ 		elseif self.y < self.parent.y then
--~ 			self.y = self.parent.y
--~ 		elseif self.x + self.w > self.parent.w then
--~ 			self.x = self.parent.w - self.w
--~ 		elseif self.y + self.h > self.parent.h then
--~ 			self.y = self.parent.h - self.h
--~ 		end

		x = x + self.parent.x
		y = y + self.parent.y
	end
	CS.UnityEngine.GUI.Box(CS.UnityEngine.Rect(x, y, self.w, self.h), self.context)
	for i, v in ipairs(self.eventFunc) do
		if v ~= nil then
			v()
		end
	end
	-- ����guiparts
	if self.guiParts ~= nil then
		for i, v in pairs(self.guiParts) do
			v:show()
		end
	end
end

-- ��ť
LGUIButton = {}
setmetatable(LGUIButton, LGUIPart)
LGUIButton.__index = LGUIButton
function LGUIButton:new(id, p, title, c, x, y, w, h)
   local self = {}
   self = LGUIPart:new(id, p, title, c, x, y, w, h)
   setmetatable(self, LGUIButton)
   self.LGUIType = "LGUIButton"
   return self
end

function LGUIButton:show()
	local x = self.x
	local y = self.y
	if self.parent ~= nil and self.parent.LGUIType ~= nil then
		-- ������������
--~ 		if self.x < self.parent.x then
--~ 			self.x = self.parent.x
--~ 		elseif self.y < self.parent.y then
--~ 			self.y = self.parent.y
--~ 		elseif self.x + self.w > self.parent.w then
--~ 			self.x = self.parent.w - self.w
--~ 		elseif self.y + self.h > self.parent.h then
--~ 			self.y = self.parent.h - self.h
--~ 		end

		x = x + self.parent.x
		y = y+ self.parent.y
	end
	if CS.UnityEngine.GUI.Button(CS.UnityEngine.Rect(x, y, self.w, self.h), self.context) then
		for i, v in ipairs(self.eventFunc) do
			if v ~= nil then
				v()
			end
		end
	end
	-- ����guiparts
	if self.guiParts ~= nil then
		for i, v in pairs(self.guiParts) do
			v:show()
		end
	end
end

-- ���������
LGUITextField = {}
setmetatable(LGUITextField, LGUIPart)
LGUITextField.__index = LGUITextField
function LGUITextField:new(id, p, title, c, x, y, w, h)
   local self = {}
   self = LGUIPart:new(id, p, title, c, x, y, w, h)
   setmetatable(self, LGUITextField)
   self.LGUIType = "LGUITextField"
   return self
end

function LGUITextField:show()
	local x = self.x
	local y = self.y
	if self.parent ~= nil and self.parent.LGUIType ~= nil then
		-- ������������
--~ 		if self.x < self.parent.x then
--~ 			self.x = self.parent.x
--~ 		elseif self.y < self.parent.y then
--~ 			self.y = self.parent.y
--~ 		elseif self.x + self.w > self.parent.w then
--~ 			self.x = self.parent.w - self.w
--~ 		elseif self.y + self.h > self.parent.h then
--~ 			self.y = self.parent.h - self.h
--~ 		end

		x = x + self.parent.x
		y = y + self.parent.y
	end
	self.context = CS.UnityEngine.GUI.TextField(CS.UnityEngine.Rect(x, y, self.w, self.h), self.context)
	for i, v in ipairs(self.eventFunc) do
		if v ~= nil then
			v()
		end
	end
	-- ����guiparts
	if self.guiParts ~= nil then
		for i, v in pairs(self.guiParts) do
			v:show()
		end
	end
end

LGUILabel = {}
setmetatable(LGUILabel, LGUIPart)
LGUILabel.__index = LGUILabel
function LGUILabel:new(id, p, title, c, x, y, w, h)
   local self = {}
   self = LGUIPart:new(id, p, title, c, x, y, w, h)
   setmetatable(self, LGUILabel)
   self.LGUIType = "LGUILabel"
   return self
end

function LGUILabel:show()
	local x = self.x
	local y = self.y
	if self.parent ~= nil and self.parent.LGUIType ~= nil then
		-- ������������
--~ 		if self.x < self.parent.x then
--~ 			self.x = self.parent.x
--~ 		elseif self.y < self.parent.y then
--~ 			self.y = self.parent.y
--~ 		elseif self.x + self.w > self.parent.w then
--~ 			self.x = self.parent.w - self.w
--~ 		elseif self.y + self.h > self.parent.h then
--~ 			self.y = self.parent.h - self.h
--~ 		end

		x = x + self.parent.x
		y = y + self.parent.y
	end
	CS.UnityEngine.GUI.Label(CS.UnityEngine.Rect(x, y, self.w, self.h), self.context)
	for i, v in ipairs(self.eventFunc) do
		if v ~= nil then
			v()
		end
	end
	-- ����guiparts
	if self.guiParts ~= nil then
		for i, v in pairs(self.guiParts) do
			v:show()
		end
	end
end

LGUIHorizontalScrollbar = {size= nil, minValue = nil, maxValue = nil}
setmetatable(LGUIHorizontalScrollbar, LGUIPart)
LGUIHorizontalScrollbar.__index = LGUIHorizontalScrollbar
function LGUIHorizontalScrollbar:new(id, p, title, c, x, y, w, h, s, min_v, max_v)
   local self = {}
   self = LGUIPart:new(id, p, title, c, x, y, w, h)
   setmetatable(self, LGUIHorizontalScrollbar)
   self.LGUIType = "LGUIHorizontalScrollbar"
   self.size = s
   self.minValue = min_v
   self.maxValue = max_v
   return self
end

function LGUIHorizontalScrollbar:show()
	local x = self.x
	local y = self.y
	if self.parent ~= nil and self.parent.LGUIType ~= nil then
		-- ������������
--~ 		if self.x < self.parent.x then
--~ 			self.x = self.parent.x
--~ 		elseif self.y < self.parent.y then
--~ 			self.y = self.parent.y
--~ 		elseif self.x + self.w > self.parent.w then
--~ 			self.x = self.parent.w - self.w
--~ 		elseif self.y + self.h > self.parent.h then
--~ 			self.y = self.parent.h - self.h
--~ 		end

		x = x + self.parent.x
		y = y + self.parent.y
	end
	self.context = CS.UnityEngine.GUI.HorizontalScrollbar(CS.UnityEngine.Rect(x, y, self.w, self.h), self.context, self.size, self.minValue, self.maxValue)
	for i, v in ipairs(self.eventFunc) do
		if v ~= nil then
			v()
		end
	end
	-- ����guiparts
	if self.guiParts ~= nil then
		for i, v in pairs(self.guiParts) do
			v:show()
		end
	end
end

LGUIVerticalScrollbar = {minValue = nil, maxValue = nil}
setmetatable(LGUIVerticalScrollbar, LGUIPart)
LGUIVerticalScrollbar.__index = LGUIVerticalScrollbar
function LGUIVerticalScrollbar:new(id, p, title, c, x, y, w, h, s, min_v, max_v)
   local self = {}
   self = LGUIPart:new(id, p, title, c, x, y, w, h)
   setmetatable(self, LGUIVerticalScrollbar)
   self.LGUIType = "LGUIVerticalScrollbar"
   self.size = s
   self.minValue = min_v
   self.maxValue = max_v
   return self
end

function LGUIVerticalScrollbar:show()
	local x = self.x
	local y = self.y
	if self.parent ~= nil and self.parent.LGUIType ~= nil then
		-- ������������
--~ 		if self.x < self.parent.x then
--~ 			self.x = self.parent.x
--~ 		elseif self.y < self.parent.y then
--~ 			self.y = self.parent.y
--~ 		elseif self.x + self.w > self.parent.w then
--~ 			self.x = self.parent.w - self.w
--~ 		elseif self.y + self.h > self.parent.h then
--~ 			self.y = self.parent.h - self.h
--~ 		end

		x = x + self.parent.x
		y = y + self.parent.y
	end
	self.context = CS.UnityEngine.GUI.VerticalScrollbar(CS.UnityEngine.Rect(x, y, self.w, self.h), self.context, self.size, self.minValue, self.maxValue)
	for i, v in ipairs(self.eventFunc) do
		if v ~= nil then
			v()
		end
	end
	-- ����guiparts
	if self.guiParts ~= nil then
		for i, v in pairs(self.guiParts) do
			v:show()
		end
	end
end

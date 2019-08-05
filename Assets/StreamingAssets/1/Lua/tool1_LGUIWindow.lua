-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

-- ������������������������������ԣ����Ҹ��������Եĳ�ʼֵ
LGUIWindow = {id = nil, title = nil, x = nil, y = nil, w = nil, h = nil, guiParts = nil, canDraw = nil, t = nil, event = nil}
-- ����Ԫ�����������ģ����Ļ����ⲽ�����ܹؼ�
LGUIWindow.__index = LGUIWindow
-- ���췽��new
function LGUIWindow:new(id, title, x, y, w, h, cd, e)
    local self = {}  --��ʼ��self�����û����䣬��ô���������Ķ��������һ���ı䣬�������󶼻�ı�
    setmetatable(self, LGUIWindow)  --��self��Ԫ���趨ΪClass
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

    return self  --��������
end

-- ���ƴ���
function LGUIWindow:show()
	-- ����������Ļ
	if self.x < 0 then
		self.x = 0
	elseif self.y < 0 then
		self.y = 0
	elseif self.x + self.w > CS.UnityEngine.Screen.width then
		self.x = CS.UnityEngine.Screen.width - self.w
	elseif self.y + self.h > CS.UnityEngine.Screen.height then
		self.y = CS.UnityEngine.Screen.height - self.h
	end

	-- ���ƴ���
	local rect = CS.UnityEngine.GUI.Window(self.id, CS.UnityEngine.Rect(self.x, self.y, self.w, self.h), function(id)
		-- ������������ڣ��򷵻ش���id
		if (CS.UnityEngine.Event.current.button == 0 or CS.UnityEngine.Event.current.button == 1) and CS.UnityEngine.Event.current.type == CS.UnityEngine.EventType.MouseDown then
			self.t = id
		else
			if self.t ~= nil then
				self.t = nil
			end
		end

		-- ����guiparts
		if self.guiParts ~= nil then
			for i, v in pairs(self.guiParts) do
				v:show()
			end
		end
		-- �ܷ���ק
		if self.canDraw then
			CS.UnityEngine.GUI.DragWindow(CS.UnityEngine.Rect(0, 0, self.w, self.h))
		end
	end, self.title)
	self.x = rect.x
	self.y = rect.y
	self.w = rect.width
	self.h = rect.height

	-- ִ��event
	if self.event ~= nil then
		self.event()
	end

	return self.t
end

function LGUIWindow:addToStacks(s)
	s[self.id] = self
end

-- ���parts
function LGUIWindow:addGUIpart(p)
	self.guiParts[p.id] = p
end




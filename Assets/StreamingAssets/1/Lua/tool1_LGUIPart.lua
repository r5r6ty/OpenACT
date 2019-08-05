-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

LGUIPart = {LGUIType = nil, id = nil, parent = nil, title = nil, context = nil, x = nil, y = nil, w = nil, h = nil, guiParts = nil, event1 = nil, eventFunc = nil, temp = nil}
LGUIPart.__index = LGUIPart
function LGUIPart:new(id, p, title, c, x, y, w, h)
	local self = {}  --��ʼ��self�����û����䣬��ô���������Ķ��������һ���ı䣬�������󶼻�ı�
	setmetatable(self, LGUIPart)  --��self��Ԫ���趨ΪClass

    self.title = title
	self.context = c
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.guiParts = {}
	self.LGUIType = "LGUIPart"
	self.id = id
	self.parent = p
	self.event1 = {}
	self.eventFunc = {}

	self.temp = nil

    return self  --��������
end

function LGUIPart:show()
end

-- ���parts
function LGUIPart:addGUIpart(p)
	self.guiParts[p.id] = p
end

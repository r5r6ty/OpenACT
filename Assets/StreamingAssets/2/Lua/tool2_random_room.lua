-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local randomRoom = {}

Room = {x = 0,
              y = 0,
              width = 0,
              height = 0,
              tile = nil,
              data = {}}

function Room:new(o, x, y, w, h)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    x = x or 0
    y = y or 0
    w = w or 0
    h = h or 0
    self.x = x;
    self.y = y;
    self.width = w;
    self.height = h;

    for i = self.x, self.x + self.width - 1, 1 do
        self.data[i] = {}
        for j = self.y, self.y + self.height - 1, 1 do
            if i % (self.x + self.width) == self.x or j % (self.y + self.height) == self.y or i % (self.width + self.width) == self.x + self.width - 1 or j % (self.y + self.height) == self.y + self.height - 1 then
                self.data[i][j] = "1"
            else
                self.data[i][j] = "0"
            end
        end
    end

    print("new", self.x, self.y, self.width, self.height)
    return o
end

function Room:printArea(name)
    print("print", self.x, self.y, self.width, self.height)
    local str = ""
    for j = self.y, self.y + self.height - 1, 1 do
        for i = self.x, self.x + self.width - 1, 1 do
            str = str .. self.data[i][j] .. ","
        end
        str = str .. "\n"
    end
    str = self.x .. "," .. self.y .. "," .. self.width .. "," .. self.height  .. "\n" .. str
    local f = io.open(CS.UnityEngine.Application.dataPath .. "/StreamingAssets/2/" .. name,'w')
    f:write(str)
    f:close()
    return str
end

function Room:addChildRoom(fill)
    local count = 1
    local x, y ,w, h = self:canMakeRoom(fill)
    while x == nil or y == nil or w == nil or h == nil  do
        if count >= 100 then
            return
        end
        x, y ,w, h = self:canMakeRoom(fill)
        count = count + 1
    end
    for i = x, x + w - 1, 1 do
        for j = y, y + h - 1, 1 do
            if fill == 0 then
                if i % (x + w) == x or j % (y + h) == y or i % (x + w) == x + w - 1 or j % (y + h) == y + h - 1 then
                    self.data[i][j] = "1"
                else
                    self.data[i][j] = "0"
                end
            else
                 self.data[i][j] = "1"
            end
        end
    end
--    local context = r:printArea("testroom2.txt")
end

function Room:canMakeRoom(isFill)
    local iw = 1
    local ih = 1
    if isfill == 0 then
        iw = 3 + 2
        ih = 4 + 2
    end
    local x = CS.Tools.Instance:RandomRangeInt(self.x + 1, self.width - 1)
    local y = CS.Tools.Instance:RandomRangeInt(self.y + 1, self.height - 1)
    local w = CS.Tools.Instance:RandomRangeInt(iw, self.width - 2 - x + 1)
    local h = CS.Tools.Instance:RandomRangeInt(ih, self.height - 2 - y + 1)

    for i = x, x + w - 1, 1 do
        for j = y, y + h - 1, 1 do
            if self.data[i][j] == "1" then
                return nil, nil, nil, nil
            end
        end
    end

    for k = 0, h - 1, 1 do
        if self.data[x - 1][y + k] == "1" then
        else
            for t = x - 2, x - 3, -1 do
                if self.data[t][y + k] ~= nil and self.data[t][y + k] == "1" then
                    return nil, nil, nil, nil
                end
            end
        end

        if self.data[x + w][y + k] == "1" then
        else
            for t = x + w + 1, x + w + 2, 1 do
                if self.data[t][y + k] ~= nil and self.data[t][y + k] == "1" then
                    return nil, nil, nil, nil
                end
            end
        end
    end


    for k = 0, w - 1, 1 do
        if self.data[x + k][y - 1] == "1" then
        else
            for t = y - 2, y - 3, -1 do
                if self.data[x + k][t] ~= nil and self.data[x + k][t] == "1" then
                    return nil, nil, nil, nil
                end
            end
        end

        if self.data[x + k][y + h] == "1" then
        else
            for t = y + h + 1, y + h + 2, 1 do
                if self.data[x + k][t] ~= nil and self.data[x + k][t] == "1" then
                    return nil, nil, nil, nil
                end
            end
        end
    end

--    if self.data[x - 1][y] == "0" and self.data[x - 2][y] == "1" then
--        return nil, nil, nil, nil
--    end

--    if self.data[x - 1][y] == "0" and self.data[x - 2][y] == "0" and self.data[x - 3][y] == "1" then
--        return nil, nil, nil, nil
--    end

--    if self.data[x + w + 1][y] == "0" and self.data[x + w + 2][y] == "1" then
--        return nil, nil, nil, nil
--    end

--    if self.data[x + w + 1][y] == "0" and self.data[x + w + 2][y] == "0" and self.data[x + w + 3][y] == "1" then
--        return nil, nil, nil, nil
--    end

    return x, y, w, h
end





function randomRoom.gen()
    local myroom = nil 
--    myroom = Room:new(nil, 10, 10)
--    myroom:printArea()
--    myroom = Room:new(nil, 0, 0, CS.Tools.Instance:RandomRangeInt(3 + 2, 31), CS.Tools.Instance:RandomRangeInt(4 + 2, 31))
    myroom = Room:new(nil, 0, 0, 30, 30)
    for i = 1, 20, 1 do
        myroom:addChildRoom(CS.Tools.Instance:RandomRangeInt(0, 2))
    end
    local context = myroom:printArea("testroom.csv")
end

return randomRoom
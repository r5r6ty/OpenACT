-- Tencent is pleased to support the open source community by making xLua available.
-- Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
-- Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
-- http://opensource.org/licenses/MIT
-- Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

local json = require "json"
local utils = require 'tool1_utils'
require "LAI"

castleDB = {DBPath = nil, DBFile = nil, DBData = nil, IMGFile = nil, IMGData = nil, DBSheets = nil}
castleDB.__index = castleDB
function castleDB:new(path, file)
	local self = {}
	setmetatable(self, castleDB)

	self.DBPath = path
	self.DBFile = file
	self.IMGFile = nil
	self.DBData = nil
	self.IMGData = nil
	self.DBSheets = nil

	return self
end

function castleDB:readDB()

	local str = utils.openFileText(self.DBPath .. self.DBFile)

    self.DBData = json.decode(str)

	self.DBSheets = {}
    for i, v in ipairs(self.DBData["sheets"]) do
        if self.DBSheets[v.name] == nil then
            self.DBSheets[v.name] = v
        end
	end
	print(self.DBPath .. self.DBFile .. ": json read!")
end

function castleDB:writeDB()
	local data = json.encode(self.DBData)
	local file = io.open(self.DBPath .. self.DBFile, "w")
	file:write(data)
	file:close()

	print(self.DBPath .. self.DBFile .. ": json wrote!")
end

function castleDB:readIMG()
	local idx = string.match(self.DBFile, ".+()%.%w+$")
	if idx then
		self.IMGFile = string.sub(self.DBFile, 1, idx - 1) .. ".img"
	end

    local str = utils.openFileText(self.DBPath .. self.DBFile)

    self.IMGData = json.decode(str)

	print(self.DBPath .. self.IMGFile .. ": json read!")
end

function castleDB:writeIMG()
	local data = json.encode(self.IMGData)
	local file = io.open(self.DBPath .. self.IMGFile, "w")
	file:write(data)
	file:close()

	print(self.DBPath .. self.IMGFile .. ": json wrote!")
end

-- ¶ÁÈ¡imagesÖÐµÄpic
function castleDB:loadIMGToTexture2Ds()
	local result = {}
    for i, v in pairs(self.IMGData) do
        if result[i] == nil then
            result[i] = utils.loadImageToTexture2D(v)
        end
	end
	return result
end

function castleDB:getLines(name)
	return self.DBSheets[name].lines
end


LCastleDBCharacter = {characters = nil, AI = nil}
setmetatable(LCastleDBCharacter, castleDB)
LCastleDBCharacter.__index = LCastleDBCharacter
function LCastleDBCharacter:new(path, file)
	local self = {}
	self = castleDB:new(path, file)
	setmetatable(self, LCastleDBCharacter)

	self.characters = nil
	self.AI = nil
	return self
end


function LCastleDBCharacter:readDB()
	local str = utils.openFileText(self.DBPath .. self.DBFile)

    self.DBData = json.decode(str)

	self.DBSheets = {}
    for i, v in ipairs(self.DBData["sheets"]) do
        if self.DBSheets[v.name] == nil then
            self.DBSheets[v.name] = v
        end
	end
	print(self.DBPath .. self.DBFile .. ": json read!")


	self.characters = {}
	for i, v in ipairs(self:getLines("actions")) do
		self.characters[v.name] = v.frames
	end

	self.AI = LAI:new(self)
end

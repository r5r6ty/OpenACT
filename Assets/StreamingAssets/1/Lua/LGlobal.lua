




local LGlobal = {DBPath = nil}
LGlobal.__index = LGlobal
local function LGlobal:new(path)
	local self = {}
	setmetatable(self, LGlobal)

	self.DBPath = path

	return self
end



return LGlobal

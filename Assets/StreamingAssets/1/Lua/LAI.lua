local utils = require "tool1_utils"

LAI = {object = nil, strategys = nil, commands = nil}
LAI.__index = LAI
function LAI:new(o)
	local self = {}
	setmetatable(self, LAI)

	self.object = o
	
	self.strategys = {}

	self:createStrategys(self.object.database[self.object.id].char.AI)

	

    return self
end

function LAI:createStrategys(ai)
	for i, v in ipairs(ai) do
		local strategy = {}
		strategy.name = v.name
		strategy.command = v.command
		strategy.level = v.level
		strategy.distanceA, strategy.distanceB = utils.getRangeAB(v.distanceRange)
		strategy.probability = v.probability
		strategy.active = v.active
		strategy.canTurnAround = v.canTurnAround

		self.strategys[strategy.name] = strategy
	end
end

function LAI:judgeAI()
	if self.object.target ~= nil and self.object.HP > 0 then
		for i, v in pairs(self.strategys) do
			if v.active then
				local r = CS.Tools.Instance:RandomRangeInt(1, 101)
				if r <= v.probability * 100 then
					local pos = self.object.target.gameObject.transform.position - self.object.gameObject.transform.position
					
					local dx = self.object.direction.x
					local r = false
					if v.canTurnAround then
						if dx == 1 then
							r = (pos.x >= v.distanceA / 100 * dx and pos.x <= v.distanceB / 100 * dx) or (pos.x <= v.distanceA / 100 * -dx and pos.x >= v.distanceB / 100 * -dx)
						else
							r = (pos.x <= v.distanceA / 100 * dx and pos.x >= v.distanceB / 100 * dx) or (pos.x >= v.distanceA / 100 * -dx and pos.x <= v.distanceB / 100 * -dx)
						end
					else
						if dx == 1 then
							r = pos.x >= v.distanceA / 100 * dx and pos.x <= v.distanceB / 100 * dx
						else
							r = pos.x <= v.distanceA / 100 * dx and pos.x >= v.distanceB / 100 * dx
						end
					end
					if r then
						-- print(d)
						-- print(pos.x , v.distanceA / 100 , pos.x , v.distanceB / 100)

						if v.canTurnAround then
							if (pos.x < 0 and dx == 1) or (pos.x > 0 and dx == -1) then
								dx = dx * -1
							end
						end
						self.object:addEvent("Input", 0, 1, {level = v.level, name = v.name, direction = dx, frame = v.command})
					end
				end
			end
		end
	else
		-- print("wawa")
	end
end

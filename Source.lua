local o_clock = os.clock
local c_yield = coroutine.yield
local c_running = coroutine.running
local c_resume = coroutine.resume
local t_insert = table.insert

local Yields = {}
game:GetService('RunService').Stepped:Connect(function()
	local PrioritizedThread = Yields[1]
	if not PrioritizedThread then
		return
	end

	local Clock = o_clock()
	for Idx, data in next, Yields do
		local Spent = Clock - data[1]
		if Spent >= data[2] then
			c_resume(data[3], Spent, Clock)
			Yields[Idx] = nil
		end
	end
end)

return function(Time)
	Time = (type(Time) ~= 'number' or Time < 0) and 0 or Time
	t_insert(Yields, {o_clock(), Time, c_running()})
	return c_yield()
end
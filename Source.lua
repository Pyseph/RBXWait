local OsClock = os.clock
local CoroutineYield = coroutine.yield
local CoroutineRunning = coroutine.running
local TaskSpawn = task.spawn
local TableInsert = table.insert

-- Pre-allocate 100 indices
local Yields = table.create(100)
game:GetService("RunService").Stepped:Connect(function()
	local Now = OsClock()
	for Index, Data in next, Yields do
		local TimeYielded = Now - Data[1]
		if TimeYielded >= Data[2] then
			Yields[Index] = nil
			TaskSpawn(Data[3], TimeYielded, Now)
		end
	end
end)

return function(YieldTime)
	YieldTime = (type(YieldTime) ~= "number" or YieldTime < 0) and 0 or YieldTime
	TableInsert(Yields, {OsClock(), YieldTime, CoroutineRunning()})
	return CoroutineYield()
end
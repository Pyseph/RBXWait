local heap = {}

function heap.insert(value, data)
	local insertPos = #heap + 1
	heap[insertPos] = {
		value = value,
		data = data
	}
	local parentNode = heap[insertPos]
	local childNode = heap[math.floor(insertPos / 2)]
	-- if parent has less time left than child, swap parent and child
	-- node with least time left will be at the end
	while insertPos > 1 and parentNode.data[2] - parentNode.value < childNode.data[2] - childNode.value do
		local childPos = math.floor(insertPos / 2)
		heap[insertPos], heap[childPos] = heap[childPos], heap[insertPos]
		insertPos = math.floor(insertPos / 2)
	end
end
function heap.extract()
	local insertPos = 1
	if #heap < 2 then
		heap[1] = nil
		return
	end
	heap[1] = table.remove(heap)
	
	while insertPos < #heap do
		local childL, childR = heap[2*insertPos], heap[2*insertPos+1]
		if not childL or not childR then
			break
		end

		local smallerChild = 2*insertPos + (childL.data[2] - childL.value < childR.data[2] - childR.value and 0 or 1)

		local child = heap[smallerChild]
		local parent = heap[insertPos]

		if parent.data[2] - parent.value > child.data[2] - child.value then
			heap[smallerChild], heap[insertPos] = parent, child
		end
		insertPos = smallerChild
	end
end

local CPUTime = os.clock()

game:GetService('RunService').Stepped:Connect(function()
	CPUTime = os.clock()
	local PrioritizedThread = heap[1]

	while PrioritizedThread do
		PrioritizedThread = PrioritizedThread.data
		local YieldTime = CPUTime - PrioritizedThread[2]
		if PrioritizedThread[3] - YieldTime <= 0 then
			heap.extract()
			coroutine.resume(PrioritizedThread[1], YieldTime)
			PrioritizedThread = heap[1]
		else
			PrioritizedThread = nil
		end
	end
end)

return function(Time)
	heap.insert(Time or 0, {coroutine.running(), os.clock(), Time or 0})
	return coroutine.yield(), CPUTime
end

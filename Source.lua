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

	local start = time()
	while insertPos > 1 and start - parentNode.data[2] - parentNode.value > start - childNode.data[2] - childNode.value do
		local childPos = math.floor(insertPos / 2)
		heap[insertPos], heap[childPos] = heap[childPos], heap[insertPos]
		insertPos = math.floor(insertPos / 2)
	end
end
function heap.extract()
	if #heap < 2 then
		heap[1] = nil
		return
	end
	heap[1] = table.remove(heap)

	local insertPos = 1
	local start = time()
	while insertPos < #heap do
		local childL, childR = heap[2*insertPos], heap[2*insertPos+1]
		if not childL or not childR then
			break
		end

		local smallerChild = 2*insertPos + (start - childL.data[2] - childL.value < start - childR.data[2] - childR.value and 0 or 1)

		local child = heap[smallerChild]
		local parent = heap[insertPos]

		if start - parent.data[2] - parent.value < start - child.data[2] - child.value then
			heap[smallerChild], heap[insertPos] = parent, child
		end
		insertPos = smallerChild
	end
end

game:GetService('RunService').Stepped:Connect(function()
	local PrioritizedThread = heap[1]
	if not PrioritizedThread then
		return
	end

	local CPUTime = time()
	for _ = 1, 50000 do
		PrioritizedThread = PrioritizedThread.data
		local YieldTime = CPUTime - PrioritizedThread[2]
		if PrioritizedThread[3] - YieldTime <= 0 then
			heap.extract()
			coroutine.resume(PrioritizedThread[1], YieldTime, CPUTime)
			
			PrioritizedThread = heap[1]
			if not PrioritizedThread then 
				break 
			end
		else
			break
		end
	end
end)

return function(Time)
	heap.insert(Time or 0, {coroutine.running(), time(), Time or 0})
	return coroutine.yield()
end
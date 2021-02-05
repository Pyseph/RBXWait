local heap = {}

function heap.insert(value, data)
	local insertPos = #heap + 1
	heap[insertPos] = {
		value = value,
		data = data
	}

	local parentNode = heap[#heap]
	local childNode = heap[math.floor(#heap / 2)]
	-- if parent has less time left than child, swap parent and child
	-- node with least time left will be at the end

	local startTime = time()
	while #heap > 1 and startTime - parentNode.data[2] - parentNode.value > startTime - childNode.data[2] - childNode.value do
		local childPos = math.floor(#heap / 2)
		heap[#heap], heap[childPos] = heap[childPos], heap[#heap]
		insertPos = childPos
	end
	if data[4] == 2
end

function heap.extract()
	local insertPos = 1
	heap[1], heap[#heap] = heap[#heap], nil

	local startTime = time()
	while insertPos < #heap do
		local childL, childR = heap[2*insertPos], heap[2*insertPos+1]
		if not (childL and childR) then
			break
		end

		local smallerChild = 2*insertPos + (startTime - childL.data[2] - childL.value < startTime - childR.data[2] - childR.value and 0 or 1)

		local child = heap[smallerChild]
		local parent = heap[insertPos]

		if startTime - parent.data[2] - parent.value < startTime - child.data[2] - child.value then
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

	local startTime = time()
	for _ = 1, 100 do
		local threadData = PrioritizedThread.data
		local YieldTime = startTime - threadData[2]
		if threadData[3] - YieldTime <= 0 then
			heap.extract()
			coroutine.resume(threadData[1], YieldTime, startTime)
			PrioritizedThread = heap[1]
			if not PrioritizedThread then
				break
			end
		else
			break
		end
	end
end)

return function(Time, Index)
	heap.insert(Time or 0, {coroutine.running(), time(), Time or 0, Index})
	return coroutine.yield()
end
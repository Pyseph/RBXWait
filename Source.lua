local heap = {}

function heap.insert(value, data)
	local insertPos = #heap + 1
	heap[insertPos] = {
		value = value,
		data = data
	}
	--print('Adding', value)

	local parentNode = heap[insertPos]
	local childNode = heap[math.floor(insertPos / 2)]
	-- if parent has less time left than child, swap parent and child
	-- node with least time left will be at the end
	while insertPos > 1 and os.clock() - parentNode.data[2] - parentNode.value > os.clock() - childNode.data[2] - childNode.value do
		--print('swapping parent', heap[insertPos].value, '(' .. insertPos .. ')', 'with child', heap[math.floor(insertPos / 2)].value, '(' .. math.floor(insertPos / 2) .. ')')

		local childPos = math.floor(insertPos / 2)
		heap[insertPos], heap[childPos] = heap[childPos], heap[insertPos]
		insertPos = math.floor(insertPos / 2)
	end
end
function heap.extract()
	local insertPos = 1
	if #heap < 2 then
		--print('heap only has 1 index')
		heap[1] = nil
		return
	end
	--print('removed last element')
	heap[1] = table.remove(heap)

	--print('insertPos and #heap are:', insertPos, #heap)
	--print('unsorted heap is:', heap)
	while insertPos < #heap do
		local childL, childR = heap[2*insertPos], heap[2*insertPos+1]
		--print('getting next children', 2*insertPos, 'and', 2*insertPos+1)
		if not childL or not childR then
			--print('no such children', childL, childR)
			break
		end

		local smallerChild = 2*insertPos + (os.clock() - childL.data[2] - childL.value < os.clock() - childR.data[2] - childR.value and 0 or 1)
		--print('the smaller child is', smallerChild)

		local child = heap[smallerChild]
		local parent = heap[insertPos]

		--print('the nodes are', child, parent)
		if os.clock() - parent.data[2] - parent.value < os.clock() - child.data[2] - child.value then
			--print('swapping the two')
			heap[smallerChild], heap[insertPos] = parent, child
		end
		insertPos = smallerChild
	end
	--print('sorted heap is:', heap)
end

game:GetService('RunService').Stepped:Connect(function()
	local PrioritizedThread = heap[1]

	while PrioritizedThread do
		PrioritizedThread = PrioritizedThread.data
		local YieldTime = os.clock() - PrioritizedThread[2]
		if PrioritizedThread[3] - YieldTime <= 0 then
			--print('unyielded', PrioritizedThread[3], os.clock(), PrioritizedThread[2], YieldTime)
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
	return coroutine.yield(), os.clock()
end

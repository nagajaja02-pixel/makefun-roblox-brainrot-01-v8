-- Existing consumers use colon calls while service exports use dot calls.
-- Adapt dependency boundaries without changing service bodies or their rules.
return function(module)
	local proxy = {}
	for key, value in pairs(module) do
		if type(value) == "function" then
			proxy[key] = function(first, ...)
				if first == proxy then return value(...) end
				return value(first, ...)
			end
		else proxy[key] = value end
	end
	return proxy
end

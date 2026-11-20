-- Pure, server-owned combat limits. The client never supplies a victim.
local Rules = { Cooldown = 0.8, Range = 7, Facing = 0.2 }
function Rules.allowed(now, last, distance, facing, alive, equipped, clear)
	return alive and equipped and clear and now - last >= Rules.Cooldown
		and distance > 0 and distance <= Rules.Range and facing >= Rules.Facing
end
return Rules

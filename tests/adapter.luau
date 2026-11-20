local adapt = require("../src/shared/ServiceAdapter")
local player = {UserId = 123}
local proxy = adapt({earn = function(p, amount) assert(p == player); return amount end})
assert(proxy:earn(player, 27) == 27)
assert(proxy.earn(player, 32) == 32)
print("PASS dependency adapter preserves both existing colon consumers and dot exports")

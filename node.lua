util.init_hosted()

-- this is only supported on the Raspi....
--util.noglobals()

node.set_flag("no_clear")

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local res = util.auto_loader()
local fancy = require"fancy"
fancy.res = res

function node.render()
   fancy.render(CONFIG.style)
end

NATIVE_WIDTH = NATIVE_WIDTH or 1920
NATIVE_HEIGHT = NATIVE_HEIGHT or 1080

sys.set_flag("no_clear")

--util.noglobals()
local res = util.auto_loader()
local fancy = require"fancy"
fancy.res = res


gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

function node.render()
    fancy.render("fancy")
end

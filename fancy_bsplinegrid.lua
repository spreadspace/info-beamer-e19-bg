-- 2D grid of 3D bsplines
-- aka a function (tx, ty) -> (x,y,z)

local bspline = require"bspline"

local B = {}
B.__index = B

-- self[1,2,3] are arrays of arrays of points
function B.new(npx, npy)
    local self = { _np = npx, _step = 1 / npx }
    return setmetatable(self, B)
end

-- dst[1], dst[2], dst[3] must be arrays of points in x,y,z axis
function B:evalAxis(dst, ty)
    for t
end



return B

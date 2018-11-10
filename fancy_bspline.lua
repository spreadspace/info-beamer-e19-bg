-- translated from some of my own C++ code
-- uses zero-based indexing
-- just take care that the end of the for loop
--  for(i = 0; i < m; ++i) ...
-- in c++ is exclusive, while in lua the same loop would be inclusive, so it must be
--  for i=0, m-1 do ... end

local floor = math.floor

local PARAMETERIZATION_CUSTOM = -1
local PARAMETERIZATION_UNIFORM = 0


local function lowerbound(t, item, first, count)
    count = count or #t
    first = first or 1
    local i, step
    while count > 0 do
        step = floor(count * 0.5)
        i = first + step
        if t[i] < item then
            i = i + 1
            first = i
            count = count - (step + 1)
        else
            count = step
        end
    end
    return first
end


local abs = math.abs


local B =
{
    PARAMETERIZATION_UNIFORM = PARAMETERIZATION_UNIFORM,
    PARAMETERIZATION_CUSTOM = PARAMETERIZATION_CUSTOM,
}

local function findKnotIndex(knots, t, num)
    local i = lowerbound(knots, t, 0, num)
    if i >= num then
        return num-1
    end
    -- is is index of first element not less than t, go one back to get the one strictly less than t
    if knots[i] > 0 then
        i = i - 1
    end
    return i
end

-- uniformly spaced knots
local function generateKnotVectorUniform(knots, n, p)
    local m = 1 / (n - p + 1)
    for j = 1, n - p do
        knots[j+p] = j * m
    end
end

--[[local function generateKnotVectorAxis1(knots, n, p, xs)
    local steps = n - p
    local totallen = 0
    local points = #xs
    local prev = xs[1]
    for i = 1, points-1 do
        local cur = xs[i+1]
        local d = abs(prev - cur)
        totallen = totallen + d
        prev = cur
        knots[i+p] = totallen
    end
    
    for i = p, points-p do
        knots[i] = knots[i] / totallen
    end
end]]

local function generateKnotVector(points, degree, ty, ...)
    local n = points - 1
    local p = degree
    if n < p then
        return
    end
    ty = ty or PARAMETERIZATION_UNIFORM
    
    local numknots = n + p + 2
    local knots = {}
    
    if ty == PARAMETERIZATION_CUSTOM then
        --generateKnotVectorAxis1(knots, n, p, ...)
        -- do nothing except copy + fixup
        local customknots = ...
        local customlen = #customknots
        if customlen ~= numknots then
            error("generateKnotVector(degree: " .. p .. ", points: " .. points .. ") - custom: expected " .. numknots .. " knots, but got " .. customlen)
        end
        --table.sort(customknots) -- user must pass in knots already sorted
        local maxknot = customknots[customlen]
        for i = 1, customlen do
            knots[i-1] = customknots[i] / maxknot
            --debugLog("c: " ..customknots[i] / maxknot)
        end
        --debugLog("---")
    else
        generateKnotVectorUniform(knots, n, p)
    end

    -- end point interpolation, beginning
    for i = 0, p do
        knots[i] = 0
    end
    
    -- end point interpolation, end
    for i = numknots - p - 1, numknots-1 do
        knots[i] = 1
    end
    
    if ty == PARAMETERIZATION_UNIFORM then
         for i = 0, numknots-1 do
            --debugLog("u: " ..knots[i])
         end
    end

    return knots, numknots
end

local xwork = {}
local ywork = {}
local zwork = {}

function B:eval1d(t)
    local knots = self._knots
    local r = findKnotIndex(knots, t, self._numknots)
    local d = self._degree
    local xs = self._xs
    if r < d then
        r = d
    end
    local k = d + 1
    local xwork = xwork
    for i = 0, d do
        xwork[i] = xs[r - d + i]
    end
    
    local worksize = k
    while worksize > 1 do
        local j = k - worksize + 1 -- iteration number, starting with 1, going up to k
        local tmp = r - k + 1 + j
        for w = 0, worksize-2 do
            local i = w + tmp
            local ki = knots[i]
            local a = (t - ki) / (knots[i+k-j] - ki)
            xwork[w] = xwork[w] * (1-a) + xwork[w+1] * a
        end
        worksize = worksize - 1
    end
    return xwork[0]
end

function B:eval2d(t)
    local knots = self._knots
    local r = findKnotIndex(knots, t, self._numknots)
    local d = self._degree
    local xs = self._xs
    local ys = self._ys
    if r < d then
        r = d
    end
    local k = d + 1
    local xwork = xwork
    local ywork = ywork
    for i = 0, d do
        xwork[i] = xs[r - d + i]
        ywork[i] = ys[r - d + i]
    end
    
    local worksize = k
    while worksize > 1 do
        local j = k - worksize + 1 -- iteration number, starting with 1, going up to k
        local tmp = r - k + 1 + j
        for w = 0, worksize-2 do
            local i = w + tmp
            local ki = knots[i]
            local a = (t - ki) / (knots[i+k-j] - ki)
            xwork[w] = xwork[w] * (1-a) + xwork[w+1] * a
            ywork[w] = ywork[w] * (1-a) + ywork[w+1] * a
        end
        worksize = worksize - 1
    end
    return xwork[0], ywork[0]
end

function B:eval3d(t)
    local knots = self._knots
    local r = findKnotIndex(knots, t, self._numknots)
    local d = self._degree
    local xs = self._xs
    local ys = self._ys
    local zs = self._zs
    if r < d then
        r = d
    end
    local k = d + 1
    local xwork = xwork
    local ywork = ywork
    for i = 0, d do
        local tt = r - d + i
        xwork[i] = xs[tt]
        ywork[i] = ys[tt]
        zwork[i] = zs[tt]
    end
    
    local worksize = k
    while worksize > 1 do
        local j = k - worksize + 1 -- iteration number, starting with 1, going up to k
        local tmp = r - k + 1 + j
        for w = 0, worksize-2 do
            local i = w + tmp
            local ki = knots[i]
            local a = (t - ki) / (knots[i+k-j] - ki)
            local a1 = 1-a
            local w1 = w+1
            xwork[w] = xwork[w] * (a1) + xwork[w1] * a
            ywork[w] = ywork[w] * (a1) + ywork[w1] * a
            zwork[w] = zwork[w] * (a1) + zwork[w1] * a
        end
        worksize = worksize - 1
    end
    return xwork[0], ywork[0], zwork[0]
end

local bmeta1d = { __index = B, __call = B.eval1d }
local bmeta2d = { __index = B, __call = B.eval2d }
local bmeta3d = { __index = B, __call = B.eval3d }

function B.new1d(xs, degree, ty, ...)
    local len = #xs
    degree = degree or 3
    local knots, numknots = generateKnotVector(len, degree, ty, ...)
    assert(knots, "bspline-1D::generateKnotVector() failed. len: " .. len)
    local x = {}
    for i = 1, len do -- convert to 0-based indexing (makes things above easier)
        x[i-1] = xs[i]
    end
    return setmetatable({ _knots = knots, _numknots = numknots, _degree = degree, _xs = x,  }, bmeta1d)
end

function B.new2d(xs, ys, degree, ty, ...)
    local len = #xs
    assert(len == #ys)
    degree = degree or 3
    local knots, numknots = generateKnotVector(len, degree, ty, ...)
    assert(knots, "bspline-2D::generateKnotVector() failed. len: " .. len)
    local x, y = {}, {}
    for i = 1, len do
        x[i-1] = xs[i]
        y[i-1] = ys[i]
    end
    return setmetatable({ _knots = knots, _numknots = numknots, _degree = degree, _xs = x, _ys = y,  }, bmeta2d)
end

function B.new3d(xs, ys, zs, degree, ty, ...)
    local len = #xs
    assert(len == #ys and len == #zs)
    degree = degree or 3
    local knots, numknots = generateKnotVector(len, degree, ty, ...)
    assert(knots, "bspline-3D::generateKnotVector() failed. len:" .. len)
    local x, y, z = {}, {}, {}
    for i = 1, len do
        x[i-1] = xs[i]
        y[i-1] = ys[i]
        z[i-1] = zs[i]
    end
    return setmetatable({ _knots = knots, _numknots = numknots, _degree = degree, _xs = x, _ys = y, _zs = z  }, bmeta3d)
end

--rawset(_G, "bspline", B)


-- test code
--[[
dofile("table.lua")
debugLog = print
local xs = {-5, -1, 1, 5, 7}
local ys = {-5, 5, -5, 5, 0}
local s = B.new2d(xs, ys)

for i, k in pairs(s._knots) do
    print(i, k)
end

print(s(0.0))
print(s(0.1))
print(s(0.9))
print(s(1.0))
print("-------------")

s = B.new1d(xs)
for i, k in pairs(s._knots) do
    print(i, k)
end
print(s(0.0))
print(s(0.1))
print(s(0.9))
print(s(1.0))
]]

return B
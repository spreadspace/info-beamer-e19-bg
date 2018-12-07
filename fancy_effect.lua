local eff = {}

local max = math.max
local min = math.min
local cos = math.cos
local sin = math.sin
local exp = math.exp
local PUSH = gl.pushMatrix
local POP = gl.popMatrix
local PI = math.pi
local RADTODEG = 180.0 / 3.14159265359
local DEGTORAD = 3.14159265359 / 180.0
local ROT1 = RADTODEG * PI

local bspline = require"fancy_bspline"

local black = resource.create_colored_texture(0, 0, 0, 1)

local function chaos(t)
  return (exp(sin(t*0.22))*exp(cos(t*0.39))*sin(t*0.3))
end

local _bs = bspline.new(3, 1000)
local function makespline(now)
    local xs, ys, zs = unpack(_bs)
    for i = 0, _bs.n-1 do
        local t = now + i
        xs[i] = chaos(t)
        ys[i] = chaos(t + 3)
        zs[i] = chaos(t + 6)
    end
    return _bs
end

local function quad1(tex, ...)
    tex:draw(0,0, 1,1 ,1, ...)
end

local function quad(tex, ...)
    tex:draw(-0.5,-0.5,0.5,0.5,1, ...)
end

local vert = {
    0, 0, 0, 1,
    1, 0, 0, 1,
    1, 1, 0, 1,
    0, 1, 0, 1,
}

local uv = {
    0, 0,
    1, 0,
    1, 1,
    0, 1,
}

local POINTS = 10000
local VERT = {}
for i = 1, POINTS*4 do
    VERT[i] = 1.0
end

-- evaluate
local function eval(bs)
    bs:sample3d(POINTS, VERT,VERT,VERT, 1,2,3,  4,4,4)

    -- OLD, SLOW METHOD
    --[[local step = 1.0 / points
    local i = 1
    for t = 0, 1, step do
        local x, y, z = bs(t)
        r[i], r[i+1], r[i+2] = bs(t)
        r[i+3] = 1.0
        i = i + 4
    end]]

    return VERT
end

local texcoord = {}


function eff.draw(now, res)
    local tex = res.fancy_tex

    PUSH()

    gl.rotate(100, 1,0,0)
    gl.rotate(now*10, 0, 0, 1)
    --gl.rotate(100, 0, 0, 1)
    gl.scale(0.2, 0.2, 0.2)


    quad1(tex)
    --quad1(black)

    PUSH()
    gl.scale(0.5, 0.5, 0.5)


    local bs = makespline(now*8)
    local vert = eval(bs)
    black:drawverts("L", vert, uv)


    POP()
    POP()
end




return eff

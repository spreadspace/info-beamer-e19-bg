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

local QSIZE = 0.12
local QPOSX, QPOSY = 0.4, 0.3   -- querulant base position [(0,0) = center, (1,1) = bottom right corner]
local QMOVESCALE = 0.20
local QROTSPEED = 1.0


local fancy = {}

----------------------------------------------
-- utils

local function chaos(t)
  return (exp(sin(t*0.22))*exp(cos(t*0.39))*sin(t*0.3));
end

local function rotaterad(a, ...)
    gl.rotate(RADTODEG * a, ...)
end

local function rotate1(a, ...) -- 0.5 = half rotation, 1 = full rotation
    gl.rotate(ROT1 * a, ...)
end


----------------------------------------------
-- querulant

local function queruPos(t)
  local dx = chaos(t * PI)
  local dy = chaos(t * -1.3)
  return QPOSX + QMOVESCALE * dx, QPOSY + QMOVESCALE * dy
end

local function drawQueru(now)
    local ox, oy, x, y = 0.012, 0.01, queruPos(now)
    local s = 1.05

    -- shadow
    -- PUSH()
    --     gl.translate(x+ox, y+oy)
    --     rotate1(QROTSPEED *now, 0, 0, 1)
    --     gl.scale(s, s, s)
    --     gl.translate(QSIZE/-2, QSIZE/-2) -- center rotation point
    --     fancy.res.shadow:draw(0,0,QSIZE,QSIZE)
    -- POP()

    -- querulant
    PUSH()
        gl.translate(x,y)
        rotate1(QROTSPEED * now, 0, 0, 1)
        gl.translate(QSIZE/-2, QSIZE/-2) -- center rotation point
        fancy.res.fancy_bgcolor:draw(0,0,QSIZE,QSIZE)
    POP()
end


----------------------------------------------
-- modes: "minimal", fancy".

function fancy.render(mode, aspect)
    aspect = aspect or (WIDTH / HEIGHT)
    local now = sys.now()
    local res = fancy.res

    if mode == "minimal" then
        res.fancy_minimalbg:draw(0, 0, WIDTH, HEIGHT)
    elseif mode == "fancy" then
        res.fancy_bgcolor:draw(0, 0, WIDTH, HEIGHT)

        local fov = math.atan2(HEIGHT, WIDTH*2) * 360 / math.pi
        gl.perspective(fov, WIDTH/2, HEIGHT/2, -WIDTH,
                        WIDTH/2, HEIGHT/2, 0)

        gl.translate(WIDTH/2, HEIGHT/2)
        gl.scale(WIDTH * (1/aspect), HEIGHT)
        if fancy.fixaspect then
            fancy.fixaspect(aspect)
        end
        -- TODO: draw fancy animation
    end

    if mode == "fancy" or mode == "minimal" then
        gl.ortho()
        gl.translate(WIDTH/2, HEIGHT/2)
        gl.scale(WIDTH * (1/aspect), HEIGHT)
        if fancy.fixaspect then
            fancy.fixaspect(aspect)
        end
        drawQueru(now)
    end
end

----------------------------------------------
return fancy

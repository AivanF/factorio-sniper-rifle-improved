-- From here: https://gist.github.com/kymckay/25758d37f8e3872e1636d90ad41fe2ed
-- Fixed & adopted by AivanF

local perlin = {}
perlin.p = {}

-- Hash lookup table as defined by Ken Perlin
-- This is a randomly arranged array of all numbers from 0-255 inclusive
local permutation = {151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
}

-- p is used to hash unit cube coordinates to [0, 255]
for i=0,255 do
    -- Convert to 0 based index table
    perlin.p[i] = permutation[i+1]
    -- Repeat the array to avoid buffer overflow in hash function
    perlin.p[i+256] = permutation[i+1]
end

-- Return range: [-1, 1]
function perlin.noise3d(x, y, z)
    y = y or 0
    z = z or 0

    -- Calculate the "unit cube" that the point asked will be located in
    local xi = bit32.band(math.floor(x),255)
    local yi = bit32.band(math.floor(y),255)
    local zi = bit32.band(math.floor(z),255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)
    z = z - math.floor(z)

    -- We also fade the location to smooth the result
    local u = perlin.fade(x)
    local v = perlin.fade(y)
    local w = perlin.fade(z)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local p = perlin.p
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A   = p[xi  ] + yi
    AA  = p[A   ] + zi
    AB  = p[A+1 ] + zi
    AAA = p[ AA ]
    ABA = p[ AB ]
    AAB = p[ AA+1 ]
    ABB = p[ AB+1 ]

    B   = p[xi+1] + yi
    BA  = p[B   ] + zi
    BB  = p[B+1 ] + zi
    BAA = p[ BA ]
    BBA = p[ BB ]
    BAB = p[ BA+1 ]
    BBB = p[ BB+1 ]

    -- Take the weighted average between all 8 unit cube coordinates
    return perlin.lerp(w,
        perlin.lerp(v,
            perlin.lerp(u,
                perlin.grad3d(AAA,x,y,z),
                perlin.grad3d(BAA,x-1,y,z)
            ),
            perlin.lerp(u,
                perlin.grad3d(ABA,x,y-1,z),
                perlin.grad3d(BBA,x-1,y-1,z)
            )
        ),
        perlin.lerp(v,
            perlin.lerp(u,
                perlin.grad3d(AAB,x,y,z-1), perlin.grad3d(BAB,x-1,y,z-1)
            ),
            perlin.lerp(u,
                perlin.grad3d(ABB,x,y-1,z-1), perlin.grad3d(BBB,x-1,y-1,z-1)
            )
        )
    )
end

-- 2D is 18% faster compared to 3D (z=0)
function perlin.noise2d(x, y)
    y = y or 0

    -- Calculate the "unit cube" that the point asked will be located in
    local xi = bit32.band(math.floor(x),255)
    local yi = bit32.band(math.floor(y),255)

    -- Next we calculate the location (from 0 to 1) in that cube
    x = x - math.floor(x)
    y = y - math.floor(y)

    -- We also fade the location to smooth the result
    local u = perlin.fade(x)
    local v = perlin.fade(y)

    -- Hash all 8 unit cube coordinates surrounding input coordinate
    local p = perlin.p
    local A, AA, AB, AAA, ABA, AAB, ABB, B, BA, BB, BAA, BBA, BAB, BBB
    A   = p[xi  ] + yi
    AA  = p[A   ]
    AB  = p[A+1 ]
    AAA = p[ AA ]
    ABA = p[ AB ]
    AAB = p[ AA+1 ]
    ABB = p[ AB+1 ]

    B   = p[xi+1] + yi
    BA  = p[B   ]
    BB  = p[B+1 ]
    BAA = p[ BA ]
    BBA = p[ BB ]
    BAB = p[ BA+1 ]
    BBB = p[ BB+1 ]

    -- Take the weighted average between all 8 unit cube coordinates
    return perlin.lerp(v,
        perlin.lerp(u,
            perlin.grad2d(AAA,x,y),
            perlin.grad2d(BAA,x-1,y)
        ),
        perlin.lerp(u,
            perlin.grad2d(ABA,x,y-1),
            perlin.grad2d(BBA,x-1,y-1)
        )
    )
end

-- Gradient function finds dot product between pseudorandom gradient vector
-- and the vector from input coordinate to a unit cube vertex
perlin.dot_product3d = {
    [0x0]=function(x,y,z) return  x + y end,
    [0x1]=function(x,y,z) return -x + y end,
    [0x2]=function(x,y,z) return  x - y end,
    [0x3]=function(x,y,z) return -x - y end,
    [0x4]=function(x,y,z) return  x + z end,
    [0x5]=function(x,y,z) return -x + z end,
    [0x6]=function(x,y,z) return  x - z end,
    [0x7]=function(x,y,z) return -x - z end,
    [0x8]=function(x,y,z) return  y + z end,
    [0x9]=function(x,y,z) return -y + z end,
    [0xA]=function(x,y,z) return  y - z end,
    [0xB]=function(x,y,z) return -y - z end,
    [0xC]=function(x,y,z) return  y + x end,
    [0xD]=function(x,y,z) return -y + z end,
    [0xE]=function(x,y,z) return  y - x end,
    [0xF]=function(x,y,z) return -y - z end
}
function perlin.grad3d(hash, x, y, z)
    local i = bit32.band(hash, 0xF)
    return perlin.dot_product3d[i](x,y,z)
end
perlin.dot_product2d = {
    [0x0]=function(x,y) return  x + y end,
    [0x1]=function(x,y) return -x + y end,
    [0x2]=function(x,y) return  x - y end,
    [0x3]=function(x,y) return -x - y end,
    [0x4]=function(x,y) return  x + 0 end,
    [0x5]=function(x,y) return -x + 0 end,
    [0x6]=function(x,y) return  x - 0 end,
    [0x7]=function(x,y) return -x - 0 end,
    [0x8]=function(x,y) return  y + 0 end,
    [0x9]=function(x,y) return -y + 0 end,
    [0xA]=function(x,y) return  y - 0 end,
    [0xB]=function(x,y) return -y - 0 end,
    [0xC]=function(x,y) return  y + x end,
    [0xD]=function(x,y) return -y + 0 end,
    [0xE]=function(x,y) return  y - x end,
    [0xF]=function(x,y) return -y - 0 end
}
function perlin.grad2d(hash, x, y)
    local i = bit32.band(hash, 0xF)
    return perlin.dot_product2d[i](x,y,z)
end

-- Fade function is used to smooth final output
function perlin.fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function perlin.lerp(t, a, b)
    return a + t * (b - a)
end

return perlin
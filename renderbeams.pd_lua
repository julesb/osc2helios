local renderbeams = pd.Class:new():register("renderbeams")
local v2 = require("vec2")

function renderbeams:initialize(sel, atoms)
    self.inlets = 5
    self.outlets = 1
    self.dwell = 4
    self.subdivide = 4
    self.x_arr = {}
    self.y_arr = {}
    self.r_arr = {}
    self.g_arr = {}
    self.b_arr = {}
    return true
end

function renderbeams:in_1_list(x)
    --local in_arr = { unpack(x) }
    self.x_arr = x --in_arr
    --pd.post(string.format("in X, len=%d, x_arr=%d", #x, #self.x_arr))
    local out_arr = renderbeams:render(self.x_arr, self.y_arr, self.r_arr, self.g_arr, self.b_arr, self.dwell, self.subdivide)
    --pd.post(string.format("out_arr=%d", #out_arr))

    self:outlet(1, "list", out_arr)
end

function renderbeams:in_1_dwell(d)
    if type(d[1]) == "number" and d[1] > 0 then
        self.dwell = d[1]
        print(string.format("dwell: %s", self.dwell))
    end
end

function renderbeams:in_1_subdivide(s)
    if type(s[1]) == "number" and s[1] > 0 then
        self.subdivide = s[1]
        print(string.format("subdivide: %s", self.subdivide))
    end
end

-- function renderbeams:in_1_bang()
--     pd.post(string.format("bang: x_arr=%d", #self.x_arr))
-- end

function renderbeams:in_2_list(y)
    self.y_arr = y
end

function renderbeams:in_3_list(r)
    self.r_arr = r
end

function renderbeams:in_4_list(g)
    self.g_arr = g
end

function renderbeams:in_5_list(b)
    self.b_arr = b
end

function renderbeams:render(xa, ya, ra, ga, ba, dwell, subdivide)
    local out = {}
    local idx = 1
    local col = 0
    local nbeams = #xa
    --pd.post(string.format("render(): nbeams %d, dwell %d", nbeams, dwell))
    for i=1,nbeams do
        -- Dwell points
        local x = (xa[i] or 0) * 2047
        local y = (ya[i] or 0) * 2047
        local colr = (ra[i] or 0) * 255
        local colg = (ga[i] or 0) * 255
        local colb = (ba[i] or 0) * 255
        local r, g, b
        for d = 1,dwell do
            -- pre / post blank
            if d < dwell / 4 or d > dwell - dwell / 4 then
                r = 0
                b = 0
                g = 0
            else
                r = colr
                g = colg
                b = colb
            end
            out[idx] = x
            idx = idx + 1
            out[idx] = y
            idx = idx + 1
            out[idx] = r
            idx = idx + 1
            out[idx] = g
            idx = idx + 1
            out[idx] = b
            idx = idx + 1
        end

        -- Subdivision
        local p1 = { x=xa[i], y=ya[i] }
        local p2 = { x=xa[i % nbeams + 1], y=ya[i % nbeams + 1] }
        local tvec = v2.sub(p2, p1)
        local dir = v2.normalize(tvec)
        local len = v2.len(tvec)
        local steplen = len / subdivide
        local colr
        local colg
        local colb
        --local stepvec = v2.scale(tvec, 1 / steplen)
        for s=1,subdivide do
            local stepvec = v2.scale(dir, steplen * s)
            pnew = v2.add(p1, stepvec)
            out[idx] = pnew.x * 2048
            idx = idx + 1
            out[idx] = pnew.y * 2048
            idx = idx + 1
            out[idx] = 0
            idx = idx + 1
            out[idx] = 0
            idx = idx + 1
            out[idx] = 0
            idx = idx + 1
        end
    end
    return out
end


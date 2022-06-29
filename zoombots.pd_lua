local zoombots = pd.Class:new():register("zoombots")
local socket = require("socket")
--local zb = require("zbots")


function zoombots:initialize(sel, atoms)
    self.zb = require("zbots")
    self.inlets = 1
    self.outlets = 2
    self.framerate = 30
    --self.xout = {}
    --self.yout = {}
    self.zb.init(16)
    return true
end

function zoombots:in_1_bang()
    local t_prev = t or 0.0
    local t = socket.gettime()
    local dt = t - t_prev
    if dt > 1.0 then dt = 1.0 / self.framerate end
    self.zb.update(dt)
    local bots = self.zb.bots
    --bots[#bots+1] = bots[1] -- connect last to first
    local botsrendered = zoombots:render(bots, 32, 32)
    self:outlet(1, "list", botsrendered)
end

-- function zoombots:in_1_bang()
--     local t_prev = t or 0.0
--     local t = socket.gettime()
--     local dt = t - t_prev
--     if dt > 1.0 then dt = 1.0 / self.framerate end
--     self.zb.update(dt)
--     local bots = self.zb.bots
--     local idx = 0
--     local xout = {}
--     local yout = {}
--     for i=1,#self.zb.bots do
--         idx = i
--         xout[i] = bots[i].pos.x
--         yout[i] = bots[i].pos.y
--     end
--     idx = idx + 1
--     xout[idx] = bots[1].pos.x
--     yout[idx] = bots[1].pos.y
--     self:outlet(2, "list", yout)
--     self:outlet(1, "list", xout)
-- end

function zoombots:render(bots, dwell, subdivide)
    local out = {}
    local idx = 1
    local v2 = require("vec2")
    local col = 0
    for i=1,#bots do
        -- Dwell points
        for d = 1,dwell do
            if d < dwell / 4 or d > dwell - dwell / 4 then
                col = 0
            else
                col = 255
            end
            out[idx] = bots[i].pos.x * 2048
            idx = idx + 1
            out[idx] = bots[i].pos.y * 2048
            idx = idx + 1
            out[idx] = col 
            idx = idx + 1
            out[idx] = col
            idx = idx + 1
            out[idx] = col 
            idx = idx + 1
        end

        -- Subdivision
        local p1 = bots[i].pos
        local p2 = bots[i % #bots + 1].pos
        local tvec = v2.sub(p2, p1)
        local dir = v2.normalize(tvec)
        local len = v2.len(tvec)
        local steplen = len / subdivide
        local col1
        local col2
        local colsel = i % 4
        if colsel == 0 then
            col1 = 255
            col2 = 0
        elseif colsel == 1 then
            col1 = 0
            col2 = 0
        elseif colsel == 2 then
            col1 = 0
            col2 = 255
        else
            col1 = 0
            col2 = 0
        end
        --local stepvec = v2.scale(tvec, 1 / steplen)
        for s=1,subdivide do
            local stepvec = v2.scale(dir, steplen * s)
            pnew = v2.add(p1, stepvec)
            out[idx] = pnew.x * 2048
            idx = idx + 1
            out[idx] = pnew.y * 2048
            idx = idx + 1
            out[idx] = 0.0
            idx = idx + 1
            out[idx] = col1
            idx = idx + 1
            out[idx] = col2
            idx = idx + 1
        end
    end
    return out
end



local zbots = {}
local v2 = require("vec2")

function zbots.init(_numbots)
    zbots.numbots = _numbots or zbots.numbots
    zbots.arrived_dist = 1.0 / 4096.0
    zbots.timeout = 3
    zbots.bots = zbots.initbots(_numbots)
end


function zbots.initbots(num)
    bots = {}
    for i = 1,num do
        bots[i] = zbots.newbot(i)
    end
    return bots
end


function zbots.getbots()
    local bots = zbots.bots
    return bots
end

function zbots.randpos()
    return {
        x = 2.0 * math.random() - 1.0,
        y = 2.0 * math.random() - 1.0
    }
end

function zbots.newbot(_id)
    return {
        id = _id,
        pos = zbots.randpos(),
        vel = {x=0.0, y=0.0},
        target = zbots.randpos(),
        targettimeout = zbots.timeout,
        state = "moving",
        col = math.random(3)
    }
end

function zbots.bottostring(bot)
    return string.format("id: %02d, pos: %s, target: %s, state: %-9s, timeout: %04d",
            bot.id,
            v2.tostring(bot.pos),
            v2.tostring(bot.target),
            bot.state,
            tostring(bot.targettimeout)
            )
end


function zbots.update(dt)
    for i = 1,#zbots.bots do
        local bot = zbots.bots[i]
        if bot.state == "moving" then
            local targetvec = v2.sub(bot.target, bot.pos)
            local targetdist = v2.len(targetvec)
            if targetdist < zbots.arrived_dist then
                bot.state = "at_target"
            else
                bot.pos = v2.add(bot.pos, v2.scale(targetvec, 0.3))
            end
        elseif bot.state == "at_target" then
            bot.targettimeout = bot.targettimeout - 1
            if bot.targettimeout <= 0 then
                bot.target = zbots.randpos()
                bot.targettimeout = 1 --zbots.timeout + math.random(10)
                bot.state = "moving"
            end
        end
    end
end

return zbots

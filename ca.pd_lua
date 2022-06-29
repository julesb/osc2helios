local ca = pd.Class:new():register("ca")
local bit32 = require("bit32")

function ca:initialize(sel, atoms)
    self.inlets = 2
    self.outlets = 1
    self.cells0 = {}
    self.cells1 = {}
    self.ncells = 64
    self.rule = 90 
    self.iters = 0
    self:init(self.ncells)
    return true
end

function ca:init(numcells)
    self.ncells = numcells
    self.cells0={}
    self.cells1={}
    self.iter = 0
    for i=1,numcells do
        self.cells0[i] = 0
        self.cells1[i] = 0
    end
    self.cells0[self.ncells/2] = 1
end


function ca:in_1_bang()
    self:iterate()
    self:outlet(1, "list", self.cells0)
    -- self:printcells(self.cells0)
    self:swap()
end

function ca:in_2_ncells(x)
    local n = x[1]
    self:init(n)
    pd.post(string.format("ncells: %s", self.ncells))
end

function ca:in_2_rule(x)
    local r = x[1]
    if r >= 0 and r < 256 then
        self.rule = r
    end
    pd.post(string.format("rule: %s", self.rule))
end

function ca:seed(n)
    for i=1,n do
        idx = math.random(ncells)
        self.cells0[idx] = 1 - cells[idx]
    end
end


function ca:printcells(c)
    print(table.concat(c, ""))
end

function ca:get_nbcode(idx)
    val = 0
    if idx > 1 and idx < self.ncells then
        val = self.cells0[idx-1] * 4
            + self.cells0[idx  ] * 2
            + self.cells0[idx+1] * 1
    elseif idx == 1 then
        val = self.cells0[self.ncells] * 4
            + self.cells0[idx        ] * 2
            + self.cells0[idx+1      ] * 1
    elseif idx == self.ncells then
        val = self.cells0[idx-1] * 4
            + self.cells0[idx  ] * 2
            + self.cells0[1    ] * 1
    end
    return val
end

function ca:swap()
    temp = self.cells0
    self.cells0 = self.cells1
    self.cells1 = temp
end

function ca:iterate()
   for i=1,self.ncells do
        nbcode = self:get_nbcode(i)
        c = bit32.band(self.rule, bit32.lshift(1, nbcode))
        if c == 0 then
            self.cells1[i] = 0
        else
            self.cells1[i] = 1
        end
    end
    self.iter = self.iter + 1
end

function ca:cellcount()
    count = 0
    for i=1,ncells do
        if cells0[i] == 1 then
            count = count + 1
        end
    end
    return count
end


-- init()
-- for i=1, 50 do
--     iterate()
--     printcells(cells0)
--     swap()
-- end


splitwords = function(str)
    local words = {}
    local oldstr = str

    local idx = oldstr:find(" ")
    while idx do
        -- words:insert(oldstr:sub(1, idx))
        table.insert(words, oldstr:sub(1, idx))
        oldstr = oldstr:sub(idx + 1, #oldstr)
        idx = oldstr:find(" ")
    end
    table.insert(words, oldstr)

    return words
end

-- TODO!!
parse = function(file)
    local ins = {}
    local jmp = {}
    local addr = 0

    local line = file:read()
    while line do
        local l = splitwords(line)
        if l[0]:find(":") then
            table.insert(jmp, { l[0]:sub(1, #l[0] - 1), addr })
            table.remove(l, 0)
        end

        table.insert(ins, l)
        line = file:read()
        addr = addr + 4
    end

    return ins, jmp
end

-- lex = function(ins, jmp)
-- end

-- mount = function(ins, out)
-- end

-- input = io.open("bin.txt", "r")
-- out = io.open("aout.bin", "wb")

-- ins = lex(parse(input))
-- mount(ins, out)

-- input:close()
-- out:close()

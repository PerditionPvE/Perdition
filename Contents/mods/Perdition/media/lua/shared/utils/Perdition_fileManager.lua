
---@param path String the file path to write to
function Perdition.FileManager:open(path)
    local file = {}
    setmetatable(file, self)
    self.__index = self
    local reader = getFileReader(path, false)
    if reader then
        file.path = path
        file.lines = {}
        local line = reader:readLine()
        while line ~= nil do -- stop loop once reaching the end
            print(line)
            if line ~= "" then table.insert(file.lines, line) end -- do not append blank lines
            line = reader:readLine()
        end
        reader:close()
    else
        assert(reader, "Cannot open file.")
    end
    return file
end

---@param line string|int the value to write
---@param index int the index to inject into
function Perdition.FileManager:addLine(line, index)
    line = tostring(line) -- convert to string
    if index then
        table.insert(self.lines, line)
    else
        table.insert(self.lines, index, line)
    end
end

function Perdition.FileManager:editLine(line, index)
    line = tostring(line)
    if #self.lines >= index then
        self.lines[index] = line
    else
        self:addLine(line)
    end
end

function Perdition.FileManager:save()
    local file = getFileWriter(self.path, true, false)
    for _, line in ipairs(self.lines) do
        file:write(line .. "\n")
    end
    file:closer()
end
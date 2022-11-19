function doSafehouseBlocker()
    local safehouses = SafeHouse:getSafehouseList()
    for i=0, safehouses:size() - 1 do
        local safehouse = safehouses:get(i)
        print("Blocking item spawns for " .. safehouse:getTitle())
        for y=safehouse:getY(), safehouse:getY2() do
            for x=safehouse:getX(), safehouse:getX2() do
                for z=0, 8 do
                    local cell = getCell()
                    local square = cell:getGridSquare(x, y, z)
                    if square then
                        local stuff = square:getObjects()
                        for o=0, stuff:size() - 1 do
                            local obj = stuff:get(o)
                            if obj then
                                if not (not instanceof(obj, "IsoDeadBody") and not instanceof(obj, "IsoThumpable") and not instanceof(obj, "IsoCompost")) then
                                    for c=0, obj:getContainerCount()-1 do
                                        local container = obj:getContainerByIndex(c)
                                        container:setHasBeenLooted(false)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    print('finished blocking safehouse spawns')
end

Events.EveryHours.Add(doSafehouseBlocker)
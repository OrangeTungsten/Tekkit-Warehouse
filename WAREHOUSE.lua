---@diagnostic disable: undefined-global, undefined-field, lowercase-global, unused-local

-- ╔════════════════════════════════════════════════════════════╗
-- ║  Warehouse Manager                                         ║
-- ║  Tekkit Classic | ComputerCraft + CCSensors                ║
-- ║------------------------------------------------------------║
-- ║  Monitors up to 15 item types across multiple sensor zones ║
-- ║  (5 chests per sensor). Displays item counts, stack        ║
-- ║  counts and EMC values. Supports multi-page navigation     ║
-- ║  and exports items via bundled redstone output.            ║
-- ║------------------------------------------------------------║
-- ║  Author    :  Avram Kovačević                              ╚═══════════════╗
-- ║  GitHub    :  github.com/OrangeTungsten/TekkitClassic-CC-Sensors-Warehouse ║
-- ║  Version   :  1.0                                          ╔═══════════════╝
-- ║  Developed :  Mar, 2022    |   Published:  April, 2026     ║
-- ╚════════════════════════════════════════════════════════════╝


w,h = term.getSize()

Items = {}
Items = {"Coal", "Copper", "Tin", "Iron", "Silver", "Redstone", "Nikolite", "Lapis", "Uranium", "Sapphire", "Dirt", "Cobble", "Gravel", "Glass", "Wood"}
EMC = {}
EMC = {128, 85, 256, 256, 512, 64, 128, 864, 4096, 1024, 1, 1, 4, 1, 8}
TotalItems = {}
ShippedItems = {}
for i=1, #Items do ShippedItems[i] = 0 end
totals = 0
exported = 0

-- Output redston wire colors; must follow Items array
color = {colors.black, colors.orange, colors.white, colors.lightGray, colors.lightBlue, colors.red, colors.gray, colors.blue, colors.yellow, colors.purple, colors.magenta, colors.cyan, colors.green, colors.lime, colors.pink}

-- Paging variables
PAGE_SIZE = 10
totalPages = math.ceil(#Items / PAGE_SIZE)
currentPage = 1
selectREL = 1  -- ypos of cursor *, selection relative to the page, default pos = 1


-- Draws main frame 
function drawMain()

    -- Header
	printCentered("WAREHOUSE", 1)

	term.setCursorPos(1, 2)
	term.write(string.rep("=", w))

	term.setCursorPos(3, 4)
	term.write("Item       Stacks     Total    EMC      ShpEMC")
    
	term.setCursorPos(3, 5)
	term.write(string.rep("-", w-4))
    --Header

	acquireData()
    printValues(currentPage)
	
	term.setCursorPos(3, h-2)  
	term.write(string.rep("-", w-4))

	term.setCursorPos(w-3, h)
	printRightCentered(currentPage .. "/" .. totalPages, w+1, 1)

end


-- Identifying user input
function userInput()
    
    -- Every key hase different code:
    -- UP = 200, DOWN = 208, ENTER = 28, LEFT = 203, PGUP = 201, PGDOWN = 209, END = 207
    local id, key = os.pullEvent("key")

    if key == 207 then -- END
        term.clear()
        term.setCursorPos(1,1)
        error("", 0) -- exit
    end
    if key == 209 then  -- PGDOWN
        if currentPage < totalPages then
            currentPage = currentPage + 1
            selectREL = 1  -- reset cursor pos
        end
    elseif key == 201 then  -- PGUP
        if currentPage > 1 then
            currentPage = currentPage - 1
            selectREL = 1
        end
    elseif key == 208 then  -- DOWN
        if selectREL < getItemsOnPage(currentPage) then
            selectREL = selectREL + 1
        end
    elseif key == 200 then  -- UP
        if selectREL > 1 then
            selectREL = selectREL - 1
        end
    elseif key == 28 then  -- ENTER

        term.setCursorPos(1, h-1)
		term.write(string.rep(" ", w))

		printRightCentered("Quantity: ", 26, h-1)

		term.setCursorPos(27, h-1)

		quantity = tonumber(read())

		if quantity ~= nil then

			quantity = quantity/8 --quantity needs to be divisible by 8 for smoother interaction with Buildcraft Filter. 

			if quantity == math.floor(quantity) then  -- Check if input is divisible by 8

                local selectABS = (currentPage - 1) * PAGE_SIZE + selectREL --used for choosing item to export

				--while true do
	
					printRightCentered(tostring("+" .. tostring(EMC[selectABS] * quantity * 8 .. "?")), 49, selectREL+5) -- Confirm?
					
					local id, key = os.pullEvent("key")
					if key == 28 then -- If enter, export.
						Export(selectABS, quantity)
						--break
					--else break 
					end
				--end
			else
				repeat
					printRightCentered("->Must be divisible by 8!", w+1, h)
					local id, key = os.pullEvent("key")
				until(key == 28 or key == 203) 
			end
		else
			repeat
				printRightCentered("->Invalid input!", w+1, h)
				local id, key = os.pullEvent("key")
			until(key == 28 or key == 203) 
		end

    end


end

-- Acquiring data from sensors
function acquireData()

	os.unloadAPI("sensor")
	os.loadAPI("/rom/apis/sensors")

 	sensorController = sensors.getController()

	sensors.setSensorRange(sensorController, "Sensor1", "10")--arg
	sensors.setSensorRange(sensorController, "Sensor2", "10")
	sensors.setSensorRange(sensorController, "Sensor3", "10")
	
    targets1 = sensors.getAvailableTargetsforProbe(sensorController, "Sensor1", "InventoryInfo")
    targets2 = sensors.getAvailableTargetsforProbe(sensorController, "Sensor2", "InventoryInfo")

    local result = {}

	-- Sensor1
	sensorTargets = sensors.getAvailableTargetsforProbe(sensorController, "Sensor1", "InventoryInfo")

	-- Count TotalItems for each chest and store in TotalItems[i]
 	for i=1, 5 do

		sensorData = sensors.getSensorReadingAsDict(sensorController, "Sensor1", sensorTargets[i+5], "InventoryInfo") -- Returns: EmptySlots, UsedSlots, Size, TotalItems
		-- Note: sensorTargets index offset (+5) depends on the sensor's physical position in the MC world -- must be verified in-game
		TotalItems[i] = sensorData.TotalItems

	end 

	------------------------------
	
	-- Sensor2
	sensorTargets = sensors.getAvailableTargetsforProbe(sensorController, "Sensor2", "InventoryInfo")

	-- Count TotalItems for each chest and store in TotalItems[i+5]
	for i=1, 5 do

		sensorData = sensors.getSensorReadingAsDict(sensorController, "Sensor2", sensorTargets[i+5], "InventoryInfo") -- Returns: EmptySlots, UsedSlots, Size, TotalItems
		-- Note: sensorTargets index offset (+5) depends on the sensor's physical position in the MC world -- must be verified in-game
		TotalItems[i+5] = sensorData.TotalItems

	end 

	------------------------------

	-- Sensor3
	sensorTargets = sensors.getAvailableTargetsforProbe(sensorController, "Sensor3", "InventoryInfo")

	-- Count TotalItems for each chest and store in TotalItems[i]
	for i=1, 5 do

		sensorData = sensors.getSensorReadingAsDict(sensorController, "Sensor3", sensorTargets[i+5], "InventoryInfo") -- Returns: EmptySlots, UsedSlots, Size, TotalItems
		-- Note: sensorTargets index offset (+5) depends on the sensor's physical position in the MC world -- must be verified in-game
		TotalItems[i+10] = sensorData.TotalItems

	end 

	------------------------------

	-- Footer totals
	totalEMC = 0
	for i=1, #Items do
		totalEMC = totalEMC + TotalItems[i] * EMC[i]
	end 

	totalShippedEMC = 0
	for i=1, #Items do
		totalShippedEMC = totalShippedEMC + ShippedItems[i] * EMC[i]
	end
	

end

-- Prints sensor data
function printValues(panel)

    if panel == 1 then
		firstItem = 1
		lastItem = 10
	elseif panel == 2 then
		firstItem = 11
		lastItem = 15 -- Depends on how many items you have in observation
	end

	n = 1
	for i = firstItem, lastItem do 
		
		-- Item name
		term.setCursorPos(3, n+5)
		term.write(Items[i])

		-- Stacks
		printRightCentered(tostring(math.floor(TotalItems[i]/64)), 19, n+5)
		
		-- Total
		printRightCentered(tostring(math.floor(TotalItems[i])), 29, n+5)
		
		-- EMC
		printRightCentered(tostring(EMC[i]), 37, n+5)

		-- Shipped EMC
		printRightCentered(tostring(ShippedItems[i]*EMC[i]), 48, n+5)

		n = n + 1

	end
	n = 1

    term.setCursorPos(20, h-1)
	term.write("TotalEMC: ")
	printRightCentered(tostring(totalEMC), 37, h-1)
	printRightCentered(tostring(totalShippedEMC), 48, h-1)

end

function Export(item, qty)
	
	
	for i=1, qty do

		printRightCentered(".", w+1-i , h) --progress "bar"

		redstone.setBundledOutput("bottom", color[item])
		sleep(0.25)
		redstone.setBundledOutput("bottom", 0)
	 	sleep(0.25)

	end

	ShippedItems[item] = ShippedItems[item] + (qty * 8)

end

function getItemsOnPage(page)
    local first = (page - 1) * PAGE_SIZE + 1
    local last = math.min(page * PAGE_SIZE, #Items)
    return last - first + 1
end

function printCentered(str, ypos)
	term.setCursorPos((w+1)/2 - #str/2, ypos)
	term.write(str)
end

function printRightCentered(str, xpos, ypos)
	term.setCursorPos(xpos-#str, ypos)
	term.write(str)
end


-- Main loop
while true do

	term.clear()
	drawMain()

	-- Selection cursor (*)
	term.setCursorPos(2, selectREL+5)
	term.write("*")

    -- Wait for the user input
    userInput()

end
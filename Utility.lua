local Utility = {}
Utility.__index = Utility

--[[
	The TableCut function takes in a table and creates a copy table that is then returned.

	table_toCut -> The table to copy out of
	number_startIndex -> The start index of the cut
	number_endIndex -> The end index of the cut, if not supplied the end index is the length of the table
	
	returns the copied table
]]
local function tableCut(table_toCut, startIndex : number, endIndex : number)
	assert(typeof(table_toCut) == "table", "First argument must be of type table")
	assert(typeof(startIndex) == "number", "Second argument must be of type number")
	assert(startIndex < #table_toCut, "Second argument must be smaller than the table size")
	if endIndex then
		assert(typeof(endIndex) == "number", "Third argument must be of type nil or type number")
		assert(endIndex > startIndex, "Third argument must be greater than the second argument")
		assert(endIndex <= #table_toCut, "Third argument must be smaller than or equal to the size of the table")
	end

	local toReturn = {}
	local ending = #table_toCut
	if endIndex then
		ending = endIndex
	end
	for i=startIndex, ending do
		table.insert(toReturn, table_toCut[i])
	end
	return toReturn
end

--[[
	The FindAndDo function takes a table or dictionary, and searches the table for a value to find. There is an optional argument for the variant "key" to be added, that will index the "key" value in each object, then
	compare it to the value to find. If the value is found, the function that is called will be fired, given two arguments. The first argument will be the object that was found, the second argument will be the index of the
	found value.

	table_list -> The table to search
	variant_toFind -> The value to search for
	variant_key -> The key to search for, nil if no key to search for
	function_callback -> The function to be called if the value is found
	
	returns the return value of the supplied function
]]
local function findAndDo(table_list, variant_toFind, variant_key, function_callback)
	assert(typeof(table_list == "table"), "The first argument must be of type table")
	assert(variant_toFind ~= nil, "The second argument must not be nil")
	assert(typeof(function_callback) == "function", "The fourth argument must be a function")

	if variant_key == nil then
		for index,value in pairs(table_list) do
			if value == variant_toFind then
				return function_callback(value, index)
			end
		end
	else
		for index,value in pairs(table_list) do
			if value[variant_key] and value[variant_key] == variant_toFind then
				return function_callback(value, index)
			end
		end
	end
	return nil
end

--[[
	The TableContains function searches thte Table for the given value, then if the value is found in the table, returns true. False otherwise. There is an optional argument for the 
	variant "key" to be added, that will index the "key" value in each object, then compare it to the value to find.

	table_list -> The table to search
	variant_toFind -> The value to search for
	variant_key -> The key to search for, nil if no key to search for

	returns true if the value is found, false otherwise
]]
local function tableContains(table_list, variant_toFind, variant_key)
	assert(typeof(table_list == "table"), "The first argument must be a table")
	assert(typeof(variant_toFind) ~= "nil", "The second argument must not be nil")

	if variant_key == nil then
		for index,value in pairs(table_list) do
			if value[variant_key] == variant_toFind then
				return true
			end
		end
	else
		for index,value in pairs(table_list) do
			if value == variant_toFind then
				return true
			end
		end
	end
	return false
end

--[[
	The CopyTable function makes a deep copy of a table

	table_list -> The table to copy

	returns the copied table
]]
local function copyTable (tabl_toCopyOrig)
	assert(typeof(tabl_toCopyOrig) == "table", "First argument must be a table")

	local function copy(tabl_toCopy)
		local toReturn = {}
		for i,v in pairs(tabl_toCopy) do
			if typeof(v) == "table" then
				toReturn[i] = copy(v)
			else
				toReturn[i] = v
			end
		end
		return toReturn
	end
	return copy(tabl_toCopyOrig)
end

--[[
	The GetTablePrint function gets the print data for a supplied table, formatted for easier reading. Recurses for accuracy

	tabl_toPrint -> The table to be printed

	returns a string value representing the table
]]
local function getTablePrint(tabl_toPrint)
	assert(typeof(tabl_toPrint) == "table", "The first argument mustd be of type table")

	local function getTableData(table_toPrint, string_indent, str_toReturn)
		str_toReturn = str_toReturn .. string_indent .. "{" .. "\n"
		local currentIndent = "     "
		for i,v in pairs(table_toPrint) do
			str_toReturn = str_toReturn .. currentIndent .. string_indent .. "Index: " .. tostring(i) .. ", Value: "
			if typeof(v) == "table" then
				str_toReturn = str_toReturn .. "table: " .. "\n"
				str_toReturn = getTableData(v, string_indent .. currentIndent, str_toReturn)
			else
				str_toReturn = str_toReturn .. tostring(v) .. "\n"
			end
		end
		str_toReturn = str_toReturn.. string_indent .. "}" .. "\n"
		return str_toReturn
	end

	return getTableData(tabl_toPrint, "", "")
end

--[[
	The IsContainedIn function checks to see whether the Vector2 VectorA is located inside of the object defined by position Vector2 VectorB and size of Vector2 sizeB. This is mostly
	useful for gui implementations, to see if a supplied Vector2 is inside of a gui object.

	Vector2_vectorA -> The Vector to be checked
	Vector2_vectorB -> The position Vector of the object
	Vector2_sizeB -> The size of the object
	bool_includeInset -> Whether or not to include the GUI inset from the ROBLOX topbar
	
	returns whether or not the value is within the 
]]
local function isContainedIn(vectorA : Vector2, vectorB : Vector2, sizeB : Vector2, includeInset : boolean)
	assert(typeof(vectorA) == "Vector2", "Argument one must be of type Vector2")
	assert(typeof(vectorB) == "Vector2", "Second argument must be of type Vector2")
	assert(typeof(sizeB) == "Vector2", "Third argument must be of type Vector2")

	local inset = 0
	if includeInset then
		inset = game:GetService("GuiService"):GetGuiInset().Y
	end

	return (vectorA.X > vectorB.X and vectorA.X < vectorB.X + sizeB.X) and (vectorA.Y > vectorB.Y and vectorA.Y < vectorB.Y + sizeB.Y + inset)
end

--[[
	The CalculateDistanceXZ function is used to calculate a flat difference in magnitude between 2 vectors, without regard to the Y axis. This is useful to see whether or not something is within a certain radius
	when the Y axis is calculated differently (Cylindrical object area calculation)
	
	Vector3_posA -> The position of the first vector
	Vector3_posB -> The position of the second vector
	
	returns the distance, as a number
]]
local function calculateDistanceXZ(posA : Vector3, posB : Vector3)
	assert(typeof(posA) == "Vector3", "First argument must be of type Vector3")
	assert(typeof(posB) == "Vector3", "Second argument must be of type Vector3")

	return math.sqrt(math.pow(posB.X - posA.X, 2) + math.pow(posB.Z - posA.Z, 2))
end

--[[
	The PageIterator function works as an iterator to move over a Pages Object, being a universal method of doing so.

	Pages_pages -> The object to be iterated over

	returns a coroutine wrapped function that iterates over the pages object
]]
local function pageIterator(page : Pages)
	assert(typeof(page) == "Instance" and page:IsA("Pages"), "First argument must be of type Pages")

	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(page:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if page.IsFinished then
				break
			end
			page:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

--[[
	The PrintTable function imply prints the table provided

	table_toPrint -> The table to print
	
	returns nil
]]
local function printTable(table_toPrint)
	print(getTablePrint(table_toPrint))
end

--[[
	The NumberWithCommas function takes a number, and adds commas between the number to break it into easier to read pieces

	int64_number -> The number to be processed
	
	returns a string that is the number with commas. Example: 100,000
]]
local function numberWithCommas(num : number)
	assert(typeof(num) == "number", "First argument must be of type number")

	local str = tostring(num)
	local counter = string.len(str) - 3
	while counter >= 3 do
		str = string.sub(str, 1, counter) .. "," .. string.sub(str, counter+1)
		counter = counter - 3
		wait()
	end

	return str
end

--[[
	The SetModelTransparency function sets all instances of type BasePart (including the top of the tree) to the value that is given. This function
	recursively iterates over all descendants of the root object given. First argument must be of type instance, second argument must be of type number

	Model_model -> The root object to change and iterate over
	number_transparency -> the value for transparency to set the model at
]]
local function setModelTransparency(model : Model, transparency : number)
	assert(typeof(model) == "Instance", "The first argument must be of type Instance")
	assert(typeof(transparency) == "number", "The second argument must be of type number")

	local function recurse(Variant_model)
		if Variant_model:IsA("BasePart") then
			Variant_model.Transparency = transparency
		end
		for _,v in pairs(Variant_model:GetChildren()) do
			recurse(v)
		end
	end

	recurse(model)
end

--[[
	The CleanTable function takes in a table and dereferences every key inside of it. Also recursively dereferences for completeness.

	table_toClean -> The table to be dereferenced
	
	returns nil
]]
local function cleanTable(table_toClean)
	if _G.DEBUG then
		warn("Cleaning!")
	end
	assert(typeof(table_toClean) == "table", "First argument must be of type table")

	local function cleanTable(table_internalClean)
		for i,v in pairs(table_internalClean) do
			local Type = typeof(v)
			if Type == "table" then
				cleanTable(v)
			elseif Type == "RBXScriptConnection" then
				v:Disconnect()
			elseif Type == "Instance" then
				pcall(function() v:Destroy() end)
			end
			table_internalClean[i] = nil
		end
	end

	cleanTable(table_toClean)
end

Utility.TableCut 				= tableCut
Utility.FindAndDo 				= findAndDo
Utility.TableContains 			= tableContains
Utility.CopyTable	 			= copyTable
Utility.GetTablePrint 			= getTablePrint
Utility.IsContainedIn 			= isContainedIn
Utility.CalculateDistanceXZ 		= calculateDistanceXZ
Utility.PageIterator 				= pageIterator
Utility.PrintTable 				= printTable
Utility.NumberWithCommas 		= numberWithCommas
Utility.SetModelTransparency 	= setModelTransparency
Utility.CleanTable 				= cleanTable

return Utility

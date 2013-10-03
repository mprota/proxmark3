-- The getopt-functionality is loaded from pm3/getopt.lua
-- Have a look there for further details
getopt = require('getopt')
bin = require('bin')

example = "script run 14araw -x 6000F57b"
author = "Martin Holst Swende"
usage = "script run htmldump [-f <file>]"
desc =[[
This script takes a dumpfile and produces a html based dump, which is a 
bit more easily analyzed. 

Arguments:
	-h 				This help
	-i <file>		Specifies the dump-file (input). If omitted, 'dumpdata.bin' is used	
	-o <filename>	Speciies the output file. If omitted, <curtime>.html is used. 	

]]

-------------------------------
-- Some utilities 
-------------------------------

--- 
-- A debug printout-function
function dbg(args)
	if DEBUG then
		print("###", args)
	end
end 
--- 
-- This is only meant to be used when errors occur
function oops(err)
	print("ERROR: ",err)
end


--- 
-- Usage help
function help()
	print(desc)
	print("Example usage")
	print(example)
end

local function readdump(infile)
	 t = infile:read("*all")
	 --print(string.len(t))
	 len = string.len(t)
	 local len,hex = bin.unpack(("H%d"):format(len),t)
	 --print(len,hex)
	 return hex
end
local function convert_to_js(hexdata)
	if string.len(hexdata) % 32 ~= 0 then 
		return oops(("Bad data, length should be a multiple of 32 (was %d)"):format(string.len(hexdata)))
	end
	local js,i = "[";
	for i = 1, string.len(hexdata),32 do
		js = js .."'" ..string.sub(hexdata,i,i+31).."',\n"
	end
	js = js .. "]"
	return js
end

local function main(args)

	print(desc)
	local input = "dumpdata.bin"
	local output = os.date("%Y-%m-%d_%H%M%S.html");
	for o, a in getopt.getopt(args, 'i:o:h') do
		if o == "h" then return help() end		
		if o == "i" then input = a end
		if o == "o" then output = a end
	end
	-- Validate the parameters
	
	local infile = io.open(input, "r")
	if infile == nil then 
		return ("Could not read file ", input)
	end
	--lokal skel = require("skel")
	local dumpdata = readdump(infile)
	io.close(infile)

	local js_code = convert_to_js(dumpdata)
	--print(js_code)
	local skel = require("htmlskel")
	html = skel.getHTML(js_code);
	
	local outfile = io.open(output, "w")
	if outfile == nil then 
		return oops("Could not write to file ", output)
	end
	outfile:write(html)
	io.close(outfile)
	print(("Wrote a HTML dump to the file %s"):format(output))
end


--[[
In the future, we may implement so that scripts are invoked directly 
into a 'main' function, instead of being executed blindly. For future
compatibility, I have done so, but I invoke my main from here.  
--]]
main(args)
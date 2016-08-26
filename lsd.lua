#!/usr/bin/lua

--
-- LeakedSource Downloader
--
--   A tiny and stupid little automator to query the LeakedSource
--   database (www.leakedsource.com).
--
-- 8/2016; FMMT666(ASkr)
-- https://github.com/FMMT666/lsd.lua
-- www.askrprojects.net
--

--
-- REQUIREMENTS:
--
--  - a Lua interpreter (>=5.1)
--  - wget
--

--
-- USAGE:
--
--  - to be written
--

--
-- LIMITATIONS:
--
--  - type detection (email, user name and IP address) have limitations
--  - no spaces in user names
--  - no dots in user names
--  - no IP address range checks
--  - no IP address wildcards
--  - resulting files will be overwritten without warning or backup
--  - ...
--

--
-- TODO:
--
--  - create output file folder (wget yet throws an error if that doesn't exist)
--

--
-- NOTES:
--
--  - This code uses tabs. Tabs everywhere. Get used to it :-P
--


QUERY_TIME  = 10                 -- anti spam detection delay

LSD_URL     = "https://www.leakedsource.com/main/"
LSD_EMAIL   = "?email="
LSD_USER    = "?username="
LSD_IP      = "?ip="

WGET_CMD    = "wget --quiet "
WGET_DIR    = "results/"         -- write resulting files to this folder; highly recommended!

CHARS_MIN   = 3
CHARS_EMAIL = "[^%a%d_%-%.@]+"   -- allowed chars for email   : letters, digits, "_", "-", ".", "@"
CHARS_USER  = "[^%a%d_%-]+"      -- allowed chars for username: letters, digits, "_", "-"
CHARS_IP    = "[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+" -- minimal IP address detector


HTML_FNAME  = "lsd-results.html" -- name of the HTML file for results (links)

HTML_PRE    = "<!DOCTYPE html>\
<html lang=\"en\">\
	<head>\
		<meta charset=\"utf-8\">\
    <title>lsd.lua results</title>\
  </head>\
  <body>\
		<h1>LeakedSource Results found by lsd.lua</h1>\n<br><br>\n"
HTML_RES    = "<br>"             -- where we will fill in the found content
HTML_POST   = "\n  </body>\
</html>"


--------------------------------------------------------------------------------------------------
-- sleep( n )
-- sleeps for <n> seconds
--------------------------------------------------------------------------------------------------
function sleep(n)
	local t0 = os.clock()
	while os.clock() - t0 <= n do end
end


--------------------------------------------------------------------------------------------------
-- loadFile( filename )
-- Opens the text file with name <filename> and returns its contents in a table, each
-- table element representing one line.
-- No error checks, call with pcall(). You have been warned.
--
-- Notice the capital F in loadFile!
--   (Just saying... :-)
-- 
-- RETURNS:
--   - A table, if everything went fine: { <line1>, <line2>, ... }. Can be empty.
--------------------------------------------------------------------------------------------------
function loadFile( filename )
	local lines = {}

	for line in io.lines( filename ) do
		table.insert( lines, line )
	end

	return lines
end


--------------------------------------------------------------------------------------------------
-- snipSpaces( line )
-- Removes leading and trailing spaces from a atring and returns the result.
--------------------------------------------------------------------------------------------------
function string:snipSpaces(  )
	return self:gsub("^%s*(.-)%s*$", "%1")
end


--------------------------------------------------------------------------------------------------
-- getType( line )
-- Tries to determine if the given <line> is an email address, a user name or an IP address.
-- 
-- RETURNS:
--  "email"     - for email
--  "username"  - for user name
--  "ipaddress" - for an IP address
--  nil         - for an error
--------------------------------------------------------------------------------------------------
function getType( line )
	-- check length
	if #line < CHARS_MIN then
		return nil
	end

	-- do not allow any further spaces now
	if line:match(" ") then
		return nil
	end

  -- check for a valid email address
  if line:match("@") then
  	-- any invalid characters?
  	if line:match( CHARS_EMAIL ) then
  		return nil
  	-- more than one "@"?
  	elseif line:find("@.*@") then
  		return nil
  	-- two adjacent "." ("..")
  	elseif line:find("[.][.]") then
  		return nil
  	else
  		return "email"
  	end
  end -- end email check

	-- check fo a username (method: no dots or spaces allowed)
	if not line:match("[.]") then
		-- any invalid characters?
  	if line:match( CHARS_USER ) then
  		return nil
		else
			return "username"
		end
	end -- end user name check
	
	-- check for an IP address
	if line:match( CHARS_IP ) then
		return "ipaddress"
	end
  
	return nil
  
end


--------------------------------------------------------------------------------------------------
-- createFileName( rawname )
-- Tries its best to create a valid file name by replacing illegal or strange characters with
-- valid ones.
--   @ -> _at_
--   . -> -       <- probably not that brilliant, but good for IP addresses (for now :-)
--------------------------------------------------------------------------------------------------
function createFileName( rawName )
	local retName
	retName = rawName:gsub("@", "_at_")
	retName = retName:gsub("[.]", "-")
	return retName
end



--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- check file name argument
if arg[1] == nil then
	print("No file name specified.")
	filename = "lsd-example.txt"
else
	filename = arg[1]
end

-- load file
noErr, lines = pcall( loadFile, filename )

if not noErr then
	print("ERROR opening file '" .. filename .. "'")
	print("exiting...")
	return -1
end

-- notice
print("\n\nANTI SPAM DELAY SET TO " .. QUERY_TIME .. "s\n\n")

-- create an HTML results file with links to the downloaded files
local fileOut = io.open( HTML_FNAME, "w" )
if fileOut then
	fileOut:write( HTML_PRE )
end

local errors = 0
local firstTime = true
-- read line by line from the file and process them
for _,line in pairs( lines ) do
	local lsdUrl      = ""
	
	print("------")
	
	-- remove leading and trailing spaces
	line = line:snipSpaces()
	
	-- try to determine the type of the string (email, username, IP-address)
	typeStr = getType( line )

	-- probably better to only process those lines without an error...
	if typeStr then
		local strGet      = ""
		local wgetFileName = createFileName( line )

		-- sleep
		if firstTime then
			firstTime = false
		else
			io.write("SLEEP: ")
			io.flush()
			sleep( QUERY_TIME )
			print("done")
		end

		-- some info
		if typeStr == "email" then
			io.write("EMAIL: ")
			lsdUrl = LSD_URL .. LSD_EMAIL .. line
		elseif typeStr == "username" then
			io.write("USER : ")
			lsdUrl = LSD_URL .. LSD_USER .. line
		elseif typeStr == "ipaddress" then
			io.write("IP   : ")
			lsdUrl = LSD_URL .. LSD_IP .. line
		end

		-- create a command line string
		strGet = WGET_CMD .. lsdUrl .. " -O " .. WGET_DIR .. wgetFileName .. ".html &"

		-- show some info
		print( line )
		print("       " .. wgetFileName ) 
		print("       " .. lsdUrl )
		print("       " .. strGet )

		-- fetch the file
--		os.execute( strGet )

		-- create a link in the output file
		fileOut:write("    <a href=\"" .. WGET_DIR .. wgetFileName .. ".html\">" .. line .. "</a><br>\n")
		fileOut:write("    <a href=\"" .. lsdUrl .. "\">" .. "see at LeakedSource " .. "</a><br><br>\n")

	else
	 -- none of "email", "username" or "ip" detected
--		io.write("ERROR: ")
		print("SKIP : " .. line )
		errors = errors + 1
	end

	
end -- for all lines in file


-- close the results file
if fileOut then
	fileOut:write( HTML_POST )
	fileOut:close()
end



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
-- NOTES:
--
--  - This code uses tabs. Tabs everywhere. Get used to it :-P
--

LOAD        = false              -- if false (default) files are not fetched from LeakedSource; only results file is written

QUERY_TIME  = 10                 -- anti spam detection delay

LSD_URL     = "https://www.leakedsource.com/main/"
LSD_EMAIL   = "?email="
LSD_USER    = "?username="
LSD_IP      = "?ip="

HIBP_URL    = "https://haveibeenpwned.com/api/v2/breachedaccount/"

WGET_CMD    = "wget --quiet "
WGET_DIR    = "results/"         -- write resulting files to this folder; highly recommended!

CHARS_MIN   = 3
CHARS_EMAIL = "[^%a%d_%-%.@]+"   -- allowed chars for email   : letters, digits, "_", "-", ".", "@"
CHARS_USER  = "[^%a%d_%-]+"      -- allowed chars for username: letters, digits, "_", "-"
CHARS_IP    = "[0-9]+%.[0-9]+%.[0-9]+%.[0-9]+" -- minimal IP address detector


HTML_FNAME  = "lsd-results.html" -- name of the HTML file for results (links)

HTML_PRE    = "<!DOCTYPE html>\
<html lang=\"en\">\
	<head>\
		<meta charset=\"utf-8\">\
    <title>lsd.lua results</title>\
  </head>\
  <body>\
		<h1>LeakedSource Results Links</h1>\n<br><br>\n"
HTML_POST   = "\n    <br><br>\n  </body>\
</html>"
HTML_RULER  = "  <hr style=\"background:#444444; border:0; height:3px\">\n"

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
-- Tries to determine if the given <line> is an email address, a user name, an IP address
-- or a ruler or whatever...
-- 
-- RETURNS:
--  "email"     - for email
--  "username"  - for user name
--  "ipaddress" - for an IP address
--  "ruler"     - insert an horizontal ruler tag in the HTML output (triggered via a '###')
--  nil         - for an error
--------------------------------------------------------------------------------------------------
function getType( line )
	-- check length
	if #line < CHARS_MIN then
		return nil
	end

	-- check for a horizontal ruler
	if line:match("^###") then
		return "ruler"
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
  	elseif line:find("%.%.") then
  		return nil
  	else
  		return "email"
  	end
  end -- end email check

	-- check fo a username (method: no dots or spaces allowed)
	if not line:match("%.") then
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
	retName = retName:gsub("%.", "-")
	return retName
end


--------------------------------------------------------------------------------------------------
-- sortArgs( args )
-- Minimal command line argument check.
-- Options or parameters start with a '-'. The last argument without that becomes the file name.
-- RETURNS:
-- { <filename>, <opt1>, <opt2>, ... }
-- If no file name is given, it is replaced with an empty string { "", ... }.
--------------------------------------------------------------------------------------------------
function sortArgs( args )
	local ret = { "" }
	local i = 2

	for _,v in ipairs( args ) do
		if v:match("^[%-]") then
			ret[i] = v
			i = i + 1
		else
			ret[1] = v
		end
	end

	return ret
end



--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

print("\n")

-- sort command line arguments
myArgs = sortArgs( arg )

-- check command line arguments
for i = 2,#myArgs do
	if myArgs[i] == "-load" then
		LOAD = true
	end
end

-- some output
print("LOAD : " .. tostring(LOAD) )

-- check file name argument
io.write("FILE : ")
if myArgs[1] == "" then
	filename = "lsd-example.txt"
else
	filename = myArgs[1]
end
print( filename )

-- load file
noErr, lines = pcall( loadFile, filename )

if not noErr then
	print("FILE : ERROR opening file '" .. filename .. "'")
	print("EXIT : *burp*")
	return -1
end

-- notice
if LOAD then
	print("DELAY: " .. QUERY_TIME .. "s\n\n")
end

-- create an HTML results file with links to the downloaded files
local fileOut = io.open( HTML_FNAME, "w" )
if fileOut then
	fileOut:write( HTML_PRE )
end

local errors = 0
local firstTime = true
-- read line by line from the file and process them
for _,line in pairs( lines ) do
	local lsdUrl = ""
	local hibUrl = ""
	
	print("------")
	
	-- remove leading and trailing spaces
	line = line:snipSpaces()
	
	-- try to determine the type of the string (email, username, IP-address)
	typeStr = getType( line )

	-- probably better to only process those lines without an error...
	if typeStr == "email" or typeStr == "username" or typeStr == "ipaddress" then
		local strGet      = ""
		local wgetFileName = createFileName( line )

		-- sleep
		if firstTime or not LOAD then
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
			lsdUrl = LSD_URL  .. LSD_EMAIL .. line
			hibUrl = HIBP_URL .. line
		elseif typeStr == "username" then
			io.write("USER : ")
			lsdUrl = LSD_URL .. LSD_USER .. line
			hibUrl = HIBP_URL .. line
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
		if LOAD then
			os.execute( strGet )
		end

		-- create a link in the output file
		fileOut:write("    <p style=\"margin-left:2em\">" .. line .. "</p>\n")
		
		if Load then
			fileOut:write("    <p style=\"margin-left:4em\"> \nlocal file: <a href=\"" .. WGET_DIR .. wgetFileName .. ".html\">" .. WGET_DIR .. wgetFileName .. "</a></p>\n")
		end
		fileOut:write("    <p style=\"margin-left:4em\"> \nremote link: <a href=\"" .. lsdUrl .. "\">" .. "see at LeakedSource   " .. "</a><br></p>\n")
		
		if hibUrl ~= "" then
			fileOut:write("    <p style=\"margin-left:4em\"> \nremote link: <a href=\"" .. hibUrl .. "\">" .. "see at HaveIBeenPwned " .. "</a><br></p>\n")
		end

	else
		-- was it a ruler command?
		if typeStr == "ruler" then
			print("RULER: ###")
			fileOut:write( HTML_RULER )
		
		-- none of "email", "username", "ip" or "ruler" detected
		else
			print("SKIP : " .. line )
			errors = errors + 1
		end
	end

	
end -- for all lines in file


-- close the results file
if fileOut then
	fileOut:write( HTML_POST )
	fileOut:close()
end



lsd.lua
=======

Idiot's [LeakedSource][1] and [HaveIBeenPwned][5] Downloader.

TL;DR:  
This is simply a text file (with emails/usernames/...) to HTML converter.

A quickly hacked together tool to automatically query multiple
email addresses or user names from the [LeakedSource][1] database.  
Although there exist plently of other tools to query HaveIBeenPwned,
via its nice (and free) API, I included that here too.

---

If you would like to know whether any of your accounts were part of the latest
hacks, data breaches or leaks, there's probably no way around sites like [LeakedSource][1]
or [HaveIBeenPwned][5]


They have (m/b)illion leaked accounts stored in their databases.
Just enter your email address or any of your user account names, select the
search type (email, user name, ...) and click 'search'.

Easy. Unless you have 50 emails and 50 user names.

Here's what lsd.lua can do for you:  
Create a single text files, containing all your email addresses and user names
(or IP addresses)

    MeHero@example.com
    MeAgain@whatever.net
    Hippie68
    YepItsMe@overhere.org
    #ThisWillBeIgnored
    MyiMeshTrash
    ### <- creates a nice ruler in the HTML ouput
    #Email@will-be.skipped

and let lsd.lua do the job for you.  


---
## Why Lua?

My tools, my rules :-P  
Had to refresh my Lua knowledge for that [PIC32Lua MZ][6] thingy, and why easy if you can do the
same more complicated? Lol...


---
## NEWS

### CHANGES 2016/09/06:

    - added preliminary HaveIBeenPwned links


### CHANGES 2016/09/04:

    - lines starting with ### will now create a ruler in the HTML output

### CHANGES 2016/08/27:

    - fixed some regex stuff
    - downloading via wget is now turned off by default (enable with "-load")
    - slightly nicer HTML output

### CHANGES 2016/08/26:

    - initial upload; functional as in "evening hack"


---
## TODO

  - parsing the HIBP output
  - login
  - cURL in Lua
  - more clever anti spam delay
  - catch SIGINT and finish writing the HTML output
  - ...


---
## License

[WTFPL][4] 1.0, March 2000

You are free to do what the fuck you want to public license.


---
## Requirements

  - [Lua][2] interpreter; anything >=5.1 should be fine
  - [wget][3] downloader


So far, lsd.lua was "tested" (lol) under

  - Linux, 32 bit, 64 bit
  - ...

---
## Usage

  Copy lsd.py in an empty folder and create a subdirectory named 'results'.  
  If you just "cloned" from Git, it's already there...

  Create a text file containing all your email addresses or user names, one per line, let's
  assume 'mydata.txt':

    MeHero@example.com
    MeAgain@whatever.net
    Hippie68
    YepItsMe@overhere.org
    #ThisWillBeIgnored
    MyiMeshTrash
    #Email@will-be.skipped

  Lines starting with a '#' will be skipped.
  
  Lines starting with a '###' will create an horizontal ruler in the HTML output file.

  Run lsd.lua with the file name as argument.  
  If you omit the name, 'lsd-example.txt' will be read.  
  
    lua lsd.lua mydata.txt

  Or make it executable (Un*x only):

    chmod +x lsd.lua

  After that, you should be able to just type

    ./lsd.lua mydata.txt
  
  If that doesn't work, adjust the first line of lsd.lua

    #!/usr/bin/lua

  and point it to your Lua interpreter, e.g.:
  
    #!/usr/bin/lua5.3
    #!/usr/bin/lua5.2
    #!/usr/local/bin/luaMeh

  If called without any other arguments, lsd.lua does nothing else but create a HTML file "lsd-results.html",
  containing querying links to the LeakedSource web site.
  
  If you want to automatically download the LeakedSource result pages, just add a

    -load

  parameter anywhere:

    ./lsd.lua mydata.txt -load

  The output file names are the email addresses, user names or IP addresses with special characters removed.  
  E.g.

    Hehe@here.org    ->    Hehe_at_here-org.html
    192.186.1.1      ->    192-168-1-1.html

  That doesn't look that nice, but it's probably safer for systems that don't like that many dots...

  ...


---
## Parameters

  The order of parameters and file name is arbitrary.

     name    name of file to load;
             if multiple arguments without '-' are given, the last one is used.
    -load    also download each result file from LeakedSource; off by default


---
## Limitations

  - so far only email, user name and IP-address are supported
  - type detection (email, user name and IP address) might have limitations
  - no spaces in user names
  - no dots in user names
  - no IP address range checks; enter BS, get BS...
  - no IP address wildcards
  - resulting files will be overwritten without warning or backup
  - ...


---
Have fun  
FMMT666(ASkr)  



[1]: https://www.leakedsource.com
[2]: https://www.lua.org
[3]: https://www.gnu.org/software/wget
[4]: https://en.wikipedia.org/wiki/WTFPL
[5]: https://haveibeenpwned.com
[6]: https://github.com/FMMT666/PIC32LuaMZ

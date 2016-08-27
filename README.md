lsd.lua
=======

Idiot's [LeakedSource][1] Downloader.

A quickly hacked together tool to automatically query multiple
email addresses or user names from the [LeakedSource][1] database.

---

If you would like to know whether any of your accounts were part of the latest
hacks, data breaches or leaks, there's probably no way around [LeakedSource][1].

They have more than 2 billion leaked accounts stored in their database.
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
    #Email@will-be.skipped

and let lsd.lua do the job for you.  


---
## NEWS

### CHANGES 2016/08/26:

    - initial upload; functional as in "evening hack"


---
## TODO

  - just notices some further regex errors ([.][.])
  - turning off downloads
  - parsing the output
  - login
  - more clever anti spam delay
  - nicer output layout
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

    Hehe@here.org    ->    Hehe_at_here_org.html
    192.186.1.1      ->    192_168_1_1.html



  ...
  
  HTML parser pending :-)

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
  - suppressed the error output right now (illegal email addresses or user names)
  - resulting files will be overwritten without warning or backup
  - ...


---
Have fun  
FMMT666(ASkr)  



[1]: https://www.leakedsource.com
[2]: https://www.lua.org
[3]: https://www.gnu.org/software/wget
[4]: https://en.wikipedia.org/wiki/WTFPL

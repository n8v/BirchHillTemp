These PHP scripts spider the source weather data sources for the BirchHillTemp iOS app and cache it for responsiveness (not that our dozens of users would hit the sources all that hard) and most importantly, transform into a consistent JSON structure for the iOS app and potential other applications

## TODO
- refactor
- set expire to pubdate + ttl instead of cachedate + ttl
- remove tag from json array



https://www.nscfairbanks.org/NSCFwxgather/index.php?nocache=123
https://www.nscfairbanks.org/NSCFwxgather/index.php?nocache=123&jsonp

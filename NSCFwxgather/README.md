These PHP scripts spider the source weather data sources for the BirchHillTemp iOS app and cache it for responsiveness (not that our dozens of users would hit the sources all that hard) and most importantly, transform into a consistent JSON structure for the iOS app and potential other applications

## TODO
- refactor
- set expire to pubdate + ttl instead of cachedate + ttl
- nocache param
- jsonp param
- seek local realtime.txt

These PHP scripts spider the source weather data sources for the BirchHillTemp iOS app and cache it for responsiveness (not that our dozens of users would hit the sources all that hard) and most importantly, transform into a consistent JSON structure for the iOS app and potential other applications


## examples of additional params to backend:

https://www.nscfairbanks.org/NSCFwxgather/birchhill.php?nocache=123

https://www.nscfairbanks.org/NSCFwxgather/birchhill.php?nocache=123&jsonp=1



## TODO
-  mark stale if pubdate older than `Date.parse('now - 48 hours')`
-  use visibility api to quiesce in background
-  badge
-  faviconomatic

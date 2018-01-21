These PHP scripts spider the source weather data sources for the BirchHillTemp iOS app and cache it for responsiveness (not that our dozens of users would hit the sources all that hard) and most importantly, transform into a consistent JSON structure for the iOS app and potential other applications


## examples of additional params to backend:

https://www.nscfairbanks.org/trail-temperatures/birchhill.php?nocache=123

https://www.nscfairbanks.org/trail-temperatures/birchhill.php?nocache=123&jsonp=1


### test locally
```
php -t trail-temperatures/ -S 127.0.0.1:8081
```

### neat ftp tricks
```
NSCFPASS=xxxx
lftp nordicskier:$NSCFPASS@www.nscfairbanks.org
cd nscfairbanks.org/trail-temperatures
repeat 30 mirror -R -v --exclude cache --exclude .git --dereference
```


## TODO
- make backend more resilient eg avoid, ```
<br />
<b>Warning</b>:  file_get_contents(http://www.goldstreamsports.com/weather/realtime.txt): failed to open stream: HTTP request failed! HTTP/1.1 404 Not Found

 in <b>/Users/nathan/BirchHillTemp/trail-temperatures/goldstream.php</b> on line <b>22</b><br />
Errors parsing date ' 'Array
(
    [warning_count] => 0
    [warnings] => Array
        (
        )

    [error_count] => 3
    [errors] => Array
        (
            [0] => A two digit day could not be found
            [1] => Data missing
        )

)
"
responseText
:
"<br />
<b>Warning</b>:  file_get_contents(http://www.goldstreamsports.com/weather/realtime.txt): failed to open stream: HTTP request failed! HTTP/1.1 404 Not Found

 in <b>/Users/nathan/BirchHillTemp/trail-temperatures/goldstream.php</b> on line <b>22</b><br />
Errors parsing date ' 'Array
(
    [warning_count] => 0
    [warnings] => Array
        (
        )

    [error_count] => 3
    [errors] => Array
        (
            [0] => A two digit day could not be found
            [1] => Data missing
        )

)
"
```

-  use visibility api to quiesce in background
-  faviconomatic ... wordpress site has favicon
-  favicon badge temp

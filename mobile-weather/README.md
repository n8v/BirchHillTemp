These PHP scripts spider the source weather data sources for the BirchHillTemp iOS app and cache it for responsiveness (not that our dozens of users would hit the sources all that hard) and most importantly, transform into a consistent JSON structure for the iOS app and potential other applications


## examples of additional params to backend:

https://www.nscfairbanks.org/mobile-weather/birchhill.php?nocache=123

https://www.nscfairbanks.org/mobile-weather/birchhill.php?nocache=123&jsonp=1


### test locally
```
php -t mobile-weather/ -S 127.0.0.1:8081
```

### neat ftp tricks
```
NSCFPASS=xxxx
lftp nordicskier:$NSCFPASS@www.nscfairbanks.org
cd nscfairbanks.org/mobile-weather
repeat 30 mirror -R -v --exclude cache --exclude .git --dereference
```


## TODO
-  use visibility api to quiesce in background
-  faviconomatic ... wordpress site has favicon
-  favicon badge temp

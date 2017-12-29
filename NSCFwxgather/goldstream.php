<?php
$tag = "GoldstreamSports";
$url = "http://www.goldstreamsports.com/weather/realtime.txt";
$cachefile = './cache/gswx.json';
$cache_ttl_seconds = 60 * .5;

date_default_timezone_set('America/Anchorage');
$now = getdate();

if (file_exists($cachefile)) {
  $last_modified_time = filemtime($cachefile);

  if ($now[0] < $last_modified_time + $cache_ttl_seconds) {
    $etag = md5_file($cachefile);
    header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
    header("Etag: $etag");

    $expiretime = $last_modified_time + $cache_ttl_seconds;
    header('Expires: '.gmdate('D, d M Y H:i:s \G\M\T', $expiretime));

    if (@strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) == $last_modified_time ||
        @trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
        header("HTTP/1.1 304 Not Modified");
        exit;
    }
    else {
      readfile($cachefile);
      exit;
    }
  }
}


$keys  = explode(" ", "dateyyyymmdd timehhmmss temp hum dew wspeed wlatest bearing rrate rfall press currentwdir beaufortnumber windunit tempunitnodeg pressunit rainunit windrun presstrendval rmonth ryear rfally intemp inhum wchill temptrend tempth ttempth temptl ttemptl windtm twindtm wgusttm twgusttm pressth tpressth presstl tpresstl version build wgust heatindex humidex uv et solarrad avgbearing rhour forecastnumber isdaylight sensorcontactlost wdir cloudbasevalue cloudbaseunit apptemp sunshinehours currentsolarmax issunny");

$raw = file_get_contents($url);

// $rawefawefaw = "14/11/17 02:30:10 17.7 93 16.0 1 0 0 0.00 0.00 30.255 --- 1 mph F in in 2.4 +0.012 0.13 12.86 0.00 59.5 27 17.7 -0.5 17.9 00:00 17.5 00:11 1 00:00 3 00:44 30.255 02:30 30.226 00:00 1.9.4 1099 2 17.7 17.7 0.0 0.000 0 210 0.00 9 0 0 SSW 386 ft 11.8 0.0 0 0";
// see http://wiki.sandaysoft.com/a/Realtime.txt

$tokens = explode(" ", $raw);
// echo "<pre>$raw</pre>";
$dateParts = strptime($tokens[0],'%d/%m/%y');
// echo "parsed date parts:" , print_r($dateParts);
$dateyyyymmdd = sprintf("%04d%02d%02d", $dateParts["tm_year"]+1900, $dateParts["tm_mon"]+1, $dateParts["tm_mday"]);
// echo "<h1>$dateyyyymmdd</h1>";
$tokens[0] = $dateyyyymmdd;

$fields = array();
for ($i=0; $i < count($keys); $i++) {
  $fields[$keys[$i]] = $tokens[$i];
}


$json = array();
$json[$tag] = $fields;
$jsonout = json_encode($json);

file_put_contents($cachefile, $jsonout);

$last_modified_time = $now[0];
$etag = md5($jsonout);
$expiretime = $last_modified_time + $cache_ttl_seconds;
header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
header("Etag: $etag");
header('Expires: '.gmdate('D, d M Y H:i:s \G\M\T', $expiretime));


echo $jsonout;

// echo "<br>";
// echo md5($jsonout);
// echo "<br>";
// echo md5_file($cachefile);

file_put_contents($cachefile, $jsonout);

?>

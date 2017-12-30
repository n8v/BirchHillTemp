<?php
$tag = "UAF";
$url = "http://akclimate.org/wview/wxrss.xml";
$cachefile = './cache/uafwx.json';
$cache_ttl_seconds = 60 * 0.0005;

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


// $keys  = explode(" ", "dateyyyymmdd timehhmmss temp hum dew wspeed wlatest bearing rrate rfall press currentwdir beaufortnumber windunit tempunitnodeg pressunit rainunit windrun presstrendval rmonth ryear rfally intemp inhum wchill temptrend tempth ttempth temptl ttemptl windtm twindtm wgusttm twgusttm pressth tpressth presstl tpresstl version build wgust heatindex humidex uv et solarrad avgbearing rhour forecastnumber isdaylight sensorcontactlost wdir cloudbasevalue cloudbaseunit apptemp sunshinehours currentsolarmax issunny");

// -----------------------------
# https://stackoverflow.com/questions/32641072/current-observation-feed-from-weather-gov-forbidden-403
$options = array(
  'http'=> array(
    'header'=>"User-Agent: Birch Hill Ski Temperature iOS App/v2.15; nathan@tonallyaweso.me\r\n"
  )
);

$context = stream_context_create($options);

$raw = file_get_contents($url, false, $context);

/* $raw = preg_replace('/\<\!\[CDATA\[|\]\]\>|<br *\/?>/', '', $raw); */
// echo "<pre>$raw</pre>";
$fields = array();

if (! preg_match("/^\<\?xml/", $raw)) {
  http_response_code(500);
  echo "Inconceivable XML received from $url";
  exit;
}


$x = simplexml_load_string($raw);
// print "<pre>content:";
// // https://stackoverflow.com/a/31473904/71650
// print (string) $x->channel->item[0]->children('http://purl.org/rss/1.0/modules/content/')->encoded;
// print "</pre>";

$content = $x->channel->item[0]->children('http://purl.org/rss/1.0/modules/content/')->encoded;
if (preg_match('/Temp: *([\d.-]+) *([FC])/', (string)$content, $matches)) {

  $fields['temp'] = $matches[1];
  $fields['tempunitnodeg'] = $matches[2];
}


// You Aren't Gonna Need the other fields

$obsdate = strtotime((string)$x->channel->item[0]->pubDate);
// echo date('Ymd', $obsdate);

$fields['dateyyyymmdd'] = date('Ymd', $obsdate);
$fields['timehhmmss'] = date('H:i:s', $obsdate);
// print "<pre>"; print_r($fields); print "</pre>";
// exit;


// ------------


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
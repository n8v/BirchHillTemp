<?php
$TAG = "NSCFWx";
$URL = "https://www.nscfairbanks.org/wp-content/nscf/weather/realtime.txt";
if (preg_match('/nscfairbanks.org/', $_SERVER['SERVER_NAME'])) {
  $URL = "../wp-content/nscf/weather/realtime.txt";
}

$CACHE_TTL_SECONDS = 60 * .5;
$cachefile = "./cache/$TAG.json";

date_default_timezone_set('America/Anchorage');
include 'functions.php';

if ((! $_GET['nocache']) && serveFromCache($cachefile)) {
  exit;
}

// ----- parse Cumulus realtime.txt -------------------------------

$keys  = explode(" ", "dateyyyymmdd timehhmmss temp hum dew wspeed wlatest bearing rrate rfall press currentwdir beaufortnumber windunit tempunitnodeg pressunit rainunit windrun presstrendval rmonth ryear rfally intemp inhum wchill temptrend tempth ttempth temptl ttemptl windtm twindtm wgusttm twgusttm pressth tpressth presstl tpresstl version build wgust heatindex humidex uv et solarrad avgbearing rhour forecastnumber isdaylight sensorcontactlost wdir cloudbasevalue cloudbaseunit apptemp sunshinehours currentsolarmax issunny");

$raw = file_get_contents($URL);

// $rawefawefaw = "14/11/17 02:30:10 17.7 93 16.0 1 0 0 0.00 0.00 30.255 --- 1 mph F in in 2.4 +0.012 0.13 12.86 0.00 59.5 27 17.7 -0.5 17.9 00:00 17.5 00:11 1 00:00 3 00:44 30.255 02:30 30.226 00:00 1.9.4 1099 2 17.7 17.7 0.0 0.000 0 210 0.00 9 0 0 SSW 386 ft 11.8 0.0 0 0";
// see http://wiki.sandaysoft.com/a/Realtime.txt

$tokens = explode(" ", $raw);
// echo "<pre>$raw</pre>";
$datestring = $tokens[0] . ' ' . $tokens[1];
$d = DateTime::createFromFormat("d/m/y H:i:s", $datestring);
if (!$d) {
  http_response_code(500);
  echo "Errors parsing date '$datestring'";
  print_r(date_get_last_errors());
  exit;
}

$tokens[0] = $d->format('Ymd');
$tokens[1] = $d->format('H:i:s');

$fields = array();
for ($i=0; $i < count($keys); $i++) {
  $fields[$keys[$i]] = $tokens[$i];
}
$fields['pubdate_raw'] = $datestring;
$fields['pubdate_atom'] = $d->format(DATE_ATOM);

// ----- END parse Cumulus realtime.txt -------------------------------


$fields = addMetadataFields($fields);


serveAndCache($fields, $cachefile, $d);

<?php
$TAG = "UAF";
//  this file has way more data than we need but that's what's available I guess?
$URL = "http://dev-acrc.alaska.edu/acrc_wstation/CR1000XSeries_Ten_minute.dat";

$CACHE_TTL_SECONDS = 60 * 10;
$cachefile = './cache/uafwx.json';

date_default_timezone_set('America/Anchorage');
include 'functions.php';

if ((! $_GET['nocache']) && serveFromCache($cachefile)) {
  exit;
}


// into Cumulus style vars,
// $keys  = explode(" ", "dateyyyymmdd timehhmmss temp hum dew wspeed wlatest bearing rrate rfall press currentwdir beaufortnumber windunit tempunitnodeg pressunit rainunit windrun presstrendval rmonth ryear rfally intemp inhum wchill temptrend tempth ttempth temptl ttemptl windtm twindtm wgusttm twgusttm pressth tpressth presstl tpresstl version build wgust heatindex humidex uv et solarrad avgbearing rhour forecastnumber isdaylight sensorcontactlost wdir cloudbasevalue cloudbaseunit apptemp sunshinehours currentsolarmax issunny");

# https://stackoverflow.com/questions/32641072/current-observation-feed-from-weather-gov-forbidden-403
$options = array(
  'http'=> array(
    'header'=>"User-Agent: Birch Hill Ski Temperature iOS App/v2.15; contact tonallyaweso.me\r\n"
  )
);
$context = stream_context_create($options);

$raw = @file_get_contents($URL, false, $context);
if ($raw === FALSE) {
  $err = error_get_last();
  emitError($err[message]);
  exit;
}


//
// echo "<pre>raw:";
// print_r($raw);
// echo "\n\n\nlength:" . strlen($raw);
// echo "\n</pre>";


$fields = array();

if (! preg_match("/CR1000X/", $raw)) {
  emitError("Inconceivable HTML received from $URL : $raw");
  exit;
}

// $csv = str_getcsv($raw);
$csv = explode("\n",$raw);
// array_shift($csv); # remove file header

// $csv = array_map('str_getcsv', $csv);

// array_walk($csv, function(&$a) use ($csv) {
//   $a = array_combine($csv[0], $a);
// });
// array_shift($csv); # remove column headers
// array_shift($csv); # remove unit headers

$first = str_getcsv($csv[1]);
$last = str_getcsv($csv[count($csv) - 2]);

if (count($first) != count($last)) {
  emitError("Can't use first and last lines in array because unequal length: " . print_r($first,true) . "\n\n" . print_r($last,true));
  exit;
}

// echo "<pre>csv first and last:";
// print_r($first);
// echo "\n\n";
// print_r($last);
// echo "</pre>";

$curvals = array_combine($first, $last);

$first = $last = $csv = $raw = null;
// echo "<pre>curvals:";
// print_r($curvals);
// echo "</pre>";

// this is apparently in UTC
$fields['temp'] = $curvals['Temp_F_Avg'];
$fields['tempunitnodeg'] = 'F';


$datestring = $curvals['TIMESTAMP'];

$d = DateTime::createFromFormat("Y-m-d H:i:s", $datestring, new DateTimeZone('UTC'));
$d->setTimeZone(new DateTimeZone(date_default_timezone_get()));
$fields['pubdate_raw'] = $datestring;
$fields['dateyyyymmdd'] = $d->format('Ymd');
$fields['timehhmmss'] = $d->format('H:i:s');
$fields['pubdate_atom'] = $d->format(DATE_ATOM);



//
// You Aren't Gonna Need the other fields
//

// ------- END parse UAF climate textfile

$fields = addMetadataFields($fields);


serveAndCache($fields, $cachefile, $d);
// echo memory_get_usage();

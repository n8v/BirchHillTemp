<?php
$TAG = "UAF";
$URL = "http://akclimate.org/wview/wxrss.xml";




$CACHE_TTL_SECONDS = 60 * 5;
$cachefile = './cache/uafwx.json';

date_default_timezone_set('America/Anchorage');
include 'functions.php';

if ((! $_GET['nocache']) && serveFromCache($cachefile)) {
  exit;
}

// ----- parse wview XML -------------------------------

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

$fields = array();

if (! preg_match("/^\<\?xml/", $raw)) {
  emitError("Inconceivable XML received from $URL :" + print_r(error_get_last(), true));
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

$datestring = (string)$x->channel->item[0]->pubDate;
// $datestring = '10:36:10, 01/03/18'; // test stale date

$d = DateTime::createFromFormat("H:i:s, m/d/y", $datestring);
if (!$d) {
  emitError("Errors parsing date '$datestring'" + print_r(date_get_last_errors(), true));
  exit;
}

$fields['pubdate_raw'] = $datestring;
$fields['dateyyyymmdd'] = $d->format('Ymd');
$fields['timehhmmss'] = $d->format('H:i:s');
$fields['pubdate_atom'] = $d->format(DATE_ATOM);


// ------- END parse wview XML



$fields = addMetadataFields($fields);


serveAndCache($fields, $cachefile, $d);

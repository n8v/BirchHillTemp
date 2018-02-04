<?php
$TAG = "Ft Wainwright";
$URL = "http://w1.weather.gov/xml/current_obs/PAFB.xml";



// NWS apparently takes 9+ minutes to publish data after observation/pubdate so don't look too early
$CACHE_TTL_SECONDS = 70 * 60;
$cachefile = "./cache/$TAG.json";

date_default_timezone_set('America/Anchorage');
include 'functions.php';

if ((! $_GET['nocache']) && serveFromCache($cachefile)) {
  exit;
}

// ---- parse NWS XML file ----

// into Cumulus style vars,
// $keys  = explode(" ", "dateyyyymmdd timehhmmss temp hum dew wspeed wlatest bearing rrate rfall press currentwdir beaufortnumber windunit tempunitnodeg pressunit rainunit windrun presstrendval rmonth ryear rfally intemp inhum wchill temptrend tempth ttempth temptl ttemptl windtm twindtm wgusttm twgusttm pressth tpressth presstl tpresstl version build wgust heatindex humidex uv et solarrad avgbearing rhour forecastnumber isdaylight sensorcontactlost wdir cloudbasevalue cloudbaseunit apptemp sunshinehours currentsolarmax issunny");

// -----------------------------
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

// echo "<pre>$raw</pre>";
$fields = array();

if (! preg_match("/^\<\?xml/", $raw)) {
  emitError("Inconceivable XML received from $URL : $raw");
  exit;
}



$x = new SimpleXMLElement($raw);


// echo $x->temp_f;
$fields['temp'] = (string) $x->temp_f;
$fields['tempunitnodeg'] = "F";

// You Aren't Gonna Need the other fields

$datestring = (string)$x->observation_time_rfc822;
$d = DateTime::createFromFormat(DATE_RFC2822, $datestring);
if (!$d) {
  emitError("Errors parsing date '$datestring'" + print_r(date_get_last_errors(), true));
  exit;
}

// echo date('Ymd', $obsdate);

$fields['pubdate_raw'] = $datestring;
$fields['dateyyyymmdd'] = $d->format('Ymd');
$fields['timehhmmss'] = $d->format('H:i:s');
$fields['pubdate_atom'] = $d->format(DATE_ATOM);


// ---- END parse NWS XML file ----

$fields = addMetadataFields($fields);


serveAndCache($fields, $cachefile, $d);

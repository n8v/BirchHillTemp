<?php
$TAG = "Canterbury";
$URL = "https://thingspeak.com/channels/339607/feed.json";




$CACHE_TTL_SECONDS = 60 * 20;
$cachefile = './cache/canterbury.json';

date_default_timezone_set('America/Anchorage');
include 'functions.php';

if ((! $_GET['nocache']) && serveFromCache($cachefile)) {
  exit;
}


// into Cumulus style vars,
// $keys  = explode(" ", "dateyyyymmdd timehhmmss temp hum dew wspeed wlatest bearing rrate rfall press currentwdir beaufortnumber windunit tempunitnodeg pressunit rainunit windrun presstrendval rmonth ryear rfally intemp inhum wchill temptrend tempth ttempth temptl ttemptl windtm twindtm wgusttm twgusttm pressth tpressth presstl tpresstl version build wgust heatindex humidex uv et solarrad avgbearing rhour forecastnumber isdaylight sensorcontactlost wdir cloudbasevalue cloudbaseunit apptemp sunshinehours currentsolarmax issunny");

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

if (! preg_match("/^\{\"channel\":\{/", $raw)) {
  emitError("Inconceivable JSON received from $URL : $raw");
  exit;
}


// $x = simplexml_load_string($raw);
$x = json_decode($raw);
$last_entry_index = count($x->feeds) - 1;
$last_entry = $x->feeds[$last_entry_index];

// print "<pre>content:";
// // https://stackoverflow.com/a/31473904/71650
// // print (string) $x->channel->item[0]->children('http://purl.org/rss/1.0/modules/content/')->encoded;
// // print (string) $x->channel;
// print_r($x);
// // $last_entry_id = $x->channel->last_entry_id;
// // print("\nlast entry id:" . $last_entry_id);
//
// print("\nlast entry arr index:" . $last_entry_index);
// print("\nlast entry:" . print_r($last_entry, true));
// print "</pre>";
// exit;

//////////////////////////////////////////////
if ($last_entry->field1 != null) {
  $fields['temp'] = $last_entry->field1;
  $fields['tempunitnodeg'] = 'F';
}

$DUSKLIGHT = 250;
if ($last_entry->field4 != null) {
  $fields['light'] = $last_entry->field4;
  $fields['isdaylight'] = ($fields['light'] > $DUSKLIGHT ? true : false);
}

// You Aren't Gonna Need the other fields

$datestring = (string)$last_entry->created_at;
// print "Datestring: $datestring";

$d = DateTime::createFromFormat(DATE_ATOM, $datestring);

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

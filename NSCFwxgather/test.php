<pre><?

$tokens = explode(' ', '14/11/17 14:30:10');

$datestring = $tokens[0] . ' ' . $tokens[1];
// echo $datestring;
$d = DateTime::createFromFormat("d/m/y H:i:s", $datestring);
if (!$d) {
  http_response_code(500);
  echo "Errors parsing date '$datestring'";
  print_r(date_get_last_errors());
  exit;
}

$dateyyyymmdd = $d->format('Ymd');
// echo $dateyyyymmdd;

// echo phpversion();

echo $d->format('Ymd');
echo $d->format('H:i:s');
echo $d->format(DATE_ATOM);

echo "\n\n\n\n\n";

phpinfo();

<?php

// functions.php

function serveFromCache ($cachefile) {
  global $CACHE_TTL_SECONDS, $URL, $TAG;
  $now = getdate();
  if (file_exists($cachefile)) {
    $last_modified_time = filemtime($cachefile);

    if ( $now[0] < $last_modified_time + $CACHE_TTL_SECONDS && $last_modified_time <= $now[0] ) {
      $etag = md5_file($cachefile);
      header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
      header("Etag: $etag");

      $expiretime = $last_modified_time + $CACHE_TTL_SECONDS;
      header('Expires: '.gmdate('D, d M Y H:i:s \G\M\T', $expiretime));

      if (@strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) == $last_modified_time ||
          @trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
          header("HTTP/1.1 304 Not Modified");
          return true;
      }
      else {
        if ($GET['jsonp']) {
          echo $TAG . 'wx(';
        }

        readfile($cachefile);

        if ($_GET['jsonp']) {
          echo ');';
        }

        return true;
      }
    }
  }
  return false;
}


function addMetadataFields($f) {
  global $CACHE_TTL_SECONDS, $URL, $TAG;
  $f['ttl_s'] = $CACHE_TTL_SECONDS;
  $f['sourceurl'] = $URL;
  $f['tag'] = $TAG;
  return $f;
}



function serveAndCache($fields, $cachefile, $pubdate) {
  global $CACHE_TTL_SECONDS, $URL, $TAG;
  $jsonout = json_encode($fields);

  file_put_contents($cachefile, $jsonout);

  $now = getdate();
  $last_modified_time = $now[0];
  $etag = md5($jsonout);
  $expiretime = $last_modified_time + $CACHE_TTL_SECONDS;
  header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
  header("Etag: $etag");
  header('Expires: '.gmdate('D, d M Y H:i:s \G\M\T', $expiretime));

  if ($_GET['jsonp']) {
    echo $TAG . '(' . $jsonout . ');';
  }
  else {
    echo $jsonout;
  }

  // echo "<br>";
  // echo md5($jsonout);
  // echo "<br>";
  // echo md5_file($cachefile);

  file_put_contents($cachefile, $jsonout);
  // set lastmodified back to pubdate
  // unless pubdate is in the future :P
  if ($pubdate->getTimestamp() < $last_modified_time) {
    $last_modified_time = $pubdate->getTimestamp();
  }
  touch( $cachefile, $last_modified_time );
}


function emitError($message) {
  http_response_code(500);
  $fields = array();
  $fields['ERROR'] = $message;
  echo json_encode($fields);
  exit;
}

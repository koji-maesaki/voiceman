<?php
if( isset( $_FILES["xfile"] ) ) {
	$this_dir = dirname(__FILE__);
	if ( $_FILES["xfile"]["error"] == UPLOAD_ERR_OK ) {
		$tmp_name = $_FILES["xfile"]["tmp_name"];
		$name     = $_FILES["xfile"]["name"];
		move_uploaded_file( $tmp_name, $this_dir."/".$name );
		//echo $tmp_name;
	}
	
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
<meta http-equiv="Content-Language" content="ja" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<title>example</title>
</head>
<body>
<div>
  <form action="./voicemail.php" method="post" enctype="multipart/form-data">
    <div>
      <input type="file" name="xfile" />
    </div>
    <div>
      <input type="submit" />
    </div>
  </form>
</div>
</body>
</html>
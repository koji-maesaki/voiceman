<?php
    // カレントの言語を日本語に設定する
    mb_language("ja");
    // 内部文字エンコードを設定する
    mb_internal_encoding("UTF-8");
    $datetime = date("YmdHis",time());
    if(isset($_REQUEST["email"])){
       $to=htmlspecialchars($_REQUEST["email"]);
    }

//var_dump($_FILES);
if(isset($_POST["upload"]))
{
	if(isset($_FILES["soundFile"]))
	{
	if(is_uploaded_file($_FILES["soundFile"]["tmp_name"]))
	{
		//move_uploaded_file($_FILES["soundFile"]["tmp_name"], $_POST["upload"].".caf");
        move_uploaded_file($_FILES["soundFile"]["tmp_name"], $datetime.".caf");
		//echo "soundfile copy success:";
        
        // メール送信
        sendingmail($datetime,$to);
	}
	}
	else
	{
		//echo "soundFile is not exist.";
	}
}
else
{
	//var_dump($_POST);
}
       //POSTデータの取得確認
       /*******************
       $str="";
       foreach($_REQUEST as $key=>$value){
            $str.=$key."=>".$value."\n";
       }
       file_put_contents("log.txt",$str);
       *******************/
    
    
    function sendingmail($datetime,$to){
        /*----------------------------------------------------------
         添付ファイル付きメールをmb_send_mail()関数で送信する
         ----------------------------------------------------------*/
        // 宛て先アドレス
        $mailTo1      = 'koji@maesaki.name';
        $mailTo2      = 'info.jun@gmail.com';
        
        
        // メールのタイトル
        $mailSubject = '録音ファイルを受け取りました';
        
        // メール本文
        $mailMessage = "宛先は：".$to."です。\n";
        $mailMessage.= '以下の録音ファイルを受け取りました。';
        $mailMessage.= "\n\n";
        $mailMessage.= "http://joc.xsrv.jp/iOS/".$datetime.".caf";
        $mailMessage.= "\n\n";
        
        // 添付するファイル
        $dir = dirname(__FILE__).'/';
        $file = $datetime.".caf";
        $fileName    = $dir.$file;
        //$fileNmae="";
        
        // 差出人のメールアドレス
        $mailFrom    = 'info@joc.xsrv.jp';
        
        // Return-Pathに指定するメールアドレス
        $returnMail  = 'info@joc.xsrv.jp';
        
        // メールで日本語使用するための設定をします。
        mb_language("Ja") ;
        mb_internal_encoding("UTF-8");
        
        $header  = "From: $mailFrom\r\n";
        $header .= "MIME-Version: 1.0\r\n";
        $header .= "Content-Type: multipart/mixed; boundary=\"__PHPRECIPE__\"\r\n";
        $header .= "\r\n";
        
        $body  = "--__PHPRECIPE__\r\n";
        $body .= "Content-Type: text/plain; charset=\"ISO-2022-JP\"\r\n";
        $body .= "\r\n";
        $body .= $mailMessage . "\r\n";
        $body .= "--__PHPRECIPE__\r\n";
        
        // 添付ファイルへの処理をします。
        $handle = fopen($fileName, 'r');
        $attachFile = fread($handle, filesize($fileName));
        fclose($handle);
        $attachEncode = base64_encode($attachFile);
        
        $body .= "Content-Type: image/jpeg; name=\"$file\"\r\n";
        $body .= "Content-Transfer-Encoding: base64\r\n";
        $body .= "Content-Disposition: attachment; filename=\"$file\"\r\n";
        $body .= "\r\n";
    //    $body .= chunk_split($attachEncode) . "\r\n";
        $body .= "--__PHPRECIPE__--\r\n";
        
        // メールの送信と結果の判定をします。セーフモードがOnの場合は第5引数が使えません。
        if (ini_get('safe_mode')) {
            $result = mb_send_mail($mailTo1, $mailSubject, $mailMessage);
            $result = mb_send_mail($mailTo2, $mailSubject, $mailMessage);
         // ▼▼ 現物を添付する ▼▼ //
            //$result = mb_send_mail($mailTo1, $mailSubject, $body, $header);
            //$result = mb_send_mail($mailTo2, $mailSubject, $body, $header);
         // ▲▲ 現物を添付する ▲▲ //
        } else {
            $result = mb_send_mail($mailTo1, $mailSubject, $mailMessage);
            $result = mb_send_mail($mailTo2, $mailSubject, $mailMessage);
            // ▼▼ 現物を添付する ▼▼ //
            //$result = mb_send_mail($mailTo1, $mailSubject, $body, $header,'-f' . $returnMail);
            //$result = mb_send_mail($mailTo2, $mailSubject, $body, $header,'-f' . $returnMail);
            // ▲▲ 現物を添付する ▲▲ //
        }
    }
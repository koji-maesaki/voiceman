#import <Foundation/Foundation.h>
#import "SpeakHereViewController.h"
//#import "SpeakHereController.h"
//#import "HTTPPostSample2ViewController.h"

#import "MultipartPostHelper.h"
@implementation SpeakHereViewController
@synthesize myStr;

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}


- (void)dealloc {
    [speaker release];
    [aqlvm release];
    [r_btn release];
    [btn_play release];
    [aqlvm release];
    [super dealloc];
}

//アラートでOKをタップで終了
-(void) alertView:(UIAlertView *)alertview clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        
// ▼▼ アイコンバッジを動作させる ▼▼
// UIApplicationの取得
UIApplication *app = [UIApplication sharedApplication];
//（例）app.applicationIconBadgeNumber = 0; //非表示
//（例）app.applicationIconBadgeNumber = 3; //3を表示
app.applicationIconBadgeNumber = 0;
// ▲▲ アイコンバッジを動作させる ▲▲        
        [self dealloc];
        //exit(1);
    }else{
        btn_play.enabled =YES;
        message.hidden = YES;
        // btn_record.title = @"再録音";
    }
}
//▼▼▼メールの作成▼▼▼
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"録音メッセージ"];
    
	// 宛先を設定
	NSArray *toRecipients = [NSArray arrayWithObject:@""]; 
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
    NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
	
	[picker setToRecipients:toRecipients];
	
    //添付ファイル名の設定
	NSString *filePath = [NSString stringWithFormat:@"%@/RecordedFile.caf" , 
                          [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
	NSData* fileData = [NSData dataWithContentsOfFile:filePath];
    [picker addAttachmentData:fileData mimeType:@"audio/caf" fileName:filePath];
    
	// メールの本文
	//NSString *emailBody = @"音声データを送信しています";
    NSString *emailBody = @"音声データを自動添付します。メールの宛先は自動入力させることができます。＊非表示にすることはできません。\n\n\n添付ファイルは妙に長くなってしまっています。\n以下は開発用のメモです。";
    emailBody =[emailBody stringByAppendingPathComponent:filePath];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	

    [UIApplication sharedApplication].keyWindow.rootViewController = nil;

    
    [self dismissModalViewControllerAnimated:YES];
	message.hidden = NO;
    btn_play.enabled = YES;

	switch (result)
	{
		case MFMailComposeResultCancelled:
			message.text = @"";
            message.hidden = YES;
            speaker.hidden = NO;
            aqlvm.hidden = NO;
            r_btn.title = @"再録音";
            btn_play.enabled = NO;
            //[self Recording];
            /*********
             SpeakHereController *sphc2 = [[SpeakHereController alloc] init];
             [sphc2 Recording];
             *********/
            exit(1);
			break;
		case MFMailComposeResultSaved:
            exit(1);
			message.text = @"メッセージを一時保存しています";
            r_btn.title = @"送信";
			break;
		case MFMailComposeResultSent:
			message.text = @"送信しました";
            /********************************/
             UIAlertView *alert = [[UIAlertView alloc]
             initWithTitle:@"メール送信"
             message:@"メールの送信が完了しました"
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:@"OK", nil];
             [alert show];
             [alert release];
             /********************************/            
            //exit(1);
			break;
		case MFMailComposeResultFailed:
			message.text = @"失敗しました";
            exit(1);
			break;
		default:
			message.text = @"送信していません";
            exit(1);
			break;
	}
    

}



-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=音声データを送信しています";
	NSString *body = @"&body=音声データを送信しています";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


-(void) CreateMail { 
    speaker.hidden = YES;
    aqlvm.hidden = YES;
    message.hidden = NO;
    
    message.enabled = YES;
	message.text = @"SENDING";
    
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
            message.text = @"メッセージを送信します";
		}
		else
		{
			[self launchMailAppOnDevice];
            message.text = @"メッセージを送信できません";
		}
	}
	else
	{
		[self launchMailAppOnDevice];
        message.text = @"メッセージの送信機能を利用できません。";
	}
    
}
//▲▲▲メールの作成▲▲▲

/**
 * アップロードするファイルをNSDataとして取得する
 */
-(NSData *)getUploadFile
{
    //添付ファイル名の設定
	NSString *dataPath = [NSString stringWithFormat:@"%@/RecordedFile.caf" , 
                          [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    
	NSFileManager *fm = [NSFileManager defaultManager];
	NSData *data;
	if([fm fileExistsAtPath:dataPath])
	{
		NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:dataPath];
		data = [handle readDataToEndOfFile];
		[handle closeFile];
	}
	return data;
}

-(void) PostData2
{
    NSString *sendFileName2 = @"RecFile";
    NSString *emailaddress3 = emailaddress2;
    //添付ファイル名の設定
	NSString *filePath2 = [NSString stringWithFormat:@"%@/RecordedFile.caf" , 
                          [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
	NSData* fileData2 = [NSData dataWithContentsOfFile:filePath2];
    
	// アップロード先URL
    NSString *urlStr = @"http://joc.xsrv.jp/iOS/voiceman.php";
    
	//---------------------------->> 文字列データの作成
	NSArray *stringKeys2 = [[NSArray alloc] initWithObjects:@"upload", @"email",nil];
	NSArray *stringValues2 = [[NSArray alloc] initWithObjects:sendFileName2, emailaddress3, nil];
	NSDictionary *stringDict2 = [[NSDictionary alloc] initWithObjects:stringValues2 forKeys:stringKeys2];
	//---------------------------->> バイナリデータの作成
	NSArray *binaryKeys2 = [[NSArray alloc] initWithObjects:@"data", @"orgName", @"postName", nil];

    NSArray *binaryValues2 = [[NSArray alloc] initWithObjects:(NSData *)[self getUploadFile], @"RecordedFile.caf", @"soundFile", nil];

    NSDictionary *binaryDict2 = [[NSDictionary alloc] initWithObjects:binaryValues2 forKeys:binaryKeys2];

	NSArray *binaries2 = [[NSArray alloc] initWithObjects:binaryDict2, nil];
    
	MultipartPostHelper *postHelper2 = [[MultipartPostHelper alloc] init:urlStr];
    
	// バイナリデータの追加
	[postHelper2 setBinaryValues:binaries2];
	// 文字データの追加
	[postHelper2 setStringValues:stringDict2];
    
	// 送信処理
	NSString *res = [postHelper2 send];
	// 送信先から返されるデータをNSLogで表示
	//NSLog(res);
    /********************************/
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"メール送信"
                          message:[@"音声データを預かりました\n送信先：" stringByAppendingString: emailaddress3]
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
    /********************************/   
}

//▼▼連絡先を表示を実装▼▼
-(void) pickAdd
{
    //音声
    AudioServicesPlaySystemSound(1016);
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];  
    picker.peoplePickerDelegate = self;  
    [self presentModalViewController:picker animated:YES];  
    [picker release];
    
}

- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
    
    //キャンセル
    [self dealloc];
}
// メールアドレスのみを取得
- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(multi)>1) {
        // 複数メールアドレスがある
        // メールアドレスのみ表示するようにする
        [peoplePicker setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]]];
        return YES;
    } else {
        // メールアドレスは1件だけ
        NSString* email = (NSString*)ABMultiValueCopyValueAtIndex(multi, 0);
        NSLog(@"email = %@", email);
        emailaddress2 = email;
        [email release];
        [self dismissModalViewControllerAnimated:YES];
        [self PostData2];
        return NO;
    }
}
// 詳細情報を取得
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    // 選択したメールアドレスを取り出す
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(multi, identifier);
    NSString* email = (NSString*)ABMultiValueCopyValueAtIndex(multi, index);
    emailaddress2 = email;
    NSLog(@"email = %@", email);
    [email release];
    [self dismissModalViewControllerAnimated:YES];
    [self PostData2];
    return NO;
}
//▲▲連絡先を表示を実装▲▲

- (void)viewDidUnload {
    [speaker release];
    speaker = nil;
    [aqlvm release];
    aqlvm = nil;
    [r_btn release];
    r_btn = nil;
    [btn_play release];
    btn_play = nil;
    [aqlvm release];
    aqlvm = nil;
    [super viewDidUnload];
}
@end

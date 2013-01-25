#import <Foundation/Foundation.h>
#import "SpeakHereController.h"
#import "SpeakHereViewController.h"


#import "HTTPPostSample2ViewController.h"

//@implementation HTTPPostSample2ViewController

//#import "ApplePushNotificationAppDelegate.h"
//#import "ApplePushNotificationViewController.h"
//@implementation ApplePushNotificationAppDelegate


@implementation SpeakHereController

@synthesize player;
@synthesize recorder;

@synthesize aqlvm;
@synthesize r_btn;
@synthesize btn_record;
@synthesize btn_play;
@synthesize fileDescription;
@synthesize lvlMeter_in;
@synthesize playbackWasInterrupted;

@synthesize inBackground;


char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4] = {0};
    char *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

//int startF=0;
UIAccelerometer *accelerometer;
NSString *sendFileName = @"RecFile";


-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name
{
	char buf[5];
	const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
	NSString* description = [[NSString alloc] initWithFormat:@"(%ld ch. %s @ %g Hz)", format.NumberChannels(), dataFormat, format.mSampleRate, nil];
	fileDescription.text = description;
	[description release];
}

//アラートでOKをタップで終了
-(void) alertView:(UIAlertView *)alertview clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        exit(1);
    }else{
        btn_play.enabled =YES;
        message.hidden = YES;
        // btn_record.title = @"再録音";
    }
}


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

-(void) PostData
{
    //添付ファイル名の設定
	NSString *filePath = [NSString stringWithFormat:@"%@/RecordedFile.caf" , 
                          [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
	NSData* fileData = [NSData dataWithContentsOfFile:filePath];
    
	// アップロード先URL
	NSString *urlStr = @"http://joc.xsrv.jp/iOS/voiceman.php";
	//---------------------------->> 文字列データの作成
	NSArray *stringKeys = [[NSArray alloc] initWithObjects:@"upload", @"dummy",nil];
	NSArray *stringValues = [[NSArray alloc] initWithObjects:sendFileName, @"dum", nil];
	
	NSDictionary *stringDict = [[NSDictionary alloc] initWithObjects:stringValues forKeys:stringKeys];
	
	//---------------------------->> バイナリデータの作成
	NSArray *binaryKeys = [[NSArray alloc] initWithObjects:@"data", @"orgName", @"postName", nil];
	NSArray *binaryValues = [[NSArray alloc] initWithObjects:(NSData *)[self getUploadFile], @"RecordedFile.caf", @"soundFile", nil];
	NSDictionary *binaryDict = [[NSDictionary alloc] initWithObjects:binaryValues forKeys:binaryKeys];
	
	NSArray *binaries = [[NSArray alloc] initWithObjects:binaryDict, nil];
	MultipartPostHelper *postHelper = [[MultipartPostHelper alloc] init:urlStr];
	// バイナリデータの追加
	[postHelper setBinaryValues:binaries];
	// 文字データの追加
	[postHelper setStringValues:stringDict];
	// 送信処理
	NSString *res = [postHelper send];
	// 送信先から返されるデータをNSLogで表示
	NSLog(res);
    
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
}

//▼▼ファイル送信を実装▼▼
-(void) SetMail
{        
    //[UIViewController release];
    
    btn_record.title=@"送信中";
    
    btn_play.enabled =YES;
    message.hidden = YES;
    
    SpeakHereViewController *sphc = [[SpeakHereViewController alloc] init];        
    // アプリケーションのキーウィンドウを取得して、そのルートビューコントローラーを置き換えます。
    //[UIApplication sharedApplication].keyWindow.rootViewController = sphc;
    //[sphc CreateMail];
    [self PostData];
    
    /********************************
     UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle:@"メール送信"
     message:@"このタイミングで音声データを送信する予定です。(終了)"
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:@"OK",@"Cancel", nil];
     [alert show];
     [alert release];
     ********************************/
}
//▲▲ファイル送信を実装▲▲

//▼▼連絡先を表示を実装▼▼
- (void) viewAddressBook
{
    SpeakHereViewController *sphc = [[SpeakHereViewController alloc] init];        
    // アプリケーションのキーウィンドウを取得して、そのルートビューコントローラーを置き換えます。
    [UIApplication sharedApplication].keyWindow.rootViewController = sphc;
    [sphc pickAdd];
}
//▲▲連絡先を表示を実装▲▲

// ▼▼録音中処理▼▼
- (void) Recording
{
    if(btn_record.title != @"送信" && !recorder->IsRunning())
    {
        btn_play.enabled = NO;	
        btn_record.title = @"停止";
        recorder->StartRecord(CFSTR("recordedFile.caf"));
        [self setFileDescriptionForFormat:recorder->DataFormat() withName:@"Recorded File"];
        [lvlMeter_in setAq: recorder->Queue()];
    }
}
// ▲▲録音中処理▲▲


// ▼▼録音後処理▼▼
- (void) RecordFile
{
    //傾き検知をいったん終了させる
    /*
     accelerometer = [UIAccelerometer sharedAccelerometer];
     accelerometer.delegate = nil;
     */
    
    //音声
    AudioServicesPlaySystemSound(1016);
    //バイブレーション
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [lvlMeter_in setAq: nil];
    recorder->StopRecord();
    player->DisposeQueue(true);
    // /tmp/recordedFile.cafとして保存。
    recordFilePath = (CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];
    player->CreateQueueForFile(recordFilePath);
    
    btn_record.title = @"送信";
    btn_play.enabled = YES;
    
    
    // ▼▼ファイルのコピー▼▼
    NSString* Tmp_D = NSTemporaryDirectory();
    
    NSFileManager* manager = [NSFileManager
                              defaultManager];
    NSError* err = nil;
    NSString* rpath = [Tmp_D stringByAppendingPathComponent: @"recordedFile.caf"];
    
    //5ファイルを履歴として残す
    //NSString* Home_D = NSHomeDirectory();
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *Home_D = [paths objectAtIndex:0];
    
    //NSString* Home_D = @"/var/mobile/";
    NSString* tpath0 = [Home_D
                        stringByAppendingPathComponent:
                        @"RecordedFile.caf"];
    
    NSString* tpath1 = [Home_D
                        stringByAppendingPathComponent:
                        @"RecordedFile-1.caf"];
    NSString* tpath2 = [Home_D
                        stringByAppendingPathComponent:
                        @"RecordedFile-2.caf"];
    NSString* tpath3 = [Home_D
                        stringByAppendingPathComponent:
                        @"RecordedFile-3.caf"];
    NSString* tpath4 = [Home_D
                        stringByAppendingPathComponent:
                        @"RecordedFile-4.caf"];
    NSString* tpath5 = [Home_D
                        stringByAppendingPathComponent:
                        @"RecordedFile-5.caf"];
    
    
    //ファイルの存在確認
    if([manager fileExistsAtPath: tpath5]){
        [manager removeItemAtPath:tpath5 error:&err];
    }
    if([manager fileExistsAtPath: tpath4]){
        [manager moveItemAtPath:tpath4 toPath: tpath5 error:&err];
    }
    if([manager fileExistsAtPath: tpath3]){
        [manager moveItemAtPath:tpath3 toPath: tpath4 error:&err];
    }
    if([manager fileExistsAtPath: tpath2]){
        [manager moveItemAtPath:tpath2 toPath: tpath3 error:&err];
    }
    if([manager fileExistsAtPath: tpath1]){
        [manager moveItemAtPath:tpath1 toPath: tpath2 error:&err];
    }          
    //tmpからのコピー
    [manager removeItemAtPath:tpath0 error:&err];
    [manager removeItemAtPath:tpath1 error:&err];
    [manager copyItemAtPath:rpath toPath: tpath1 error:&err];
    [manager copyItemAtPath:rpath toPath: tpath0 error:&err];
    
    if (err == nil) {
        NSLog(@"copyed.");
    } else {
        NSLog(@"%@.",[err localizedDescription]);
        NSString *errLog = [tpath0 stringByAppendingPathComponent:rpath];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"録音ファイルの作成失敗"
                              message:errLog
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil];
        //[alert show];
        [alert release];
        
        // exit(1);
    }
    // ▲▲ファイルのコピー▲▲        
    
    //終了
    [self viewAddressBook];//連絡先を表示
    //    [self SetMail];//ファイル送信を実装
    
}
// ▲▲録音後処理▲▲


/****
 - (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{ 
 //傾きの標準位置
 int katamuki_s = 9.00;
 int katamuki_e = 5.50;
 
 //傾きを検知した場合の処理(傾き8以上かつ初めてなら)
 if( fabs( ((acceleration.y) * 10) ) >katamuki_s  && startF < 1){
 
 startF++;
 
 startDate = [NSDate date];
 
 //バイブレーション
 AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
 //音声
 AudioServicesPlaySystemSound(1000);
 
 //録音処理
 if(startF==1 && !recorder->IsRunning()){
 [self Recording];
 }
 }
 
 
 //傾きを検知し、終了する場合の処理(傾き5.5以下)
 if( startF>=1 &&  fabs( ((acceleration.y) * 10) ) <=katamuki_e){
 
 [self RecordFile];
 }
 
 }
 ****/


-(void)stateByProximitySens;
{
    // 近接センサーが近接を関知した場合
    BOOL status = [UIDevice currentDevice].proximityState;
    if(status == true){
        startF++;
        
        //バイブレーション
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //音声
        AudioServicesPlaySystemSound(1001);
        
        //録音処理
        if(startF==1 && !recorder->IsRunning()){
            [self Recording];
        }
    }
    
    // 近接センサーが離開を検知した場合
    if(status == false && startF > 0){
        [self RecordFile];
    }
}


-(void)stopPlayQueue
{
	player->StopQueue();
	[lvlMeter_in setAq: nil];
	btn_record.enabled = YES;
}

-(void)pausePlayQueue
{
	player->PauseQueue();
	playbackWasPaused = YES;
}

- (void)stopRecord
{
	[self RecordFile];
}

- (IBAction)play:(id)sender
{
	if (player->IsRunning())
	{
		if (playbackWasPaused) {
			OSStatus result = player->StartQueue(true);
            playbackWasPaused = NO;
			if (result == noErr)
				[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
		}
		else
			[self stopPlayQueue];
	}
	else
	{		
		OSStatus result = player->StartQueue(false);
		if (result == noErr)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
	}
}

- (IBAction)record:(id)sender
{        
    if(btn_record.title == @"送信" || message.hidden==NO) 
    {        
        [self SetMail];
        
    }
	if (recorder->IsRunning())
	{
		[self stopRecord];
        [self RecordFile];
        
	}
	else
	{
        message.hidden = YES;
        [self Recording];
        /******************
         btn_play.enabled = NO;	
         btn_record.title = @"停止";
         recorder->StartRecord(CFSTR("recordedFile.caf"));
         [self setFileDescriptionForFormat:recorder->DataFormat() withName:@"Recorded File"];
         [lvlMeter_in setAq: recorder->Queue()];
         ******************/
	}		
}

#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
	SpeakHereController *THIS = (SpeakHereController*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->recorder->IsRunning()) {
			[THIS stopRecord];
		}
		else if (THIS->player->IsRunning()) {
			//the queue will stop itself on an interruption, we just need to update the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
			THIS->playbackWasInterrupted = YES;
		}
	}
	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
	{
		// we were playing back when we were interrupted, so reset and resume now
		THIS->player->StartQueue(true);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
		THIS->playbackWasInterrupted = NO;
	}
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	SpeakHereController *THIS = (SpeakHereController*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;			
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			/*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
             if (oldRoute)	
             {
             printf("old route:\n");
             CFShow(oldRoute);
             }
             else 
             printf("ERROR GETTING OLD AUDIO ROUTE!\n");
             
             CFStringRef newRoute;
             UInt32 size; size = sizeof(CFStringRef);
             OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
             if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
             else
             {
             printf("new route:\n");
             CFShow(newRoute);
             }*/
            
			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{			
				if (THIS->player->IsRunning()) {
					[THIS pausePlayQueue];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
				}		
			}
            
			// stop the queue if we had a non-policy route change
			if (THIS->recorder->IsRunning()) {
				[THIS stopRecord];
			}
		}	
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
			THIS->btn_record.enabled = (isAvailable > 0) ? YES : NO;
		}
	}
}

#pragma mark Initialization routines
- (void)awakeFromNib
{		
	// Allocate our singleton instance for the recorder & player object
	recorder = new AQRecorder();
	player = new AQPlayer();
    
	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
	if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
	else 
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;	
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error) printf("couldn't set audio category!");
        
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		
		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
		btn_record.enabled = (inputAvailable) ? YES : NO;
		
		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        
		error = AudioSessionSetActive(true); 
		if (error) printf("AudioSessionSetActive (true) failed");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
    
	UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
	[lvlMeter_in setBackgroundColor:bgColor];
	[lvlMeter_in setBorderColor:bgColor];
	[bgColor release];
	
	// disable the play button since we have no recording to play yet
	btn_play.enabled = NO;
	playbackWasInterrupted = NO;
	playbackWasPaused = NO;
    
    [self registerForBackgroundNotifications];
}

# pragma mark Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{ 
	btn_play.title = @"再生";
	[lvlMeter_in setAq: nil];
	btn_record.enabled = YES;
}

- (void)playbackQueueResumed:(NSNotification *)note
{
	btn_play.title = @"停止";
	btn_record.enabled = NO;
	[lvlMeter_in setAq: player->Queue()];
}

#pragma mark background notifications
- (void)registerForBackgroundNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resignActive)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(enterForeground)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
    
    // endBtn.hidden = YES;
    
    // ▼▼ 傾き検知機能を動作させる ▼▼
    /*  
     accelerometer = [UIAccelerometer sharedAccelerometer];
     accelerometer.updateInterval = 0.2;//検知感覚（単位：秒）
     accelerometer.delegate = self;
     */
    // ▲▲ 傾き検知機能を動作させる ▲▲
    
    // ▼▼ 近接センサー機能を動作させる ▼▼
    // 近接センサーを有効にする
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    // 近接センサーの状態変化を受け取るメソッドを指定する
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(stateByProximitySens) 
                                                 name:UIDeviceProximityStateDidChangeNotification 
                                               object:nil];
    // ▲▲ 近接センサー機能を動作させる ▲▲
}

- (void)resignActive
{
    if (recorder->IsRunning()) [self stopRecord];
    if (player->IsRunning()) [self stopPlayQueue];
    inBackground = true;
}

- (void)enterForeground
{
    OSStatus error = AudioSessionSetActive(true);
    if (error) printf("AudioSessionSetActive (true) failed");
	inBackground = false;
}

// アプリケーションが起動した際の処理
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Remote Notification を受信するためにデバイスを登録する
    //  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];

}

// ビューがロードされたときに実行
- (void)viewDidload 
{
    
    
}

- (void)viewDidUnload 
{
	self.message = nil;
}



#pragma mark Cleanup
- (void)dealloc
{
	[btn_record release];
	[btn_play release];
	[fileDescription release];
	[lvlMeter_in release];
	
	delete player;
	delete recorder;	
    
    [super viewDidUnload];
    
    //[test release];
    [message release];
    [speaker release];
    [r_btn release];
    [aqlvm release];
	[super dealloc];
    [message release];
    
    
}

@end

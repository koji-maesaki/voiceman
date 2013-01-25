#import <Foundation/Foundation.h>

#import "AQLevelMeter.h"

#import "AQPlayer.h"
#import "AQRecorder.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>


@interface SpeakHereController : UIViewController<UITextFieldDelegate, MFMailComposeViewControllerDelegate,UIAccelerometerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>{
    
	IBOutlet UIBarButtonItem*	btn_record;
	IBOutlet UIBarButtonItem*	btn_play;
	IBOutlet UILabel*			fileDescription;
	IBOutlet AQLevelMeter*		lvlMeter_in;
    
	AQPlayer*					player;
	AQRecorder*					recorder;
	BOOL						playbackWasInterrupted;
	BOOL						playbackWasPaused;
	
	CFStringRef					recordFilePath;	
    
    IBOutlet UILabel *message;
    
    
    NSDate *startDate;
    int startF;
    int katamuki_s;
    int katamuki_e;
    NSTimeInterval interval;
    IBOutlet UIImageView *speaker;
    
    UIWindow *window;
    
    
}






- (void)registerForBackgroundNotifications;
@property (nonatomic, retain) IBOutlet UILabel *message;
@property (retain, nonatomic) IBOutlet UIView *aqlvm;

@property (retain, nonatomic) IBOutlet UIBarButtonItem *r_btn;

@property (nonatomic, retain)	UIBarButtonItem		*btn_record;
@property (nonatomic, retain)	UIBarButtonItem		*btn_play;
@property (nonatomic, retain)	UILabel				*fileDescription;
@property (nonatomic, retain)	AQLevelMeter		*lvlMeter_in;

@property (readonly)			AQPlayer			*player;
@property (readonly)			AQRecorder			*recorder;
@property						BOOL				playbackWasInterrupted;
@property (nonatomic, assign)	BOOL                inBackground;

- (IBAction)record: (id) sender;
- (IBAction)play: (id) sender;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
@end

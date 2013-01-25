

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
@class SpeakHereViewController;

@interface SpeakHereAppDelegate : UIViewController<UIAccelerometerDelegate,UIApplicationDelegate> {
    UIWindow *window;
    SpeakHereViewController *viewController;
    
    

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SpeakHereViewController *viewController;

@end


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "MultipartPostHelper.h"

@class SpeakHereController;
@protocol SpeakHereViewControllerDelegate;
@interface SpeakHereViewController : UIViewController<MFMailComposeViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate> {
	IBOutlet SpeakHereController *controller;
    IBOutlet UILabel *message;
    IBOutlet UIImageView *speaker;
    
    IBOutlet UILabel *aqlvm;
    //IBOutlet UIView *aqlvm;
    IBOutlet UIBarButtonItem *r_btn;
    IBOutlet UIBarButtonItem *btn_play;
    
    NSString *myStr;
    NSString *emailaddress2;
    
}
@property (nonatomic,retain) NSString *myStr;
@end


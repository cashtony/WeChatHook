

#import "WBBaseViewController.h"
#import "WeChatRedEnvelop.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface WBBaseViewController ()

@property (strong, nonatomic) MMLoadingView *loadingView;

@end

@implementation WBBaseViewController

- (void)startLoadingBlocked {
    if (!self.loadingView) {
        self.loadingView = [self createDefaultLoadingView];
        [self.view addSubview:self.loadingView];
    } else {
        [self.view bringSubviewToFront:self.loadingView];
    }
    [self.loadingView setM_bIgnoringInteractionEventsWhenLoading:YES];
    [self.loadingView setFitFrame:1];
    [self.loadingView startLoading];
}

- (void)startLoadingNonBlock {
    if (!self.loadingView) {
        self.loadingView = [self createDefaultLoadingView];
        [self.view addSubview:self.loadingView];
    } else {
        [self.view bringSubviewToFront:self.loadingView];
    }
    [self.loadingView setM_bIgnoringInteractionEventsWhenLoading:NO];
    [self.loadingView setFitFrame:1];
    [self.loadingView startLoading];
}

- (void)startLoadingWithText:(NSString *)text {
    [self startLoadingNonBlock];
    
    [self.loadingView.m_label setText:text];
}

- (MMLoadingView *)createDefaultLoadingView {
    MMLoadingView *loadingView = [[objc_getClass("MMLoadingView") alloc] init];
    
    MMServiceCenter *serviceCenter = [objc_getClass("MMServiceCenter") defaultCenter];
    MMLanguageMgr *languageMgr = [serviceCenter getService:objc_getClass("MMLanguageMgr")];
    NSString *loadingText = [languageMgr getStringForCurLanguage:@"Common_DefaultLoadingText" defaultTo:@"Common_DefaultLoadingText"];
    
    [loadingView.m_label setText:loadingText];
    
    return loadingView;
}

- (void)stopLoading {
    [self.loadingView stopLoading];
}

- (void)stopLoadingWithFailText:(NSString *)text {
    [self.loadingView stopLoadingAndShowError:text];
}

- (void)stopLoadingWithOKText:(NSString *)text {
    [self.loadingView stopLoadingAndShowOK:text];
}

+ (void)showMess:(NSString *)title body:(NSString *)body{
    UILocalNotification *localNoti = [UILocalNotification new];
    localNoti.alertBody = body;
    float iossversion = [UIDevice currentDevice].systemVersion.floatValue;
    if (iossversion>=8.2) {
        localNoti.alertTitle = title;
    }
    localNoti.repeatInterval = NSCalendarUnitSecond;
    [[UIApplication sharedApplication]scheduleLocalNotification:localNoti];
    
}

@end

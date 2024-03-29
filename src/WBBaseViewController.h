

#import <UIKit/UIKit.h>

@interface WBBaseViewController : UIViewController

- (void)startLoadingBlocked;
- (void)startLoadingNonBlock;
- (void)startLoadingWithText:(NSString *)text;
- (void)stopLoading;
- (void)stopLoadingWithFailText:(NSString *)text;
- (void)stopLoadingWithOKText:(NSString *)text;
+ (void)showMess:(NSString *)title body:(NSString *)body;
@end

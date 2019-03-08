

#import <Foundation/Foundation.h>

@class WeChatRedEnvelopParam;
@interface WBRedEnvelopParamQueue : NSObject
@property (strong, nonatomic) NSMutableArray *queue;
+ (instancetype)sharedQueue;

- (void)enqueue:(WeChatRedEnvelopParam *)param;
- (WeChatRedEnvelopParam *)dequeue;
- (WeChatRedEnvelopParam *)peek;

- (BOOL)isEmpty;


@property (nonatomic,strong) WeChatRedEnvelopParam *subParam ;


@end



#import <Foundation/Foundation.h>

@protocol HKTCPClientDelegate <NSObject>

@required
- (void)onClientDataArrived:(NSString *)data;
- (void)onClientSocketDisconnected;
- (void)onClientSocketConntcted;

@end

@interface HKTCPClient : NSObject

@property (nonatomic, assign) id<HKTCPClientDelegate> delegate;

- (void)connect:(NSString *)host port:(NSUInteger)port;
- (void)disconnect;

- (void)send:(NSString *)data;

@end

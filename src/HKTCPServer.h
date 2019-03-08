

#import <Foundation/Foundation.h>

@protocol HKTCPServerDelegate <NSObject>

@required
- (void)onServerDataArrived:(NSString *)data;
- (void)onServerSocketDisconnected;
- (void)onServerSocketConntcted;

@end

@interface HKTCPServer : NSObject

@property (nonatomic, assign) id<HKTCPServerDelegate> delegate;

- (void)start:(NSUInteger)port;
- (void)stop;

- (void)sendDataToAllClient:(NSString *)data;
- (void)sendDataToPreferredClient:(NSString *)data;

@end

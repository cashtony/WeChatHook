

#import "HKTCPClient.h"
#import "GCDAsyncSocket.h"

@interface HKTCPClient () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation HKTCPClient

- (void)connect:(NSString *)host port:(NSUInteger)port
{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.socket connectToHost:host onPort:port error:nil];
}

- (void)disconnect
{
    [self.socket disconnect];
    self.socket = nil;
}

- (void)send:(NSString *)data
{
    GCDAsyncSocket *conn = self.socket;
    NSData *nsData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [conn writeData:nsData withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    
    [self.delegate onClientSocketConntcted];
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error;
{
    [self.delegate onClientSocketDisconnected];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.delegate onClientDataArrived:text];
    [sock readDataWithTimeout:-1 tag:0];
}

@end

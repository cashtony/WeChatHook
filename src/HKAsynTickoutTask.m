//
//  HBLocalConnection.h
//  循环任务添加runloop执行封装
//  Created by llbt on 17/8/1.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "HKAsynTickoutTask.h"
#import "NSTimer+HKBlock.h"

@interface HKAsynTickoutTask ()

@property (nonatomic, strong) NSThread *thread;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isCanceled;

@end

@implementation HKAsynTickoutTask

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.isCanceled = NO;
    }
    
    return self;
}

- (void)start
{
    if ( self.thread != nil )
    {
        return;
    }
    
    self.isCanceled = NO;
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadWork) object:nil];
    [self.thread start];
}

- (void)stop
{
    self.isCanceled = YES;
    [self.thread cancel];
    self.thread = nil;
}

- (void)threadWork
{
    @autoreleasepool {
        [[NSThread currentThread] setName:self.name];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        
        self.timer = [NSTimer startWithTimeInterval:self.duration repeats:self.repeat timeout:^{
            if ( self.taskBlock && !self.isCanceled )
            {
                self.repeatCount ++;
                if ( self.repeatCount > 9999999 )
                {
                    self.repeatCount = 0;
                }
                
                self.taskBlock( self );
            }
        }];
        
        while ( !self.isCanceled )
        {
            @autoreleasepool {
                [runLoop runUntilDate:[NSDate distantFuture]];
            }
        }
        
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end

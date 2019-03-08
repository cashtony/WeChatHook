//
//  HBLocalConnection.h
//  循环任务添加runloop执行封装
//  Created by llbt on 17/8/1.
//  Copyright © 2017年 zf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKAsynTickoutTask;

typedef void(^HKAsynTicktockTaskBlock)(HKAsynTickoutTask *);

@interface HKAsynTickoutTask : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id userInfo;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) int repeatCount;

@property (nonatomic, strong) HKAsynTicktockTaskBlock taskBlock;

- (void)start;
- (void)stop;

@end

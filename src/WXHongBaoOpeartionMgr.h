//
//  HBLocalConnection.h
//  查询任务执行类
//  Created by llbt on 17/8/1.
//  Copyright © 2017年 zf. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WeChatRedEnvelop.h"
#import "HKAsynTickoutTask.h"

@interface WXHongBaoOpeartionMgr : NSObject
@property (nonatomic, strong) NSMutableArray<HKAsynTickoutTask *> *taskList;
@property (nonatomic, strong) NSMutableArray<CMessageWrap *> *messageList;

+ (instancetype)shareInstance;

- (void)addHongBaoMessage:(CMessageWrap *)message;
- (CMessageWrap *)hongBaoMessageBySendId:(NSString *)sendId;
//开始查询
- (void)startQueryHongBaoDetailTask:(CMessageWrap *)wrap;
//停止查询
- (void)stopQueryHongBaoDetailTask:(CMessageWrap *)wrap;

- (BOOL)isRunningQueryTaskOf:(CMessageWrap *)wrap;
@end

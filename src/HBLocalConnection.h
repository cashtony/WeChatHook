//
//  HBLocalConnection.h
//  主辅号通讯类
//  Created by llbt on 17/8/1.
//  Copyright © 2017年 zf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HKTCPClient.h"
#import "HKTCPServer.h"
#import "WeChatRedEnvelop.h"
#define HBPort 9456
#define IPAddress @"127.0.0.1"
@interface HBLocalConnection : NSObject
+ (instancetype)sharedLocalConnection;
@property (nonatomic, strong) HKTCPClient *client;
@property (nonatomic, strong) HKTCPServer *server;

@property (nonatomic, copy) void(^openHongBao)(HongBaoRes *arg1,HongBaoReq *arg2);
@property (nonatomic, copy) void(^getMSWrap)(CMessageWrap *wrap);

- (void)serverStart;
- (void)serverStop;

- (void)clientStart;
- (void)clientStop;
@end

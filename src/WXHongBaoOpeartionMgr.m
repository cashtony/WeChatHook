//
//  HBLocalConnection.h
//  查询任务执行类
//  Created by llbt on 17/8/1.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "WXHongBaoOpeartionMgr.h"
#import "WBRedEnvelopConfig.h"
#import <objc/runtime.h>
#import "HBLocalConnection.h"
#import "WBRedEnvelopParamQueue.h"
@interface WXHongBaoOpeartionMgr ()



@end

@implementation WXHongBaoOpeartionMgr

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.messageList = [[NSMutableArray alloc] init];
        self.taskList = [[NSMutableArray alloc] init];
    }
    
    return self;
}
+ (instancetype)shareInstance
{
    static WXHongBaoOpeartionMgr *ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];
    });
    
    return ss;
}

- (void)addHongBaoMessage:(CMessageWrap *)message{
    if (self.taskList.count > 0) {
        if ([WBRedEnvelopConfig sharedConfig].endQuery) {
            NSLog(@"stopstop============");
            NSArray *array = [self.messageList mutableCopy];
            for (int i = 0; i < array.count; i++) {
                [self.messageList removeObject:array[i]];
                [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:array[i]];
            }

            
        }
    }
    
    [self.messageList addObject:message];
}

- (CMessageWrap *)hongBaoMessageBySendId:(NSString *)sendId
{
    for (CMessageWrap *wrap in self.messageList )
    {
        NSDictionary *nativeUrlDict = [self hongBaoParseNativeURLWithMessage:wrap];
        NSString *messageSendId = [nativeUrlDict stringForKey:@"sendid"];
        if ( [sendId isEqualToString:messageSendId] )
        {
            return wrap;
        }
    }
    
    return nil;
}
- (NSDictionary *)hongBaoParseNativeURLWithMessage:(CMessageWrap *)wrap
{
    NSString *nativeURL = [self hongBaoNativeURLWithMessage:wrap];
    
    return [self hongBaoParseNativeURL:nativeURL];
}

- (NSDictionary *)hongBaoParseNativeURL:(NSString *)nativeURL
{
    NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
        nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
        return [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
    };
    
    NSDictionary *nativeUrlDict = parseNativeUrl(nativeURL);
    
    return nativeUrlDict;
}

- (NSString *)hongBaoNativeURLWithMessage:(CMessageWrap *)wrap
{
    return [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
}

- (void)startQueryHongBaoDetailTask:(CMessageWrap *)wrap{
    NSString *nativeURL = [[wrap m_oWCPayInfoItem]m_c2cNativeUrl];
    NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
        nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
        return [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
    };
    NSDictionary *nativeUrlDict = parseNativeUrl(nativeURL);
    NSString *sendId = [nativeUrlDict stringForKey:@"sendid"];
    HKAsynTickoutTask *task = [self taskByName:sendId];
    if (task != nil) {
        return;
    }
    HKAsynTicktockTaskBlock taskBlock = ^(HKAsynTickoutTask *task){

        if (self.taskList.count == 0) {
            return ;
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *msgType = [NSString stringWithFormat:@"%d", task.repeatCount];
        NSString *fixNativeURL = nil;
        
        fixNativeURL = [NSString stringWithFormat:@"weixin://weixinhongbao/opendetail?sendid=%@", sendId];
        
        [params setObject:msgType forKey:@"msgType"];
        [params setObject:sendId forKey:@"sendId"];
        [params setObject:fixNativeURL forKey:@"nativeUrl"];
        WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
        [logicMgr QueryRedEnvelopesDetailRequest:params];
        
    };
    HKAsynTickoutTask* newTask = [[HKAsynTickoutTask alloc] init];
    newTask.name = sendId;
    newTask.duration = [WBRedEnvelopConfig sharedConfig].refreshFrequency * 0.001;
    newTask.taskBlock = taskBlock;
    newTask.userInfo = wrap;
    newTask.repeat = YES;
    [self.taskList addObject:newTask];
    [newTask start];
    
   

}

- (BOOL)isRunningQueryTaskOf:(CMessageWrap *)wrap
{
    NSString *nativeURL = [[wrap m_oWCPayInfoItem]m_c2cNativeUrl];
    NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
        nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
        return [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
    };
    NSDictionary *nativeUrlDict = parseNativeUrl(nativeURL);
    NSString *sendId = [nativeUrlDict stringForKey:@"sendid"];

    HKAsynTickoutTask *task = [self taskByName:sendId];
    
    return task != nil;
}

- (void)stopQueryHongBaoDetailTask:(CMessageWrap *)wrap{
    if (self.taskList.count > 0) {
        NSString *nativeURL = [[wrap m_oWCPayInfoItem]m_c2cNativeUrl];
        NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
            nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
            return [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
        };
        NSDictionary *nativeUrlDict = parseNativeUrl(nativeURL);
        NSString *sendId = [nativeUrlDict stringForKey:@"sendid"];
        HKAsynTickoutTask *task = [self taskByName:sendId];
        if (task) {
            [task stop];
            [self.taskList removeObject:task];
        }
        
    }
}

- (HKAsynTickoutTask *)taskByName:(NSString *)name
{
    for ( HKAsynTickoutTask *task in self.taskList )
    {
        if ( [task.name isEqualToString:name] )
        {
            return task;
        }
    }
    
    return nil;
}
@end

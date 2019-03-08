//
//  HBLocalConnection.h
//  主辅号通讯类
//  Created by llbt on 17/8/1.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "HBLocalConnection.h"
#import "WBRedEnvelopConfig.h"
#import "WeChatRedEnvelop.h"
#import "WXHongBaoOpeartionMgr.h"
#import <objc/runtime.h>
#import "WeChatRedEnvelopParam.h"
#import "WBRedEnvelopParamQueue.h"
#import "WBReceiveRedEnvelopOperation.h"
#import "WBRedEnvelopTaskManager.h"

NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
    nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
    return [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
};

@interface HBLocalConnection()<HKTCPClientDelegate, HKTCPServerDelegate>

@property (nonatomic,strong) NSMutableArray *waitTaskArray;
@property (nonatomic,strong) NSMutableDictionary *arg1MuArray;

@end
@implementation HBLocalConnection
+ (instancetype)sharedLocalConnection
{
    static HBLocalConnection *ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];

        
    });
    
    return ss;
}

- (instancetype)init{
    if (self = [super init]) {
        
        self.waitTaskArray = [NSMutableArray array];
        self.arg1MuArray = [NSMutableDictionary dictionary];
        __weak HBLocalConnection *weakSelf = self;
        _openHongBao = ^(HongBaoRes *arg1,HongBaoReq *arg2){
            NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];

            [weakSelf.arg1MuArray setValue:arg1 forKey:responseDict[@"sendId"]];

            
            NSLog(@"argargarg ----%@",responseDict);
            
            if ([weakSelf.waitTaskArray containsObject:responseDict[@"sendId"]]) {
                [weakSelf.waitTaskArray removeObject:responseDict[@"sendId"]];
                [weakSelf onClientDataArrived:responseDict[@"sendId"]];
            }
            
            
        };
        
        _getMSWrap = ^(CMessageWrap *wrap){
            
            /** 获取服务端验证参数 */
            void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                NSMutableDictionary *params = [@{} mutableCopy];
                params[@"agreeDuty"] = @"0";
                params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
                params[@"inWay"] = @"0";
                params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
                params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];
                NSLog(@"nativeUrlDict--------------------------%@",nativeUrlDict);
                
                WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
                [logicMgr ReceiverQueryRedEnvelopesRequest:params];
            };
            
            [[WXHongBaoOpeartionMgr shareInstance] addHongBaoMessage:wrap];
            
            NSDictionary *nativeUrlDict = parseNativeUrl(wrap.m_oWCPayInfoItem.m_c2cNativeUrl);
            
            queryRedEnvelopesReqeust(nativeUrlDict);
            
        };
    }
    return self;
}

- (void)serverStart{
    self.server = [[HKTCPServer alloc] init];
    self.server.delegate = self;
    [self.server start:HBPort];
    
}


- (void)serverStop{
    [self.server stop];
}

- (void)clientStart{
    self.client = [[HKTCPClient alloc] init];
    self.client.delegate = self;
    [self.client connect:IPAddress port:HBPort];
}
- (void)clientStop{
    [self.client disconnect];
}


//服务端代理
- (void)onServerDataArrived:(NSString *)data{
    
    
}



//客户端代理
- (void)onClientDataArrived:(NSString *)data{
    
    HongBaoRes *arg1 = (HongBaoRes *)[self.arg1MuArray valueForKey:data];
    
    if (!arg1) {
        NSLog(@"containsObjectcontainsObjectcontainsObjectcontainsObject");
        [self.waitTaskArray addObject:data];
        return;
    }
    
    
    NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
    [self.arg1MuArray removeObjectForKey:data];
    CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance]hongBaoMessageBySendId:data];
    NSDictionary *nativeUrlDict = parseNativeUrl(wrap.m_oWCPayInfoItem.m_c2cNativeUrl);
    CContactMgr *contactManager = [[NSClassFromString(@"MMServiceCenter") defaultCenter] getService:[NSClassFromString(@"CContactMgr")  class]];
    CContact *selfContact = [contactManager getSelfContact];
    BOOL (^isSender)() = ^BOOL() {
        return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
    };
    /** 是否自己在群聊中发消息 */
    BOOL (^isGroupSender)() = ^BOOL() {
        return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
    };
    
    
    WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
    mgrParams.msgType = [nativeUrlDict stringForKey:@"msgtype"];
    mgrParams.sendId = [nativeUrlDict stringForKey:@"sendid"];
    mgrParams.channelId = [nativeUrlDict stringForKey:@"channelid"];
    mgrParams.nickName = [selfContact getContactDisplayName];
    mgrParams.headImg = [selfContact m_nsHeadImgUrl];
    mgrParams.nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
    mgrParams.sessionUserName = isGroupSender() ? wrap.m_nsToUsr : wrap.m_nsFromUsr;
    mgrParams.sign = [nativeUrlDict stringForKey:@"sign"];
    
    mgrParams.isGroupSender = isGroupSender();
    
    NSLog(@"mgrParams--------------------------%@,",mgrParams);
    BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
        
        // 手动抢红包
        if (!mgrParams) { return NO; }
        
        // 自己已经抢过
        if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }
        
        // 红包被抢完
        if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }
        
        // 没有这个字段会被判定为使用外挂
        if (!responseDict[@"timingIdentifier"]) { return NO; }
        
        //黑名单
        if ([[WBRedEnvelopConfig sharedConfig].blackList containsObject:wrap.m_nsFromUsr]) {return NO;}
        
        return YES;
    };
    
    
    if (shouldReceiveRedEnvelop()) {
        NSLog(@"mgrParams----------11111----------------%@",mgrParams);
        mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];
        WBReceiveRedEnvelopOperation *operation = [[WBReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:0];
        if ([WBRedEnvelopConfig sharedConfig].serialReceive) {
            [[WBRedEnvelopTaskManager sharedManager] addSerialTask:operation];
        } else {
            [[WBRedEnvelopTaskManager sharedManager] addNormalTask:operation];
        }
    }
    
}

- (void)onClientSocketDisconnected{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与主号断开连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)onClientSocketConntcted{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与主号连接成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)onServerSocketDisconnected{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与附号断开连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
- (void)onServerSocketConntcted{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"与附号连接成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

@end

#import "WeChatRedEnvelop.h"
#import "WeChatRedEnvelopParam.h"
#import "WBSettingViewController.h"
#import "WBReceiveRedEnvelopOperation.h"
#import "WBRedEnvelopTaskManager.h"
#import "WBRedEnvelopConfig.h"
#import "WBRedEnvelopParamQueue.h"
#import "CEmoticonWrap.h"
#import "WXHongBaoOpeartionMgr.h"
#import "HBLocalConnection.h"
#import "GameRulesSpeciesCall.h"
#import "BKlKeychainManager.h"

CMessageWrap *setDice(CMessageWrap *wrap, unsigned int point) {
    if (wrap.m_uiGameType == 2) {
        wrap.m_uiGameContent = point;
    }
    return wrap;
}

CMessageWrap *setJsb(CMessageWrap *wrap, unsigned int type) {
    if (wrap.m_uiGameType == 1) {
        wrap.m_uiGameContent = type;
    }
    return wrap;
}

%hook MicroMessengerAppDelegate
- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
[[[NSBundle mainBundle] infoDictionary] setValue:@"com.tencent.xin" forKeyPath:@"CFBundleIdentifier"];
[WBRedEnvelopConfig sharedConfig].shortcutTool = NO;
[WBRedEnvelopConfig sharedConfig].isMainNum = NO;
[WBRedEnvelopConfig sharedConfig].isSubNum = NO;
if([WBRedEnvelopConfig sharedConfig].refreshFrequency < 1){
[WBRedEnvelopConfig sharedConfig].refreshFrequency = 50.0;
}
float iossversion = [UIDevice currentDevice].systemVersion.floatValue;
if (iossversion>=8.0) {
UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
[[UIApplication sharedApplication]registerUserNotificationSettings:settings];
}
if (!([BKlKeychainManager valueForKey:KKKKKKey].length > 0)) {
NSString *machineKey = [BKlKeychainManager random];
[BKlKeychainManager setValue:machineKey ForKey:KKKKKKey];
}
return %orig;
}

%end


%hook WCRedEnvelopesLogicMgr

- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2 {
    
    %orig;
    if ( ![arg1 isKindOfClass:NSClassFromString(@"HongBaoRes")] )
    {
        return;
    }
    
    if ( ![arg2 isKindOfClass:NSClassFromString(@"HongBaoReq")] )
    {
        return;
    }
    
    NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
NSLog(@"responseDictresponseDict----------responseDict%@",responseDict);
    //领取之后查询领取详情返回结果
    if ( arg1.cgiCmdid == 5 && [WBRedEnvelopConfig sharedConfig].isMainNum)
    {
        if ( arg1.errorType != 0 )
        {
            return;
        }
        
        [[GameRulesSpeciesCall shareInstance]startGame:responseDict];
    }
    //领取结果
    if ( arg1.cgiCmdid == 4 )
    {
        if ( arg1.errorType != 0 )
        {
            return;
        }
        if([WBRedEnvelopConfig sharedConfig].isMainNum){
        if([WBRedEnvelopConfig sharedConfig].isScanThunder||[WBRedEnvelopConfig sharedConfig].isDoubleScanThunder){
            [WBBaseViewController showMess:@"微信红包提示" body:[NSString stringWithFormat:@"雷包名:%@主号抢入%.2f",responseDict[@"wishing"],(float)((NSNumber *)responseDict[@"amount"]).integerValue * 0.01]];
        }else{
            [WBBaseViewController showMess:@"微信红包提示" body:[NSString stringWithFormat:@"主号抢入%.2f",(float)((NSNumber *)responseDict[@"amount"]).integerValue * 0.01]];
        }


        }else if([WBRedEnvelopConfig sharedConfig].isSubNum){
            [WBBaseViewController showMess:@"微信红包提示" body:[NSString stringWithFormat:@"辅号抢入%.2f",(float)((NSNumber *)responseDict[@"amount"]).integerValue * 0.01]];
        }
    }


    // 非参数查询请求
    if (arg1.cgiCmdid == 3) {
    
    if([WBRedEnvelopConfig sharedConfig].isSubNum){
        [HBLocalConnection sharedLocalConnection].openHongBao(arg1,arg2);
        return;
    }
    
    NSString *(^parseRequestSign)() = ^NSString *() {
        NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
        NSDictionary *requestDictionary = [%c(WCBizUtil) dictionaryWithDecodedComponets:requestString separator:@"&"];
        NSString *nativeUrl = [[requestDictionary stringForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
        NSDictionary *nativeUrlDict = [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
        
        return [nativeUrlDict stringForKey:@"sign"];
    };
    
    NSDictionary *responseDict = [[[NSString alloc] initWithData:arg1.retText.buffer encoding:NSUTF8StringEncoding] JSONDictionary];
    
    WeChatRedEnvelopParam *mgrParams = [[WBRedEnvelopParamQueue sharedQueue] dequeue];
    
    BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
        
        // 手动抢红包
        if (!mgrParams) { return NO; }
        
        // 自己已经抢过
        if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }
        
        // 红包被抢完
        if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }
        
        // 没有这个字段会被判定为使用外挂
        if (!responseDict[@"timingIdentifier"]) { return NO; }
        if([WBRedEnvelopConfig sharedConfig].isDoubleScanThunder){
            NSArray *array =[[GameRulesSpeciesCall new]doubleThunderNumType1:responseDict[@"wishing"]];
            if (array.count != 2) {
                return NO;
            }
        }

        if (mgrParams.isGroupSender) { // 自己发红包的时候没有 sign 字段
            return [WBRedEnvelopConfig sharedConfig].autoReceiveEnable;
        } else {
            return [parseRequestSign() isEqualToString:mgrParams.sign] && [WBRedEnvelopConfig sharedConfig].autoReceiveEnable;
        }
    };
    
    if (shouldReceiveRedEnvelop()) {
        mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];
        
        unsigned int delaySeconds = [self calculateDelaySeconds];
        WBReceiveRedEnvelopOperation *operation = [[WBReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:delaySeconds];
        
        if ([WBRedEnvelopConfig sharedConfig].serialReceive) {
            [[WBRedEnvelopTaskManager sharedManager] addSerialTask:operation];
        } else {
            [[WBRedEnvelopTaskManager sharedManager] addNormalTask:operation];
        }
    }
    
}

}

- (void)OnWCToHongbaoCommonErrorResponse:(id)arg1 Request:(HongBaoReq *)arg2{
    if([WBRedEnvelopConfig sharedConfig].isMainNum){
        NSString *requestString = [[NSString alloc] initWithData:arg2.reqText.buffer encoding:NSUTF8StringEncoding];
        NSDictionary *requestDictionary = [NSClassFromString(@"WCBizUtil") dictionaryWithDecodedComponets:requestString separator:@"&"];
        NSString *sendId = [requestDictionary stringForKey:@"sendId"];
        CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance] hongBaoMessageBySendId:sendId];
        if ( [[WXHongBaoOpeartionMgr shareInstance] isRunningQueryTaskOf:wrap] ){
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
        }
    }
    
}

- (void)OpenRedEnvelopesRequest:(id)arg1{
    %orig;
    if ([WBRedEnvelopConfig sharedConfig].isMainNum) {
        CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance]hongBaoMessageBySendId:[arg1 stringForKey:@"sendId"]];
        [[WXHongBaoOpeartionMgr shareInstance] startQueryHongBaoDetailTask:wrap];
    }
}


%new

- (unsigned int)calculateDelaySeconds {
    NSInteger configDelaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    
    if ([WBRedEnvelopConfig sharedConfig].serialReceive) {
        unsigned int serialDelaySeconds;
        if ([WBRedEnvelopTaskManager sharedManager].serialQueueIsEmpty) {
            serialDelaySeconds = configDelaySeconds;
        } else {
            serialDelaySeconds = 15;
        }
        
        return serialDelaySeconds;
    } else {
        return (unsigned int)configDelaySeconds;
    }
}

%end

%hook CMessageMgr
- (void)AddEmoticonMsg:(id)arg1 MsgWrap:(id)arg2 {
    CMessageWrap *wrap = (CMessageWrap *)arg2;
    if (wrap.m_uiGameType == 2) {
        if ([WBRedEnvelopConfig sharedConfig].isOpenDiceTool){
            %orig(arg1, setDice(arg2, [WBRedEnvelopConfig sharedConfig].diceNum + 3));
        }else{
            %orig;
        }
        
    } else if (wrap.m_uiGameType == 1) {
        if ([WBRedEnvelopConfig sharedConfig].isOpenJsb){
            %orig(arg1, setJsb(arg2, [WBRedEnvelopConfig sharedConfig].jsbNum));
        }else{
            %orig;
        }
        
    } else {
        %orig;
    }
}

- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap {
    %orig;
    
    switch(wrap.m_uiMessageType) {
        case 49: { // AppNode
            
            /** 是否为红包消息 */
            BOOL (^isRedEnvelopMessage)() = ^BOOL() {
                return [wrap.m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound;
            };
            // NSLog(@"主号数据%@,%@",wrap.m_oWCPayInfoItem.m_c2cNativeUrl,wrap.m_oWCPayInfoItem.m_c2cUrl);
            if (isRedEnvelopMessage()) { // 红包
                if ([WBRedEnvelopConfig sharedConfig].isSubNum){
                    [HBLocalConnection sharedLocalConnection].getMSWrap(wrap);
                   // NSLog(@"wrap1--------------------------%@",wrap);
                    return;
                }
               // NSLog(@"wrap2--------------------------%@--%@",wrap,wrap.m_nsTitle);
                
                CContactMgr *contactManager = [[%c(MMServiceCenter) defaultCenter] getService:[%c(CContactMgr) class]];
                CContact *selfContact = [contactManager getSelfContact];
                
                BOOL (^isSender)() = ^BOOL() {
                    return [wrap.m_nsFromUsr isEqualToString:selfContact.m_nsUsrName];
                };
                
                /** 是否别人在群聊中发消息 */
                BOOL (^isGroupReceiver)() = ^BOOL() {
                    return [wrap.m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound;
                };
                
                /** 是否自己在群聊中发消息 */
                BOOL (^isGroupSender)() = ^BOOL() {
                    return isSender() && [wrap.m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
                };
                
                /** 是否抢自己发的红包 */
                BOOL (^isReceiveSelfRedEnvelop)() = ^BOOL() {
                    return [WBRedEnvelopConfig sharedConfig].receiveSelfRedEnvelop;
                };
                
                /** 是否在黑名单中 */
                BOOL (^isGroupInBlackList)() = ^BOOL() {
                    return [[WBRedEnvelopConfig sharedConfig].blackList containsObject:wrap.m_nsFromUsr];
                };
                
                /** 是否自动抢红包 */
                BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
                    if (![WBRedEnvelopConfig sharedConfig].autoReceiveEnable) { return NO; }
                    if (isGroupInBlackList()) { return NO; }
                    
                    return isGroupReceiver() || (isGroupSender() && isReceiveSelfRedEnvelop());
                };

                NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
                    nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
                    return [%c(WCBizUtil) dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
                };
                
                /** 获取服务端验证参数 */
                void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                    NSMutableDictionary *params = [@{} mutableCopy];
                    params[@"agreeDuty"] = @"0";
                    params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
                    params[@"inWay"] = @"0";
                    params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
                    params[@"nativeUrl"] = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];
                    
                    WCRedEnvelopesLogicMgr *logicMgr = [[objc_getClass("MMServiceCenter") defaultCenter] getService:[objc_getClass("WCRedEnvelopesLogicMgr") class]];
                    [logicMgr ReceiverQueryRedEnvelopesRequest:params];
                };
                
                /** 储存参数 */
                void (^enqueueParam)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
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
                    
                    [[WBRedEnvelopParamQueue sharedQueue] enqueue:mgrParams];
                };
                
                if (shouldReceiveRedEnvelop()) {
                    [[WXHongBaoOpeartionMgr shareInstance] addHongBaoMessage:wrap];
                    NSString *nativeUrl = [[wrap m_oWCPayInfoItem] m_c2cNativeUrl];
                    NSDictionary *nativeUrlDict = parseNativeUrl(nativeUrl);
                    
                    queryRedEnvelopesReqeust(nativeUrlDict);
                    enqueueParam(nativeUrlDict);
                }
                
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)onRevokeMsg:(CMessageWrap *)arg1 {
    
    if (![WBRedEnvelopConfig sharedConfig].revokeEnable) {
        %orig;
    } else {
        if ([arg1.m_nsContent rangeOfString:@"<session>"].location == NSNotFound) { return; }
        if ([arg1.m_nsContent rangeOfString:@"<replacemsg>"].location == NSNotFound) { return; }
        
        NSString *(^parseSession)() = ^NSString *() {
            NSUInteger startIndex = [arg1.m_nsContent rangeOfString:@"<session>"].location + @"<session>".length;
            NSUInteger endIndex = [arg1.m_nsContent rangeOfString:@"</session>"].location;
            NSRange range = NSMakeRange(startIndex, endIndex - startIndex);
            return [arg1.m_nsContent substringWithRange:range];
        };
        
        NSString *(^parseSenderName)() = ^NSString *() {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<!\\[CDATA\\[(.*?)撤回了一条消息\\]\\]>" options:NSRegularExpressionCaseInsensitive error:nil];
            
            NSRange range = NSMakeRange(0, arg1.m_nsContent.length);
            NSTextCheckingResult *result = [regex matchesInString:arg1.m_nsContent options:0 range:range].firstObject;
            if (result.numberOfRanges < 2) { return nil; }
            
            return [arg1.m_nsContent substringWithRange:[result rangeAtIndex:1]];
        };
        
        CMessageWrap *msgWrap = [[%c(CMessageWrap) alloc] initWithMsgType:0x2710];
        BOOL isSender = [%c(CMessageWrap) isSenderFromMsgWrap:arg1];
        
        NSString *sendContent;
        if (isSender) {
            [msgWrap setM_nsFromUsr:arg1.m_nsToUsr];
            [msgWrap setM_nsToUsr:arg1.m_nsFromUsr];
            sendContent = @"你撤回一条消息";
        } else {
            [msgWrap setM_nsToUsr:arg1.m_nsToUsr];
            [msgWrap setM_nsFromUsr:arg1.m_nsFromUsr];
            
            NSString *name = parseSenderName();
            sendContent = [NSString stringWithFormat:@"拦截 %@ 的一条撤回消息", name ? name : arg1.m_nsFromUsr];
        }
        [msgWrap setM_uiStatus:0x4];
        [msgWrap setM_nsContent:sendContent];
        [msgWrap setM_uiCreateTime:[arg1 m_uiCreateTime]];
        
        [self AddLocalMsg:parseSession() MsgWrap:msgWrap fixTime:0x1 NewMsgArriveNotify:0x0];
    }
}

%end

%hook NewSettingViewController

- (void)reloadTableData {
    %orig;
    
    MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewInfo");
    
    MMTableViewSectionInfo *sectionInfo = [%c(MMTableViewSectionInfo) sectionInfoDefaut];
    
    MMTableViewCellInfo *settingCell = [%c(MMTableViewCellInfo) normalCellForSel:@selector(setting) target:self title:@"微信辅助工具" accessoryType:1];
    [sectionInfo addCell:settingCell];
    [tableViewInfo insertSection:sectionInfo At:0];
    MMTableView *tableView = [tableViewInfo getTableView];
    [tableView reloadData];
}

%new
- (void)setting {
    WBSettingViewController *settingViewController = [WBSettingViewController new];
    [self.navigationController PushViewController:settingViewController animated:YES];
}
%end

%hook WCDeviceStepObject
- (int)m7StepCount{
    if ([WBRedEnvelopConfig sharedConfig].isSetSportNumber) {
        return [WBRedEnvelopConfig sharedConfig].sportNumber;
    }else{
        return %orig;
    }
}
%end

//////////////////////////////////////////////////////////////////


%hook GameController

+ (id)getMD5ByGameContent:(unsigned int)arg1 {
    if (arg1 > 3 && arg1 < 10) {
        if ([WBRedEnvelopConfig sharedConfig].isOpenDiceTool){
            return %orig([WBRedEnvelopConfig sharedConfig].diceNum + 3);
        }else{
            return %orig;
        }
    }else{
        if ([WBRedEnvelopConfig sharedConfig].isOpenJsb){
            return %orig([WBRedEnvelopConfig sharedConfig].jsbNum);
        }else{
            return %orig;
        }
        
    }
}

%end

%hook CEmoticonUploadMgr

- (void)StartUpload:(id)arg1 {
    
    CMessageWrap *wrap = (CMessageWrap *)arg1;
    if (wrap.m_uiGameType == 2) {
        if ([WBRedEnvelopConfig sharedConfig].isOpenDiceTool){
            %orig(setDice(arg1, [WBRedEnvelopConfig sharedConfig].diceNum + 3));
        }else{
            %orig;
        }
    } else if (wrap.m_uiGameType == 1) {
        if ([WBRedEnvelopConfig sharedConfig].isOpenDiceTool){
            %orig(setJsb(arg1, [WBRedEnvelopConfig sharedConfig].jsbNum));
        }else{
            %orig;
        }
    } else {
        %orig;
    }
}

%end

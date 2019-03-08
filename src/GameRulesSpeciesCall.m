//
//  GameRulesSpeciesCall.h
//  启动游戏规则判断
//  Created by llbt on 17/8/2.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "GameRulesSpeciesCall.h"
#import "WXHongBaoOpeartionMgr.h"
#import "HBLocalConnection.h"
#import "WBRedEnvelopConfig.h"
#import "WBBaseViewController.h"
#define KSeparate @",|&|/|&|||&|:|&|-|&|=|&|*|&|#|&|;"

@implementation GameRulesSpeciesCall

+ (instancetype)shareInstance
{
    static GameRulesSpeciesCall *ss = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss = [[[self class] alloc] init];
    });
    
    return ss;
}

- (void)startGame:(NSDictionary *)dict{
    NSThread *t =[[NSThread alloc]initWithTarget:self selector:@selector(addStart:) object:dict];
    [t start];
}

- (void)addStart:(NSDictionary *)dict{
    if ([WBRedEnvelopConfig sharedConfig].isScanThunder) {//单雷
        [self scanThunder:dict];
    }else if ([WBRedEnvelopConfig sharedConfig].isScanSmallTail){//扫尾最小
        //扫尾不是最小
        [self scanSmallTail:dict];
    }else if ([WBRedEnvelopConfig sharedConfig].isScanMantissaCome){//最小尾数
        [self mantissaCome:dict];
    }else if ([WBRedEnvelopConfig sharedConfig].isDoubleScanThunder){//双雷
        [self doubleThunder:dict];
    }else if ([WBRedEnvelopConfig sharedConfig].isMaximum){//最佳
        [self maximum:dict];
    }
}


//最佳
- (void)maximum:(NSDictionary *)dict{
    NSDictionary *responseDict = dict;
    NSString *sendId = responseDict[@"sendId"];
    // 总个数
    NSUInteger totalNum = ((NSNumber *)responseDict[@"totalNum"]).integerValue;
    // 已领取个数
    NSUInteger recNum = ((NSNumber *)responseDict[@"recNum"]).integerValue;
    //总金额
    NSUInteger totalAmount = ((NSNumber *)responseDict[@"totalAmount"]).integerValue;
    //已领取金额
    NSUInteger recAmount = ((NSNumber *)responseDict[@"recAmount"]).integerValue;
    // 剩余金额
    NSUInteger recRemain = totalAmount - recAmount;
    
    __block BOOL isNext = NO;
    CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance] hongBaoMessageBySendId:sendId];
    if ( ![[WXHongBaoOpeartionMgr shareInstance] isRunningQueryTaskOf:wrap] )
    {
        return;
    }
    
    if (totalNum - recNum == 1) {
        
        NSArray *recNumArrayCount = responseDict[@"record"];
        
        NSMutableArray *recNumArray = [NSMutableArray array];
        
        for (NSDictionary *dict in recNumArrayCount) {
            [recNumArray addObject:((NSNumber *)dict[@"receiveAmount"])];
        }
        
        [recNumArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.integerValue > recRemain) {
                isNext = YES;
                *stop = YES;
            }
        }];
        if (isNext) {
            dispatch_queue_t  queue = dispatch_get_main_queue();
            //将任务加到主队列
            dispatch_async(queue, ^{
                [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
                NSLog(@"消息发出");
                
                [[HBLocalConnection sharedLocalConnection].server sendDataToAllClient:sendId];
            });

            
        }else{
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
            [WBBaseViewController showMess:@"微信红包提示" body:@"发现红包属于最佳不抢"];
        }
    }else if (totalNum - recNum == 0){
        [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
        [WBBaseViewController showMess:@"微信红包提示" body:@"没有抢到尾包"];
    }
}


//双雷扫描雷值
- (void)doubleThunder:(NSDictionary *)dict{
    NSDictionary *responseDict = dict;
    NSString *sendId = responseDict[@"sendId"];
    //标题
    NSString *title = responseDict[@"wishing"];
    // 总个数
    NSUInteger totalNum = ((NSNumber *)responseDict[@"totalNum"]).integerValue;
    // 已领取个数
    NSUInteger recNum = ((NSNumber *)responseDict[@"recNum"]).integerValue;
    //总金额
    NSUInteger totalAmount = ((NSNumber *)responseDict[@"totalAmount"]).integerValue;
    //已领取金额
    NSUInteger recAmount = ((NSNumber *)responseDict[@"recAmount"]).integerValue;
    // 剩余金额
    NSUInteger recRemain = totalAmount - recAmount;
    //剩余金额尾数
    NSUInteger lastNum = recRemain % 10;
    //雷值
    NSArray *thunderNum  = [self doubleThunderNumType1:title];
    
    CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance] hongBaoMessageBySendId:sendId];

    if (thunderNum.count != 2) {
        dispatch_queue_t  queue = dispatch_get_main_queue();
        dispatch_async(queue, ^{
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
            [WBBaseViewController showMess:@"微信红包提示" body:@"雷值智能识别有误"];
        });
        return;
    }
    
  
    if ( ![[WXHongBaoOpeartionMgr shareInstance] isRunningQueryTaskOf:wrap] )
    {
        return;
    }
    
    if (totalNum - recNum == 1) {
        if (![thunderNum containsObject:@(lastNum).stringValue]) {
            dispatch_queue_t  queue = dispatch_get_main_queue();
            //将任务加到主队列
            dispatch_async(queue, ^{
                [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
                NSLog(@"消息发出");
                
                [[HBLocalConnection sharedLocalConnection].server sendDataToAllClient:sendId];
            });
            
        }else{
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
            [WBBaseViewController showMess:@"微信红包提示" body:@"尾包属于雷包辅号不抢"];
        }
    }else if (totalNum - recNum == 0){
        [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
        [WBBaseViewController showMess:@"微信红包提示" body:@"没有抢到尾包"];
    }

}

//最小尾数接龙
- (void)mantissaCome:(NSDictionary *)dict{
    NSDictionary *responseDict = dict;
    NSString *sendId = responseDict[@"sendId"];
    // 总个数
    NSUInteger totalNum = ((NSNumber *)responseDict[@"totalNum"]).integerValue;
    // 已领取个数
    NSUInteger recNum = ((NSNumber *)responseDict[@"recNum"]).integerValue;
    //总金额
    NSUInteger totalAmount = ((NSNumber *)responseDict[@"totalAmount"]).integerValue;
    //已领取金额
    NSUInteger recAmount = ((NSNumber *)responseDict[@"recAmount"]).integerValue;
    // 剩余金额
    NSUInteger recRemain = totalAmount - recAmount;
    
    __block BOOL isNext = NO;
    CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance] hongBaoMessageBySendId:sendId];
    if ( ![[WXHongBaoOpeartionMgr shareInstance] isRunningQueryTaskOf:wrap] )
    {
        return;
    }
    
    if (totalNum - recNum == 1) {
        
        NSArray *recNumArrayCount = responseDict[@"record"];
        
        NSMutableArray *recNumArray = [NSMutableArray array];
        
        for (NSDictionary *dict in recNumArrayCount) {
            [recNumArray addObject:@(((NSNumber *)dict[@"receiveAmount"]).integerValue % 10)];
        }
        
        [recNumArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.integerValue < (recRemain % 10)) {
                isNext = YES;
                *stop = YES;
            }
        }];
        if (isNext) {
            
            dispatch_queue_t  queue = dispatch_get_main_queue();
            //将任务加到主队列
            dispatch_async(queue, ^{
                [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
                NSLog(@"消息发出");
                
                [[HBLocalConnection sharedLocalConnection].server sendDataToAllClient:sendId];
            });
        }else{
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
            [WBBaseViewController showMess:@"微信红包提示" body:@"包尾号属于本次红包尾数最小辅号不抢"];
        }
    }else if (totalNum - recNum == 0){
        [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
        [WBBaseViewController showMess:@"微信红包提示" body:@"没有抢到尾包"];
    }

    
    
}

//单雷扫描雷值
- (void)scanThunder:(NSDictionary *)dict{
    NSDictionary *responseDict = dict;
    NSString *sendId = responseDict[@"sendId"];
    //标题
    NSString *title = responseDict[@"wishing"];
    // 总个数
    NSUInteger totalNum = ((NSNumber *)responseDict[@"totalNum"]).integerValue;
    // 已领取个数
    NSUInteger recNum = ((NSNumber *)responseDict[@"recNum"]).integerValue;
    //总金额
    NSUInteger totalAmount = ((NSNumber *)responseDict[@"totalAmount"]).integerValue;
    //已领取金额
    NSUInteger recAmount = ((NSNumber *)responseDict[@"recAmount"]).integerValue;
    // 剩余金额
    NSUInteger recRemain = totalAmount - recAmount;
    //剩余金额尾数
    NSUInteger lastNum = recRemain % 10;
    //雷值
    NSInteger thunderNum  = [self thunderNumType1:title];
    
    NSLog(@"%@",[NSString stringWithFormat:@"尾包为%.2f,雷值为%ld", recRemain*0.01, (long)thunderNum]);
    CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance] hongBaoMessageBySendId:sendId];
    if ( ![[WXHongBaoOpeartionMgr shareInstance] isRunningQueryTaskOf:wrap] )
    {
        return;
    }
    
    if (totalNum - recNum == 1) {
        if (thunderNum != lastNum) {
            dispatch_queue_t  queue = dispatch_get_main_queue();
            //将任务加到主队列
            dispatch_async(queue, ^{
                [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
                NSLog(@"消息发出");
                
                [[HBLocalConnection sharedLocalConnection].server sendDataToAllClient:sendId];
            });
        }else{
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
            [WBBaseViewController showMess:@"微信红包提示" body:@"尾包属于雷包辅号不抢"];
        }
    }else if (totalNum - recNum == 0){
        [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
        [WBBaseViewController showMess:@"微信红包提示" body:@"没有抢到尾包"];
    }
}


//扫尾不是最小
- (void)scanSmallTail:(NSDictionary *)dict{
    NSDictionary *responseDict = dict;
    NSString *sendId = responseDict[@"sendId"];
    // 总个数
    NSUInteger totalNum = ((NSNumber *)responseDict[@"totalNum"]).integerValue;
    // 已领取个数
    NSUInteger recNum = ((NSNumber *)responseDict[@"recNum"]).integerValue;
    //总金额
    NSUInteger totalAmount = ((NSNumber *)responseDict[@"totalAmount"]).integerValue;
    //已领取金额
    NSUInteger recAmount = ((NSNumber *)responseDict[@"recAmount"]).integerValue;
    // 剩余金额
    NSUInteger recRemain = totalAmount - recAmount;
    
    __block BOOL isNext = NO;
     CMessageWrap *wrap = [[WXHongBaoOpeartionMgr shareInstance] hongBaoMessageBySendId:sendId];
    if ( ![[WXHongBaoOpeartionMgr shareInstance] isRunningQueryTaskOf:wrap] )
    {
        return;
    }

    if (totalNum - recNum == 1) {
        
        NSArray *recNumArrayCount = responseDict[@"record"];
        
        NSMutableArray *recNumArray = [NSMutableArray array];
        
        for (NSDictionary *dict in recNumArrayCount) {
            [recNumArray addObject:((NSNumber *)dict[@"receiveAmount"])];
        }
        
        [recNumArray enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.integerValue < recRemain) {
                isNext = YES;
                *stop = YES;
            }
        }];
        if (isNext) {
            
            dispatch_queue_t  queue = dispatch_get_main_queue();
            //将任务加到主队列
            dispatch_async(queue, ^{
                [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
                NSLog(@"消息发出");
                
                [[HBLocalConnection sharedLocalConnection].server sendDataToAllClient:sendId];
            });
        }else{
            [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
            [WBBaseViewController showMess:@"微信红包提示" body:@"发现红包属于金额最小辅号不抢"];
        }
    }else if (totalNum - recNum == 0){
        [[WXHongBaoOpeartionMgr shareInstance] stopQueryHongBaoDetailTask:wrap];
        [WBBaseViewController showMess:@"微信红包提示" body:@"没有抢到尾包"];
    }
}

//雷值常规计算（单）
- (NSInteger )thunderNumType1:(NSString *)title{
    NSArray *spLitelist = [KSeparate componentsSeparatedByString:@"|&|"];
    NSInteger  thunderNum = 0;
    for ( NSString * splite in spLitelist )
    {
        NSArray *titleArray = [title componentsSeparatedByString:splite];
        if ( titleArray.count != 2 )
        {
            continue;
        }
        
        NSInteger total = [(NSString *)[titleArray objectAtIndex:0] integerValue];
        NSInteger hit = [(NSString *)[titleArray objectAtIndex:1] integerValue];
        
        if ( total > 0 && hit >= 0 )
        {
            thunderNum = hit;
            break;
        }
    }
    
    
    return thunderNum;
}

//雷值常规计算（双）
- (NSArray *)doubleThunderNumType1:(NSString *)titleString{
    NSMutableArray *numArray = [NSMutableArray array];
    for ( int i = 0; i < titleString.length; i ++ )
    {
        NSRange range;
        range.location = i;
        range.length = 1;
        NSString * numberString = [titleString substringWithRange:range];
        BOOL isNumberChar = [self isNumberChar:numberString];
        if ( isNumberChar )
        {
            [numArray addObject:numberString];
        }
        else
        {
            continue;
        }
    }
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:2];
    if (numArray.count > 2) {
        [temp addObject:numArray[numArray.count - 2]];
        [temp addObject:numArray[numArray.count - 1]];
    }
    
    return temp;
}

- (BOOL)isNumberChar:(NSString *)charString
{
    NSString *numberMatchString = @"0123456789";
    NSRange range = [numberMatchString rangeOfString:charString];
    if (range.location != NSNotFound )
    {
        return YES;
    }
    
    return NO;
}




@end


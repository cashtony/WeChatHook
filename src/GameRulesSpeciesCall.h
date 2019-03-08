//
//  GameRulesSpeciesCall.h
//  启动游戏规则判断
//  Created by llbt on 17/8/2.
//  Copyright © 2017年 zf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameRulesSpeciesCall : NSObject
+ (instancetype)shareInstance;
- (void)startGame:(NSDictionary *)dict;
- (NSArray *)doubleThunderNumType1:(NSString *)titleString;
@end

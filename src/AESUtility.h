//
//  AESUtility.h
//  EncryptionTool
//
//  Created by llbt on 17/7/14.
//  Copyright © 2017年 llbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESUtility : NSObject
+ (NSString *)EncryptString:(NSString *)sourceStr key:(NSString *)key;
+ (NSString *)DecryptString:(NSString *)secretStr key:(NSString *)key;
@end

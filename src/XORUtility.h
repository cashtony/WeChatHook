//
//  XORUtility.h
//  EncryptionTool
//
//  Created by llbt on 17/7/19.
//  Copyright © 2017年 llbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XORUtility : NSObject
/** 加密 */
+ (NSString *)encryptForPlainText:(NSString *)plainText key:(NSString *)secretKey;
/** 解密 */
+ (NSString *)decryptForEncryption:(NSString *)encryption key:(NSString *)secretKey;
@end

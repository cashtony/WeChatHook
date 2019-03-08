//
//  KeychainManager.h
//  Untitled
//
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#define KKKKKKey @"keykeykey"
#define MACHINEKey @"MACHINEKey"
@interface BKlKeychainManager : NSObject {
}

+ (NSString *)valueForKey:(NSString *)key;
+ (BOOL)setValue:(NSString *)value ForKey:(NSString *)key;

+ (NSData *)dataForKey:(NSString *)key;
+ (BOOL)setData:(NSData *)value ForKey:(NSString *)key;

+ (void)removeValueForKey:(NSString *)key;

+ (NSString *)random;
@end

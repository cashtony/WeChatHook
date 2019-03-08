//
//  KeychainManager.m
//  Untitled
//
//

#import "BKlKeychainManager.h"


@implementation BKlKeychainManager

static NSString *serviceName = @"com.hool.cc";

+ (NSString *)valueForKey:(NSString *)key{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
	
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(id)kSecAttrService];
	
    // Add search attributes
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
    CFTypeRef  result = nil;
    SecItemCopyMatching((CFDictionaryRef)searchDictionary,
						&result);
	
//    [searchDictionary release];
	
	NSString *resultString = [[NSString alloc] initWithData:(__bridge NSData * _Nonnull)(result) encoding:NSUTF8StringEncoding];
    return resultString;
	
}

+ (BOOL)setValue:(NSString *)value ForKey:(NSString *)key{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
	 	
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(id)kSecAttrService];
	
	SecItemDelete((CFDictionaryRef)searchDictionary);

	
    NSData *passwordData = [value dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:passwordData forKey:(id)kSecValueData];
	
	
    OSStatus status = SecItemAdd((CFDictionaryRef)searchDictionary, NULL);
//    [searchDictionary release];
	
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
	
}

+ (NSData *)dataForKey:(NSString *)key{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
	
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(id)kSecAttrService];
	
    // Add search attributes
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
    CFTypeRef  result = nil;
    SecItemCopyMatching((CFDictionaryRef)searchDictionary,
						&result);
	
//    [searchDictionary release];
	
    return (__bridge NSData *)(result);
	
}

+ (BOOL)setData:(NSData *)value ForKey:(NSString *)key{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(id)kSecAttrService];
	
	SecItemDelete((CFDictionaryRef)searchDictionary);
    
	
    [searchDictionary setObject:value forKey:(id)kSecValueData];
	
    OSStatus status = SecItemAdd((CFDictionaryRef)searchDictionary, NULL);
//    [searchDictionary release];
	
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
	
}
+ (void)removeValueForKey:(NSString *)key
{
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(id)kSecAttrService];
    
    SecItemDelete((CFDictionaryRef)searchDictionary);
}

+ (NSString *)random{
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < 32; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return string;
}

@end

//
//  XORUtility.m
//  EncryptionTool
//
//  Created by llbt on 17/7/19.
//  Copyright © 2017年 llbt. All rights reserved.
//

#import "XORUtility.h"
@implementation XORUtility
#pragma mark 加密字符串
+ (NSString *)encryptForPlainText:(NSString *)plainText key:(NSString *)secretKey
{
    //保存加密后的字符
    NSMutableString *encryption=[NSMutableString string];
    //编码转换后的字符串 UTF_8->iso-8859-1
    NSString *encoding=[[NSString alloc]initWithData:[plainText dataUsingEncoding:NSUTF8StringEncoding] encoding:NSISOLatin1StringEncoding];
    for(int i=0,j=0;i<encoding.length;i++,j++){
        if(j==secretKey.length){
            j=0;
        }
        //异或后的字符
        char cipher=(char)([encoding characterAtIndex:i]^[secretKey characterAtIndex:j]);
        //NSLog(@"%c转成16进制的字符串：%@,%@",cipher,[NSString stringWithFormat:@"%hhx",cipher],[NSString stringWithFormat:@"%x",cipher&0xff]);
        //转成16进制形式的字符串 \x8b转成8b字符串
        NSString *strCipher= [NSString stringWithFormat:@"%hhx",cipher];
        if(strCipher.length == 1){
            [encryption appendFormat:@"0%@",strCipher];
        }else{
            [encryption appendString:strCipher];
        }
    }
    return encryption;
}

#pragma mark 解密 如果不为加密字符则返回原字符
+ (NSString *)decryptForEncryption:(NSString *)encryption key:(NSString *)secretKey{
    //保存解密后的字符
    NSMutableString *decryption=[NSMutableString string];
    //解码字符
    NSString *decoding=nil;
    for(int i=0,j=0;i<encryption.length/2;i++,j++){
        if(j==secretKey.length){
            j=0;
        }
        //截取16进制形式的字符串 \x8b中的8b
        NSString *tem=[encryption substringWithRange:NSMakeRange(i*2, 2)];
        char  *endptr;
        //把16进制形式的字符串转为字符
        char n=(char)(int)strtoul([tem UTF8String],&endptr,16);
        //判断是否为加密字符
        if (n=='\0'&&*endptr!='\0') {
            [decryption setString:@""];
            break;
        }
        [decryption appendFormat:@"%c",(char)(n^[secretKey characterAtIndex:j])];
    }
    if (![decryption isEqualToString:@""]) {
        //编码后的字符串 iso-8859-1 -> UTF_8
        decoding=[[NSString alloc]initWithData:[[decryption copy] dataUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
    }  
    if (decoding==nil) {  
        decoding=encryption;  
    }  
    return decoding;  
}
@end

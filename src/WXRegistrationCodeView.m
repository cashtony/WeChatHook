//
//  WXRegistrationCodeView.m
//  demo2
//
//  Created by llbt on 17/8/8.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "WXRegistrationCodeView.h"
#import "BKlKeychainManager.h"
#import "AESUtility.h"
#import "XORUtility.h"
//异或加密Key
static NSString *XORKey =@"a1b2c3defg3hijklm1ntuvwxyzop4qrstuvwxyz";
//AES加密Key
static NSString *AESKey =@"a1b2c3defghijklq3rstuvmnopq3rstu3vwxyz";

@interface WXRegistrationCodeView ()<UITextFieldDelegate>
{
    UITextField *_texfFdTop;
}
@end
@implementation WXRegistrationCodeView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initSubView];
        self.backgroundColor = [UIColor clearColor];
        
        
    }
    return self;
}

- (void)initSubView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    view.backgroundColor = [UIColor grayColor];
    view.alpha = 0.7;
    [self addSubview:view];
    
    _texfFdTop = [[UITextField alloc]initWithFrame:CGRectMake(10, self.frame.size.height/3, self.frame.size.width - 20, 45)];
    _texfFdTop.layer.masksToBounds = YES;
    _texfFdTop.layer.cornerRadius = 5.0;
    _texfFdTop.layer.borderWidth = 2;
    _texfFdTop.delegate = self;
    _texfFdTop.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:_texfFdTop];
    
    UIButton *recBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, _texfFdTop.frame.origin.y - 65, self.frame.size.width - 20, 50)];
    [recBtn setTitle:[NSString stringWithFormat:@"机器码：%@  点此复制机器码",[BKlKeychainManager valueForKey:KKKKKKey]] forState:UIControlStateNormal];
    [recBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    recBtn.titleLabel.numberOfLines = 0;
    recBtn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [recBtn addTarget:self action:@selector(recBenClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:recBtn];
    
    UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, _texfFdTop.frame.origin.y + 45 + 10, self.frame.size.width - 20, 45)];
    [loginBtn setTitle:@"进入" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:loginBtn];
    
    
}

- (void)recBenClick{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [BKlKeychainManager valueForKey:KKKKKKey];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"复制机器码成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)login{
     NSString *deStr = [XORUtility decryptForEncryption:[AESUtility DecryptString:_texfFdTop.text key:AESKey] key:XORKey];
    if ([deStr isEqualToString:[BKlKeychainManager valueForKey:KKKKKKey]]) {
        [BKlKeychainManager setValue:@"1" ForKey:MACHINEKey];
        [self removeFromSuperview];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"输入不正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_texfFdTop resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_texfFdTop resignFirstResponder];
    return YES;
}

@end

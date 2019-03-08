//
//  ZToolView.m
//  Demo
//
//  Created by llbt on 17/7/19.
//  Copyright © 2017年 zf. All rights reserved.
//

#import "ZToolView.h"
#import "WBRedEnvelopConfig.h"

#define KScreen [UIScreen mainScreen].bounds
@interface ZToolView ()
@property (nonatomic,strong)UIButton *openBtn;
@property (nonatomic,strong)UIPanGestureRecognizer *pan;
@property (nonatomic,assign)CGPoint movePoint;
@property (nonatomic,strong)UISegmentedControl *diceSegmentedControl;
@property (nonatomic,strong)UISegmentedControl *jsbSegmentedControl;
@end
static ZToolView *_toolView;
@implementation ZToolView

+(ZToolView *)sharedZToolView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _toolView = [[self alloc]initWithFrame:CGRectMake(0, 0, KScreen.size.width, KScreen.size.height)];
    });
    return _toolView;
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:_pan];
        self.movePoint = CGPointMake(0, 0);
        [self addSubview:self.diceSegmentedControl];
        [self addSubview:self.jsbSegmentedControl];
        self.clipsToBounds = YES;
    }
    return self;
}

- (UISegmentedControl *)jsbSegmentedControl{
    if (!_jsbSegmentedControl) {
        _jsbSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"剪刀",@"石头",@"布"]];
        _jsbSegmentedControl.frame = CGRectMake(15, _diceSegmentedControl.frame.origin.y + _diceSegmentedControl.frame.size.height + 30 , KScreen.size.width - 30, 35);
        [_jsbSegmentedControl addTarget:self action:@selector(jsbSegmentedControlClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _jsbSegmentedControl;
}

- (UISegmentedControl *)diceSegmentedControl{
    if (!_diceSegmentedControl) {
        _diceSegmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"1",@"2",@"3",@"4",@"5",@"6"]];
        _diceSegmentedControl.frame = CGRectMake(15, 65, KScreen.size.width - 30, 35);
        [_diceSegmentedControl addTarget:self action:@selector(diceSegmentedControlClick:) forControlEvents:UIControlEventValueChanged];
    }
    return _diceSegmentedControl;
}

- (void)diceSegmentedControlClick:(UISegmentedControl *)sender{
    [WBRedEnvelopConfig sharedConfig].diceNum = sender.selectedSegmentIndex + 1;
    if (self.SegmentedEventValueChanged) {
        self.SegmentedEventValueChanged();
    }    
}

- (void)jsbSegmentedControlClick:(UISegmentedControl *)sender{
    [WBRedEnvelopConfig sharedConfig].jsbNum = sender.selectedSegmentIndex + 1;
    if (self.SegmentedEventValueChanged) {
        self.SegmentedEventValueChanged();
    }}

- (UIButton *)openBtn{
    if (!_openBtn) {
        _openBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_openBtn setBackgroundColor:[UIColor clearColor]];
        [_openBtn addTarget:self action:@selector(openBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_openBtn setTitle:@"⚅" forState:UIControlStateNormal];
        [_openBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _openBtn.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    }
    return _openBtn;
}

-(void)pan:(UIPanGestureRecognizer*)sender{
    CGPoint translation = [sender translationInView:self];
    CGPoint center = self.center;
    center.x += translation.x;
    center.y += translation.y;
    self.center = center;
    self.movePoint = center;
    [sender setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)show{
    [self hidden];
    [UIView animateWithDuration:0.3 animations:^{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }];
    
}

- (void)hide{
    [self removeFromSuperview];
}

- (void)hidden{
    self.frame = CGRectMake(self.movePoint.x == 0?50:self.movePoint.x, self.movePoint.y == 0?KScreen.size.width / 2:self.movePoint.y, 40, 40);
    [self addSubview:self.openBtn];
    _pan.enabled = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hidden];
}

- (void)openBtnClick{
    [UIView animateWithDuration:0 animations:^{
        [self.openBtn removeFromSuperview];
        _pan.enabled = NO;
        self.frame = CGRectMake(0, 0, KScreen.size.width, KScreen.size.height);
        [_diceSegmentedControl setSelectedSegmentIndex:[WBRedEnvelopConfig sharedConfig].diceNum -1];
        [_jsbSegmentedControl  setSelectedSegmentIndex:[WBRedEnvelopConfig sharedConfig].jsbNum - 1];
    }];
}
@end

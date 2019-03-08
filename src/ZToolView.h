//
//  ZToolView.h
//  Demo
//
//  Created by llbt on 17/7/19.
//  Copyright © 2017年 zf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZToolView : UIView
+ (ZToolView *)sharedZToolView;
@property (nonatomic,copy) void(^SegmentedEventValueChanged)();
- (void)show;
- (void)hide;
@end

//
//  SuspendedBall.h
//  SuspendedBall Example
//
//  Created by MountainX on 2018/1/29.
//  Copyright © 2018年 MTX Software Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IS_IPAD_IDIOM (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_IDIOM (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])

typedef enum : NSUInteger {
    BerthType_Around     = 15,
    BerthType_Horizontal = 3,
    BerthType_Vertical   = 12,
    BerthType_Left       = 1 << 0,
    BerthType_Right      = 1 << 1,
    BerthType_Top        = 1 << 2,
    BerthType_Bottom     = 1 << 3
} BerthType;

NS_ASSUME_NONNULL_BEGIN

@interface SuspendedBall : NSObject

/**
 * 悬浮球停靠方式
 * default:BerthType_Around
 */
@property (nonatomic, assign) BerthType berthType;

/**
 * 停靠后是否延迟透明化（效果类似于AssistiveTouch）
 * default: YES
 */
@property (nonatomic, assign) BOOL delayTranslucent;

/**
 * 悬浮球停留时的透明度（stayAlpha >= 0，1：不透明）
 * default: 0.4
 */
@property (nonatomic, assign) CGFloat transparency;

/**
 * 停靠时的图片（可传入GIF图片）
 * default: [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"redpacket" ofType:@"gif"]]]
 */
@property (nonatomic, strong)UIImage *berthImage;

/**
 * 拖动时的图片（可传入GIF图片）
 * default: [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"girl" ofType:@"gif"]]]
 */
@property (nonatomic, strong)UIImage *draggingImage;

/**
 * 停靠GIF重复次数(0:无限循环)
 * default: 1
 */
@property (nonatomic, assign) CGFloat berthImageRepeatCount;

/**
 * 拖动GIF重复次数(0:无限循环)
 * default: 0
 */
@property (nonatomic, assign) CGFloat draggingImageRepeatCount;

+ (instancetype)sharedInstance;
- (void)showInView:(UIView *)view;
- (void)hide;

@end

NS_ASSUME_NONNULL_END

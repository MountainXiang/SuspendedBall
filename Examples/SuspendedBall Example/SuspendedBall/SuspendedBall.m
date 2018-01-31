//
//  SuspendedBall.m
//  SuspendedBall Example
//
//  Created by MountainX on 2018/1/29.
//  Copyright © 2018年 MTX Software Technology Co.,Ltd. All rights reserved.
//

#import "SuspendedBall.h"
#import <SDWebImage/UIImage+GIF.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIImage+MultiFormat.h>
#import <UIImage+ForceDecode.h>

@interface SuspendedBall()

@property (nonatomic, strong)UIImageView *ball;
@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, strong)NSTimer *delayTimer;

@property (nonatomic, strong)NSTimer *repeatBerthTimer;
@property (nonatomic, strong)NSTimer *repeatDraggingTimer;

@end

@implementation SuspendedBall

#pragma mark - Singlton
+ (instancetype)sharedInstance {
    static SuspendedBall *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
        sharedInstance.transparency = 0.4;
        sharedInstance.delayTranslucentSeconds = 4.f;
        sharedInstance.berthType = BerthType_Around;
        sharedInstance.berthImage = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"redpacket" ofType:@"gif"]]];
        sharedInstance.draggingImage = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"girl" ofType:@"gif"]]];
        sharedInstance.berthImageRepeatCount = 1;
        sharedInstance.draggingImageRepeatCount = 0;
        sharedInstance.margin = 2;
    });
    return sharedInstance;
}

#pragma mark - Public Method
- (void)showInView:(UIView *)view {
    [view addSubview:self.ball];
    [view bringSubviewToFront:self.ball];
    [self beginTimer];
    [self showBerthImage];
}

- (void)hide {
    [self.ball removeFromSuperview];
    [self stopTimer];
    [self stopBerthTimer];
    [self stopDraggingTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter
- (UIImageView *)ball {
    if (!_ball) {
        _ball = [[UIImageView alloc] init];
        _ball.userInteractionEnabled = YES;
        [_ball addGestureRecognizer:self.panGesture];
        [_ball addGestureRecognizer:self.tapGesture];
    }
    return _ball;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    }
    return _tapGesture;
}

#pragma mark - Gesture Action
- (void)panGestureAction:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.ball.superview];
    CGFloat ballWidth = CGRectGetWidth(self.ball.bounds);
    CGFloat ballHeight = CGRectGetHeight(self.ball.bounds);
    
    static CGPoint pointOffset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointOffset = [gestureRecognizer locationInView:self.ball];
    });
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self stopTimer];
        [UIView animateWithDuration:0.25 animations:^{
            self.ball.alpha = 1;
        }];
        if (!self.dragging) {
            [self showDraggingImage];
        }
        self.dragging = YES;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.ball.center = CGPointMake(point.x + ballWidth / 2 - pointOffset.x, point.y  + ballHeight / 2 - pointOffset.y);
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled
               || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.dragging = NO;
        [self showBerthImage];
        [UIView animateWithDuration:0.25 animations:^{
            self.ball.center = [self stickToPointByHorizontal];
        } completion:^(BOOL finished) {
            [self beginTimer];
        }];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gestureRecognizer {
    [self hide];
}

#pragma mark - StickToPoint
- (CGPoint)stickToPointByHorizontal {
    CGRect screen = [UIScreen mainScreen].bounds;
    CGPoint center = self.ball.center;
    CGFloat ballWidth = CGRectGetWidth(self.ball.bounds);
    CGFloat ballHeight = CGRectGetHeight(self.ball.bounds);
    if (center.y < center.x && center.y < -center.x + screen.size.width) {
        CGPoint point = CGPointMake(center.x, _margin + ballHeight / 2);
        point = [self makePointValid:point];
        return point;
    } else if (center.y > center.x + screen.size.height - screen.size.width
               && center.y > -center.x + screen.size.height) {
        CGPoint point = CGPointMake(center.x, CGRectGetHeight(screen) - ballHeight / 2 - _margin);
        point = [self makePointValid:point];
        return point;
    } else {
        if (center.x < screen.size.width / 2) {
            CGPoint point = CGPointMake(_margin + ballWidth / 2, center.y);
            point = [self makePointValid:point];
            return point;
        } else {
            CGPoint point = CGPointMake(CGRectGetWidth(screen) - ballWidth / 2 - _margin, center.y);
            point = [self makePointValid:point];
            return point;
        }
    }
}

- (CGPoint)makePointValid:(CGPoint)point {
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat ballWidth = CGRectGetWidth(self.ball.bounds);
    CGFloat ballHeight = CGRectGetHeight(self.ball.bounds);
    if (point.x < _margin + ballWidth / 2) {
        point.x = _margin + ballWidth / 2;
    }
    if (point.x > CGRectGetWidth(screen) - ballWidth / 2 - _margin) {
        point.x = CGRectGetWidth(screen) - ballWidth / 2 - _margin;
    }
    if (point.y < _margin + ballHeight / 2) {
        point.y = _margin + ballHeight / 2;
    }
    if (point.y > CGRectGetHeight(screen) - ballHeight / 2 - _margin) {
        point.y = CGRectGetHeight(screen) - ballHeight / 2 - _margin;
    }
    return point;
}

#pragma mark - Delay Transparent Timer
- (void)beginTimer {
    _delayTimer = [NSTimer timerWithTimeInterval:_delayTranslucentSeconds target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_delayTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_delayTimer invalidate];
    _delayTimer = nil;
}

- (void)timerFire {
    [UIView animateWithDuration:0.25 animations:^{
        self.ball.alpha = self.transparency;
    } completion:^(BOOL finished) {
        [self stopTimer];
    }];
}

#pragma mark - Repeat Berth Timer
- (void)startBerthTimer {
    if (self.berthImageRepeatCount == 0) {
        [self stopBerthTimer];
        return;
    }
    NSTimeInterval animationInSeconds = self.berthImageRepeatCount * _berthImage.duration;
    _repeatBerthTimer = [NSTimer scheduledTimerWithTimeInterval:animationInSeconds target:self selector:@selector(berthTimerFire) userInfo:nil repeats:NO];
}

- (void)stopBerthTimer {
    [_repeatBerthTimer invalidate];
    _repeatBerthTimer = nil;
}

- (void)berthTimerFire {
    if (!_dragging && _berthImage.images != nil && _berthImage.images.count > 0) {
        self.ball.image = [self redrawImage:[_berthImage.images firstObject]];
    }
}

#pragma mark - Repeat Dragging Timer
- (void)startDraggingTimer {
    if (self.draggingImageRepeatCount == 0) {
        [self stopDraggingTimer];
        return;
    }
    NSTimeInterval animationInSeconds = self.draggingImageRepeatCount * _draggingImage.duration;
    _repeatDraggingTimer = [NSTimer scheduledTimerWithTimeInterval:animationInSeconds target:self selector:@selector(draggingTimerFire) userInfo:nil repeats:NO];
}

- (void)stopDraggingTimer {
    [_repeatDraggingTimer invalidate];
    _repeatDraggingTimer = nil;
}

- (void)draggingTimerFire {
    if (_dragging && _draggingImage.images != nil && _draggingImage.images.count > 0) {
        self.ball.image = [self redrawImage:[_draggingImage.images firstObject]];
    }
}

#pragma mark - GIF Animation
- (void)showBerthImage {
    if (_berthImage.images != nil) {
        self.ball.image = [UIImage animatedImageWithImages:_berthImage.images duration:_berthImage.duration];
        [self startBerthTimer];
    } else {
        self.ball.image = _berthImage;
    }
    [self.ball sizeToFit];
}

- (void)showDraggingImage {
    if (_draggingImage.images != nil) {
        self.ball.image = [UIImage animatedImageWithImages:_draggingImage.images duration:_draggingImage.duration];
        [self startDraggingTimer];
    } else {
        self.ball.image = _draggingImage;
    }
    [self.ball sizeToFit];
}

#pragma mark - Private Method
/**
 绘制指定大小的图片
 */
- (UIImage *)redrawImage:(UIImage *)originalImage {
    CGFloat scale = [UIScreen mainScreen].scale;
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, scale);
    // 绘制图片
    [originalImage drawInRect:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* redrawImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return redrawImage;
}

@end

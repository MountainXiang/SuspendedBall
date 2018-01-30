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

@interface SuspendedBall()

@property (nonatomic, strong)UIImageView *ball;
@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, strong)NSTimer *delayTimer;

@end

@implementation SuspendedBall

#pragma mark - Singlton
+ (instancetype)sharedInstance {
    static SuspendedBall *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
        sharedInstance.transparency = 0.4;
        sharedInstance.delayTranslucent = YES;
        sharedInstance.berthType = BerthType_Around;
        sharedInstance.berthImage = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"redpacket" ofType:@"gif"]]];
        sharedInstance.draggingImage = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"girl" ofType:@"gif"]]];
        sharedInstance.berthImageRepeatCount = 1;
        sharedInstance.draggingImageRepeatCount = 0;
    });
    return sharedInstance;
}

#pragma mark - Dealloc
- (void)dealloc {
    NSLog(@"====Dealloc Success====");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method
- (void)showInView:(UIView *)view {
    [view addSubview:self.ball];
    [view bringSubviewToFront:self.ball];
    [self beginTimer];
}

- (void)hide {
    [self stopTimer];
    [self.ball removeFromSuperview];
}

#pragma mark - Setter
- (void)setBerthImageRepeatCount:(CGFloat)berthImageRepeatCount {
    _berthImageRepeatCount = berthImageRepeatCount;
    _berthImage.sd_imageLoopCount = _berthImageRepeatCount;
}

- (void)setDraggingImageRepeatCount:(CGFloat)draggingImageRepeatCount {
    _draggingImageRepeatCount = draggingImageRepeatCount;
    _draggingImage.sd_imageLoopCount = _draggingImageRepeatCount;
}

#pragma mark - Getter
- (UIImageView *)ball {
    if (!_ball) {
        _ball = [[UIImageView alloc] initWithImage:_berthImage];
        [_ball sizeToFit];
        _ball.userInteractionEnabled = YES;
        [_ball addGestureRecognizer:self.panGesture];
    }
    return _ball;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    }
    return _panGesture;
}

//- (UITapGestureRecognizer *)spreadGestureRecognizer {
//    if (!_spreadGestureRecognizer) {
//        _spreadGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(<#selector#>)];
//    }
//    return _spreadGestureRecognizer;
//}

#pragma mark - Private Methods
- (void)panGestureAction:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.ball.superview];
    CGFloat ballWidth = CGRectGetWidth(self.ball.bounds);
    CGFloat ballHeight = CGRectGetHeight(self.ball.bounds);
    CGFloat margin = 2;
    
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
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (!self.dragging) {
            self.ball.image = _draggingImage;
            [self.ball sizeToFit];
        }
        self.dragging = YES;
        self.ball.center = CGPointMake(point.x + ballWidth / 2 - pointOffset.x, point.y  + ballWidth / 2 - pointOffset.y);
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled
               || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.dragging = NO;
        self.ball.image = _berthImage;
        [self.ball sizeToFit];
        [UIView animateWithDuration:0.25 animations:^{
            self.ball.center = [self stickToPointByHorizontal];
        } completion:^(BOOL finished) {
            [self beginTimer];
        }];
    }
}

#pragma mark - StickToPoint
- (CGPoint)stickToPointByHorizontal {
    CGRect screen = [UIScreen mainScreen].bounds;
    CGPoint center = self.ball.center;
    CGFloat ballWidth = CGRectGetWidth(self.ball.bounds);
    CGFloat ballHeight = CGRectGetHeight(self.ball.bounds);
    CGFloat margin = 2;
    if (center.y < center.x && center.y < -center.x + screen.size.width) {
        CGPoint point = CGPointMake(center.x, margin + ballHeight / 2);
        point = [self makePointValid:point];
        return point;
    } else if (center.y > center.x + screen.size.height - screen.size.width
               && center.y > -center.x + screen.size.height) {
        CGPoint point = CGPointMake(center.x, CGRectGetHeight(screen) - ballHeight / 2 - margin);
        point = [self makePointValid:point];
        return point;
    } else {
        if (center.x < screen.size.width / 2) {
            CGPoint point = CGPointMake(margin + ballWidth / 2, center.y);
            point = [self makePointValid:point];
            return point;
        } else {
            CGPoint point = CGPointMake(CGRectGetWidth(screen) - ballWidth / 2 - margin, center.y);
            point = [self makePointValid:point];
            return point;
        }
    }
}

- (CGPoint)makePointValid:(CGPoint)point {
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat margin = 2;
    CGFloat ballWidth = CGRectGetWidth(self.ball.bounds);
    CGFloat ballHeight = CGRectGetHeight(self.ball.bounds);
    if (point.x < margin + ballWidth / 2) {
        point.x = margin + ballWidth / 2;
    }
    if (point.x > CGRectGetWidth(screen) - ballWidth / 2 - margin) {
        point.x = CGRectGetWidth(screen) - ballWidth / 2 - margin;
    }
    if (point.y < margin + ballHeight / 2) {
        point.y = margin + ballHeight / 2;
    }
    if (point.y > CGRectGetHeight(screen) - ballHeight / 2 - margin) {
        point.y = CGRectGetHeight(screen) - ballHeight / 2 - margin;
    }
    return point;
}

#pragma mark - Timer
- (void)beginTimer {
    _delayTimer = [NSTimer timerWithTimeInterval:4 target:self selector:@selector(timerFireMethod) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_delayTimer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_delayTimer invalidate];
    _delayTimer = nil;
}

- (void)timerFireMethod {
    [UIView animateWithDuration:0.25 animations:^{
        self.ball.alpha = self.transparency;
    } completion:^(BOOL finished) {
        [self stopTimer];
    }];
}

#pragma mark - GIF Animation
- (void)showBerthImage {
    if ([_berthImage isGIF]) {
        
    } else {
        self.ball.image = _berthImage;
    }
}

- (void)showDraggingImage {
    if ([_draggingImage isGIF]) {
        
    } else {
        self.ball.image = _draggingImage;
    }
}

- (void)controlGIFRepeatCount {
    
}

@end

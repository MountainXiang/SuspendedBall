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

@interface SuspendedBall()

@property (nonatomic, strong)UIImageView *ball;
//@property (nonatomic, strong)UITapGestureRecognizer *spreadGestureRecognizer;
@property (nonatomic, strong)UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) BOOL dragging;
@property (nonatomic, strong)UIImage *gifImage;


@end

@implementation SuspendedBall

#pragma mark - Singlton
+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
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
}

- (void)hide {
    [self.ball removeFromSuperview];
}

#pragma mark - Getter
- (UIImageView *)ball {
    if (!_ball) {
        _ball = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SuspendedBall"]];
        [_ball sizeToFit];
        _ball.userInteractionEnabled = YES;
        [_ball addGestureRecognizer:self.panGesture];
        NSData *gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"girl" ofType:@"gif"]];
        _gifImage = [UIImage sd_animatedGIFWithData:gifData];;
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
    
    UIImage *normalImage = [UIImage imageNamed:@"SuspendedBall"];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:1.0 animations:^{
        }];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (!self.dragging) {
            self.ball.image = _gifImage;
            [self.ball sizeToFit];
        }
        self.dragging = YES;
        self.ball.center = CGPointMake(point.x + ballWidth / 2 - pointOffset.x, point.y  + ballWidth / 2 - pointOffset.y);
//        [self.ball sd_setImageWithURL:[NSURL URLWithString:@"http://img.mp.itc.cn/upload/20160829/1455a31c239b4e458c849c68aae1aa7c_th.jpg"]];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled
               || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.dragging = NO;
        self.ball.image = normalImage;
        [self.ball sizeToFit];
        [UIView animateWithDuration:0.3 animations:^{
            self.ball.center = [self stickToPointByHorizontal];
        } completion:^(BOOL finished) {
            
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

@end

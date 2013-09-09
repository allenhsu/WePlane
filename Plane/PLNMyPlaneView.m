//
//  PLNMyPlaneView.m
//  Plane
//
//  Created by Allen Hsu on 9/9/13.
//  Copyright (c) 2013 Allen Hsu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PLNMyPlaneView.h"

#define kMyPlaneFireMargin    5.0
#define kMyPlaneWidth         82.0
#define kMyPlaneHeight        79.0 + 22.0 + kMyPlaneFireMargin

@interface PLNMyPlaneView ()

@property (strong, nonatomic) UIImageView *planeView;
@property (strong, nonatomic) UIImageView *fireView;

@end

@implementation PLNMyPlaneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *myPlane = [UIImage imageNamed:@"plane"];
        self.planeView = [[UIImageView alloc] initWithImage:myPlane];
        self.planeView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.planeView];
        
        UIImage *fire = [UIImage imageNamed:@"plane-rear-fire"];
        self.fireView = [[UIImageView alloc] initWithImage:fire];
        self.fireView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        CGRect fireFrame = self.fireView.frame;
        fireFrame.origin.x = 0;
        fireFrame.origin.y = self.planeView.frame.size.height;
        self.fireView.frame = fireFrame;
        [self addSubview:self.fireView];
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, kMyPlaneWidth, kMyPlaneHeight);
    }
    return self;
}

- (void)didMoveToSuperview
{
    [self stopAnimation];
    [self beginAnimation];
}

- (void)stopAnimation
{
    [self.fireView.layer removeAllAnimations];
}

- (void)beginAnimation
{
    CABasicAnimation *fireAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    fireAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    fireAnimation.toValue = [NSNumber numberWithFloat:3.0];
    fireAnimation.autoreverses = YES;
    fireAnimation.removedOnCompletion = NO;
    fireAnimation.beginTime = 0.0;
    fireAnimation.duration = 0.1;
    fireAnimation.repeatCount = HUGE_VALF;
    [self.fireView.layer addAnimation:fireAnimation forKey:@"fireAnimation"];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

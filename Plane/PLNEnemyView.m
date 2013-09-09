//
//  PLNEnemyView.m
//  Plane
//
//  Created by Allen Hsu on 9/9/13.
//  Copyright (c) 2013 Allen Hsu. All rights reserved.
//

#import "PLNEnemyView.h"

@interface PLNEnemyView ()


@end

@implementation PLNEnemyView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *enemy = [UIImage imageNamed:@"enemy"];
        self.image = enemy;
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, enemy.size.width, enemy.size.height);
        self.speed = kEnemySpeedMin;
    }
    return self;
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

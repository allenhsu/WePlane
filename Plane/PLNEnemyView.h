//
//  PLNEnemyView.h
//  Plane
//
//  Created by Allen Hsu on 9/9/13.
//  Copyright (c) 2013 Allen Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kEnemySpeedMin      100
#define kEnemySpeedMax      200

@interface PLNEnemyView : UIImageView

@property (assign, nonatomic) CGFloat speed;
@property (assign, nonatomic) CFTimeInterval beginTime;

@end

//
//  PLNMainViewController.m
//  Plane
//
//  Created by Allen Hsu on 9/9/13.
//  Copyright (c) 2013 Allen Hsu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PLNMainViewController.h"
#import "PLNMyPlaneView.h"
#import "PLNEnemyView.h"

#define kBgSpeed        100
#define kBulletSpeed    800

#define kPointPerPlane  1000

@interface PLNMainViewController ()

- (void)initViews;
- (void)restartGame;
- (void)gameEnds;
- (void)newRandomEnemy;

@property (assign, nonatomic) NSUInteger point;
@property (strong, nonatomic) NSMutableArray *enemies;

@property (strong, nonatomic) UIView *bulletView;
@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) PLNMyPlaneView *myPlaneView;

@property (strong, nonatomic) CADisplayLink *timer;
@property (assign, nonatomic) CFTimeInterval gameBeginTime;
@property (assign, nonatomic) CFTimeInterval bulletBeginTime;
@property (assign, nonatomic) CGPoint bulletBeginCenter;

@property (strong, nonatomic) UILabel *pointLabel;

@end

@implementation PLNMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initViews];
        [self restartGame];
    }
    return self;
}

- (void)initViews
{
    self.view.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:200.0/255.0 blue:201.0/255.0 alpha:1.0];
    
    UIImage *background = [UIImage imageNamed:@"background"];
    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.frame = CGRectMake(0.0, 0.0 - self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height * 2);
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:background];
    [self.view addSubview:self.backgroundView];
    
    self.myPlaneView = [[PLNMyPlaneView alloc] init];
    CGRect initFrame = self.myPlaneView.frame;
    initFrame.origin.x = (self.view.frame.size.width - initFrame.size.width) / 2;
    initFrame.origin.y = self.view.frame.size.height - initFrame.size.height;
    self.myPlaneView.frame = initFrame;
    
    self.bulletView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bullet"]];
    [self.view addSubview:self.bulletView];
    [self shoot];
    
    self.pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 40.0)];
    self.pointLabel.font = [UIFont boldSystemFontOfSize:32.0];
    self.pointLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.pointLabel];
    
    // Pan gesture for moving my plane
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panRecognizer];
    [self.view addSubview:self.myPlaneView];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognier
{
    CGPoint translation = [recognier translationInView:self.view];
    CGFloat x = self.myPlaneView.frame.origin.x + translation.x;
    CGFloat y = self.myPlaneView.frame.origin.y + translation.y;
    
    // 两边多 10.0，以便可以打到屏幕边缘的飞机
    x = fminf(fmaxf(x, -10.0), self.view.frame.size.width - self.myPlaneView.frame.size.width + 10.0);
    y = fminf(fmaxf(y, -10.0), self.view.frame.size.height - self.myPlaneView.frame.size.height + 10.0);
    
    x += self.myPlaneView.frame.size.width / 2;
    y += self.myPlaneView.frame.size.height / 2;
    
    self.myPlaneView.center = CGPointMake(x, y);
    
    [recognier setTranslation:CGPointMake(0.0, 0.0) inView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)restartGame
{
    self.point = 0;
    self.pointLabel.text = @"0";
    self.enemies = [NSMutableArray array];
    
    CGRect initFrame = self.myPlaneView.frame;
    initFrame.origin.x = (self.view.frame.size.width - initFrame.size.width) / 2;
    initFrame.origin.y = self.view.frame.size.height - initFrame.size.height;
    self.myPlaneView.frame = initFrame;
    self.myPlaneView.hidden = NO;
    self.bulletView.hidden = NO;
    
    self.gameBeginTime = 0;
    
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(mainLoop)];
    [self.timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self shoot];
}

- (void)gameEnds
{
    CFTimeInterval endTime = self.timer.timestamp;
    
    if (self.timer) {
        [self.timer invalidate];
    }
    
    self.myPlaneView.hidden = YES;
    self.bulletView.hidden = YES;
    
    for (PLNEnemyView *enemy in self.enemies) {
        [enemy removeFromSuperview];
    }
    
    self.enemies = nil;
    
    NSString *message = [NSString stringWithFormat:@"你坚持了 %d 秒，最后得分：%u", (int)(endTime - self.gameBeginTime), self.point];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"游戏结束" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"重新开始", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self restartGame];
}

- (void)mainLoop
{
    CFTimeInterval time = self.timer.timestamp;
    
    if (self.gameBeginTime == 0) {
        self.gameBeginTime = time;
    }
    
    // 难度系统，飞机越来越多，60 秒后到达高峰
    
    int level = (int)(time - self.gameBeginTime);
    level = MIN(level, 59);
    
    if (0 == rand() % (60 - level))
    {
        [self newRandomEnemy];
    }
    // Background
    CGRect bgFrame = self.backgroundView.frame;
    bgFrame.origin.y = (int)(time * kBgSpeed) % 480 - 480.0;
    self.backgroundView.frame = bgFrame;
    
//    CGPoint lastBulletCenter = self.bulletView.center;
//    CGPoint newBulletCenter = self.bulletView.center;
//    newBulletCenter.y = self.bulletBeginCenter.y - (time - self.bulletBeginTime) * kBulletSpeed;
    self.bulletView.center = CGPointMake(self.bulletView.center.x, self.bulletBeginCenter.y - (time - self.bulletBeginTime) * kBulletSpeed);
    
    NSMutableArray *enemiesToRemove = [NSMutableArray array];
    BOOL isHit = NO;
    BOOL isCrash = NO;
    
    for (PLNEnemyView *enemy in self.enemies) {
        enemy.center = CGPointMake(enemy.center.x, (time - enemy.beginTime) * enemy.speed);
        
        BOOL enemyDown = NO;
        // Hit Test
        if (!isHit) {
            // Check if bullet hits the enemy
            isHit = enemyDown = CGRectIntersectsRect(self.bulletView.frame, enemy.frame);
            
            if (enemyDown) {
                self.point += kPointPerPlane;
                self.pointLabel.text = [NSString stringWithFormat:@"%u", self.point];
                [enemy removeFromSuperview];
                [enemiesToRemove addObject:enemy];
            }
        }
        
        // Crash Test
        if (!enemyDown) {
            isCrash = CGRectIntersectsRect(self.myPlaneView.frame, enemy.frame);
        }
        
        if (isCrash) {
            [self gameEnds];
        }
        
        // Out of screen test
        
        if (enemy.frame.origin.y > self.view.bounds.size.height) {
            [enemy removeFromSuperview];
            [enemiesToRemove addObject:enemy];
        }
    }
    
    [self.enemies removeObjectsInArray:enemiesToRemove];
    
    if (isHit || self.bulletView.frame.origin.y + self.bulletView.frame.size.height < 0.0) {
        [self shoot];
    }
}

- (void)shoot
{
    self.bulletBeginTime = self.timer.timestamp;
    self.bulletBeginCenter = CGPointMake(self.myPlaneView.center.x, self.myPlaneView.frame.origin.y - self.bulletView.frame.size.height);
    self.bulletView.center = self.bulletBeginCenter;
}

- (void)newRandomEnemy
{
    PLNEnemyView *enemy = [[PLNEnemyView alloc] init];
    CGFloat x = arc4random() % (int)self.view.frame.size.width;
    x = fminf(fmaxf(x, 0.0), self.view.frame.size.width - enemy.frame.size.width);
    x += enemy.frame.size.width / 2;
    enemy.center = CGPointMake(x, 0.0 - enemy.frame.size.height / 2);
    
    CGFloat speed = arc4random() % (kEnemySpeedMax - kEnemySpeedMin) + kEnemySpeedMin;
    enemy.speed = speed;
    enemy.beginTime = self.timer.timestamp;
    
    [self.enemies addObject:enemy];
    [self.view addSubview:enemy];
}

@end

//
//  PannableViewController.m
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/14.
//  Copyright © 2018年 Django. All rights reserved.
//

#import "PannableViewController.h"

@interface PannableViewController ()
@property (nonatomic) CGFloat minimumVelocityToHide;
@property (nonatomic) CGFloat minimumScreenRatioToHide;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic)BOOL canPan;
-(void) setupController;
-(void) slideViewVerticallyTo:(CGFloat)yPosition;
-(void) onPan:(UIPanGestureRecognizer*)panGesture;
@end

@implementation PannableViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupController];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:(@selector(onPan:))];
    [[self view] addGestureRecognizer:panGesture];
}

- (void)enablePanToDismiss:(BOOL)to {
    self.canPan = to;
}

#pragma mark - Public Methods
-(void)backToAppear {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:self.animationDuration animations:^{
        [weakSelf slideViewVerticallyTo:0];
        weakSelf.view.alpha = 1;
    }];
}

-(void)onDismiss {
    // For Child Controller Override
}

#pragma mark - Private Methods
-(void)setupController {
    self.minimumVelocityToHide = 1500;
    self.minimumScreenRatioToHide = 0.5;
    self.animationDuration = 0.2;
    self.canPan = false;
}

- (void)onPan:(UIPanGestureRecognizer*)panGesture {
    if (self.canPan) {
        CGPoint translation = [panGesture translationInView:self.view];
        CGPoint velocity = [panGesture velocityInView:self.view];
        CGFloat yPosition = MAX(0, translation.y);
        BOOL closing = (translation.y > self.view.frame.size.height * self.minimumScreenRatioToHide) ||
        (velocity.y > self.minimumVelocityToHide);
        
        switch (panGesture.state) {
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged:
                [self slideViewVerticallyTo:yPosition];
                break;
            case UIGestureRecognizerStateEnded:
                if (closing) {
                    __weak typeof(self) weakSelf = self;
                    [UIView animateWithDuration:self.animationDuration animations:^{
                        weakSelf.view.alpha = 0;
                        [weakSelf slideViewVerticallyTo:weakSelf.view.frame.size.height];
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [weakSelf onDismiss];
                        }
                    }];
                } else {
                    [self backToAppear];
                }
            default:
                
                [UIView animateWithDuration:self.animationDuration animations:^{
                    [self slideViewVerticallyTo: 0];
                }];
                break;
        }
    }
}

-(void) slideViewVerticallyTo:(CGFloat)yPosition {
    self.view.alpha = 1 - (yPosition/self.view.bounds.size.height);
    CGRect tempRect = self.view.frame;
    tempRect.origin = CGPointMake(0, yPosition);
    self.view.frame = tempRect;
}
@end

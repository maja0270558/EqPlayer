//
//  PannableViewController.h
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/14.
//  Copyright © 2018年 Django. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface PannableViewController : UIViewController
-(void) backToAppear;
-(void) onDismiss;
-(void) enablePanToDismiss:(BOOL)to;
@end

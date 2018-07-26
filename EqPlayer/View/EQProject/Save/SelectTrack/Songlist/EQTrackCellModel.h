//
//  EQTrackCellModel.h
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/19.
//  Copyright © 2018年 Django. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class EQTrack;

@interface EQTrackCellModel : NSObject
@property (nonatomic) NSString *trackName;
@property (nonatomic) NSString *coverURL;
@property (nonatomic) NSString *artist;
@property (nonatomic) UIColor *swipeColor;
@property (nonatomic) UIImage *swipeImage;
@property (nonatomic) CGFloat constraintWidth;
- (instancetype)initWithTrackModel:(EQTrack *)track isAdded:(BOOL)added isParentController:(BOOL) isParent;
@end

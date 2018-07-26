//
//  EQTrackCellModel.m
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/19.
//  Copyright © 2018年 Django. All rights reserved.
//

#import "EQTrackCellModel.h"
#import "EqPlayer-Swift.h"

@implementation EQTrackCellModel

- (instancetype)initWithTrackModel:(EQTrack *)track isAdded:(BOOL)added isParentController:(BOOL) isParent {
    self = [super init];
    if (self) {
        self.trackName = track.name;
        self.artist = track.artist;
        self.coverURL = track.coverURL;
        self.swipeImage = added ? [UIImage imageNamed:@"remove"] : [UIImage imageNamed:@"add"];
        self.swipeColor = added ? [UIColor colorWithRed:1 green:38/255 blue:0 alpha:0.3] : [UIColor colorWithRed:0.3 green:0.5 blue:0 alpha:0.3];
        self.constraintWidth = (added && !isParent) ? 20 : 0;
    }
    return self;
}
@end

//
//  EQTrackTableViewModel.h
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/18.
//  Copyright © 2018年 Django. All rights reserved.
//
#import "EQTrackCellModel.h"
#import <ReactiveObjC/ReactiveObjC.h>

@class EQSettingModelManager;
@class EQTrack;
@class EQSonglistTableViewCell;
@protocol EQTrackProtocol;

@protocol EQTrackTableViewModelProtocol <NSObject>
@property (nonatomic, strong) EQSettingModelManager *projectModel;
@property (nonatomic, strong) NSMutableArray<id<EQTrackProtocol>> *tracks;
@property (nonatomic) RACSignal *dataChangeSignal;
@property (nonatomic, strong) NSMutableArray<EQTrackCellModel *> *cellModels;
-(NSInteger) numberOfRowInSection;
-(NSInteger) estimatedHeightForRow;
-(EQTrackCellModel *) getCellModelAt:(NSIndexPath *) indexPath;
-(void) addOrRemoveThisTrackInProjectModelAt:(NSIndexPath *) indexPath;
-(BOOL) checkCellIsCurrentPlayingPreviewCellAt:(NSIndexPath *) indexPath;
-(void) playOrStopTrackPreviewPlaybackAt:(NSIndexPath*) indexPath completion:(void (^)(void))callback;
@end

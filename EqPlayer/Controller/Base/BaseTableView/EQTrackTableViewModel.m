//
//  EQTrackTableViewModel.m
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/17.
//  Copyright © 2018年 Django. All rights reserved.
//

#import "EqPlayer-Swift.h"
// View Model
#import "EQTrackTableViewModel.h"
#import "EQTrackCellModel.h"

@interface EQTrackTableViewModel()

@property (nonatomic) RACSignal *trackSignal;
-(EQTrack *) getTrcakAt:(NSIndexPath *) indexPath;
-(BOOL) checkTrackCurrentIsAddedInProjectModelAt:(NSIndexPath *) indexPath;
@end

@implementation EQTrackTableViewModel
#pragma mark - EQTrackTableViewModelProtocol Methods
-(instancetype) initWithEQSettingManager:(EQSettingModelManager*) manager andTracks:(NSMutableArray<id<EQTrackProtocol>> *) tracks isProjectController:(BOOL) isProjectVC {
    self = [super init];
    if (self) {
        self.tracks = tracks;
        self.projectModel = manager;
        self.isParentTrackViewController = isProjectVC;
        
        RAC(self,cellModels) = self.trackSignal;
        
        @weakify(self)
        [[self.projectModel trackSignal] subscribeNext:^(id x) {
            @strongify(self)
            NSMutableArray<EQTrackCellModel *> *cellModels = [[NSMutableArray<EQTrackCellModel *> alloc] init];
            for (id<EQTrackProtocol> trackProtocol in self.tracks) {
                EQTrack *track = [trackProtocol getTrack];
                BOOL added = [self.projectModel checkIsAddedWithUri:track.uri];
                EQTrackCellModel *cellModel = [[EQTrackCellModel alloc] initWithTrackModel:track isAdded:added isParentController:self.isParentTrackViewController];
                [cellModels addObject:cellModel];
            }
            self.cellModels = cellModels;
        }];
        
        self.dataChangeSignal = RACObserve(self, cellModels);
    }
    return self;
}

- (RACSignal *)trackSignal {
    if (_trackSignal) {
        return _trackSignal;
    }
    
    _trackSignal = [RACObserve(self, tracks) map:^id (NSMutableArray<id<EQTrackProtocol>> *array) {
        NSMutableArray<EQTrackCellModel *> *cellModels = [[NSMutableArray<EQTrackCellModel *> alloc] init];
        for (id<EQTrackProtocol> trackProtocol in array) {
            EQTrack *track = [trackProtocol getTrack];
            BOOL added = [self.projectModel checkIsAddedWithUri:track.uri];
            EQTrackCellModel *cellModel = [[EQTrackCellModel alloc] initWithTrackModel:track isAdded:added isParentController:self.isParentTrackViewController];
            [cellModels addObject:cellModel];
        }
        return cellModels;
    }];
    return _trackSignal;
}

- (void)addOrRemoveThisTrackInProjectModelAt:(NSIndexPath *) indexPath{
    EQTrack *track = [self getTrcakAt:indexPath];
    if ([self checkTrackCurrentIsAddedInProjectModelAt:indexPath]) {
        [self.projectModel getIndexWithUri:track.uri completion:^(NSInteger index) {
            [self.projectModel removeTrackAtIndex:index];
        }];
    } else {
        [self.projectModel appendTrackAtTrack:track];
    }
    self.projectModel.isModify = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification.eqProjectTrackModifyNotification object:self];
}

- (BOOL) checkCellIsCurrentPlayingPreviewCellAt:(NSIndexPath *) indexPath {
    if (indexPath.row >= self.tracks.count){
        return false;
    }
    EQTrack *track = [self getTrcakAt:indexPath];
    return [EQSpotifyManager.shard.previousPreviewURLString isEqualToString:track.uri];
}

- (void) playOrStopTrackPreviewPlaybackAt:(NSIndexPath*) indexPath completion:(void (^)(void))callback {
    EQTrack *track = [self getTrcakAt:indexPath];
    if ([EQSpotifyManager.shard.previousPreviewURLString isEqualToString:track.uri] == false) {
        [EQSpotifyManager.shard playPreviewWithUri:track.uri duration:track.duration callback:^{
            EQSpotifyManager.shard.previousPreviewURLString = track.uri;
            EQSpotifyManager.shard.durationObseve.previewCurrentDuration = 0;
            callback();
            if (self.isParentTrackViewController == false){
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification.eqProjectPlayPreviewTrack object:self];
            }
        }];
    } else {
        [EQSpotifyManager.shard setCurrentPlayingTypeWithIndex:1];
        [EQSpotifyManager.shard playOrPauseWithIsPlay:false completion:^{
            EQSpotifyManager.shard.previousPreviewURLString = @"";
            if (self.isParentTrackViewController == false){
                [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification.eqProjectPlayPreviewTrack object:self];
            }
        }];
    }
}

-(EQTrackCellModel *) getCellModelAt:(NSIndexPath *) indexPath {
    if(indexPath.row >= self.cellModels.count) {
        return nil;
    }
    return self.cellModels[indexPath.row];
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfRowInSection {
    if (self.cellModels) {
        return self.cellModels.count;
    }
    return 0;
}

- (NSInteger)estimatedHeightForRow {
    return 55;
}

#pragma mark - Private Methods
-(EQTrack *) getTrcakAt:(NSIndexPath *) indexPath {
    return [self.tracks[indexPath.row] getTrack];
}

- (BOOL)checkTrackCurrentIsAddedInProjectModelAt:(NSIndexPath *) indexPath{
    EQTrack *track = [self getTrcakAt:indexPath];
    return [self.projectModel checkIsAddedWithUri:track.uri];
}
@end

//
//  EQTrackTableViewModelTest.m
//  EqPlayerTests
//
//  Created by 大容 林 on 2018/7/19.
//  Copyright © 2018年 Django. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EQTrackTableViewModel.h"
#import "EqPlayer-Swift.h"
#import "EQTrackCellModel.h"
#import "EqPlayer-Bridging-Header.h"

@interface EQTrackTableViewModelTest : XCTestCase
@property EQTrackTableViewModel *model;
@property EQSettingModelManager *manager;
@property NSMutableArray<id<EQTrackProtocol>> *tracks;
@property NSMutableArray<EQTrack *> *inputTrackArray;
@end

@implementation EQTrackTableViewModelTest
- (void)setUp {
    [super setUp];
    [self createFakeData];
}

- (void)tearDown {
    [self cleanFakeData];
    [super tearDown];
}

- (void)createFakeData {
    EQSettingModelManager *manager = [EQSettingModelManager new];
    self.inputTrackArray = [NSMutableArray<EQTrack *> new];
    for (int i=0; i<=5; i++) {
        EQTrack *track = [EQTrack new];
        NSString *index = [NSString stringWithFormat:@"%d",i];
        track.name = [@"Test" stringByAppendingString:index];
        track.coverURL = [@"TestURL" stringByAppendingString:index];
        track.artist = [@"Django1" stringByAppendingString:index];
        track.uri = [@"TestURI" stringByAppendingString:index];
        [self.inputTrackArray addObject:track];
    }
    [self.tracks addObjectsFromArray:self.inputTrackArray];
    self.model = [[EQTrackTableViewModel alloc] initWithEQSettingManager:manager andTracks:((NSMutableArray<id<EQTrackProtocol>> *) self.inputTrackArray) isProjectController:false];
    [self.model.projectModel appendTrackAtTrack:self.inputTrackArray[0]];

}

- (void)cleanFakeData {
    self.manager = nil;
    self.model = nil;
    self.tracks = nil;
}

- (void)test_NumberOfRowInSection_WhenTrackArrayIsEmpty_ReturnZero {
    self.model.cellModels = nil;
    XCTAssertEqual(self.model.numberOfRowInSection, 0);
}

- (void)test_NumberOfRowInSection_WhenTrackArrayIsNotEmpty_ReturnCellModelCount {
    XCTAssertEqual(self.model.numberOfRowInSection, self.model.cellModels.count);
}

- (void)test_EstimatedHeightForRow_ReturnDefaultValue {
    XCTAssertEqual(self.model.estimatedHeightForRow, 55);
}

- (void)test_AddOrRemoveThisTrackInProjectModelAt_WhenProjectModelDoesNotContainTrack_AddTrackInProjectModel {
    int targetIndex = 3;
    NSIndexPath *input = [NSIndexPath indexPathForRow:targetIndex inSection:0];
    EQTrack *target = self.inputTrackArray[targetIndex];
    [self.model addOrRemoveThisTrackInProjectModelAt:input];
    BOOL result = [self.model.projectModel.tempModel.tracksForObjc containsObject:target];
    XCTAssertTrue(result);
}

- (void)test_AddOrRemoveThisTrackInProjectModelAt_WhenProjectModelContainTrack_RemoveTrackInProjectModel {
    int targetIndex = 0;
    NSIndexPath *input = [NSIndexPath indexPathForRow:targetIndex inSection:0];
    EQTrack *target = self.inputTrackArray[targetIndex];
    [self.model addOrRemoveThisTrackInProjectModelAt:input];
    BOOL result = [self.model.projectModel.tempModel.tracksForObjc containsObject:target];
    XCTAssertFalse(result);
}

- (void)test_CheckCellIsCurrentPlayingPreviewCellAt_WhenTrackURIIsEqualToManagerPreviousPreviewURI_ReturnTrue {
    int targetIndex = 0;
    NSIndexPath *input = [NSIndexPath indexPathForRow:targetIndex inSection:0];
    EQSpotifyManager.shard.previousPreviewURLString = @"TestURI0";
    BOOL result = [self.model checkCellIsCurrentPlayingPreviewCellAt:input];
    XCTAssertTrue(result);
}

- (void)test_CheckCellIsCurrentPlayingPreviewCellAt_WhenIndexOutOfRange_ReturnFalse {
    int targetIndex = 99;
    NSIndexPath *input = [NSIndexPath indexPathForRow:targetIndex inSection:0];
    EQSpotifyManager.shard.previousPreviewURLString = @"TestURI0";
    BOOL result = [self.model checkCellIsCurrentPlayingPreviewCellAt:input];
    XCTAssertFalse(result);
}

- (void)test_GetCellModelAt_WhenPassingIndexPath_ReturnCellModelAtThatIndexPath {
    int targetIndex = 0;
    NSIndexPath *input = [NSIndexPath indexPathForRow:targetIndex inSection:0];
    EQTrack *target = self.inputTrackArray[targetIndex];
    EQTrackCellModel *result = [self.model getCellModelAt:input];
    XCTAssertEqual(target.name, result.trackName);
}

- (void)test_GetCellModelAt_WhenIndexPathOutOfRange_ReturnNil {
    int targetIndex = 99;
    NSIndexPath *input = [NSIndexPath indexPathForRow:targetIndex inSection:0];
    EQTrackCellModel *result = [self.model getCellModelAt:input];
    XCTAssertEqual(result, nil);
}
@end

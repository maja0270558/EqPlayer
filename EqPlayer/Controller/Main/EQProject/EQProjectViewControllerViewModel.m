//
//  EQProjectViewControllerViewModel.m
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/18.
//  Copyright © 2018年 Django. All rights reserved.
//

#import "EQProjectViewControllerViewModel.h"
#import "EqPlayer-Swift.h"

@implementation EQProjectViewControllerViewModel
- (void)updateProjectTrack  {
    self.tracks = [NSMutableArray arrayWithArray:self.projectModel.tempModel.tracksForObjc];
    self.projectModel.isModify = true;
}
- (NSString *)saveButtonTitle {
    return self.projectModel.isModify ? @"儲存" : @"編輯";
}


- (void)resetAllEQSetting {
    [EQSpotifyManager.shard resetPreviewURL ];
    [EQSpotifyManager.shard playFromLastDuration ];
    [EQSpotifyManager.shard setGainWithSetting:EQSpotifyManager.shard.currentSetting];
}

-(void) save:(int) type withDescribe:(nullable NSString*)describe{
    if (self.projectModel.tempModel.tracksForObjc.count > 0) {
    switch (type) {
        case 2:
            [self.projectModel saveObjectToStatus:EQProjectStatusSaved];
            self.projectModel.tempModel.status = EQProjectStatusSaved;
            break;
        case 4:
            self.projectModel.tempModel.status = EQProjectStatusPost;
            self.projectModel.tempModel.detailDescription = describe;
            [EQFirebaseManager postEQProjectWithProjectModel:self.projectModel.tempModel];
            break;
        case 3:
            if (self.projectModel.tempModel.status != EQProjectStatusSaved)
            [self.projectModel saveObjectToStatus:EQProjectStatusTemp];
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNotification.eqProjectSave object:self];
    }

}

- (void)settingEQAt:(int)index andGiveValue:(double)value {
    self.projectModel.isModify = true;
    [self.projectModel setEQSettingAtIndex:index value:value];
}

-(void) setProjectName:(NSString*)name {
    self.projectModel.tempModel.name = name;
}

- (NSString *)projectName {
    return [self.projectModel.tempModel.name  isEqual: @""] ? @"專案" : self.projectModel.tempModel.name;
}





@end

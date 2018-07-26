//
//  EQProjectViewControllerViewModelProtocol.h
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/18.
//  Copyright © 2018年 Django. All rights reserved.
//


@protocol EQProjectViewControllerViewModelProtocol <EQTrackTableViewModelProtocol>
-(void) updateProjectTrack;
-(void) resetAllEQSetting;
-(void) settingEQAt:(int)index andGiveValue:(double)value;
-(void) save:(int) type withDescribe:(nullable NSString*)describe;
-(nonnull NSString *) saveButtonTitle;
-(nonnull NSString *) projectName;
-(void) setProjectName:(nonnull NSString*)name;
@end

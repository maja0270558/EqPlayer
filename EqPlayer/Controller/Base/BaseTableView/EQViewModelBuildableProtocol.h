//
//  EQViewModelBuildableProtocol.h
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/18.
//  Copyright © 2018年 Django. All rights reserved.
//

@protocol EQViewModelBuildableProtocol
-(void) buildViewModel:(EQSettingModelManager*) projectModel withTracks:(NSMutableArray<id<EQTrackProtocol>>*)tracks isProjectController:(BOOL) isProjectVC;
@end

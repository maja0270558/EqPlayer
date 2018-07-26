//
//  EQTrackTableViewModel.h
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/17.
//  Copyright © 2018年 Django. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ReactiveObjC/ReactiveObjC.h>

// Cell View Model
#import "EQTrackCellModel.h"
// Protocol
#import "EQTrackTableViewModelProtocol.h"

@class EQSettingModelManager;
@class EQTrack;
@class EQSonglistTableViewCell;
@protocol EQTrackProtocol;

@interface EQTrackTableViewModel : NSObject <EQTrackTableViewModelProtocol>
@property (nonatomic, assign) BOOL isParentTrackViewController;
@property (nonatomic, strong) EQSettingModelManager *projectModel;
@property (nonatomic, strong) NSMutableArray<id<EQTrackProtocol>> *tracks;
@property (nonatomic) RACSignal *dataChangeSignal;
@property (nonatomic, strong) NSMutableArray<EQTrackCellModel *> *cellModels;
-(instancetype) initWithEQSettingManager:(EQSettingModelManager*) manager andTracks:(NSMutableArray<id<EQTrackProtocol>> *) tracks isProjectController:(BOOL) isProjectVC;
@end

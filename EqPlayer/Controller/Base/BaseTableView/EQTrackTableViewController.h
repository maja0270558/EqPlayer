//
//  EQTrackTableViewController.h
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/14.
//  Copyright © 2018年 Django. All rights reserved.
//

#import <UIKit/UIKit.h>

// Super View Controller
#import "PannableViewController.h"
// View Model
#import "EQTrackTableViewModel.h"
#import "EQTrackCellModel.h"
// Protocol
#import "EQViewModelBuildableProtocol.h"
#import "EQTrackTableViewModelProtocol.h"

@protocol EQTrackProtocol;
@class EQSettingModelManager;
@class EQTrackTableViewModel;

@interface EQTrackTableViewController : PannableViewController <UITableViewDelegate, UITableViewDataSource , EQViewModelBuildableProtocol>
@property (nonatomic, readonly) id<EQTrackTableViewModelProtocol> parentViewModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

//
//  EQTrackTableViewController.m
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/14.
//  Copyright © 2018年 Django. All rights reserved.
//

#import "EQTrackTableViewController.h"
#import "EqPlayer-Swift.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface EQTrackTableViewController ()
@property (nonatomic) NSString *identifier;
-(void) resetAllVisibleCell;
-(void) resetCellWith:(EQSonglistTableViewCell*)cell;
-(void) setupTableView;
-(void) cleanUpCellPreviewProgressBar:(EQSonglistTableViewCell *) cell;
@end

@implementation EQTrackTableViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    @weakify(self)
    [self.parentViewModel.dataChangeSignal subscribeNext:^(id x) {
        @strongify(self)
        [self.tableView reloadDataUpdateFade];
    }];
}

#pragma mark - EQViewModelBuildableProtocol
- (void)buildViewModel:(EQSettingModelManager *)projectModel withTracks:(NSMutableArray<id<EQTrackProtocol>> *)tracks isProjectController:(BOOL)isProjectVC {
    _parentViewModel = [[EQTrackTableViewModel alloc] initWithEQSettingManager:projectModel andTracks:tracks isProjectController:isProjectVC];
}

#pragma mark - For TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.parentViewModel numberOfRowInSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *unTypeCell = [self.tableView dequeueReusableCellWithIdentifier:self.identifier forIndexPath:indexPath];
    
    if(![unTypeCell isKindOfClass:EQSonglistTableViewCell.class]) {
        return unTypeCell;
    }
    
    EQSonglistTableViewCell *cell = (EQSonglistTableViewCell *) unTypeCell;
    
    @weakify(self)
    [[[cell.previewButton rac_signalForControlEvents:UIControlEventTouchUpInside]
       takeUntil:(cell.rac_prepareForReuseSignal)]
       subscribeNext:^(UIControl *x) {
           @strongify(self)
           [self previewAction:cell];
     }];
    
    EQTrackCellModel *cellModel = self.parentViewModel.cellModels[indexPath.row];
    if (cellModel) {
        [cell configureCellWithCellModel:cellModel swipeCallback:^BOOL(MGSwipeTableCell *sender) {
            @strongify(self)
            [self.parentViewModel addOrRemoveThisTrackInProjectModelAt:indexPath];
            return true;
        }];
    }
    
    if([self.parentViewModel checkCellIsCurrentPlayingPreviewCellAt:indexPath]) {
        [cell obsevePreviewDuration];
        [cell.previewButton setSelected:true];
        [cell startObseve];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.parentViewModel estimatedHeightForRow];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([cell isKindOfClass:EQSonglistTableViewCell.class]) {
        [self resetCellWith:(EQSonglistTableViewCell *) cell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.parentViewModel addOrRemoveThisTrackInProjectModelAt:indexPath];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView fadeTopCell];
}

#pragma mark - Private Methods
- (void)setupTableView {
    self.identifier = @"EQSonglistTableViewCell";
    UINib *nib = [UINib nibWithNibName: self.identifier bundle: nil];
    [self.tableView registerNib:nib forCellReuseIdentifier: self.identifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void) resetAllVisibleCell{
    if (![[self.tableView visibleCells] isKindOfClass:[NSArray<EQSonglistTableViewCell *> class]]) {
        return;
    }
    NSArray<EQSonglistTableViewCell *> *cells = [self.tableView visibleCells];
    [cells enumerateObjectsUsingBlock:^(EQSonglistTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self cleanUpCellPreviewProgressBar:obj];
    }];
}

-(void) resetCellWith:(EQSonglistTableViewCell*)cell {
    [self cleanUpCellPreviewProgressBar:cell];
}

- (void)previewAction:(UITableViewCell *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if(![cell isKindOfClass:EQSonglistTableViewCell.class] && indexPath) {
        return;
    }
    EQSonglistTableViewCell *trackCell = (EQSonglistTableViewCell *) cell;
    [self resetAllVisibleCell];
    [self.parentViewModel playOrStopTrackPreviewPlaybackAt:indexPath completion:^{
        [trackCell startObseve];
        [trackCell.previewButton setSelected:true];
    }];
}

-(void) cleanUpCellPreviewProgressBar:(EQSonglistTableViewCell *) cell {
    [cell.timer invalidate];
    cell.previewProgressBar.progress = 0;
    [cell.previewButton setSelected:false];
}

@end

//
//  PDCLTableView.h
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDCLTableView;

NS_ASSUME_NONNULL_BEGIN

typedef UIView PDCLTableViewCell;
typedef UIView PDCLTableViewHeaderFooterView;

@protocol PDCLTableViewDelegate <UIScrollViewDelegate>

- (CGFloat)tableView:(PDCLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(PDCLTableView *)tableView heightForHeaderInSection:(NSInteger)section;

@end

@protocol PDCLTableViewDataSource <NSObject>

- (UIView *)ceilingHeaderContainerForTableView:(PDCLTableView *)tableView;

- (NSInteger)tableView:(PDCLTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (PDCLTableViewCell *)tableView:(PDCLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(PDCLTableView *)tableView;
- (PDCLTableViewHeaderFooterView *)tableView:(PDCLTableView *)tableView viewForHeaderInSection:(NSInteger)section;

@end

@interface PDCLTableView : UIScrollView

@property (nonatomic, weak, nullable) id<PDCLTableViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<PDCLTableViewDataSource> dataSource;

- (void)reloadData; // Remove cells and headers, then readd them.
- (void)reloadFrame; // Only reload frame.

- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END

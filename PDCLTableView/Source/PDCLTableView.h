//
//  PDCLTableView.h
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//
//  Without reuse mechanism, support ceiling header.
//

#import <UIKit/UIKit.h>
#import "PDCLTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class PDCLTableView, PDCLTableViewHeaderFooterView;

@protocol PDCLTableViewDelegate <UIScrollViewDelegate>

- (CGFloat)tableView:(PDCLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(PDCLTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (PDCLTableViewHeaderFooterView *)tableView:(PDCLTableView *)tableView viewForHeaderInSection:(NSInteger)section;

@end

@protocol PDCLTableViewDataSource <NSObject>

- (NSInteger)numberOfSectionsInTableView:(PDCLTableView *)tableView;
- (NSInteger)tableView:(PDCLTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (PDCLTableViewCell *)tableView:(PDCLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PDCLTableView : UIScrollView

@property (nonatomic, weak, nullable) id<PDCLTableViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<PDCLTableViewDataSource> dataSource;

@property (nonatomic, readonly) NSInteger numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (void)reloadData; // Remove cells and headers, then readd them.
- (void)reloadFrame; // Only reload frame.

- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForSection:(NSInteger)section;

- (nullable PDCLTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSArray<PDCLTableViewCell *> *)cellsInSection:(NSInteger)section;
- (nullable PDCLTableViewHeaderFooterView *)headerViewForSection:(NSInteger)section;
- (nullable NSArray<PDCLTableViewHeaderFooterView *> *)allHeaders;

@end

@interface PDCLTableViewHeaderFooterView : UIView

@property (nonatomic, assign) CGFloat ceilingOffset;

@end

NS_ASSUME_NONNULL_END

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

@optional
- (CGFloat)tableView:(PDCLTableView *)tableView heightForHeaderInSection:(NSInteger)section;

@end

@protocol PDCLTableViewDataSource <NSObject>

- (NSInteger)tableView:(PDCLTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (__kindof PDCLTableViewCell *)tableView:(PDCLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(PDCLTableView *)tableView;
- (PDCLTableViewHeaderFooterView *)tableView:(PDCLTableView *)tableView viewForHeaderInSection:(NSInteger)section;

@end

@interface PDCLTableView : UIScrollView

@property (nonatomic, weak, nullable) id<PDCLTableViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<PDCLTableViewDataSource> dataSource;

// Remove cells and headers, then readd them.
- (void)reloadData;
- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath;

// Only reload frame.
- (void)reloadFrame;
- (void)reloadFrameAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

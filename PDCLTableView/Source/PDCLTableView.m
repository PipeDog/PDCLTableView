//
//  PDCLTableView.m
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//

#import "PDCLTableView.h"
#import "NSMutableArray+PDAdd.h"

@interface PDCLTableView () {
    CGFloat _totalHeight;
    NSInteger _numberOfSections;
    
    struct {
        unsigned heightForRowAtIndexPath : 1;
        unsigned heightForHeaderInSection : 1;
    } _delegateHas;
    
    struct {
        unsigned numberOfRowsInSection : 1;
        unsigned cellForRowAtIndexPath : 1;
        unsigned numberOfSectionsInTableView : 1;
        unsigned viewForHeaderInSection : 1;
    } _dataSourceHas;
}

@property (nonatomic, strong) NSMutableArray<NSMutableArray<PDCLTableViewCell *> *> *cells;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSValue *> *> *cellFrames;
@property (nonatomic, strong) NSMutableArray<PDCLTableViewHeaderFooterView *> *headers;
@property (nonatomic, strong) NSMutableArray<NSValue *> *headerFrames;
@property (readonly) CGFloat tableWidth;

@end

@implementation PDCLTableView

@synthesize delegate = _delegate;

- (void)reloadData {
    if (!_delegateHas.heightForRowAtIndexPath) { return; }
    if (!_dataSourceHas.numberOfRowsInSection) { return; }

    [self removeAllHeaders];
    [self removeAllCells];
    
    _numberOfSections = 1;
    if (_dataSourceHas.numberOfSectionsInTableView) {
        _numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
    }
    if (!_numberOfSections) { return; }
    
    _totalHeight = self.contentInset.top; // Start top position.
    
    for (NSInteger section = 0; section < _numberOfSections; section++) {
        CGFloat left = self.contentInset.left;
        
        // Add section header
        if (_dataSourceHas.viewForHeaderInSection && _delegateHas.heightForHeaderInSection) {
            PDCLTableViewHeaderFooterView *header = [self.dataSource tableView:self viewForHeaderInSection:section];
            CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:section];
            
            CGRect headerFrame = CGRectMake(left, _totalHeight, self.tableWidth, headerHeight);
            header.frame = headerFrame;
            _totalHeight += headerHeight;
            
            [self addSubview:header];
            [self.headers addObject:header];
            [self.headerFrames addObject:[NSValue valueWithCGRect:headerFrame]];
        }
        
        // Add cells for section
        NSMutableArray<PDCLTableViewCell *> *cellsInSection = [NSMutableArray array];
        NSMutableArray<NSValue *> *cellFramesInSection = [NSMutableArray array];
        
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < numberOfRows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            PDCLTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
            CGFloat cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
            
            CGRect cellFrame = CGRectMake(left, _totalHeight, self.tableWidth, cellHeight);
            cell.frame = cellFrame;
            _totalHeight += cellHeight;
            
            [self addSubview:cell];
            [cellsInSection addObject:cell];
            [cellFramesInSection addObject:[NSValue valueWithCGRect:cellFrame]];
        }
        
        [self.cells addObject:cellsInSection];
        [self.cellFrames addObject:cellFramesInSection];
    }
    
    _totalHeight += self.contentInset.bottom;
    self.contentSize = CGSizeMake(self.tableWidth, _totalHeight);
}

- (void)reloadRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_delegateHas.heightForRowAtIndexPath) { return; }
    if (!_dataSourceHas.numberOfRowsInSection) { return; }
    if (![self checkIndexPath:indexPath]) { return; }
    
    
    
//
//    [self removeAllHeaders];
//    [self removeAllCells];
//
//    _numberOfSections = 1;
//    if (_dataSourceHas.numberOfSectionsInTableView) {
//        _numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
//    }
//    if (!_numberOfSections) { return; }
//
//    _totalHeight = self.contentInset.top; // Start top position.
//
//    for (NSInteger section = 0; section < _numberOfSections; section++) {
//        CGFloat left = self.contentInset.left;
//
//        // Add section header
//        if (_dataSourceHas.viewForHeaderInSection && _delegateHas.heightForHeaderInSection) {
//            PDCLTableViewHeaderFooterView *header = [self.dataSource tableView:self viewForHeaderInSection:section];
//            CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:section];
//
//            CGRect headerFrame = CGRectMake(left, _totalHeight, self.tableWidth, headerHeight);
//            header.frame = headerFrame;
//            _totalHeight += headerHeight;
//
//            [self addSubview:header];
//            [self.headers addObject:header];
//            [self.headerFrames addObject:[NSValue valueWithCGRect:headerFrame]];
//        }
//
//        // Add cells for section
//        NSMutableArray<PDCLTableViewCell *> *cellsInSection = [NSMutableArray array];
//        NSMutableArray<NSValue *> *cellFramesInSection = [NSMutableArray array];
//
//        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
//        for (NSInteger row = 0; row < numberOfRows; row++) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//            PDCLTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
//            CGFloat cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
//
//            CGRect cellFrame = CGRectMake(left, _totalHeight, self.tableWidth, cellHeight);
//            cell.frame = cellFrame;
//            _totalHeight += cellHeight;
//
//            [self addSubview:cell];
//            [cellsInSection addObject:cell];
//            [cellFramesInSection addObject:[NSValue valueWithCGRect:cellFrame]];
//        }
//
//        [self.cells addObject:cellsInSection];
//        [self.cellFrames addObject:cellFramesInSection];
//    }
//
//    _totalHeight += self.contentInset.bottom;
//    self.contentSize = CGSizeMake(self.tableWidth, _totalHeight);
}

- (void)reloadRowFromIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)reloadFrame {
    
}

- (void)reloadFrameAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Private Methods
- (void)removeAllCells {
    for (NSMutableArray *cellsInSection in _cells) {
        for (PDCLTableViewCell *cell in cellsInSection) {
            [cell removeFromSuperview];
        }
    }
    
    [_cells removeAllObjects];
    [_cellFrames removeAllObjects];
}

- (void)removeCellsFromIndexPath:(NSIndexPath *)indexPath {
    NSInteger beginSection = indexPath.section;
    for (NSInteger section = beginSection; section < _numberOfSections; section++) {
        
        NSMutableArray<PDCLTableViewCell *> *cellsInSection = self.cells[section];
        NSMutableArray<NSValue *> *cellFramesInSection = self.cellFrames[section];
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        NSInteger beginRow = (section == beginSection ? indexPath.row : 0);
        
        for (NSInteger row = beginRow; row < numberOfRows; row++) {
            PDCLTableViewCell *cell = cellsInSection[row];
            [cell removeFromSuperview];
        }

        [cellsInSection removeObjectsToTailFromIndex:beginRow];
        [cellFramesInSection removeObjectsToTailFromIndex:beginRow];
        
        if (section == beginSection) {
            // Reset begin section objects.
            self.cells[section] = cellsInSection;
            self.cellFrames[section] = cellFramesInSection;
        }
    }
    
    // Remove objects to tail.
    NSInteger nextSecion = beginSection + 1;
    [self.cells removeObjectsToTailFromIndex:nextSecion];
    [self.cellFrames removeObjectsToTailFromIndex:nextSecion];
}

- (void)removeAllHeaders {
    for (PDCLTableViewHeaderFooterView *view in _headers) {
        [view removeFromSuperview];
    }
    
    [_headers removeAllObjects];
    [_headerFrames removeAllObjects];
}

- (void)removeHeadersFromIndexPath:(NSIndexPath *)indexPath {
    NSInteger beginSection = indexPath.section + 1;
    for (NSInteger section = beginSection; section < _numberOfSections; section++) {
        PDCLTableViewHeaderFooterView *header = self.headers[section];
        [header removeFromSuperview];
    }

    [self.headers removeObjectsToTailFromIndex:beginSection];
    [self.headerFrames removeObjectsToTailFromIndex:beginSection];
}

- (void)resetAllCellFrames {

}

- (void)resetCellFramesFromIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)resetAllHeaderFrames {
    
}

- (void)resetHeaderFramesFromIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)checkIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 0 || indexPath.section > _numberOfSections - 1) {
        NSAssert(NO, @"Invalid indexPath, the argument `section` out of bounds!");
        return NO;
    }
    
    NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:indexPath.section];
    if (indexPath.row < 0 || indexPath.row > numberOfRows - 1) {
        NSAssert(NO, @"Invalid indexPath, the argument `row` out of bounds!");
        return NO;
    }
    
    return YES;
}

#pragma mark - Override Methods
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark - Setter Methods
- (void)setDelegate:(id<PDCLTableViewDelegate>)delegate {
    [super setDelegate:delegate];

    _delegateHas.heightForRowAtIndexPath = [_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
    _delegateHas.heightForHeaderInSection = [_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
}

- (void)setDataSource:(id<PDCLTableViewDataSource>)dataSource {
    _dataSource = dataSource;

    _dataSourceHas.numberOfRowsInSection = [_dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)];
    _dataSourceHas.cellForRowAtIndexPath = [_dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)];
    _dataSourceHas.numberOfSectionsInTableView = [_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)];
    _dataSourceHas.viewForHeaderInSection = [_dataSource respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
}

#pragma mark - Getter Methods
- (NSMutableArray<NSMutableArray<PDCLTableViewCell *> *> *)cells {
    if (!_cells) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (NSMutableArray<NSMutableArray<NSValue *> *> *)cellFrames {
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableArray<PDCLTableViewHeaderFooterView *> *)headers {
    if (!_headers) {
        _headers = [NSMutableArray array];
    }
    return _headers;
}

- (NSMutableArray<NSValue *> *)headerFrames {
    if (!_headerFrames) {
        _headerFrames = [NSMutableArray array];
    }
    return _headerFrames;
}

- (CGFloat)tableWidth {
    return CGRectGetWidth(self.bounds) - (self.contentInset.left + self.contentInset.right);
}

@end

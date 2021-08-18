//
//  PDCLTableView.m
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//

#import "PDCLTableView.h"

typedef NSString * PDCLTableViewKVOKeyPath NS_TYPED_ENUM;

static PDCLTableViewKVOKeyPath const PDCLTableViewKVOKeyPathContentOffset = @"contentOffset";

@interface NSArray (PDAdd)

- (id)_pd_objectOrNilAtIndex:(NSInteger)index;

@end

@implementation NSArray (PDAdd)

- (id)_pd_objectOrNilAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.count) {
        return nil;
    }
    return [self objectAtIndex:index];
}

@end

@interface PDVirtualCellNode : NSObject

@property (nonatomic, assign, readonly) NSInteger section;
@property (nonatomic, assign, readonly) NSInteger row;
@property (nonatomic, strong) PDCLTableViewCell *cell;
@property (nonatomic, assign) CGRect cellRect;

@end

@implementation PDVirtualCellNode

- (instancetype)initWithSection:(NSInteger)section row:(NSInteger)row {
    self = [super init];
    if (self) {
        _section = section;
        _row = row;
    }
    return self;
}

@end

@interface PDVirtualHeaderFooterNode : NSObject

@property (nonatomic, assign, readonly) NSInteger section;
@property (nonatomic, strong) PDCLTableViewHeaderFooterView *view;
@property (nonatomic, assign) CGRect viewRect;

@end

@implementation PDVirtualHeaderFooterNode

- (instancetype)initWithSection:(NSInteger)section {
    self = [super init];
    if (self) {
        _section = section;
    }
    return self;
}

@end

@interface PDCLTableView () {
    CGFloat _totalHeight;
    NSInteger _numberOfSections;
}

@property (readonly) CGFloat tableWidth;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<PDVirtualCellNode *> *> *cellNodes;
@property (nonatomic, strong) NSMutableArray<PDVirtualHeaderFooterNode *> *headerNodes;

@end

@implementation PDCLTableView

@synthesize delegate = _delegate;

- (void)dealloc {
    [self _removeObserver];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupInitializeConfiguration];
        [self _addObserver];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _setupInitializeConfiguration];
        [self _addObserver];
    }
    return self;
}

#pragma mark - Initialize Methods
- (void)_setupInitializeConfiguration {
    _cellNodes = [NSMutableArray array];
    _headerNodes = [NSMutableArray array];
}

- (void)_addObserver {
    [self addObserver:self forKeyPath:PDCLTableViewKVOKeyPathContentOffset
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)_removeObserver {
    [self removeObserver:self forKeyPath:PDCLTableViewKVOKeyPathContentOffset];
}

#pragma mark - Observer Methods
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (![keyPath isEqualToString:PDCLTableViewKVOKeyPathContentOffset]) {
        return;
    }
    
    CGRect visibleRect = self.visibleRect;
    
    for (NSInteger section = 0; section < _numberOfSections; section++) {
        CGRect headerRectInContainer = [self _rectForHeaderInSectionBaseOnSuperview:section];
        if (CGRectGetMinY(headerRectInContainer) > CGRectGetHeight(self.frame)) { break; }
        
        if (CGRectIntersectsRect(visibleRect, [self rectForSection:section])) {
            [self _reloadHeaderInSectin:section];
        }
                
        NSArray<PDVirtualCellNode *> *curSectionCellNodes = self.cellNodes[section];
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        
        for (NSInteger row = 0; row < numberOfRows; row++) {
            PDVirtualCellNode *cellNode = curSectionCellNodes[row];
            CGRect cellRect = cellNode.cellRect;
            
            if (!CGRectIntersectsRect(visibleRect, cellRect)) {
                break;
            }
            
            if (!cellNode.cell) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                PDCLTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
                cell.frame = cellNode.cellRect;
                cellNode.cell = cell;
                [self addSubview:cell];
            }
        }
    }
}

#pragma mark - Private Methods
- (void)_reloadHeaderInSectin:(NSInteger)section {
    NSInteger lastSection = section - 1;
    PDVirtualHeaderFooterNode *headerNode = [self.headerNodes _pd_objectOrNilAtIndex:lastSection];
    PDCLTableViewHeaderFooterView *lastHeader = headerNode.view;
    
    CGRect lastHeaderRectInContainer = CGRectMake(self.contentInset.left,
                                                  lastHeader.ceilingOffset,
                                                  self.tableWidth,
                                                  [self rectForHeaderInSection:lastSection].size.height);
    CGRect currentHeaderRectInContainer = [self _rectForHeaderInSectionBaseOnSuperview:section];
    
    if (lastHeader) {
        if (CGRectIntersectsRect(currentHeaderRectInContainer, lastHeaderRectInContainer)) {
            CGRect lastHeaderRealRectInContainer = lastHeader.frame;
            lastHeaderRealRectInContainer.origin.y = -(CGRectGetHeight(lastHeader.frame) - CGRectGetMinY(currentHeaderRectInContainer));
            lastHeader.frame = lastHeaderRealRectInContainer;
        } else {
            // Do nothing...
        }
    }
    
    PDCLTableViewHeaderFooterView *currentHeader = [self headerViewForSection:section];
    if (CGRectGetMinY(currentHeaderRectInContainer) < currentHeader.ceilingOffset) {
        [self _addHeaderToSuperviewForSection:section];
    } else {
        [self _addHeaderToSelfForSection:section];
    }
}

- (void)_addHeaderToSuperviewForSection:(NSInteger)section {
    PDVirtualHeaderFooterNode *headerNode = [self.headerNodes _pd_objectOrNilAtIndex:section];
    PDCLTableViewHeaderFooterView *header = headerNode.view;
    
    if (header.superview != self.superview) {
        CGRect rect = [self rectForHeaderInSection:section];
        rect.origin.y = CGRectGetMinY(self.frame) + header.ceilingOffset;
        rect.origin.x = self.contentInset.left;
        header.frame = rect;
        [self.superview addSubview:header];
    }
}

- (void)_addHeaderToSelfForSection:(NSInteger)section {
    PDVirtualHeaderFooterNode *headerNode = [self.headerNodes _pd_objectOrNilAtIndex:section];
    PDCLTableViewHeaderFooterView *header = headerNode.view;
    
    if (header.superview != self) {
        CGRect rect = [self rectForHeaderInSection:section];
        header.frame = rect;
        [self addSubview:header];
    }
}

- (CGRect)_rectForHeaderInSectionBaseOnSuperview:(NSInteger)section {
    if (section < 0) { return CGRectNull; }

    PDVirtualHeaderFooterNode *headerNode = [self.headerNodes _pd_objectOrNilAtIndex:section];
    if (!headerNode) { return CGRectNull; }
    
    CGRect rect = headerNode.viewRect;
    CGRect convertRect = [self convertRect:rect toView:self.superview];
    return convertRect;
}

#pragma mark - Public Methods
- (void)reloadData {
    // remove all headers
    for (PDVirtualHeaderFooterNode *node in [_headerNodes copy]) {
        if (!node.view) { break; }
        [node.view removeFromSuperview];
    }
    
    [_headerNodes removeAllObjects];
    
    // remove all cells
    for (NSArray *curSectionCellNodes in [_cellNodes copy]) {
        for (PDVirtualCellNode *node in curSectionCellNodes) {
            if (!node.cell) { break; }
            [node.cell removeFromSuperview];
        }
    }
    
    [_cellNodes removeAllObjects];
    
    // add cells and headers to self and calculate subviews frames.
    _numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
    if (!_numberOfSections) { return; }
    
    // start top position.
    _totalHeight = self.contentInset.top;
    
    // get visible frame
    CGRect visibleRect = self.visibleRect;
    
    for (NSInteger section = 0; section < _numberOfSections; section++) {
        CGFloat left = 0.f;
        
        // setup header node info
        PDVirtualHeaderFooterNode *headerNode = [[PDVirtualHeaderFooterNode alloc] initWithSection:section];
        [_headerNodes addObject:headerNode];
        
        CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:section];
        CGRect headerRect = CGRectMake(left, _totalHeight, self.tableWidth, headerHeight);
        headerNode.viewRect = headerRect;
        
        BOOL headerShouldAddToSuperview = CGRectIntersectsRect(visibleRect, headerRect);
        if (headerShouldAddToSuperview) {
            PDCLTableViewHeaderFooterView *header = [self.delegate tableView:self viewForHeaderInSection:section];
            header.frame = headerRect;
            headerNode.view = header;
            [self addSubview:header];
        }
        
        // update total height
        _totalHeight += headerHeight;

        // setup cell nodes info
        NSMutableArray<PDVirtualCellNode *> *curSectionCellNodes = [NSMutableArray array];
        [_cellNodes addObject:curSectionCellNodes];
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        
        for (NSInteger row = 0; row < numberOfRows; row++) {
            // setup cell node info at index `row`
            PDVirtualCellNode *cellNode = [[PDVirtualCellNode alloc] initWithSection:section row:row];
            [curSectionCellNodes addObject:cellNode];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            CGFloat cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
            CGRect cellRect = CGRectMake(left, _totalHeight, self.tableWidth, cellHeight);
            cellNode.cellRect = cellRect;

            BOOL cellShouldAddToSuperview = CGRectIntersectsRect(visibleRect, cellRect);
            if (cellShouldAddToSuperview) {
                PDCLTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
                cell.frame = cellRect;
                cellNode.cell = cell;
                [self addSubview:cell];
            }
            
            _totalHeight += cellHeight;
        }
    }
    
    _totalHeight += self.contentInset.bottom;
    self.contentSize = CGSizeMake(self.tableWidth, _totalHeight);
}

- (void)reloadFrame {
    if (!_headerNodes.count && !_cellNodes.count) {
        return;
    }
    
    CGRect visibleRect = self.visibleRect;
    
    // start top position.
    _totalHeight = self.contentInset.top;
    
    for (NSInteger section = 0; section < _numberOfSections; section++) {
        CGFloat left = 0.f;
        
        // get header at section
        PDVirtualHeaderFooterNode *headerNode = self.headerNodes[section];
        PDCLTableViewHeaderFooterView *header = headerNode.view;
        
        // reset header rect
        CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:section];
        CGRect headerRect = CGRectMake(left, _totalHeight, self.tableWidth, headerHeight);
        headerNode.viewRect = headerRect;
        
        if (header) {
            if (header.superview == self) {
                header.frame = headerRect;
            } else {
                CGRect rect = header.frame;
                rect.size.height = headerHeight;
                header.frame = rect;
            }
        } else {
            if (CGRectIntersectsRect(visibleRect, headerRect)) {
                headerNode.view = [self.delegate tableView:self viewForHeaderInSection:section];
                headerNode.view.frame = headerRect;
                [self addSubview:headerNode.view];
            }
        }
        
        _totalHeight += headerHeight;

        // update cell frames
        NSArray<PDVirtualCellNode *> *curSectionCellNodes = self.cellNodes[section];
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        
        for (NSInteger row = 0; row < numberOfRows; row++) {
            PDVirtualCellNode *cellNode = curSectionCellNodes[row];
            PDCLTableViewCell *cell = cellNode.cell;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            CGFloat cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
            CGRect cellRect = CGRectMake(left, _totalHeight, self.tableWidth, cellHeight);
            cellNode.cellRect = cellRect;
            
            if (cell) {
                cell.frame = cellRect;
            } else {
                if (CGRectIntersectsRect(visibleRect, cellRect)) {
                    cellNode.cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
                    cellNode.cell.frame = cellRect;
                    [self addSubview:cellNode.cell];
                }
            }
            
            _totalHeight += cellHeight;
        }
    }
    
    _totalHeight += self.contentInset.bottom;
    self.contentSize = CGSizeMake(self.tableWidth, _totalHeight);
}

- (CGRect)rectForHeaderInSection:(NSInteger)section {
    PDVirtualHeaderFooterNode *headerNode = [self.headerNodes _pd_objectOrNilAtIndex:section];
    if (!headerNode) { return CGRectNull; }
    
    return headerNode.viewRect;
}

- (CGRect)rectForSection:(NSInteger)section {
    CGRect headerFrame = [self rectForHeaderInSection:section];
    
    NSArray<PDVirtualCellNode *> *curSectionCellNodes = [self.cellNodes _pd_objectOrNilAtIndex:section];
    if (!curSectionCellNodes.count) { return headerFrame; }
    
    PDVirtualCellNode *lastCellNode = curSectionCellNodes.lastObject;
    CGRect lastCellRect = lastCellNode.cellRect;
    CGFloat height = CGRectGetMaxY(lastCellRect) - CGRectGetMinY(headerFrame);
    return CGRectMake(self.contentInset.left, CGRectGetMinY(headerFrame), self.tableWidth, height);
}

- (PDCLTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<PDVirtualCellNode *> *curSectionCellNodes = [self.cellNodes _pd_objectOrNilAtIndex:indexPath.section];
    if (!curSectionCellNodes.count) { return nil; }
    
    PDVirtualCellNode *cellNode = curSectionCellNodes[indexPath.row];
    if (!cellNode) { return nil; }
    
    if (!cellNode.cell) {
        cellNode.cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
    }
    
    return cellNode.cell;
}

- (NSArray<PDCLTableViewCell *> *)cellsInSection:(NSInteger)section {
    NSArray<PDVirtualCellNode *> *curSectionCellNodes = [self.cellNodes _pd_objectOrNilAtIndex:section];
    if (!curSectionCellNodes.count) { return nil; }
    
    NSMutableArray *cells = [NSMutableArray array];
    
    for (NSInteger row = 0; row < curSectionCellNodes.count; row++) {
        PDVirtualCellNode *cellNode = curSectionCellNodes[row];
        if (!cellNode.cell) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            cellNode.cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
        }
        [cells addObject:cellNode.cell];
    }
    
    return [cells copy];
}

- (PDCLTableViewHeaderFooterView *)headerViewForSection:(NSInteger)section {
    PDVirtualHeaderFooterNode *headerNode = [self.headerNodes _pd_objectOrNilAtIndex:section];
    if (!headerNode) { return nil; }
    
    if (!headerNode.view) {
        headerNode.view = [self.delegate tableView:self viewForHeaderInSection:section];
        headerNode.view.frame = headerNode.viewRect;
        [self addSubview:headerNode.view];
    }
    return headerNode.view;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSArray *cellNodesInSection = [self.cellNodes _pd_objectOrNilAtIndex:section];
    return cellNodesInSection.count;
}

- (NSArray<PDCLTableViewHeaderFooterView *> *)allHeaders {
    NSMutableArray *headers = [NSMutableArray array];
    
    for (NSInteger section = 0; section < self.headerNodes.count; section++) {
        UIView *header = [self headerViewForSection:section];
        if (header) { [headers addObject:header]; }
    }
    
    return [headers copy];
}

#pragma mark - Override Methods
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark - Setter Methods
- (void)setDelegate:(id<PDCLTableViewDelegate>)delegate {
    [super setDelegate:(_delegate = delegate)];
    
    NSAssert([_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)], @"The protocol method `tableView:heightForRowAtIndexPath:` must be impl!");
    NSAssert([_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)], @"The protocol method `tableView:heightForHeaderInSection:` must be impl!");
    NSAssert([_delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)], @"The protocol method `tableView:viewForHeaderInSection:` must be impl!");
}

- (void)setDataSource:(id<PDCLTableViewDataSource>)dataSource {
    _dataSource = dataSource;

    NSAssert([_dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)], @"The protocol method `tableView:numberOfRowsInSection:` must be impl!");
    NSAssert([_dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)], @"The protocol method `tableView:cellForRowAtIndexPath:` must be impl!");
    NSAssert([_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)], @"The protocol method `numberOfSectionsInTableView:` must be impl!");
}

#pragma mark - Getter Methods
- (NSInteger)numberOfSections {
    return _numberOfSections;
}

- (CGFloat)tableWidth {
    return CGRectGetWidth(self.bounds) - (self.contentInset.left + self.contentInset.right);
}

- (CGRect)visibleRect {
    CGRect visibleRect = CGRectMake(self.contentOffset.x,
                                    self.contentOffset.y,
                                    CGRectGetWidth(self.bounds),
                                    CGRectGetHeight(self.bounds));
    return visibleRect;
}

@end

@implementation PDCLTableViewHeaderFooterView

@end

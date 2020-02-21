//
//  PDCLTableView.m
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//

#import "PDCLTableView.h"
#import "NSMutableArray+PDAdd.h"

/*
typedef NSNumber * PDCLTableViewSection;

@interface PDCLLinkNode : NSObject

@property (nonatomic, weak) PDCLLinkNode *prev;
@property (nonatomic, weak) PDCLLinkNode *next;
@property (nonatomic, weak) PDCLTableViewSection key;
@property (nonatomic, weak) UIView *value;

@end

@implementation PDCLLinkNode

@end

@interface PDCLLinkMap : NSObject

@property (nonatomic, weak) PDCLLinkNode *head;
@property (nonatomic, weak) PDCLLinkNode *tail;
@property (nonatomic, strong) NSMutableDictionary<PDCLTableViewSection, PDCLLinkNode *> *holder;

- (void)removeAllNodes;
- (PDCLLinkNode *)nodeForKey:(PDCLTableViewSection)section;
- (void)didUpdateToObjects:(NSArray<UIView *> *)objects;

@end

@implementation PDCLLinkMap

- (instancetype)init {
    self = [super init];
    if (self) {
        _holder = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)removeAllNodes {
    _head = nil;
    _tail = nil;
    [_holder removeAllObjects];
}

- (PDCLLinkNode *)nodeForKey:(PDCLTableViewSection)section {
    return self.holder[section];
}

- (void)didUpdateToObjects:(NSArray *)objects {
    [_holder removeAllObjects];
    
    if (!objects.count) {
        return;
    }
    
    PDCLLinkNode *prev = nil;
    for (NSInteger i = 0; i < objects.count; i++) {
        PDCLLinkNode *node = [[PDCLLinkNode alloc] init];
        node.value = objects[i];
        node.prev = prev;
        node.next = nil;
        
        prev.next = node;
        prev = node;
        self.holder[@(i)] = node;
    }
    
    self.head = self.holder[@0];
    self.tail = self.holder[@(objects.count - 1)];
}

@end
 */

typedef NSString * PDCLTableViewKVOKeyPath;

static PDCLTableViewKVOKeyPath const PDCLTableViewKVOKeyPathContentOffset = @"contentOffset";

@interface PDCLTableView () {
    CGFloat _totalHeight;
    NSInteger _numberOfSections;
}

@property (nonatomic, strong) NSMutableArray<NSMutableArray<PDCLTableViewCell *> *> *cells;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSValue *> *> *cellFrames;
@property (nonatomic, strong) NSMutableArray<PDCLTableViewHeaderFooterView *> *headers;
@property (nonatomic, strong) NSMutableArray<NSValue *> *headerFrames;
@property (readonly) CGFloat tableWidth;

@end

@implementation PDCLTableView

@synthesize delegate = _delegate;

- (void)dealloc {
    [self removeObserver:self forKeyPath:PDCLTableViewKVOKeyPathContentOffset];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    [self addObserver:self forKeyPath:PDCLTableViewKVOKeyPathContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - Observer Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:PDCLTableViewKVOKeyPathContentOffset]) {
        return;
    }
    
    CGRect visibleRect = CGRectMake(self.contentOffset.x,
                                    self.contentOffset.y,
                                    CGRectGetWidth(self.bounds),
                                    CGRectGetHeight(self.bounds));
//    CGFloat offsetY = scrollView.contentOffset.y;
//
//        if (offsetY >= self.imageView.frame.size.height) {
//            //将redView控件添加到控制器的view中，设置Y值为0
//            CGRect redFrame = self.redView.frame;
//            redFrame.origin.y = 0;
//            self.redView.frame = redFrame;
//            [self.view addSubview:self.redView];
//        }else{
//            //将redView控件添加到scrollView中，设置Y值为图片的高度
//            CGRect redFrame = self.redView.frame;
//            redFrame.origin.y = 140;
//            self.redView.frame = redFrame;
//            [self.scrollView addSubview:self.redView];
//        }
    
    

    
    for (NSInteger section = 0; section < _numberOfSections; section++) {
        if (CGRectIntersectsRect(visibleRect, [self rectForSection:section])) {
            [self updateHeaderRectInSection:section];
//            break;
        }
    }
}

- (void)updateHeaderRectInSection:(NSInteger)section {
    /*
    // 完全在屏幕外
    CGRect rect = [self rectForHeaderInContainerAtSection:section];
    if (CGRectGetMaxY(rect) < 0) { return; }

    // 还未接触到上个 section 吸顶的 header
    CGRect lastRect = [self rectForHeaderInSection:section - 1];
    if (CGRectGetMinY(rect) > CGRectGetHeight(lastRect)) { return; }

    // TODO: 更新上一个吸顶 header 的 frame
    PDCLTableViewHeaderFooterView *lastView = [self.headers objectOrNilAtIndex:section - 1];
    CGRect lastViewRect = lastView.frame;
    lastViewRect.origin.y = (CGRectGetMinY(rect) - CGRectGetHeight(lastViewRect));
    lastView.frame = lastViewRect;
    
    // 吸顶
    if (CGRectGetMinY(rect) <= 0) {
        [self addHeaderToContainerForSection:section];
    } else {
        [self addHeaderToSelfForSection:section];
    }
     */
    
    UIView *container = [self.dataSource ceilingHeaderContainerForTableView:self];
    
    NSInteger lastSection = section - 1;
    UIView *lastHeader = [self.headers objectOrNilAtIndex:lastSection];
    
    CGRect lastHeaderRectInContainer = CGRectMake(self.contentInset.left, 0.f, self.tableWidth, [self rectForHeaderInSection:section].size.height);//[self rectForHeaderInContainerAtSection:lastSection];

    if (lastHeader) {
        CGRect currentHeaderRectInContainer = [self rectForHeaderInContainerAtSection:section];

        if (CGRectIntersectsRect(currentHeaderRectInContainer, lastHeaderRectInContainer)) {
            // 与上一个 header 相交，更新上一个 header 的 frame
            CGRect lastHeaderRealRectInContainer = lastHeader.frame;
            lastHeaderRealRectInContainer.origin.y = -(CGRectGetHeight(lastHeader.frame) - CGRectGetMinY(currentHeaderRectInContainer));
            lastHeader.frame = lastHeaderRealRectInContainer;
//            [container addSubview:lastHeader];
        } else {
            // Do nothing...
        }
        
        if (CGRectGetMinY(currentHeaderRectInContainer) <= 0.f) {
            // 触及到 scrollView 的 top，添加到 container 上，进行悬停操作
            [self addHeaderToContainerForSection:section];
        } else {
            // 添加到 scrollView 上，取消悬停操作
            [self addHeaderToSelfForSection:section];
        }
    } else {
        CGRect currentHeaderRectInContainer = [self rectForHeaderInContainerAtSection:section];

        if (CGRectGetMinY(currentHeaderRectInContainer) <= 0.f) {
            // 触及到 scrollView 的 top，添加到 container 上，进行悬停操作
            [self addHeaderToContainerForSection:section];
        } else {
            // 添加到 scrollView 上，取消悬停操作
            [self addHeaderToSelfForSection:section];
        }
    }
}

- (void)addHeaderToContainerForSection:(NSInteger)section {
    UIView *container = [self.dataSource ceilingHeaderContainerForTableView:self];
    PDCLTableViewHeaderFooterView *header = [self.headers objectOrNilAtIndex:section];
    
    if (header.superview != container) {
        CGRect rect = [self rectForHeaderInSection:section];
        rect.origin.y = 0.f;
        header.frame = rect;
        [container addSubview:header];
    }
}

- (void)addHeaderToSelfForSection:(NSInteger)section {
    PDCLTableViewHeaderFooterView *header = [self.headers objectOrNilAtIndex:section];
    
    if (header.superview != self) {
        CGRect rect = [self rectForHeaderInSection:section];
        header.frame = rect;
        [self addSubview:header];
    }
}


- (CGRect)rectForHeaderInContainerAtSection:(NSInteger)section {
    if (section < 0) { return CGRectNull; }

    CGRect rect = [[self.headerFrames objectOrNilAtIndex:section] CGRectValue];
    UIView *container = [self.dataSource ceilingHeaderContainerForTableView:self];
    CGRect convertRect = [self convertRect:rect toView:container];
    return convertRect;
}

#pragma mark - Public Methods
- (void)reloadData {
    // Remove all headers
    for (PDCLTableViewHeaderFooterView *view in _headers) {
        [view removeFromSuperview];
    }
    
    [_headers removeAllObjects];
    [_headerFrames removeAllObjects];
    
    // Remove all cells
    for (NSMutableArray *cellsInSection in _cells) {
        for (PDCLTableViewCell *cell in cellsInSection) {
            [cell removeFromSuperview];
        }
    }
    
    [_cells removeAllObjects];
    [_cellFrames removeAllObjects];
    
    // Add cells and headers to self and calculate subviews frames.
    _numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
    if (!_numberOfSections) { return; }
    
    _totalHeight = self.contentInset.top; // Start top position.
    
    for (NSInteger section = 0; section < _numberOfSections; section++) {
        CGFloat left = self.contentInset.left;
        
        // Add section header
        PDCLTableViewHeaderFooterView *header = [self.dataSource tableView:self viewForHeaderInSection:section];
        CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:section];
        
        CGRect headerFrame = CGRectMake(left, _totalHeight, self.tableWidth, headerHeight);
        header.frame = headerFrame;
        _totalHeight += headerHeight;
        
        [self addSubview:header];
        [self.headers addObject:header];
        [self.headerFrames addObject:[NSValue valueWithCGRect:headerFrame]];
        
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

- (void)reloadFrame {
    // Remove origin frames
    [_headerFrames removeAllObjects];
    [_cellFrames removeAllObjects];
    
    // Add cells and headers to self and calculate subviews frames.
    _totalHeight = self.contentInset.top; // Start top position.
    
    for (NSInteger section = 0; section < _numberOfSections; section++) {
        CGFloat left = self.contentInset.left;
        
        // Reset header frame
        PDCLTableViewHeaderFooterView *header = self.headers[section];
        CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:section];
        CGRect headerFrame = CGRectMake(left, _totalHeight, self.tableWidth, headerHeight);
        
        if (header.superview == self) {
            header.frame = headerFrame;
        } else {
            CGRect rect = header.frame;
            rect.size.height = headerHeight;
            header.frame = rect;
        }
        
        _totalHeight += headerHeight;
        [self.headerFrames addObject:[NSValue valueWithCGRect:headerFrame]];
        
        // Add cells for section
        NSMutableArray<PDCLTableViewCell *> *cellsInSection = [NSMutableArray array];
        NSMutableArray<NSValue *> *cellFramesInSection = [NSMutableArray array];
        
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < numberOfRows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            PDCLTableViewCell *cell = cellsInSection[row];
            CGFloat cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
            
            CGRect cellFrame = CGRectMake(left, _totalHeight, self.tableWidth, cellHeight);
            cell.frame = cellFrame;
            _totalHeight += cellHeight;
            
            [cellFramesInSection addObject:[NSValue valueWithCGRect:cellFrame]];
        }

        [self.cellFrames addObject:cellFramesInSection];
    }
    
    _totalHeight += self.contentInset.bottom;
    self.contentSize = CGSizeMake(self.tableWidth, _totalHeight);
}

- (CGRect)rectForHeaderInSection:(NSInteger)section {
    NSValue *rectValue = [self.headerFrames objectOrNilAtIndex:section];
    if (!rectValue) { return CGRectNull; }
    
    return [rectValue CGRectValue];
}

- (CGRect)rectForSection:(NSInteger)section {
    NSArray<NSValue *> *cellFramesInSection = [self.cellFrames objectOrNilAtIndex:section];
    CGRect lastCellFrame = [cellFramesInSection.lastObject CGRectValue];
    CGRect headerFrame = [self rectForHeaderInSection:section];
    
    CGFloat height = CGRectGetMaxY(lastCellFrame) - CGRectGetMinY(headerFrame);
    return CGRectMake(self.contentInset.left, CGRectGetMinY(headerFrame), self.tableWidth, height);
}

#pragma mark - Override Methods
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark - Setter Methods
- (void)setDelegate:(id<PDCLTableViewDelegate>)delegate {
    _delegate = delegate;
    
    NSAssert([_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)], @"The protocol method `tableView:heightForRowAtIndexPath:` must be impl!");
    NSAssert([_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)], @"The protocol method `tableView:heightForHeaderInSection:` must be impl!");
}

- (void)setDataSource:(id<PDCLTableViewDataSource>)dataSource {
    _dataSource = dataSource;

    NSAssert([_dataSource respondsToSelector:@selector(ceilingHeaderContainerForTableView:)], @"The protocol method `ceilingHeaderContainerForTableView:` must be impl!");
    NSAssert([_dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)], @"The protocol method `tableView:numberOfRowsInSection:` must be impl!");
    NSAssert([_dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)], @"The protocol method `tableView:cellForRowAtIndexPath:` must be impl!");
    NSAssert([_dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)], @"The protocol method `numberOfSectionsInTableView:` must be impl!");
    NSAssert([_dataSource respondsToSelector:@selector(tableView:viewForHeaderInSection:)], @"The protocol method `tableView:viewForHeaderInSection:` must be impl!");
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

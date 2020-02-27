//
//  ViewController.m
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//

#import "ViewController.h"
#import "PDCLTableView.h"

static inline UIColor *UIColorRandom(void) {
    uint32_t red = arc4random() % 255;
    uint32_t green = arc4random() % 255;
    uint32_t blue = arc4random() % 255;
    return [UIColor colorWithRed:red / 255.f
                           green:green / 255.f
                            blue:blue / 255.f
                           alpha:1.f];
}

@interface ViewController () <PDCLTableViewDelegate, PDCLTableViewDataSource>

@property (nonatomic, strong) PDCLTableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self reload];
//    });
}

- (void)reload {
    [UIView animateWithDuration:0.5f animations:^{
        [self.tableView reloadFrame];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reload];
    });
}

#pragma mark - PDCLTableViewDelegate && PDCLTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(PDCLTableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(PDCLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(PDCLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rand() % 80;
}

- (CGFloat)tableView:(PDCLTableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80.f;
}

- (PDCLTableViewHeaderFooterView *)tableView:(PDCLTableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300.f, 60.f)];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.backgroundColor = [UIColorRandom() colorWithAlphaComponent:0.3f];
    textLabel.font = [UIFont boldSystemFontOfSize:30];
    textLabel.text = [NSString stringWithFormat:@"header section = %zd", section];
    
    PDCLTableViewHeaderFooterView *header = [[PDCLTableViewHeaderFooterView alloc] init];
    header.ceilingOffset = -10.f;
    header.backgroundColor = [UIColorRandom() colorWithAlphaComponent:0.3f];
    [header addSubview:textLabel];
    return header;
}

- (PDCLTableViewCell *)tableView:(PDCLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *cell = [[UILabel alloc] init];
    cell.textColor = UIColorRandom();
    cell.backgroundColor = [UIColorRandom() colorWithAlphaComponent:0.1f];
    cell.text = [NSString stringWithFormat:@"section = %zd, row = %zd", indexPath.section, indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Do something here...
}

#pragma mark - Getter Methods
- (PDCLTableView *)tableView {
    if (!_tableView) {
        _tableView = [[PDCLTableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = YES;
        _tableView.contentInset = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
    }
    return _tableView;
}

@end

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
}

#pragma mark - PDCLTableViewDelegate && PDCLTableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(PDCLTableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(PDCLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(PDCLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

- (CGFloat)tableView:(PDCLTableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0 ? 80.f : 70.f);
}

- (PDCLTableViewHeaderFooterView *)tableView:(PDCLTableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *header = [[UILabel alloc] init];
    header.textColor = [UIColor whiteColor];
    header.backgroundColor = UIColorRandom();
    header.font = [UIFont boldSystemFontOfSize:30];
    header.text = [NSString stringWithFormat:@"header section = %zd", section];
    return header;
}

- (PDCLTableViewCell *)tableView:(PDCLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *cell = [[UILabel alloc] init];
    cell.textColor = UIColorRandom();
    cell.backgroundColor = [UIColorRandom() colorWithAlphaComponent:0.1f];
    cell.text = [NSString stringWithFormat:@"section = %zd, row = %zd", indexPath.section, indexPath.row];
    return cell;
}

#pragma mark - Getter Methods
- (PDCLTableView *)tableView {
    if (!_tableView) {
        _tableView = [[PDCLTableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = YES;
        // _tableView.contentInset = UIEdgeInsetsMake(10.f, 0.f, 0.f, 0.f);
    }
    return _tableView;
}

@end

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

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, PDCLTableViewDelegate, PDCLTableViewDataSource>

@property (nonatomic, strong) UIView *ceilingContainer;
@property (nonatomic, strong) PDCLTableView *tableView;
//@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, assign) BOOL animate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _ceilingContainer = [[UIView alloc] initWithFrame:CGRectMake(30, 100, 300, 500)];
    [self.view addSubview:_ceilingContainer];
    [_ceilingContainer addSubview:self.tableView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"section 0 => %@", NSStringFromCGRect([self.tableView rectForSection:0]));
        NSLog(@"section 1 => %@", NSStringFromCGRect([self.tableView rectForSection:1]));
    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.animate = YES;
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    });
}

//#pragma mark - PDCLTableViewDelegate && PDCLTableViewDataSource
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
////    return <#expression#>
//    if (self.animate == YES && indexPath.row == 3 && indexPath.section == 0) {
//        NSLog(@"=======");
//        return 100.f;
//    }
//    return 50.f;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 10;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 10;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 100;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = UIColorRandom();
//    return view;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *reuseId = [NSString stringWithFormat:@"section_%zd_row_%zd", indexPath.section, indexPath.row];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
//        cell.textLabel.text = [NSString stringWithFormat:@"%zd->row=%zd", indexPath.section, indexPath.row];
//    }
//
//    if (self.animate == YES && indexPath.row == 3 && indexPath.section == 0) {
//        NSLog(@">>>>>>>>");
//    }
//    return cell;
//}
- (UIView *)ceilingHeaderContainerForTableView:(PDCLTableView *)tableView {
    return self.ceilingContainer;
}

- (NSInteger)numberOfSectionsInTableView:(PDCLTableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(PDCLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 15;
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
//- (UITableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//    }
//    return _tableView;
//}
- (PDCLTableView *)tableView {
    if (!_tableView) {
        _tableView = [[PDCLTableView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = YES;
    }
    return _tableView;
}

@end

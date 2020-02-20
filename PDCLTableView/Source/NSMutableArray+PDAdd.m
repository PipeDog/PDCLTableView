//
//  NSMutableArray+PDAdd.m
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//

#import "NSMutableArray+PDAdd.h"

@implementation NSMutableArray (PDAdd)

- (void)removeObjectsToTailFromIndex:(NSInteger)index {
    if (index < 0 || index >= self.count) {
        return;
    }
    
    NSInteger len = self.count - 2;
    [self removeObjectsInRange:NSMakeRange(index, len)];
}

@end

//
//  NSMutableArray+PDAdd.h
//  PDCLTableView
//
//  Created by liang on 2020/2/20.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (PDAdd)

- (void)removeObjectsToTailFromIndex:(NSInteger)index;

@end

@interface NSArray (PDAdd)

- (nullable id)objectOrNilAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

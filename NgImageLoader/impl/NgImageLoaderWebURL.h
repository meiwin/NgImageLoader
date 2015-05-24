//
//  NgImageLoaderNSURL.h
//  NgImageLoader
//
//  Created by Meiwin Fu on 1/6/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#import "NgImageLoader.h"

@interface NgImageLoaderWebURL : NgImageLoader
@property (nonatomic, copy, readonly) NSURL           * URL;
- (instancetype)initWithURL:(NSURL *)URL;
@end

//
//  NgImageLoaderFileURL.h
//  NgImageLoader
//
//  Created by Meiwin Fu on 1/6/15.
//  Copyright (c) 2015 BlockThirty. All rights reserved.
//

#import "NgImageLoader.h"

@interface NgImageLoaderFileURL : NgImageLoader
@property (nonatomic, copy, readonly) NSURL             * fileURL;
- (instancetype)initWithFileURL:(NSURL *)fileURL;
@end

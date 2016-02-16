//
//  NgImageLoaderPrivates.h
//  NgImageLoader
//
//  Created by Meiwin Fu on 25/5/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#ifndef NgImageLoader_NgImageLoaderSubclass_h
#define NgImageLoader_NgImageLoaderSubclass_h

@interface NgImageLoader (Subclass)

- (void)setCompletionHandler:(void(^)(id, NgImageLoaderImageKind, NSError *, BOOL))completionHandler;

#pragma mark Subclass must override
- (void)loadImageData:(void(^)(NSData *, NSError *, BOOL))completion;
- (void)cancelLoad;
@end

#endif

//
//  NgImageLoaderFileURL.m
//  NgImageLoader
//
//  Created by Meiwin Fu on 1/6/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import "NgImageLoaderFileURL.h"
#import "NgImageLoaderSubclass.h"


@class NgImageLoaderFileURLOperation;
@interface NgImageLoaderFileURL () {
  void(^_completion)(NSData *, NSError *, BOOL);
  NgImageLoaderFileURLOperation * _loadOperation;
}
- (void)invokeCompletionWithData:(NSData *)data error:(NSError *)error cancelled:(BOOL)cancelled;
@end

#pragma mark -
@interface NgImageLoaderFileURLOperation : NSOperation
@property (nonatomic, weak, readonly) NgImageLoaderFileURL * loader;
- (instancetype)initWithLoader:(NgImageLoaderFileURL *)loader;
@end

@implementation NgImageLoaderFileURLOperation
- (instancetype)initWithLoader:(NgImageLoaderFileURL *)loader {
  self = [super init];
  if (self) {
    _loader = loader;
  }
  return self;
}
- (void)main {
  
  __strong NgImageLoaderFileURL * loader = _loader;
  if ([self isCancelled]) {
    [loader invokeCompletionWithData:nil error:nil cancelled:YES];
  } else if ([self isReady]) {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    NSString * path = [loader.fileURL path];
    BOOL fileIsDir = NO;
    BOOL fileExist = [fm fileExistsAtPath:path isDirectory:&fileIsDir];
    
    if ( !fileExist ) {
      error = [NSError errorWithDomain:NgImageLoaderErrorDomain
                                  code:NgImageLoaderResourceNotFound
                              userInfo:nil];
    } else if ( fileIsDir || ![fm isReadableFileAtPath:path] ) {
      error = [NSError errorWithDomain:NgImageLoaderErrorDomain
                                  code:NgImageLoaderResourceNotAccessible
                              userInfo:nil];
    }

    if (error) {
      [loader invokeCompletionWithData:nil error:error cancelled:NO];
    } else {
      NSData * data = [NSData dataWithContentsOfURL:loader.fileURL];
      [loader invokeCompletionWithData:data error:nil cancelled:NO];
    }
  }
}
@end

#pragma mark -

@implementation NgImageLoaderFileURL

+ (NSOperationQueue *)operationQueue {
  static NSOperationQueue * operationQueue = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
  });
  return operationQueue;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL {
  NSParameterAssert(fileURL);
  self = [super init];
  if (self) {
    _fileURL = [fileURL copy];
    [self resolveImageScale];
  }
  return self;
}

- (void)resolveImageScale {
  
  NSString * extension = [_fileURL pathExtension];
  NSString * tmp = [_fileURL lastPathComponent];
  NSString * filename = [tmp substringWithRange:NSMakeRange(0, tmp.length - extension.length)];
  
  NSRange atRange = [filename rangeOfString:@"@" options:NSBackwardsSearch];
  if (atRange.location != NSNotFound)
  {
    NSString * scaleStr = [filename substringFromIndex:atRange.location+1];
    self.imageScale = MAX(1.f, [scaleStr floatValue]);
  }

}

- (void)loadImageData:(void (^)(NSData *, NSError *, BOOL))completion {
  
  _completion = [completion copy];
  _loadOperation = [[NgImageLoaderFileURLOperation alloc] initWithLoader:self];
  [[NgImageLoaderFileURL operationQueue] addOperation:_loadOperation];
}

- (void)cancelLoad {
  
  if (![_loadOperation isCancelled] && ![_loadOperation isExecuting]) {
    [_loadOperation cancel];
    [self invokeCompletionWithData:nil error:nil cancelled:YES];
  }
}

- (void)invokeCompletionWithData:(NSData *)data error:(NSError *)error cancelled:(BOOL)cancelled {
  
  if (_completion) _completion(data, error, cancelled);
  _loadOperation = nil;
  _completion = nil;
}
@end

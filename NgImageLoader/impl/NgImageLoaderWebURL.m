//
//  NgImageLoaderNSURL.m
//  NgImageLoader
//
//  Created by Meiwin Fu on 1/6/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import "NgImageLoaderWebURL.h"
#import "NgImageLoaderSubclass.h"

@interface NgImageLoaderWebURL () {
  NSURLSessionDataTask * _task;
}
@end

@implementation NgImageLoaderWebURL

+ (NSURLSession *)URLSession {
  static NSURLSession * _session = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  });
  return _session;
}

- (instancetype)initWithURL:(NSURL *)URL {
  NSParameterAssert(URL);
  self = [super init];
  if (self) {
    _URL = [URL copy];
  }
  return self;
}
- (void)dealloc {
  _task = nil;
}
- (void)loadImageData:(void (^)(NSData *, NSError *, BOOL cancelled))completion {
  
  NSURLSession * session = [NgImageLoaderWebURL URLSession];
  NSURLRequest * request = [NSURLRequest requestWithURL:self.URL];
  
  _task = [session dataTaskWithRequest:request
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                       if (completion) {
                         
                         BOOL cancelled = ( [error.domain isEqual:NSURLErrorDomain] &&
                                           error.code == NSURLErrorCancelled );
                         
                         if (!error) {
                           if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                             NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
                             if (httpResponse.statusCode != 200) {
                               error = [NSError errorWithDomain:NgImageLoaderErrorDomain
                                                           code:NgImageLoaderResourceNotFound
                                                       userInfo:nil];
                             }
                           }
                         }
                         
                         completion( data, error, cancelled );
                       }
                       _task = nil;
                     }];
  [_task resume];
}
- (void)cancelLoad {
  [_task cancel];
}

@end

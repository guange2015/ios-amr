//
//  URLCache.m
//  ZhangDian
//
//  Created by xiaoguang huang on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "URLCache.h"
#import "IosApi.h"
#import "Api.h"


@implementation URLCache

@synthesize cachedResponses=_cachedResponses;

static NSSet *supportSchemes;
static NSString *cacheDirectory;

+ (void)initialize {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cacheDirectory = [[paths objectAtIndex:0] retain];
    supportSchemes = [[NSSet setWithObjects:@"http", @"https", @"ftp", nil] retain];
}

- (void)dealloc
{
    [_cachedResponses release];
    [super dealloc];
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"removeCachedResponseForRequest:%@", request.URL.absoluteString);
    [self.cachedResponses removeObjectForKey:request.URL.absoluteString];
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
    NSLog(@"removeAllObjects");
    [self.cachedResponses removeAllObjects];
    [super removeAllCachedResponses];
}


- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    
    self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path];
    if (self) {
        _cachedResponses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(NSDictionary *)parserUrl:(NSString *)url {
    NSArray *ary = [url componentsSeparatedByString:@"act/res.pic/?"];
    if ([ary count]==2) {
        NSDictionary *d = [MMApi parserDict:[ary objectAtIndex:1] p1:@"&" p2:@"="];
        return d;
    }
    return nil;
}

+(long)makeHashCodeFromUrl:(NSString *)url {
    long hashCode = 0;

    NSDictionary *d = [self parserUrl:url];
    
    if (d) {
        NSString *s = [NSString stringWithFormat:@"%@###%d#%d",
                       [d objectForKey:@"name"],
                       [[d objectForKey:@"width"] intValue],
                       [[d objectForKey:@"height"]intValue] ];
        hashCode = HASH_URL_IMG+[Api hashCode:s];
    }

    return hashCode;
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    NSURL *url = request.URL;
    if (![supportSchemes containsObject:url.scheme]) {
        return [super cachedResponseForRequest:request];
    }
    
    NSString *absoluteString = url.absoluteString;
    NSLog(@"%@", absoluteString);
    NSCachedURLResponse *cachedResponse 
        = [self.cachedResponses objectForKey:absoluteString];
    
    if (cachedResponse) {
        NSLog(@"cached: %@", absoluteString);
        return cachedResponse;
    }
    
    //本机有的
    NSData * imgData = nil;
    NSString *localPrefix = @"http://localhost/";
    long hashCode = [URLCache makeHashCodeFromUrl:absoluteString];
    NSString *mimetype = @"image/";
    if([absoluteString hasPrefix:localPrefix]){
        UIImage *img = [UIImage imageNamed:[absoluteString substringFromIndex:
                                       [localPrefix length]]];
        imgData =[img getPngData];
    }
    else {
    //从rms中查找
        imgData=[Api loadTmpFileByHash:hashCode forTime:99999];
    }
    mimetype = [NSString stringWithFormat:@"%@%@",mimetype, [absoluteString substringFromIndex:[absoluteString length]-3]];
    
    if ([imgData length]>1) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:mimetype expectedContentLength:imgData.length textEncodingName:nil];
        cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:imgData];
        [response release];
        
        [self.cachedResponses setObject:cachedResponse forKey:absoluteString];
        [cachedResponse release];
        NSLog(@"rms cached: %@", absoluteString);
        return cachedResponse;
    }
    
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    newRequest.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&error];
    if (error) {
        NSLog(@"%@", error);
        NSLog(@"not cached: %@", absoluteString);
        return nil;
    }
    
    //可以存入RMS
    if ( ([absoluteString hasSuffix:@".jpg"] 
          || [absoluteString hasSuffix:@".png"]
          || [absoluteString hasSuffix:@".gif"] )
        && ( [absoluteString rangeOfString:@"act/res.pic"].length>1)
        ) {
        [Api saveTmpFileByHash:hashCode forData:data forTime:9999999];
    }
    
    NSURLResponse *newResponse = [[NSURLResponse alloc] initWithURL:response.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:nil];

    
    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse data:data];
    [newResponse release];
    [self.cachedResponses setObject:cachedResponse forKey:absoluteString];
    [cachedResponse release];
    return cachedResponse;
    
}

@end

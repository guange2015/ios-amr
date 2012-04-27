//
//  URLCache.h
//  ZhangDian
//
//  Created by xiaoguang huang on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HASH_URL_IMG 1234589*31

@interface URLCache : NSURLCache

+(long)makeHashCodeFromUrl:(NSString *)url;
+(NSDictionary *)parserUrl:(NSString *)url;
@property (nonatomic, retain) NSMutableDictionary *cachedResponses;
@end

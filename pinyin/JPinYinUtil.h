//
//  JPinYinUtil.h
//  JuuJuu
//
//  Created by xiaoguang.huang on 11-6-26.
//  Copyright 2011 长沙果壳. All rights reserved.
//

#import <Foundation/Foundation.h>

//根据中文得到拼音，如果是多音字，会得到多个拼音,后面是声调
extern NSArray *makePinYin(unichar ch_chr);

//不带声调
extern NSArray *makePinYin2(unichar ch_chr);
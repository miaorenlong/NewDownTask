//
//  Model.m
//  NewDownLoadTask
//
//  Created by 夏财祥 on 2018/1/8.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import "Model.h"

@implementation Model

-(instancetype)initWith:(NSURLSession *)session withIdentifier:(NSString *)identifier withURL:(NSString *)urlString withIndexPath:(NSIndexPath *)indexPath
{
    if (self = [super init]) {
        _identifier = identifier;
        _session = session;
        _urlString = urlString;
        _indexPath = indexPath;
    }
    return self;
}

@end

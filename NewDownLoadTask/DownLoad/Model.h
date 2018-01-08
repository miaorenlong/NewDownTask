//
//  Model.h
//  NewDownLoadTask
//
//  Created by 夏财祥 on 2018/1/8.
//  Copyright © 2018年 众鑫贷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, copy) NSString *identifier; // 后台下载配置标签
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSData *resumeData;

-(instancetype)initWith:(NSURLSession *)session withIdentifier:(NSString *)identifier withURL:(NSString *)urlString withIndexPath:(NSIndexPath *)indexPath;

-(NSURLSessionDownloadTask *)downLoadTaskwith:(NSURLSession *)session;

@end

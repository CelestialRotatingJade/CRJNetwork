//
//  CRJBaseNetwork.h
//  AFNetworking
//
//  Created by 朱玉辉(EX-ZHUYUHUI002) on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "CRJUploadFile.h"
#import "CRJBaseResponse.h"
#import "CRJBaseRequestGenerator.h"

// 项目打包上线都不会打印日志，因此可放心。
#ifdef DEBUG
#define CRJNET_Log(s, ... ) NSLog( @"[%@ in line %d] ===============>%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define CRJNET_Log(s, ... )
#endif

typedef NS_ENUM(NSInteger, CRJNetworkRequestType) {
    CRJNetworkRequestTypeGET,
    CRJNetworkRequestTypePOST,
    CRJNetworkRequestTypePUT,
    CRJNetworkRequestTypePATCH,
    CRJNetworkRequestTypeDELETE
};

/// 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小
typedef void(^PPHttpProgress)(NSProgress *_Nonnull progress);
/// 请求成功或失败回调
typedef void(^PPCompletionHandler)(CRJBaseResponse *_Nonnull response);

NS_ASSUME_NONNULL_BEGIN
@class AFHTTPSessionManager;
@interface CRJBaseNetwork : NSObject
/// sessionManager
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) CRJBaseRequestGenerator *requestGenerator;
@property (nonatomic, strong) NSMutableArray *allSessionTask;

/// 取消所有HTTP请求
- (void)cancelAllRequest;

/// 取消指定URL的HTTP请求
- (void)cancelRequestWithURL:(NSString *)URL;

#pragma mark - base dataTask
- (NSURLSessionDataTask *)dataTaskWithUrlPath:(NSString *)urlPath
                                  requestType:(CRJNetworkRequestType)requestType
                                       header:(nullable NSDictionary *)header
                                       params:(nullable NSDictionary *)params
                          uploadProgressBlock:(nullable PPHttpProgress)uploadProgressBlock
                        downloadProgressBlock:(nullable PPHttpProgress)downloadProgressBlock
                            completionHandler:(nullable PPCompletionHandler)completionHandler;

- (NSURLSessionDataTask *)uploadDataWithUrlPath:(NSString *)urlPath
                                    requestType:(CRJNetworkRequestType)requestType
                                         header:(nullable NSDictionary *)header
                                         params:(nullable NSDictionary *)params
                                       contents:(nullable NSArray<CRJUploadFile *> *)contents
                            uploadProgressBlock:(nullable PPHttpProgress)uploadProgressBlock
                              completionHandler:(nullable PPCompletionHandler)completionHandler;

@end
NS_ASSUME_NONNULL_END

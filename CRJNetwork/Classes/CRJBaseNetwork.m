//
//  CRJBaseNetwork.m
//  AFNetworking
//
//  Created by 朱玉辉(EX-ZHUYUHUI002) on 2021/1/20.
//

#import "CRJBaseNetwork.h"

@interface CRJBaseNetwork()

@end

@implementation CRJBaseNetwork
- (void)cancelAllRequest {
    // 锁操作
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

- (void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) { return; }
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}
#pragma mark - Interface
-(NSString *)methodName:(CRJNetworkRequestType)requestType{
    NSString *method = @"";
    switch (requestType) {
        case CRJNetworkRequestTypeGET:
            method = @"GET";
            break;
        case CRJNetworkRequestTypePOST:
            method = @"POST";
            break;
        case CRJNetworkRequestTypePUT:
            method = @"PUT";
            break;
        case CRJNetworkRequestTypePATCH:
            method = @"PATCH";
            break;
        case CRJNetworkRequestTypeDELETE:
            method = @"DELETE";
            break;
        default:
            break;
    }
    return method;
}

#pragma mark - base dataTask
- (NSURLSessionDataTask *)dataTaskWithUrlPath:(NSString *)urlPath
                                  requestType:(CRJNetworkRequestType)requestType
                                       header:(nullable NSDictionary *)header
                                       params:(nullable NSDictionary *)params
                          uploadProgressBlock:(nullable PPHttpProgress)uploadProgressBlock
                        downloadProgressBlock:(nullable PPHttpProgress)downloadProgressBlock
                            completionHandler:(nullable PPCompletionHandler)completionHandler;
{
    NSString *method = [self methodName:requestType];
    
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionary];
    [finalParams addEntriesFromDictionary:params];

    NSMutableURLRequest *request = [self.requestGenerator generateRequestWithUrlPath:urlPath method:method params:finalParams header:header];
    
    
    __block NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [[self allSessionTask] removeObject:task];

        if (error) {
            NSError *parseError = [self _errorFromRequestWithTask:task httpResponse:(NSHTTPURLResponse *)response responseObject:responseObject error:error];
            [self HTTPRequestLog:task body:params error:parseError];
            /// 解析参数
            CRJBaseResponse *ojbkResponse = [[CRJBaseResponse alloc] initWithResponseObject:responseObject parseError:parseError];
            if (completionHandler) {
                completionHandler(ojbkResponse);
            }
        } else {
            [self HTTPRequestLog:task body:params error:nil];
            /// 解析参数
            CRJBaseResponse *ojbkResponse = [[CRJBaseResponse alloc] initWithResponseObject:responseObject parseError:nil];
            if (completionHandler) {
                completionHandler(ojbkResponse);
            }
        }
    }];
    
    // 添加sessionTask到数组
    task ? [[self allSessionTask] addObject:task] : nil ;
    return task;
}

- (NSURLSessionDataTask *)uploadDataWithUrlPath:(NSString *)urlPath
                                    requestType:(CRJNetworkRequestType)requestType
                                         header:(nullable NSDictionary *)header
                                         params:(nullable NSDictionary *)params
                                       contents:(nullable NSArray<CRJUploadFile *> *)contents
                            uploadProgressBlock:(nullable PPHttpProgress)uploadProgressBlock
                              completionHandler:(nullable PPCompletionHandler)completionHandler;
{
    
    NSMutableDictionary *finalParams = [NSMutableDictionary dictionary];
    [finalParams addEntriesFromDictionary:params];

    NSMutableURLRequest *request =[self.requestGenerator generateUploadRequestUrlPath:urlPath params:params contents:contents header:header];
    
    __block NSURLSessionDataTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:uploadProgressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        [[self allSessionTask] removeObject:task];

        if (error) {
            NSError *parseError = [self _errorFromRequestWithTask:task httpResponse:(NSHTTPURLResponse *)response responseObject:responseObject error:error];
            [self HTTPRequestLog:task body:params error:parseError];
            /// 解析参数
            CRJBaseResponse *ojbkResponse = [[CRJBaseResponse alloc] initWithResponseObject:responseObject parseError:parseError];
            if (completionHandler) {
                completionHandler(ojbkResponse);
            }
        } else {
            [self HTTPRequestLog:task body:params error:nil];
            /// 解析参数
            CRJBaseResponse *ojbkResponse = [[CRJBaseResponse alloc] initWithResponseObject:responseObject parseError:nil];
            if (completionHandler) {
                completionHandler(ojbkResponse);
            }
        }
    }];
    
    // 添加sessionTask到数组
    task ? [[self allSessionTask] addObject:task] : nil ;
    return task;
}

#pragma mark - Error Handling
/// 请求错误解析
- (NSError *)_errorFromRequestWithTask:(NSURLSessionTask *)task httpResponse:(NSHTTPURLResponse *)httpResponse responseObject:(NSDictionary *)responseObject error:(NSError *)error {
    NSInteger HTTPCode = httpResponse.statusCode;
    NSString *errorDesc = @"服务器出错了，请稍后重试~";
    /// 其实这里需要处理后台数据错误，一般包在 responseObject
    /// HttpCode错误码解析 https://www.guhei.net/post/jb1153
    /// 1xx : 请求消息 [100  102]
    /// 2xx : 请求成功 [200  206]
    /// 3xx : 请求重定向[300  307]
    /// 4xx : 请求错误  [400  417] 、[422 426] 、449、451
    /// 5xx 、600: 服务器错误 [500 510] 、600
    NSInteger httpFirstCode = HTTPCode/100;
    if (httpFirstCode > 0) {
        if (httpFirstCode == 4) {
            /// 请求出错了，请稍后重试
            if (HTTPCode == 408) {
#if defined(DEBUG)||defined(_DEBUG)
                errorDesc = @"请求超时，请稍后再试(408)~";
#else
                errorDesc = @"请求超时，请稍后再试~";
#endif
            }else{
#if defined(DEBUG)||defined(_DEBUG)
                errorDesc = [NSString stringWithFormat:@"请求出错了，请稍后重试(%zd)~",HTTPCode];
#else
                errorDesc = @"请求出错了，请稍后重试~";
#endif
            }
        } else if (httpFirstCode == 5 || httpFirstCode == 6){
            /// 服务器出错了，请稍后重试
#if defined(DEBUG)||defined(_DEBUG)
            errorDesc = [NSString stringWithFormat:@"服务器出错了，请稍后重试(%zd)~",HTTPCode];
#else
            errorDesc = @"服务器出错了，请稍后重试~";
#endif
            
        } else if (!self.sessionManager.reachabilityManager.isReachable){
            /// 网络不给力，请检查网络
            errorDesc = @"网络开小差了，请稍后重试~";
        }
    } else {
        if (!self.sessionManager.reachabilityManager.isReachable){
            /// 网络不给力，请检查网络
            errorDesc = @"网络开小差了，请稍后重试~";
        }
    }
    
    /// 从error中解析
    if ([error.domain isEqual:NSURLErrorDomain]) {
#if defined(DEBUG)||defined(_DEBUG)
        errorDesc = [NSString stringWithFormat:@"请求出错了，请稍后重试(%zd)~",error.code];
#else
        errorDesc = @"请求出错了，请稍后重试~";
#endif
        switch (error.code) {
            case NSURLErrorSecureConnectionFailed:
            case NSURLErrorServerCertificateHasBadDate:
            case NSURLErrorServerCertificateHasUnknownRoot:
            case NSURLErrorServerCertificateUntrusted:
            case NSURLErrorServerCertificateNotYetValid:
            case NSURLErrorClientCertificateRejected:
            case NSURLErrorClientCertificateRequired:
                break;
            case NSURLErrorTimedOut:{
#if defined(DEBUG)||defined(_DEBUG)
                errorDesc = @"请求超时，请稍后再试(-1001)~";
#else
                errorDesc = @"请求超时，请稍后再试~";
#endif
                break;
            }
            case NSURLErrorNotConnectedToInternet:{
#if defined(DEBUG)||defined(_DEBUG)
                errorDesc = @"网络开小差了，请稍后重试(-1009)~";
#else
                errorDesc = @"网络开小差了，请稍后重试~";
#endif
                break;
            }
        }
    }

    NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:error.userInfo];
    dict[NSLocalizedDescriptionKey] = errorDesc;
    return [NSError errorWithDomain:error.domain code:error.code userInfo:dict];
}

#pragma mark - 打印请求日志
- (void)HTTPRequestLog:(NSURLSessionTask *)task body:params error:(NSError *)error {
    NSLog(@">>>>>>>>>>>>>>>>>>>>>👇 REQUEST FINISH 👇>>>>>>>>>>>>>>>>>>>>>>>>>>");
    NSLog(@"Request%@=======>:%@", error?@"失败":@"成功", task.currentRequest.URL.absoluteString);
    NSLog(@"requestBody======>:%@", params);
    NSLog(@"requstHeader=====>:%@", task.currentRequest.allHTTPHeaderFields);
    NSLog(@"response=========>:%@", task.response);
    NSLog(@"error============>:%@", error);
    NSLog(@"<<<<<<<<<<<<<<<<<<<<<👆 REQUEST FINISH 👆<<<<<<<<<<<<<<<<<<<<<<<<<<");
}

#pragma mark - getter && setter
- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _sessionManager.requestSerializer.timeoutInterval = 30.0f;//默认是60秒的超时时间
        [_sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [_sessionManager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
    
    return _sessionManager;
}

- (CRJBaseRequestGenerator *)requestGenerator {
    if (!_requestGenerator) {
        _requestGenerator = [[CRJBaseRequestGenerator alloc] init];
    }
    return _requestGenerator;
}

- (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}
@end

//
//  CRJBaseRequestGenerator.h
//  CRJNetwork
//
//  Created by 朱玉辉(EX-ZHUYUHUI002) on 2021/1/21.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "CRJUploadFile.h"
NS_ASSUME_NONNULL_BEGIN

@interface CRJBaseRequestGenerator : NSObject

@property(nonatomic, strong) AFHTTPRequestSerializer *requestSerialize;

- (NSMutableURLRequest *)generateRequestWithUrlPath:(NSString *)urlPath
                                             method:(NSString *)method
                                             params:(NSDictionary *)params
                                             header:(NSDictionary *)header;

- (NSMutableURLRequest *)generateUploadRequestUrlPath:(NSString *)urlPath
                                               params:(NSDictionary *)params
                                             contents:(NSArray<CRJUploadFile *> *)contents
                                               header:(NSDictionary *)header;
@end

NS_ASSUME_NONNULL_END

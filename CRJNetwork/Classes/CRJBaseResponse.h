//
//  CRJBaseResponse.h
//  CRJNetwork
//
//  Created by 朱玉辉(EX-ZHUYUHUI002) on 2021/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRJBaseResponse : NSObject
/// 成功or失败
@property(nonatomic, assign) BOOL success;
@property(nullable, nonatomic, strong) NSError *error;
@property(nullable, nonatomic, strong) id responseObject;
- (instancetype)initWithResponseObject:(nullable id)responseObject parseError:(nullable NSError *)parseError;
@end

NS_ASSUME_NONNULL_END

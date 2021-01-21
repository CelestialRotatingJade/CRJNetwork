//
//  CRJBaseResponse.m
//  CRJNetwork
//
//  Created by 朱玉辉(EX-ZHUYUHUI002) on 2021/1/21.
//

#import "CRJBaseResponse.h"

@implementation CRJBaseResponse
- (instancetype)initWithResponseObject:(id)responseObject parseError:(NSError *)parseError {
    self = [super init];
    if (self) {
        self.responseObject = responseObject;
        self.error = parseError;
        if (parseError) {
            self.success    = NO;
        }else{
            self.success    = YES;
        }
    }
    return self;

}
@end

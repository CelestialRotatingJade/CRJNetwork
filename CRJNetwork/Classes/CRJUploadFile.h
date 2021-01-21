//
//  CRJUploadFile.h
//  CRJNetwork
//
//  Created by 朱玉辉(EX-ZHUYUHUI002) on 2021/1/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRJUploadFile : NSObject
/// fileData
@property (nonatomic, strong) NSData *fileData;
/// 请求字段
@property (nonatomic, copy) NSString *name;
/// 上传文件名
@property (nonatomic, copy) NSString *fileName;
/// 文件mimeType
@property (nonatomic, copy) NSString *mimeType;
@end

NS_ASSUME_NONNULL_END

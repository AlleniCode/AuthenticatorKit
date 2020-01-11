//
//  AuthenticatorKit.h
//  AuthenticatorKit
//
//  Created by Mac on 2020/1/9.
//  Copyright © 2020 Onchain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ActionType) {
    ActionTypeDecentralizedRegister         = 0, // Decentralized registration（去中心化的注册【需要调起 ONTAuth】）
    ActionTypeDecentralizedLogin            = 1, // Decentralized login（去中心化的登录【需要调起 ONTAuth】）
    ActionTypeApplyClaim                    = 2, // Apply Claim（申请 Claim）
    ActionTypeGetClaim                      = 3, // Get Claim（获取 Claim（需要先申请 Claim）【需要调起 ONTAuth】）
    ActionTypeAuthorizeClaim                = 4, // Authorize Claim（授权 Claim【需要调起 ONTAuth】）
    ActionTypeCentralizedRegister           = 5, // Centralized registration（中心化的注册）
    ActionTypeCentralizedLogin              = 6, // Centralized login（中心化的登录）
    ActionTypeCentralizedAddOwner           = 7, // Centralized add Owner（中心化的添加 Owner【需要调起 ONTAuth】）
    ActionTypeCentralizedLoginByOwner       = 8, // Centralized login by Owner（中心化的通过 Owner 登录【需要调起 ONTAuth】）
};

@protocol AuthenticatorKitDelegate <NSObject>

@optional
- (void)receiveResultFromAuthenticator:(NSDictionary *)result;

@end

@interface AuthenticatorKit : NSObject

@property (nonatomic, weak) id<AuthenticatorKitDelegate> delegate;
@property (nonatomic, strong) NSString *urlSchemes;


+ (instancetype)shareInstance;

/// Decentralized registration
- (void)decentralizedRegisterWithUserName:(NSString *)userName callback:(void (^)(BOOL success, NSError *error))callback;

/// Decentralized login
- (void)decentralizedLoginCallback:(void (^)(BOOL success, NSError *error))callback;

/// Get decentralized login status
- (void)getDecentralizedLoginStatusCallback:(void (^)(NSInteger status, NSError *error))callback;

/// Apply Claim
- (void)applyClaimWithOntid:(NSString *)ontid name:(NSString *)name age:(NSInteger)age callback:(void (^)(BOOL success, NSError *error))callback;

/// Get Claim
- (void)getClaimCallback:(void (^)(BOOL success, NSError *error))callback;

/// Authorize Claim
- (void)authorizeClaimCallback:(void (^)(BOOL success, NSError *error))callback;

/// Centralized registration
- (void)centralizedRegisterWithUserName:(NSString *)userName password:(NSString *)password callback:(void (^)(BOOL success, NSString *ontid, NSError *error))callback;

/// Centralized login
- (void)centralizedLoginWithUserName:(NSString *)userName password:(NSString *)password callback:(void (^)(BOOL success, NSString *ontid, NSError *error))callback;

/// Centralized add Owner
- (void)centralizedAddOwnerWithOntid:(NSString *)ontid callback:(void (^)(BOOL success, NSError *error))callback;

/// Centralized login by Owner
- (void)centralizedLoginByOwnerCallback:(void (^)(BOOL success, NSError *error))callback;

/// Get centralized login status
- (void)getCentralizedLoginStatusCallback:(void (^)(NSInteger status, NSError *error))callback;

/// Authenticator 
- (void)handelURL:(NSURL *)url;


@end

NS_ASSUME_NONNULL_END

# AuthenticatorKit


## Usage


#### Step 1

Add  `pod 'AuthenticatorKit', '0.1.2'` in your Podfile.

And run `pod install`.


#### Step 2

Add a URL Schemes in your project targets.

And add a key of  `LSApplicationQueriesSchemes` with value `ontologyauthenticator` in your Info.plist file.


#### Step 3

Add `#import <AuthenticatorKit/AuthenticatorKit.h>` in `AppDelegate.m`.

And add some code in the `application:didFinishLaunchingWithOptions` func:
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[AuthenticatorKit shareInstance] setUrlSchemes:@"AuthenticatorKitDemo"];
    
    return YES;
}
```


#### Step 4

Add some cod in `AppDelegate.m` and `SceneDelegate.m`:
```
- (BOOL)application:(UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [[AuthenticatorKit shareInstance] handelURL:url];
    
    return YES;
}
```

```
- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    UIOpenURLContext *context = URLContexts.allObjects.firstObject;
    NSURL *url = context.URL;
    [[AuthenticatorKit shareInstance] handelURL:url];
}
```


#### Step 5

Set the `AuthenticatorKitDelegate` where you want, and add the func `receiveResultFromAuthenticator`.
```
[[AuthenticatorKit shareInstance] setDelegate:self];
```

```
#pragma mark - AuthenticatorKitDelegate
- (void)receiveResultFromAuthenticator:(NSDictionary *)result {
    NSLog(@"%@", result);
}
```


## Examples

See more usage in the example project of `AuthenticatorKitDemo`.




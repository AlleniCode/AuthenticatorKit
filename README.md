# AuthenticatorKit


## Usage

#### Step 1

Add  `pod 'AuthenticatorKit', '0.1.2'` in your Podfile.

And run `pod install`.


#### Step 2

Add a URL Schemes in your project targets.

![image](https://github.com/AlleniCode/AuthenticatorKit/blob/master/Resources/QQ20200111-141537%402x.png)

And add a key of  `LSApplicationQueriesSchemes` with value `ontologyauthenticator` in your Info.plist file.

![image](https://github.com/AlleniCode/AuthenticatorKit/blob/master/Resources/QQ20200111-141723%402x.png)


#### Step 3

Add `#import <AuthenticatorKit/AuthenticatorKit.h>` in `AppDelegate.m`.

And add some code in the `application:didFinishLaunchingWithOptions` func:
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[AuthenticatorKit shareInstance] setUrlSchemes:@"AuthenticatorKitDemo"]; // the url schemes set in step 2
    
    return YES;
}
```

![image](https://github.com/AlleniCode/AuthenticatorKit/blob/master/Resources/QQ20200111-142345%402x.png)


#### Step 4

Add some cod in `AppDelegate.m` and `SceneDelegate.m`:
```
- (BOOL)application:(UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [[AuthenticatorKit shareInstance] handelURL:url];
    
    return YES;
}
```

![image](https://github.com/AlleniCode/AuthenticatorKit/blob/master/Resources/QQ20200111-142743%402x.png)

```
- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    UIOpenURLContext *context = URLContexts.allObjects.firstObject;
    NSURL *url = context.URL;
    [[AuthenticatorKit shareInstance] handelURL:url];
}
```
![image](https://github.com/AlleniCode/AuthenticatorKit/blob/master/Resources/QQ20200111-142814%402x.png)


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

![image](https://github.com/AlleniCode/AuthenticatorKit/blob/master/Resources/QQ20200111-143020%402x.png)


## Examples

See more usage in the example project of `AuthenticatorKitDemo`.

[AuthenticatorKitDemo](https://github.com/AlleniCode/AuthenticatorKit/tree/master/AuthenticatorKitDemo)


#import "AdmobBanner.h"
#include "reference.h"


@implementation AdmobBanner

- (void)dealloc {
    bannerView.delegate = nil;
    [bannerView release];
    [super dealloc];
}

- (void)initialize:(BOOL)is_real: (int)instance_id {
    isReal = is_real;
    initialized = true;
    instanceId = instance_id;
    rootController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
}

- (void) loadBanner:(NSString*)bannerId: (BOOL)is_on_top {
    NSLog(@"Calling loadBanner");
    
    isOnTop = is_on_top;
    
    if (!initialized) {
        return;
    }
    

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (bannerView == nil) {
        if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) { //portrait
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        }
        else { //landscape
            bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
        }
        
        if(!isReal) {
            bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
        }
        else {
            bannerView.adUnitID = bannerId;
        }

        bannerView.delegate = self;
        
        bannerView.rootViewController = rootController;
        [rootController.view addSubview:bannerView];
        
    }
    
    GADRequest *request = [GADRequest request];
    [bannerView loadRequest:request];
    
    
    float height = rootController.view.frame.size.height;
    float width = rootController.view.frame.size.width;
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) { // landscape: swap width/height
        float tmp = height;
        height = width;
        width = tmp;
    }
    
    NSLog(@"height: %f, width: %f", height, width);

    if(!isOnTop) {
        [bannerView setFrame:CGRectMake(0, height-bannerView.bounds.size.height, bannerView.bounds.size.width, bannerView.bounds.size.height)];
    }
}



- (void)showBanner {
    NSLog(@"Calling showBanner");
    
    if (bannerView == nil || !initialized) {
        return;
    }
    
    [bannerView setHidden:NO];
}

- (void) hideBanner {
    NSLog(@"Calling hideBanner");
    if (bannerView == nil || !initialized) {
        return;
    }
    [bannerView setHidden:YES];
}

- (void) resize {
    NSLog(@"Calling resize");
    NSString* currentAdUnitId = bannerView.adUnitID;
    [self hideBanner];
    [bannerView removeFromSuperview];
    bannerView = nil;
    [self loadBanner:currentAdUnitId:isOnTop];
}

/// The number of pixels per inch for this device
- (CGFloat) pixelsPerInch {
    struct utsname sysinfo;
    
    if (uname(&sysinfo) == 0) {
        NSString *my_device_model = [NSString stringWithUTF8String:sysinfo.machine];

        // if in emulator
        if ([my_device_model isEqualToString:@"x86_64"] || [my_device_model isEqualToString:@"i386"]) {
            my_device_model = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
        }
        NSLog(@"My device model: %@", my_device_model);

        NSArray *PPI_132 = [NSArray arrayWithObjects: @"iPad2,4", @"iPad2,3", @"iPad2,2", @"iPad2,1", nil];
        NSArray *PPI_163 = [NSArray arrayWithObjects: @"iPad2,7", @"iPad2,6", @"iPad2,5", nil];
        NSArray *PPI_264 = [NSArray arrayWithObjects: @"iPad3,3", @"iPad3,2", @"iPad3,1", @"iPad3,6", @"iPad3,5", @"iPad3,4", @"iPad4,3", @"iPad4,2", @"iPad4,1", @"iPad5,4", @"iPad5,3", @"iPad6,8", @"iPad6,7", @"iPad6,4", @"iPad6,3", @"iPad6,12", @"iPad6,11", @"iPad7,2", @"iPad7,1", @"iPad7,4", @"iPad7,3", @"iPad7,6", @"iPad7,5", nil];
        NSArray *PPI_326 = [NSArray arrayWithObjects: @"iPhone4,1", @"iPhone5,2", @"iPhone5,1", @"iPhone5,4", @"iPhone5,3", @"iPhone6,2", @"iPhone6,1", @"iPhone8,4", @"iPhone7,2", @"iPhone8,1", @"iPhone9,3", @"iPhone9,1", @"iPhone10,4", @"iPhone10,1", @"iPod5,1", @"iPod7,1", @"iPad4,6", @"iPad4,5", @"iPad4,4", @"iPad4,9", @"iPad4,8", @"iPad4,7", @"iPad5,2", @"iPad5,1", nil];
        NSArray *PPI_401 = [NSArray arrayWithObjects: @"iPhone7,1", @"iPhone8,2", @"iPhone9,4", @"iPhone9,2", @"iPhone10,5", @"iPhone10,2", nil];
        NSArray *PPI_458 = [NSArray arrayWithObjects: @"iPhone10,6", @"iPhone10,3", nil];
        NSArray *PPI_NAMES = [NSArray arrayWithObjects: PPI_132, PPI_163, PPI_264, PPI_326, PPI_401, PPI_458, nil];
        NSArray *PPIS = [NSArray arrayWithObjects: @132.0, @163.0, @264.0, @326.0, @401.0, @458.0, nil];

        int i;
        int count = [PPIS count];
        for (i = 0; i < count; i++) {
            NSArray *devices = PPI_NAMES[i];
            int j;
            int device_count = [devices count];
            for (j = 0; j < device_count; j++) {
                NSString *device_model = devices[j];
                NSLog(@"Device model: %@", device_model);
                if ([my_device_model isEqualToString:device_model]) {
                    return [PPIS[i] floatValue];
                }
            }
        }
    }

    // make an aproximation
    float scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    float dpi;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        dpi = 132 * scale;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        dpi = 163 * scale;
    } else {
        dpi = 160 * scale;
    }
    return dpi;
}


- (CGFloat) pointsToPixels:(int)points:(int)screenHeight {
    // CGFloat ppi = [self pixelsPerInch];

    // NSLog(@"Points %f", points);
    // NSLog(@"PPI %f", ppi);
    // NSLog(@"h %f", h);

    // CGFloat original_pixels = (points / 163.0) * ppi;
    // return original_pixels / h * 1920.0;
    CGRect r = [[UIScreen mainScreen] nativeBounds];
    CGFloat h = r.size.height;
    return (points * [UIScreen mainScreen].scale) / h * screenHeight;
}

- (int) getBannerHeight:(int)screenHeight {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == 0 || orientation == UIInterfaceOrientationPortrait) { //portrait
        NSLog(@"GADAdSize: %f", kGADAdSizeSmartBannerPortrait.size.height);
        return [self pointsToPixels:CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height:screenHeight];
    }

    NSLog(@"GADAdSize: %f", kGADAdSizeSmartBannerLandscape.size.height);
    return [self pointsToPixels:CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height:screenHeight];
}

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_admob_ad_loaded");
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    Object *obj = ObjectDB::get_instance(instanceId);
    obj->call_deferred("_on_admob_network_error");
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
}


@end

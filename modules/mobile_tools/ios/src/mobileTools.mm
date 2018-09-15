#include "mobileTools.h"


#import "app_delegate.h"
#import <StoreKit/StoreKit.h>


MobileTools::MobileTools() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

MobileTools::~MobileTools() {
    instance = NULL;
}



void MobileTools::shareText(const String &title, const String &subject, const String &text) {
    
    ViewController *root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    NSString * message = [NSString stringWithCString:text.utf8().get_data() encoding:NSUTF8StringEncoding];
    
    NSArray * shareItems = @[message];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    [root_controller presentViewController:avc animated:YES completion:nil];

}

void MobileTools::sharePic(const String &path, const String &title, const String &subject, const String &text) {
    ViewController *root_controller = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    NSString * message = [NSString stringWithCString:text.utf8().get_data() encoding:NSUTF8StringEncoding];
    NSString * imagePath = [NSString stringWithCString:path.utf8().get_data() encoding:NSUTF8StringEncoding];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    NSArray * shareItems = @[message, image];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    [root_controller presentViewController:avc animated:YES completion:nil];
}

void MobileTools::rateApp() {
    [SKStoreReviewController requestReview];
}

bool MobileTools::canShowRate() {
    if (@available(iOS 10.3, *)) {
        return true;
    }

    return true;
}

void MobileTools::rateInAppStore() {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/itunes-u/id1431765471?action=write-review"];
    [application openURL:URL options:@{} completionHandler:nil];
}

float MobileTools::pixelsPerInch() {
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

float MobileTools::getDiagonal() {
    float width = ([[UIScreen mainScreen] bounds].size.width * scale);
    float height = ([[UIScreen mainScreen] bounds].size.height * scale);
    return sqrt(pow(width, 2) + pow(height, 2));
}

float MobileTools::getDiagonalInches() {
    float ppi = pixelsPerInch();
    float width = ([[UIScreen mainScreen] bounds].size.width * scale);
    float height = ([[UIScreen mainScreen] bounds].size.height * scale);

    float horizontal = width / ppi, vertical = height / ppi;

    return sqrt(pow(horizontal, 2) + pow(vertical, 2));
}

void MobileTools::_bind_methods() {
#if VERSION_MAJOR == 3
    ClassDB::bind_method(D_METHOD("shareText"), &MobileTools::shareText);
    ClassDB::bind_method(D_METHOD("sharePic"), &MobileTools::sharePic);
    ClassDB::bind_method(D_METHOD("rateApp"), &MobileTools::rateApp);
    ClassDB::bind_method(D_METHOD("rateInAppStore"), &MobileTools::rateInAppStore);
    ClassDB::bind_method(D_METHOD("canShowRate"), &MobileTools::canShowRate);
    ClassDB::bind_method(D_METHOD("getDiagonal"), &MobileTools::getDiagonal);
    ClassDB::bind_method(D_METHOD("getDiagonalInches"), &MobileTools::getDiagonalInches);
#else
    ObjectTypeDB::bind_method("shareText", &MobileTools::shareText);
    ObjectTypeDB::bind_method("sharePic", &MobileTools::sharePic);
    ObjectTypeDB::bind_method("rateApp", &MobileTools::rateApp);
    ObjectTypeDB::bind_method("rateInAppStore", &MobileTools::rateInAppStore);
    ObjectTypeDB::bind_method("canShowRate", &MobileTools::canShowRate);
    ObjectTypeDB::bind_method("getDiagonal", &MobileTools::getDiagonal);
    ObjectTypeDB::bind_method("getDiagonalInches", &MobileTools::getDiagonalInches);
#endif
    
}

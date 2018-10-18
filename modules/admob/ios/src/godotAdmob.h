#ifndef GODOT_ADMOB_H
#define GODOT_ADMOB_H

#include <core/version_generated.gen.h>

#include "core/reference.h"


#ifdef __OBJC__
// @class AdmobBanner;
// typedef AdmobBanner *bannerPtr;
@class AdmobRewarded;
typedef AdmobRewarded *rewardedPtr;
#else
typedef void *bannerPtr;
typedef void *rewardedPtr;
#endif



class GodotAdmob : public Reference {
    
#if VERSION_MAJOR == 3
    GDCLASS(GodotAdmob, Reference);
#else
    OBJ_TYPE(GodotAdmob, Reference);
#endif

    bool initialized;
    GodotAdmob *instance;
    
    // bannerPtr banner;
    rewardedPtr rewarded;
    String lang;
    PACConsentForm *form;
    

protected:
    static void _bind_methods();

public:

    void init(bool isReal, int instanceId, String lang);
    // void loadBanner(const String &bannerId, bool isOnTop);
    // void showBanner();
    // void hideBanner();
    // void resize();
    // int getBannerWidth();
    // int getBannerHeight();
    void loadRewardedVideo(const String &rewardedId);
    void showRewardedVideo();

    GodotAdmob();
    ~GodotAdmob();
};

#endif

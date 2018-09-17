#ifndef GODOT_MOBILE_TOOLS_H
#define GODOT_MOBILE_TOOLS_H

#include <core/version_generated.gen.h>
#import <sys/utsname.h>
#include "core/reference.h"

class MobileTools : public Reference {
#if VERSION_MAJOR == 3
    GDCLASS(MobileTools, Reference);
#else
    OBJ_TYPE(MobileTools, Reference);
#endif
    

protected:
    static void _bind_methods();
    
    MobileTools* instance;
    
public:

    void shareText(const String &title, const String &subject, const String &text);
    void sharePic(const String &path, const String &title, const String &subject, const String &text);
    void rateApp();
    void rateInAppStore();
    bool canShowRate();
    int getPointDivisor();
    float getDiagonal();
    float getDiagonalInches();
    float pixelsPerInch();

    MobileTools();
    ~MobileTools();
};

#endif

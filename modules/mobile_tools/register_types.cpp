#include <version_generated.gen.h>

#if VERSION_MAJOR == 3
#include <core/class_db.h>
#include <core/engine.h>
#else
#include "object_type_db.h"
#include "core/globals.h"
#endif
#include "register_types.h"

#include "ios/src/mobileTools.h"

void register_mobile_tools_types() {
#if VERSION_MAJOR == 3
    Engine::get_singleton()->add_singleton(Engine::Singleton("MobileTools", memnew(MobileTools)));
#else
    Globals::get_singleton()->add_singleton(Globals::Singleton("MobileTools", memnew(MobileTools)));
#endif
}

void unregister_mobile_tools_types() {
}

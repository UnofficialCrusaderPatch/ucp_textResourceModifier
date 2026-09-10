#pragma once
// Test host only: production builds use the framework SDK.
enum ucp_NamedVerbosity { Verbosity_FATAL = -3, Verbosity_ERROR = -2,
  Verbosity_WARNING = -1, Verbosity_INFO = 0, Verbosity_1 = 1 };
void ucp_log(ucp_NamedVerbosity, const char*);
inline void* ucp_getProcAddressFromLibraryInModule(const char*, const char*, const char*) { return nullptr; }

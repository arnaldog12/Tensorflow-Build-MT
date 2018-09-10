#pragma once

#include "tensorflow/core/public/session.h"

#ifdef __cplusplus
// only need to export C interface if // used by C++ source code
extern "C"
{
#endif

	void doSomething();

#ifdef __cplusplus
}
#endif
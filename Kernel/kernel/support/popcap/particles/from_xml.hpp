#pragma once

#include "kernel/utility/utility.hpp"
#include "kernel/support/popcap/particles/definition.hpp"
#include "kernel/support/popcap/particles/common.hpp"

namespace Sen::Kernel::Support::PopCap::Particles
{


    struct FromXML : Common
    { static auto process_fs(
            std::string_view source,
            std::string_view destination) -> void
        {
        }
    };
}

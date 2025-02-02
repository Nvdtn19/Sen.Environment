#pragma once

#include "kernel/utility/utility.hpp"
#include "kernel/support/popcap/animation/convert/definition.hpp"
#include "kernel/support/popcap/animation/convert/common.hpp"

namespace Sen::Kernel::Support::PopCap::Animation::Convert
{
	struct ToFlash : Common
	{
		 static auto process_whole(
			ExtraInfo &extra,
			std::string_view destination) -> void
		{
		}

		 static auto process_fs(
			std::string_view source,
			std::string_view destination,
			int resolution) -> void
		{
		}
	};

}
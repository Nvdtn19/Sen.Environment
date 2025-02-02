#pragma once

#include "kernel/utility/library.hpp"
#include "kernel/utility/assert.hpp"
#include "kernel/utility/macro.hpp"

namespace Sen::Kernel::Encryption::FNV {

	// Common

	template <typename T> requires std::is_integral<T>::value 
		&& std::is_unsigned<T>::value
	struct Common {

		// Offset
		inline static constexpr auto offset = static_cast<T>(0x811c9dc5);

		// Prime

		inline static constexpr auto prime = static_cast<T>(0x1000193);

	};

	// Hash
	template <typename T> requires std::is_integral<T>::value &&
		std::is_unsigned<T>::value
	class Hash {

		public:

			using Type = T;

		private:

			using Common = Common<Hash::Type>;

			using Size = std::uint64_t;

		protected:

			auto constexpr hash (
				const char* str, 
				Hash::Type value = Common::offset
			) noexcept -> Hash::Type
			{
				if (str != nullptr) {
					return hash(str + 1, (value ^ *str) * static_cast<Size>(Common::prime));
				}
				return value;
			}

		public:

			Hash (
			) = default;

			~Hash (
			) = default;

			Hash (
				Hash&& that
			) = delete;

			auto operator =(
				Hash&& that
			) -> Hash& = delete;

			auto constexpr make_hash (
				const char* str
			) noexcept -> Hash::Type
			{
				auto value = Common::offset;
				while (str != nullptr) {
					value ^= *str++;
					value *= Common::prime;
				}
				return value;
			}
	};
	

}
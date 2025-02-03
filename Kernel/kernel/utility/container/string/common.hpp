#pragma once

#include "kernel/utility/library.hpp"

namespace Sen::Kernel {

    inline constexpr auto hash_string (
        std::string_view const & string
    ) -> std::uint64_t {
        auto offset = std::uint64_t{14695981039346656037ull};
        auto prime = std::uint64_t{1099511628211ull};
        auto result = offset;
        for (auto & element : string) {
            result ^= static_cast<std::uint8_t>(element);
            result *= prime;
        }
        return result;
    }

    inline auto replace_all(
        const std::string& str, 
        const std::string& old_sub, 
        const std::string& new_sub
    ) -> std::string
    {
        auto result = std::string{};
        result.reserve(str.size());
        auto pos = size_t{0};
        auto old_sub_len = old_sub.size();
        auto new_sub_len = new_sub.size();
        while (true) {
            auto found = str.find(old_sub, pos);
            if (found == std::string::npos) {
                result.append(str.substr(pos));
                break;
            }
            result.append(str, pos, found - pos);
            result.append(new_sub);
            pos = found + old_sub_len;
        }
        return result;
    }

    inline auto to_posix_style(
        std::string_view source
    ) -> std::string
    {
        auto destination = std::string{source.data(), source.size()};
        std::replace(destination.begin(), destination.end(), '\\', '/');
        return destination;
    }

    inline auto to_windows_style(
        std::string_view source
    ) -> std::string
    {
        auto destination = std::string{source.data(), source.size()};
        std::replace(destination.begin(), destination.end(), '/', '\\');
        return destination;
    }

    inline auto to_windows_style(
        std::wstring_view source
    ) -> std::wstring
    {
        auto destination = std::wstring{source.data(), source.size()};
        std::replace(destination.begin(), destination.end(), L'/', L'\\');
        return destination;
    }

    inline auto utf8_to_utf16(
        const std::string_view& str
    ) -> std::wstring
    {
        auto myconv = std::wstring_convert<std::codecvt_utf8<wchar_t>>{};
        return myconv.from_bytes(str.data(), str.data() + str.size());
    }

    inline auto utf16_to_utf8(
        const std::wstring_view& wstr
    ) -> std::string
    {
        auto myconv = std::wstring_convert<std::codecvt_utf8<wchar_t>>{};
        return myconv.to_bytes(wstr.data(), wstr.data() + wstr.size());
    }

    template<typename... Args>
    inline auto format(
        const std::string& str, 
        Args&&... args
    ) -> std::string
    {
        auto destination = std::string{str.data(), str.size()};
        auto placeholder = "{}"_sv;
        auto replacePlaceholder = [&](auto&& arg) -> void {
            auto pos = destination.find(placeholder);
            if (pos != std::string::npos) {
                destination.replace(pos, placeholder.length(), arg);
            }
        };
        (replacePlaceholder(args), ...);
        return destination;
    }

    template <typename T> requires std::is_integral_v<T> || std::is_floating_point_v<T>
    inline auto decimal_to_hexadecimal (
        const T& decNumber
    ) -> std::string 
    {
        auto ss = std::stringstream{};
        ss << std::hex << decNumber;
        return ss.str();
    }

    template <typename T> requires std::is_integral_v<T>
    inline constexpr bool is_whitespace_character(
        const T& c
    ) noexcept {
        return c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == '\f' || c == '\v';
    }

}
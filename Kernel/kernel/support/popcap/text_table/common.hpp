#pragma once

#include "kernel/utility/utility.hpp"
#include "kernel/utility/container/map/linear_map.hpp"

namespace Sen::Kernel::Support::PopCap::TextTable {

    enum Type : u8 {

        utf16_text,

        utf8_text,

        json_map,

        json_array,

    };

    struct Common {

        inline static constexpr auto key_regex = Subprojects::ctre::fixed_string{R"(\[([^\]]+)\])"};

        inline static constexpr auto value_regex = Subprojects::ctre::fixed_string{R"((?s)\n*(.*?)(?=\[|$))"};

    };

    namespace Detail {

        inline static constexpr auto all_types = std::to_array({ Type::utf16_text, Type::utf8_text, Type::json_map, Type::json_array });

    }

    struct ObjectData {
        LinearMap<String, String> LocStringValues;
    };

    struct ObjectList {
        List<String> LocStringValues;
    };

    template <auto is_map> requires std::is_same_v<type_of<is_map>, bool>
    struct ObjectEntry;
    
    template <>
    struct ObjectEntry<true> {
        List<String> aliases;
        String objclass;
        ObjectData objdata;
    };

    template <>
    struct ObjectEntry<false> {
        List<String> aliases;
        String objclass;
        ObjectList objdata;
    };
    
    template <auto is_map> requires std::is_same_v<type_of<is_map>, bool>
    struct LawnStrings {
        u32 version;
        List<ObjectEntry<is_map>> objects;
    };

    using MapLawnStrings = LawnStrings<true>;

    using ListLawnStrings = LawnStrings<false>;

    inline static constexpr auto k_supported = std::to_array<Type>({Type::utf16_text, Type::utf8_text, Type::json_map, Type::json_array});

    constexpr auto type_index(
        const Type& t
    ) -> std::optional<usize> {
        if (const auto it = std::ranges::find(k_supported, t); it != k_supported.end()) {
            return std::distance(k_supported.begin(), it);
        }
        return std::nullopt;
    }


}

JSONCONS_ALL_MEMBER_TRAITS(Sen::Kernel::Support::PopCap::TextTable::ObjectData, LocStringValues)

JSONCONS_ALL_MEMBER_TRAITS(Sen::Kernel::Support::PopCap::TextTable::ObjectList, LocStringValues)

JSONCONS_ALL_MEMBER_TRAITS(Sen::Kernel::Support::PopCap::TextTable::ObjectEntry<true>, aliases, objclass, objdata)

JSONCONS_ALL_MEMBER_TRAITS(Sen::Kernel::Support::PopCap::TextTable::ObjectEntry<false>, aliases, objclass, objdata)

JSONCONS_ALL_MEMBER_TRAITS(Sen::Kernel::Support::PopCap::TextTable::MapLawnStrings, version, objects)

JSONCONS_ALL_MEMBER_TRAITS(Sen::Kernel::Support::PopCap::TextTable::ListLawnStrings, version, objects)

template <>
struct Sen::Kernel::Javascript::Trait<Sen::Kernel::Support::PopCap::TextTable::Type> {

    using Type = Sen::Kernel::Support::PopCap::TextTable::Type;

    inline static auto constexpr k_utf8_text = "utf8-text"_sv;

    inline static auto constexpr k_utf16_text = "utf16-text"_sv;

    inline static auto constexpr k_json_map = "json-map"_sv;

    inline static auto constexpr k_json_array = "json-array"_sv;

    inline static auto constexpr k_utf8_text_hash = hash_string(k_utf8_text);

    inline static auto constexpr k_utf16_text_hash = hash_string(k_utf16_text);

    inline static auto constexpr k_json_map_hash = hash_string(k_json_map);

    inline static auto constexpr k_json_array_hash = hash_string(k_json_array);

    static auto from_value(
        Value& source,
        Type& destination
    ) -> void {
        assert_conditional(source.is_string(), "Expected the value to be number, but the actual type is not", "from_value");
        auto value = NativeString{};
        Trait<NativeString>::from_value(source, value);
        switch (hash_string(value.view())) {
            case k_utf8_text_hash:
                destination = Type::utf8_text;
                break;
            case k_utf16_text_hash:
                destination = Type::utf16_text;
                break;
            case k_json_map_hash:
                destination = Type::json_map;
                break;
            case k_json_array_hash:
                destination = Type::json_array;
                break;
            default:
                assert_conditional(false, "Invalid type", "from_value");
        }
    }

};

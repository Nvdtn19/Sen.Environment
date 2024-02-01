#pragma once

#include "kernel/definition/utility.hpp"

namespace Sen::Kernel::Support::PopCap::Animation
{

#pragma region AnimationSize
    struct AnimationSize
    {
    public:
        int width = -1;
        int height = -1;
        explicit AnimationSize(

            ) = default;

        explicit constexpr AnimationSize(
            int width,
            int height) : width(width), height(height)
        {
        }

        ~AnimationSize(

            ) = default;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationSize &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"width", anim.width},
            {"height", anim.height}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationSize &anim) -> void
    {
        json.at("width").get_to(anim.width);
        json.at("height").get_to(anim.height);
        return;
    }

#pragma endregion

#pragma region AnimationPosition
    struct AnimationPosition
    {
    public:
        int x;
        int y;
        explicit AnimationPosition(

            ) = default;

        explicit constexpr AnimationPosition(
            int x,
            int y) : x(x), y(y)
        {
        }

        ~AnimationPosition(

            ) = default;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationPosition &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"x", anim.x},
            {"y", anim.y}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationPosition &anim) -> void
    {
        json.at("x").get_to(anim.x);
        json.at("y").get_to(anim.y);
        return;
    }

#pragma endregion

#pragma region using

    using Sen::Kernel::Definition::DataStreamView;

#pragma endregion

#pragma region definition

    struct Definition
    {

    public:
        // magic

        inline static constexpr auto magic = 3136297300;

        inline static constexpr auto version = std::array<int, 6>{1, 2, 3, 4, 5, 6};
    };

#pragma region FrameFlags

    struct FrameFlags
    {
    public:
        inline static constexpr auto remove = 1;
        inline static constexpr auto append = 2;
        inline static constexpr auto change = 4;
        inline static constexpr auto label = 8;
        inline static constexpr auto stop = 16;
        inline static constexpr auto command = 32;
    };

#pragma endregion

#pragma region MoveFlags

    struct MoveFlags
    {
    public:
        inline static constexpr auto src_react = 32768;
        inline static constexpr auto rotate = 16384;
        inline static constexpr auto color = 8192;
        inline static constexpr auto matrix = 4096;
        inline static constexpr auto long_coords = 2048;
        inline static constexpr auto sprite_frame_number = 1024;
    };

#pragma endregion

#pragma region AnimationImage

    struct AnimationImage
    {
    public:
        std::string name;
        AnimationSize size;
        std::vector<double> transform;

        explicit AnimationImage(

        ) = default;

        ~AnimationImage(

        ) = default;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationImage &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"name", anim.name},
            {"size", anim.size},
            {"transform", anim.transform}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationImage &anim) -> void
    {
        json.at("name").get_to(anim.name);
        json.at("size").get_to(anim.size);
        json.at("transform").get_to(anim.transform);
        return;
    }

#pragma endregion

#pragma region AnimationWorkArea

    struct AnimationWorkArea
    {
    public:
        int index;
        int duration = 1;
        explicit AnimationWorkArea(

            ) = default;

        explicit constexpr AnimationWorkArea(
            int index,
            int duration) : index(index), duration(duration)
        {
        }

        ~AnimationWorkArea(

            ) = default;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationWorkArea &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"index", anim.index},
            {"duration", anim.duration}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationWorkArea &anim) -> void
    {
        json.at("index").get_to(anim.index);
        json.at("duration").get_to(anim.duration);
        return;
    }

#pragma endregion

#pragma region AnimationCommand

    struct AnimationCommand
    {
    public:
        std::string command;
        std::string parameter;
        explicit AnimationCommand(

            ) = default;

        explicit constexpr AnimationCommand(
            std::string command,
            std::string parameter) : command(command), parameter(parameter)
        {
        }

        ~AnimationCommand(

            ) = default;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationCommand &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"command", anim.command},
            {"parameter", anim.parameter}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationCommand &anim) -> void
    {
        json.at("command").get_to(anim.command);
        json.at("parameter").get_to(anim.parameter);
        return;
    }

#pragma endregion

#pragma region AnimationAppend

    struct AnimationAppend
    {
    public:
        int index;
        std::string name;
        int resource;
        bool sprite;
        bool additive;
        int preload_frame;
        int time_scale = 1;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationAppend &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"index", anim.index},
            {"name", anim.name},
            {"resource", anim.resource},
            {"sprite", anim.sprite},
            {"additive", anim.additive},
            {"preload_frame", anim.preload_frame},
            {"time_scale", anim.time_scale}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationAppend &anim) -> void
    {
        json.at("name").get_to(anim.name);
        json.at("index").get_to(anim.index);
        json.at("resource").get_to(anim.resource);
        json.at("sprite").get_to(anim.sprite);
        json.at("additive").get_to(anim.additive);
        json.at("preload_frame").get_to(anim.preload_frame);
        json.at("time_scale").get_to(anim.time_scale);
        return;
    }

#pragma endregion

#pragma region AnimationMove

    struct AnimationMove
    {
    public:
        int index;
        std::vector<double> transform;
        std::vector<double> color;
        std::vector<double> source_rectangle;
        int sprite_frame_number;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationMove &anim) -> void
    {
        nlohmann::ordered_json color = nullptr;
        if (!anim.color.empty())
        {
            color = anim.color;
        }
        nlohmann::ordered_json source_rectangle = nullptr;
        if (!anim.source_rectangle.empty())
        {
            source_rectangle = anim.source_rectangle;
        }
        json = nlohmann::ordered_json{
            {"index", anim.index},
            {"transform", anim.transform},
            {"color", color},
            {"source_rectangle", source_rectangle},
            {"sprite_frame_number", anim.sprite_frame_number}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationMove &anim) -> void
    {
        json.at("index").get_to(anim.index);
        json.at("transform").get_to(anim.transform);
        if (json.at("color") != nullptr)
        {
            json.at("color").get_to(anim.color);
        }
        if (json.at("source_rectangle") != nullptr)
        {
            json.at("source_rectangle").get_to(anim.source_rectangle);
        }
        json.at("sprite_frame_number").get_to(anim.sprite_frame_number);
        return;
    }

#pragma endregion

#pragma region AnimationFrame

    struct AnimationFrame
    {
    public:
        std::string label;
        bool stop;
        std::vector<AnimationCommand> command;
        std::vector<int> remove;
        std::vector<AnimationAppend> append;
        std::vector<AnimationMove> change;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationFrame &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"label", anim.label},
            {"stop", anim.stop},
            {"command", anim.command},
            {"remove", anim.remove},
            {"append", anim.append},
            {"change", anim.change}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationFrame &anim) -> void
    {
        json.at("label").get_to(anim.label);
        json.at("stop").get_to(anim.stop);
        json.at("command").get_to(anim.command);
        json.at("remove").get_to(anim.remove);
        json.at("append").get_to(anim.append);
        json.at("change").get_to(anim.change);
        return;
    }

#pragma endregion

#pragma region AnimationSprite

    struct AnimationSprite
    {
    public:
        std::string description;
        AnimationWorkArea work_area;
        std::vector<AnimationFrame> frame;

        explicit AnimationSprite(

        ) = default;

        ~AnimationSprite(

        ) = default;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const AnimationSprite &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"description", anim.description},
            {"work_area", anim.work_area},
            {"frame", anim.frame}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        AnimationSprite &anim) -> void
    {
        json.at("description").get_to(anim.description);
        json.at("work_area").get_to(anim.work_area);
        json.at("frame").get_to(anim.frame);
        return;
    }

#pragma endregion

#pragma region SexyAnimation

    struct SexyAnimation
    {
    public:
        int version;
        int frame_rate;
        AnimationPosition position;
        AnimationSize size;
        nlohmann::ordered_json image;
        nlohmann::ordered_json sprite;
        AnimationSprite main_sprite;

        explicit SexyAnimation(

            ) = default;

        explicit SexyAnimation(
            int version,
            int frame_rate) : version(version), frame_rate(frame_rate)
        {
        }

        ~SexyAnimation(

            ) = default;
    };

    inline static auto to_json(
        nlohmann::ordered_json &json,
        const SexyAnimation &anim) -> void
    {
        json = nlohmann::ordered_json{
            {"version", anim.version},
            {"frame_rate", anim.frame_rate},
            {"position", anim.position},
            {"size", anim.size},
            {"image", anim.image},
            {"sprite", anim.sprite},
            {"main_sprite", anim.main_sprite}};
        return;
    };

    inline static auto from_json(
        const nlohmann::ordered_json &json,
        SexyAnimation &anim) -> void
    {
        json.at("version").get_to(anim.version);
        json.at("frame_rate").get_to(anim.frame_rate);
        json.at("position").get_to(anim.position);
        json.at("size").get_to(anim.size);
        json.at("image").get_to(anim.image);
        json.at("sprite").get_to(anim.sprite);
        json.at("main_sprite").get_to(anim.main_sprite);
        return;
    }

#pragma endregion
}

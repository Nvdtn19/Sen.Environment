﻿#include "kernel/interface/callback.hpp"
using namespace Sen::Kernel;
using namespace Sen::Kernel::Interface;

M_EXPORT_API
auto execute (
    StringList* argument,
    Callback callback
) -> int
{
    try
    {
        // std::setlocale(LC_ALL, "C");
        // auto& script = argument->value[2];
        // Shell::callback = callback;
        // Executor::register_external(&script, argument);
        // auto kernel = Runtime{};
        // kernel.execute();
        // Executor::unregister_external();
        auto value = String{};
        auto path = String{"C:/Users/Admin/Downloads/worldmap (1).json"};
        FileSystem::read_file(path, value);
    }
    catch(...)
    {
        auto parameters = std::unique_ptr<CStringList, StringListFinalizer>(new CStringList(nullptr, 0), finalizer<CStringList>);
        construct_string_list(std::array<std::string, 4>{std::string{"display"}, std::string{"Unknown Exception"}, fmt::format("Caught unknown exception: {}", parse_exception().what()), std::string{"red"}}, parameters.operator*());
        Shell::callback(parameters.get(), nullptr);
        return 1;
    }
    return 0;
}
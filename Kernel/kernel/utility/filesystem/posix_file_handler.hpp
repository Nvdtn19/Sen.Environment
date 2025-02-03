#pragma once

#include "kernel/utility/container/string/basic_string.hpp"
#include "kernel/utility/container/array/byte_array.hpp"
#include "kernel/utility/container/list/byte_list.hpp"
#include "kernel/utility/container/list/list.hpp"
#include "kernel/utility/container/string/common.hpp"

namespace Sen::Kernel::FileSystem {

    #if !WINDOWS

    namespace Detail {

        inline static auto constexpr $DEFAULT_OPEN = int{0644};

        inline static auto constexpr $O_WRONLY = O_WRONLY;

        inline static auto constexpr $O_CREAT = O_CREAT;

        inline static auto constexpr $O_TRUNC = O_TRUNC;

        inline static auto constexpr $O_RDONLY = O_RDONLY;

    }

    struct PosixFileReader;

    struct PosixFileWriter;

    struct PosixFileReader {

    protected:

        int fd{-1};

    public:
        explicit PosixFileReader(const String& path) {
            thiz.fd = open(path.cbegin(), Detail::$O_RDONLY);
            assert(thiz.fd != -1, fmt::format("{}: {}", Language::get("cannot_read_file"), path.view()), "PosixFileReader");
        }

        ~PosixFileReader() {
            if (thiz.fd != -1) {
                close(thiz.fd);
                thiz.fd = -1;
            }
        }

        PosixFileReader(
            const PosixFileReader& other
        ) = delete;

        auto operator=(
            const PosixFileReader& other
        ) -> PosixFileReader& = delete;

        PosixFileReader(
            PosixFileReader&& other
        ) noexcept : fd{other.fd} {
            other.fd = -1;
        }

        auto operator=(
            PosixFileReader&& other
        ) noexcept -> PosixFileReader& {
            if (this != &other) {
                if (thiz.fd != -1) {
                    close(thiz.fd);
                }
                thiz.fd = other.fd;
                other.fd = -1;
            }
            return *this;
        }

        template <typename T> requires std::is_base_of_v<BaseContainer<extract_container_t<T>>, T> && requires (T t) {
            { t.size() } -> std::convertible_to<usize>;
            { t.begin() } -> std::convertible_to<extract_container_t<T>*>;
        }
        void read(T& data) {
            auto bytes_read = ::read(fd, data.begin(), data.size());
            assert_conditional(bytes_read == static_cast<ssize_t>(data.size()), fmt::format("Missing bytes when read file, expected: {} but got: {}", data.size(), bytes_read), "read");
        }

        auto data(
        ) -> int& {
            return fd;
        }
    };

    struct PosixFileWriter {

    protected:
        int fd{-1};

    public:
        explicit PosixFileWriter(const String& path) {
            thiz.fd = open(path.cbegin(), Detail::$O_WRONLY | Detail::$O_CREAT | Detail::$O_TRUNC, Detail::$DEFAULT_OPEN);
            assert_conditional(thiz.fd != -1 , fmt::format("{}: {}", Language::get("write_file_error"), path.view()), "PosixFileWriter");
        }

        ~PosixFileWriter(
        ) {
            if (thiz.fd != -1) {
                close(thiz.fd);
                thiz.fd = -1;
            }
        }

        PosixFileWriter(
            const PosixFileWriter& other
        ) = delete;

        auto operator=(
            const PosixFileWriter& other
        ) -> PosixFileWriter& = delete;

        PosixFileWriter(
            PosixFileWriter&& other
        ) noexcept : fd{other.fd} {
            other.fd = -1;
        }

        auto operator=(
            PosixFileWriter&& other
        ) noexcept -> PosixFileWriter& {
            if (this != &other) {
                if (thiz.fd != -1) {
                    close(thiz.fd);
                }
                thiz.fd = other.fd;
                other.fd = -1;
            }
            return *this;
        }

        template <typename T> requires std::is_base_of_v<BaseContainer<extract_container_t<T>>, T> && requires (T t) {
            { t.size() } -> std::convertible_to<usize>;
            { t.begin() } -> std::convertible_to<extract_container_t<T>*>;
        }
        void write(T& data) {
            auto bytes_written = ::write(fd, data.begin(), data.size());
            assert_conditional(bytes_written == static_cast<ssize_t>(data.size()), fmt::format("Missing bytes when write file, expected: {} but got: {}", sizeof(u8) * data.size(), bytes_written), "write");
        }

        auto data(
        ) -> int& {
            return fd;
        }
    };


    #endif

}

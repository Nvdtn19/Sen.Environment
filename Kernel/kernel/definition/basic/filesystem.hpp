#pragma once 

#include "kernel/definition/library.hpp"
#include "kernel/definition/assert.hpp"
#include "kernel/definition/basic/string.hpp"
#include "kernel/definition/basic/path.hpp"

namespace Sen::Kernel::FileSystem
{

	template <typename T>
	concept CharacterBufferView = std::is_same_v<T, char> || std::is_same_v<T, unsigned char>;

	/**
	 * Lambda
	*/
	
	inline static auto constexpr close_file =  [](auto f){ 
		if (f) fclose(f); 
	};

	// give file path to open
	// return: the file data as string

	inline static auto read_file(
		std::string_view filepath
	) -> std::string 
	{
		#if WINDOWS
				auto file = std::unique_ptr<FILE, decltype(close_file)>(_wfopen(String::utf8_to_utf16(filepath.data()).c_str(), L"r"), close_file);
		#else
				auto file = std::unique_ptr<FILE, decltype(close_file)>(std::fopen(filepath.data(), "r"), close_file);
		#endif
		if (!file) {
			throw Exception(fmt::format("{}: {}", Language::get("cannot_read_file"), filepath), std::source_location::current(), "read_file");
		}
		std::fseek(file.get(), 0, SEEK_END);
		auto length = std::ftell(file.get());
		std::fseek(file.get(), 0, SEEK_SET);
		auto buffer = std::string(length, ' ');
		std::fread(buffer.data(), 1, length, file.get());
		return buffer;
	}

	// Provide file path to read json
	// return: if the json is valid, the json data will be parsed as object

	inline static auto read_json(
		std::string_view source
	) -> nlohmann::ordered_json const 
	{
		auto file = std::ifstream(source.data());
        if (!file.is_open()) {
			throw Exception(fmt::format("{}: {}", Language::get("cannot_read_file") ,source), std::source_location::current(), "read_json");
        }
        auto buffer = std::stringstream{};
        buffer << file.rdbuf();
		return nlohmann::ordered_json::parse(buffer.str());
	}

	// Provide file path to write
	// Provide json content to serialize & write
	// return: writed json content

	inline static auto write_json(
		std::string_view filepath,
		const nlohmann::ordered_json & content
	) -> void
	{
		#if WINDOWS
				auto file = std::unique_ptr<FILE, decltype(close_file)>(_wfopen(String::utf8_to_utf16(filepath.data()).c_str(), L"w"), close_file);
		#else
				auto file = std::unique_ptr<FILE, decltype(close_file)>(std::fopen(filepath.data(), "w"), close_file);
		#endif
		if (!file) {
			throw Exception(fmt::format("{}: {}", Language::get("write_file_error"), filepath), std::source_location::current(), "write_json");
		}
		auto dumped_content = content.dump(1, '\t');
		fwrite(dumped_content.data(), 1, dumped_content.size(), file.get());
		return;
	}

	// Provide file path to write
	// Provide json content to serialize & write
	// indent: provide indentation
	// indent_char: indentation in segment line
	// return: writed json content

	inline static auto write_json(
		std::string_view filepath,
		const nlohmann::ordered_json & content,
		int indent,
		char indent_char
	) -> void
	{
		#if WINDOWS
				auto file = std::unique_ptr<FILE, decltype(close_file)>(_wfopen(String::utf8_to_utf16(filepath.data()).c_str(), L"w"), close_file);
		#else
				auto file = std::unique_ptr<FILE, decltype(close_file)>(std::fopen(filepath.data(), "w"), close_file);
		#endif
		if (!file) {
			throw Exception(fmt::format("{}: {}", Language::get("write_file_error"), filepath), std::source_location::current(), "write_json");
		}
		auto dumped_content = content.dump(indent, indent_char);
		fwrite(dumped_content.data(), 1, dumped_content.size(), file.get());
		return;
	}

	// Provide file path to write
	// Provide json content to serialize & write
	// indent_char: indentation in segment line
	// return: writed json content

	inline static auto write_json(
		std::string_view filepath,
		const nlohmann::ordered_json & content,
		char indent_char
	) -> void
	{
		#if WINDOWS
				auto file = std::unique_ptr<FILE, decltype(close_file)>(_wfopen(String::utf8_to_utf16(filepath.data()).c_str(), L"w"), close_file);
		#else
				auto file = std::unique_ptr<FILE, decltype(close_file)>(std::fopen(filepath.data(), "w"), close_file);
		#endif
		if (!file) {
			throw Exception(fmt::format("{}: {}", Language::get("write_file_error"), filepath), std::source_location::current(), "write_json");
		}
		auto dumped_content = content.dump(1, indent_char);
		fwrite(dumped_content.data(), 1, dumped_content.size(), file.get());
		return;
	}

	// Provide file path to write
	// Provide json content to serialize & write
	// indent: provide indentation
	// indent_char: indentation in segment line
	// ensure ascii: will it ensure ascii?
	// return: writed json content

	inline static auto write_json(
		std::string_view filepath,
		const nlohmann::ordered_json &content,
		int indent,
		char indent_char,
		bool ensureAscii
	) -> void
	{
		#if WINDOWS
				auto file = std::unique_ptr<FILE, decltype(close_file)>(_wfopen(String::utf8_to_utf16(filepath.data()).c_str(), L"w"), close_file);
		#else
				auto file = std::unique_ptr<FILE, decltype(close_file)>(std::fopen(filepath.data(), "w"), close_file);
		#endif
		if (!file) {
			throw Exception(fmt::format("{}: {}", Language::get("cannot_read_file"), filepath), std::source_location::current(), "write_json");
		}
		auto dumped_content = content.dump(indent, indent_char, ensureAscii);
		fwrite(dumped_content.data(), 1, dumped_content.size(), file.get());
		return;
	}

	// file path: the file uses utf16le encoding
	// return: the utf16le string

	inline static auto read_file_by_utf16(
		std::string_view source
	) -> std::wstring
	{
		auto wif = std::wifstream(std::wstring{ source.begin(), source.end()});
		wif.imbue(std::locale(std::locale::empty(), new std::codecvt_utf16<wchar_t, 0x10ffff, std::consume_header>));
		auto content = std::wstring((std::istreambuf_iterator<wchar_t>(wif)), std::istreambuf_iterator<wchar_t>());
		return content;
	}

	// filePath: the file path to write
	// data: utf16-le charset
	// return: the data has been written

	inline static auto write_file_by_utf16le(
		std::string_view source,
		const std::wstring & data
	) -> void
	{
		auto utf16le_locale = std::locale(std::locale::classic(), new std::codecvt_utf16<wchar_t, 0x10ffff,
			(std::codecvt_mode)(std::little_endian | std::generate_header)>);
		auto file = std::wofstream(source.data(), std::ios::binary);
		file.imbue(utf16le_locale);
		file << data;
		file.close();
		return;
	}

	// file system

	namespace fs = std::filesystem;

	// directoryPath: folder path
	// return: create directory

	inline static auto create_directory(
		std::string_view path
	) -> void
	{
		if(fs::is_directory(path)){
			return;
		}
		auto status = fs::create_directories(path);
		return;
	}



	// path: file path to open
	// content: content to write
	// return: the file has been written

	inline static auto write_file(
		std::string_view filepath,
		std::string_view content
	) -> void
	{
		auto temporary = Path::toPosixStyle(filepath.data());
		auto data = String::split(temporary, "/"_sv);
		data.erase(data.end() - 1, data.end());
		auto c = String::join(data, "/"_sv);
		create_directory(c);
		#if WINDOWS
		auto file = std::unique_ptr<FILE, decltype(close_file)>(_wfopen(String::utf8_to_utf16(filepath.data()).c_str(), L"w"), close_file);
		#else
		auto file = std::unique_ptr<FILE, decltype(close_file)>(std::fopen(filepath.data(), "w"), close_file);
		#endif
		if (!file) {
			throw Exception(fmt::format("{}: {}", Language::get("cannot_write_file"), filepath), std::source_location::current(), "write_file");
		}
		std::fwrite(content.data(), 1, content.size(), file.get());
		return;
	}

	// filePath: the file path to write file
	// content: content to write
	// return: the file has been written

	inline static auto out_file(
		std::string_view filePath,
		std::string_view content
	) -> void
	{
		auto temporary = Path::normalize(filePath.data());
		auto data = String::split(temporary, "/"_sv);
		auto& last = data.at(data.size() - 1);
		data.pop_back();
		create_directory(String::join(data, "/"_sv));
		write_file(filePath, content);
		return;
	}

	// filePath: the file path to write file
	// content: json object
	// return: the file has been written to json

	inline static auto out_json(
		const std::string &filePath,
		const nlohmann::ordered_json &content
	) -> void
	{
		out_file(filePath, content.dump(1, '\t'));
		return;
	}

	
	template <typename T> requires CharacterBufferView<T> 
	inline static auto read_binary(
		std::string_view filepath
	) -> std::vector<T> const
	{
		auto file = std::ifstream(filepath.data(), std::ios::binary);
		if(!file)
		{
			throw Exception(fmt::format("{}: {}", Language::get("cannot_read_file"), filepath), std::source_location::current(), "read_binary");
		}
		file.seekg(0, std::ios::end);
		auto size = static_cast<std::streamsize>(file.tellg());
		file.seekg(0, std::ios::beg);
		auto data = std::vector<T>(size);
		if (!file.read(reinterpret_cast<char*>(data.data()), size))
		{
			throw Exception(fmt::format("{}: {}", Language::get("cannot_read_file") ,filepath), std::source_location::current(), "read_binary");
		}
		file.close();
		return data;	
	}

	// dirPath: directory to read
	// return: everything inside it even directory or file

	inline static auto read_directory(
		std::string_view directory_path
	) -> std::vector<std::string> const
	{
		auto result = std::vector<std::string>{};
		#if WINDOWS
			for (auto& c : fs::directory_iterator(String::utf8_to_utf16(directory_path.data())))
		#else
			for (auto& c : fs::directory_iterator(directory_path))
		#endif
		{
			#if WINDOWS
				result.emplace_back(Path::normalize(String::utf16_to_utf8(c.path().generic_wstring())));
			#else
				result.emplace_back(Path::normalize(c.path().generic_string()));
			#endif
		}
		return result;
	}

	// dirPath: directory to read
	// return: only files inside

	inline static auto read_directory_only_file(
		std::string_view directory_path
	) -> std::vector<string> const
	{
		auto result = std::vector<string>{};
		#if WINDOWS
				for (auto& c : fs::directory_iterator(String::utf8_to_utf16(directory_path.data())))
		#else
				for (auto& c : fs::directory_iterator(directory_path))
		#endif
		{
			if(c.is_regular_file()){
				#if WINDOWS
					result.emplace_back(Path::normalize(String::utf16_to_utf8(c.path().generic_wstring())));
				#else
					result.emplace_back(Path::normalize(c.path().generic_string()));
				#endif
			}
		}
		return result;
	}

	// dirPath: directory to read
	// return: only dirs inside

	inline static auto read_directory_only_directory(
		std::string_view directory_path
	) -> std::vector<std::string> const
	{
		auto result = std::vector<std::string>{};
		#if WINDOWS
				for (auto& c : fs::directory_iterator(String::utf8_to_utf16(directory_path.data())))
		#else
				for (auto& c : fs::directory_iterator(directory_path))
		#endif
		{
			if(c.is_directory()){
				#if WINDOWS
					result.emplace_back(Path::normalize(String::utf16_to_utf8(c.path().generic_wstring())));
				#else
					result.emplace_back(Path::normalize(c.path().generic_string()));
				#endif
			}
		}
		return result;
	}


	// dirPath: directory to read
	// return: only files inside nested directories

	inline static auto read_whole_directory(
		std::string_view directory_path
	) -> std::vector<std::string> const
	{
		auto result = std::vector<string>{};
		#if WINDOWS
				for (auto& c : fs::directory_iterator(String::utf8_to_utf16(directory_path.data())))
		#else
				for (auto& c : fs::directory_iterator(directory_path))
		#endif
		{
			if(c.is_directory()){
				#if WINDOWS
					for (auto& e : read_whole_directory(String::utf16_to_utf8(c.path().generic_wstring())))
				#else
					for (auto& e : read_whole_directory(c.path().generic_string()))
				#endif
				{
					result.emplace_back(Path::normalize(e));
				}
			}
			else{
				#if WINDOWS
					result.emplace_back(Path::normalize(String::utf16_to_utf8(c.path().generic_wstring())));
				#else
					result.emplace_back(Path::normalize(c.path().generic_string()));
				#endif
			}
		}
		return result;
	}

	/**
	 * outFile: the output file to write
	 * data: data to write
	 * return: the written file
	*/


	template <typename T> requires CharacterBufferView<T>
	inline static auto write_binary(
		std::string_view filepath,
		const std::vector<T> & data
	) -> void
	{
		#if WINDOWS
				auto file = std::unique_ptr<FILE, decltype(close_file)>(_wfopen(String::utf8_to_utf16(filepath.data()).c_str(), L"wb"), close_file);
		#else
				auto file = std::unique_ptr<FILE, decltype(close_file)>(std::fopen(filepath.data(), "wb"), close_file);
		#endif
		if(!file){
			throw Exception(fmt::format("{}: {}", Language::get("write_file_error"), filepath), std::source_location::current(), "write_binary");
		}
		std::fwrite(reinterpret_cast<const char *>(data.data()), sizeof(T), data.size(), file.get());
		return;
	}

	/**
	 * file path: the file path to read
	 * return: xml document
	*/

	inline static auto read_xml(
		std::string_view filePath
	) -> std::unique_ptr<tinyxml2::XMLDocument>
	{
		auto xml = std::unique_ptr<tinyxml2::XMLDocument>(new tinyxml2::XMLDocument{});
		auto data = FileSystem::read_file(filePath);
		auto eResult = xml->Parse(data.data(), data.size());
		assert_conditional(eResult == tinyxml2::XML_SUCCESS, fmt::format("XML Read error: {}", filePath), "read_xml");
		return xml;
	}

	/**
	 * file path: the file path to write
	 * xml document: the xml document
	 * notice: the function will delete the xml document after write
	 * return: xml dumped data
	*/

	inline static auto write_xml(
		std::string_view file_path,
		tinyxml2::XMLDocument* data
	) -> void
	{
		auto printer = tinyxml2::XMLPrinter{};
		data->Print(&printer);
		FileSystem::write_file(file_path, std::string{printer.CStr()});
		return;
	}

}
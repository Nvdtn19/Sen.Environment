#pragma once

namespace Sen::Kernel::Interface {

	/**
	 * Call back method
	*/

	enum CliCallBack
	{

		MD5_HASH,
		SHA224_HASH,
		SHA256_HASH,
		BASE64_ENCODE,
		BASE64_DECODE,
		ZLIB_COMPRESS,
		ZLIB_UNCOMPRESS,
		GZIP_COMPRESS,
		GZIP_UNCOMPRESS,
		RESOURCE_GROUP_SPLIT,
		RESOURCE_GROUP_MERGE,
		RES_INFO_SPLIT,
		RES_INFO_MERGE,
		RESOURCE_GROUP_TO_RES_INFO,
		RES_INFO_TO_RESOURCE_GROUP,
		TEXTURE_ENCODE,
		TEXTURE_DECODE,
	};

	/**
	 * Color picker
	*/

	enum Color {
		GREEN = 10,
		CYAN = 11,
		RED = 12,
		YELLOW = 14,
	};
	
}
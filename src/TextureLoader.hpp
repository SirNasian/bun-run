#pragma once

#include <map>
#include <string>

#include <GL/glew.h>
#include <stb/stb_image.h>

namespace bunrun
{
	class TextureLoader
	{
		public:
			static unsigned int load(const char* filepath);
		private:
			TextureLoader() = delete;
			TextureLoader(const TextureLoader&) = delete;
			TextureLoader& operator=(const TextureLoader&) = delete;
	};
}

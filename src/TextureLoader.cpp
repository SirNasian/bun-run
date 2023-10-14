#include "TextureLoader.hpp"

namespace bunrun
{
	unsigned int TextureLoader::load(const char* filepath)
	{
		static std::map<std::string, unsigned int> textures;

		std::string key(filepath);
		if (textures.count(filepath)) return textures[filepath];
		int width, height, channels;
		unsigned int texture;
		glGenTextures(1, &texture);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		textures[filepath] = texture;

		stbi_set_flip_vertically_on_load(true);
		unsigned char* data = stbi_load(filepath, &width, &height, &channels, 4);
		glBindTexture(GL_TEXTURE_2D, texture);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
		stbi_image_free(data);
		glGenerateMipmap(GL_TEXTURE_2D);

		return texture;
	}
}

#pragma once

#include <string>

#include "TextureLoader.hpp"
#include "Transformation.hpp"

namespace bunrun
{
	class Sprite
	{
		public:
			Transformation transform;
			Sprite(const char* filepath) : texture(TextureLoader::load(filepath)), transform(Transformation()) {};
			Sprite(const char* filepath, Transformation transform) : texture(TextureLoader::load(filepath)), transform(transform) {};
			unsigned int getTexture() { return this->texture; };
		private:
			unsigned int texture;
	};
}

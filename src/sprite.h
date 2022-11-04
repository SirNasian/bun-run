#pragma once

#include <string>

#include "renderable.h"
#include "texture-loader.h"

namespace
{
	TextureLoader *texture_loader = new TextureLoader();
};

class Sprite: public Renderable
{
	protected:
		unsigned int texture;
	public:
		Sprite() {};
		Sprite(const char *filepath) { load(filepath); };
		Sprite* load(const char *filepath) { this->texture = texture_loader->load(filepath); return this; };
		unsigned int getTexture() { return this->texture; };
};

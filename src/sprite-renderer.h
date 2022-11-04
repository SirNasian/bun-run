#pragma once

#include <glm/glm.hpp>

#include "renderer.h"
#include "sprite.h"

class SpriteRenderer: public Renderer<Sprite>
{
	protected:
		const char* getVertexShaderSource();
		const char* getFragmentShaderSource();
		void render(Sprite *sprite);
	public:
		SpriteRenderer();
		using Renderer::render;
};

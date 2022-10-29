#pragma once

#include <glm/glm.hpp>

#include "renderer.h"

class SpriteRenderer: public Renderer
{
	protected:
		const char* getVertexShaderSource();
		const char* getFragmentShaderSource();
		void render(float pos_x, float pos_y);
	public:
		SpriteRenderer();
		using Renderer::render;
};

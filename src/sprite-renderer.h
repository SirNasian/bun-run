#pragma once

#include <glm/glm.hpp>

#include "renderer.h"

class SpriteRenderer: public Renderer
{
	protected:
		const char* getVertexShaderSource();
		const char* getFragmentShaderSource();
		void render(float pos_x, float pos_y);
		void setViewMatrix(glm::mat4 view);
		void setProjectionMatrix(glm::mat4 projection);
	public:
		SpriteRenderer();
		using Renderer::render;
};

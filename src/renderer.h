#pragma once

#include <list>

#include <GL/glew.h>
#include <glm/glm.hpp>

#include "renderable.h"

class Renderer
{
	private:
		GLuint vao;
		GLuint shader;
		GLuint texture;
		std::list<Renderable*> renderables;
		virtual void render(float pos_x, float pos_y) {};
	public:
		Renderer();
		~Renderer();
		void render();
		void setViewMatrix(glm::mat4 view);
		void setProjectionMatrix(glm::mat4 projection);
		void addRenderable(Renderable *renderable);
};

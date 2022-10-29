#pragma once

#include <list>

#include <GL/glew.h>
#include <glm/glm.hpp>

#include "renderable.h"

class Renderer
{
	protected:
		GLuint vao;
		GLuint shader;
		GLuint texture;
		std::list<Renderable*> renderables;
		virtual const char* getVertexShaderSource() { return ""; };
		virtual const char* getFragmentShaderSource() { return ""; };
		virtual void render(float pos_x, float pos_y) {};
		virtual void setViewMatrix(glm::mat4 view) {};
		virtual void setProjectionMatrix(glm::mat4 projection) {};
		GLuint compileShader();
	public:
		void render();
		void addRenderable(Renderable *renderable);
		void removeRenderable(Renderable *renderable);
};

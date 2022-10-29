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
		GLint modelMatrixLocation, viewMatrixLocation, projectionMatrixLocation;
		std::list<Renderable*> renderables;
		virtual const char* getVertexShaderSource() { return ""; };
		virtual const char* getFragmentShaderSource() { return ""; };
		virtual void render(float pos_x, float pos_y) {};
		GLuint compileShader();
	public:
		void render(glm::mat4 view, glm::mat4 projection);
		void addRenderable(Renderable *renderable);
		void removeRenderable(Renderable *renderable);
};

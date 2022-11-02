#pragma once

#include <list>

#include <GL/glew.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "renderable.h"

template <typename T1>
class Renderer
{
	protected:
		GLuint vao;
		GLuint shader;
		GLuint texture;
		GLint modelMatrixLocation, viewMatrixLocation, projectionMatrixLocation;
		std::list<T1*> renderables;

		virtual const char* getVertexShaderSource() { return ""; };
		virtual const char* getFragmentShaderSource() { return ""; };
		virtual void render(float pos_x, float pos_y) {};

		GLuint compileShader()
		{
			GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
			const char *vertexSource = this->getVertexShaderSource();
			glShaderSource(vertexShader, 1, &vertexSource, NULL);
			glCompileShader(vertexShader);

			GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
			const char *fragmentSource = this->getFragmentShaderSource();
			glShaderSource(fragmentShader, 1, &fragmentSource, NULL);
			glCompileShader(fragmentShader);

			GLuint shaderProgram = glCreateProgram();
			glAttachShader(shaderProgram, vertexShader);
			glAttachShader(shaderProgram, fragmentShader);
			glLinkProgram(shaderProgram);

			return shaderProgram;
		}

	public:
		void render(glm::mat4 view, glm::mat4 projection)
		{
			glBindVertexArray(this->vao);
			glUseProgram(this->shader);
			glBindTexture(GL_TEXTURE_2D, this->texture);
			glUniformMatrix4fv(this->viewMatrixLocation, 1, GL_FALSE, glm::value_ptr(view));
			glUniformMatrix4fv(this->projectionMatrixLocation, 1, GL_FALSE, glm::value_ptr(projection));
			for (Renderable* renderable: this->renderables)
				this->render(renderable->getPosX(), renderable->getPosY());
		}

		void addRenderable(Renderable *renderable)
		{
			this->renderables.push_back(renderable);
		}

		void removeRenderable(Renderable *renderable)
		{
			this->renderables.remove(renderable);
		}
		template <typename T2> T2* createRenderable()
		{
			T2 *renderable = new T2();
			this->renderables.push_back(renderable);
			return renderable;
		}
};

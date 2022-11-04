#pragma once

#include <list>

#include <GL/glew.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "renderable.h"

template <typename T>
class Renderer
{
	protected:
		GLuint vao;
		GLuint shader;
		GLint modelMatrixLocation, viewMatrixLocation, projectionMatrixLocation;
		std::list<T*> renderables;

		virtual const char* getVertexShaderSource() { return ""; };
		virtual const char* getFragmentShaderSource() { return ""; };
		virtual void render(T *renderable) {};

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
			glUniformMatrix4fv(this->viewMatrixLocation, 1, GL_FALSE, glm::value_ptr(view));
			glUniformMatrix4fv(this->projectionMatrixLocation, 1, GL_FALSE, glm::value_ptr(projection));
			for (T *renderable: this->renderables)
				this->render(renderable);
		}

		void addRenderable(T *renderable)
		{
			this->renderables.push_back(renderable);
		}

		void removeRenderable(T *renderable)
		{
			this->renderables.remove(renderable);
		}

		T* createRenderable()
		{
			T *renderable = new T();
			this->renderables.push_back(renderable);
			return renderable;
		}
};

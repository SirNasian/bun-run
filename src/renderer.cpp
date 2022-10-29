#include "renderer.h"

#include <list>

#include <GL/glew.h>

#include "renderable.h"

GLuint Renderer::compileShader()
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

void Renderer::render()
{
	glBindVertexArray(this->vao);
	glUseProgram(this->shader);
	glBindTexture(GL_TEXTURE_2D, this->texture);
	for (Renderable* renderable: this->renderables)
		this->render(renderable->getPosX(), renderable->getPosY());
}

void Renderer::addRenderable(Renderable *renderable)
{
	this->renderables.push_back(renderable);
}

void Renderer::removeRenderable(Renderable *renderable)
{
	this->renderables.remove(renderable);
}

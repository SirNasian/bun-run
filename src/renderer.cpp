#include "renderer.h"

#include <list>

#include <GL/glew.h>

#include "renderable.h"

Renderer::Renderer()
{
	// TODO: set up vao, shader, and texture
}

Renderer::~Renderer()
{
	// TODO: clean up vao, shader, and texture
}

void Renderer::render()
{
	glBindVertexArray(this->vao);
	glUseProgram(this->shader);
	glBindTexture(GL_TEXTURE_2D, this->texture);
	for (Renderable* renderable: this->renderables)
		this->render(renderable->getPosX(), renderable->getPosY());
}

void Renderer::setViewMatrix(glm::mat4 view)
{
	// TODO: implement this
}

void Renderer::setProjectionMatrix(glm::mat4 projection)
{
	// TODO: implement this
}

void Renderer::addRenderable(Renderable *renderable)
{
	this->renderables.push_back(renderable);
}

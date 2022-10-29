#include "renderer.h"

#include <list>

#include <GL/glew.h>

#include "renderable.h"

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

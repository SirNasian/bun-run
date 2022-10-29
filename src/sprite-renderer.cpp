#include "sprite-renderer.h"

#include <GL/glew.h>

SpriteRenderer::SpriteRenderer()
{
	// Compile Shader
	this->shader = this->compileShader();
	this->texture = 0;

	// Generate VAO
	glGenVertexArrays(1, &(this->vao));
	glBindVertexArray(this->vao);

	// Generate VBO (data)
	float vertices[] = {
		-0.5f,  0.5f,
		 0.5f,  0.5f,
		 0.5f, -0.5f,
		-0.5f, -0.5f,
	};

	// Generate VBO (state)
	GLuint vbo;
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

	// Generate EBO (data)
	unsigned int indices[] = {
		0, 1, 2,
		2, 3, 0,
	};

	// Generate EBO (state)
	GLuint ebo;
	glGenBuffers(1, &ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

	// Set Array Attribute `position`
	GLint positionAttribute = glGetAttribLocation(this->shader, "position");
	glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(positionAttribute);

	// Unbind State
	glBindVertexArray(0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

const char* SpriteRenderer::getVertexShaderSource()
{
	return R"glsl(
		#version 150 core
		in vec2 position;
		void main()
		{
			gl_Position = vec4(position, 0.0, 1.0);
		}
	)glsl";
}

const char* SpriteRenderer::getFragmentShaderSource()
{
	return R"glsl(
		#version 150 core

		out vec4 fragColour;

		void main()
		{
			fragColour = vec4(1.0, 0.0, 0.0, 1.0);
		}
	)glsl";
}

void SpriteRenderer::render(float pos_x, float pos_y)
{
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}

void SpriteRenderer::setViewMatrix(glm::mat4 view)
{
	// TODO: implement this
}

void SpriteRenderer::setProjectionMatrix(glm::mat4 projection)
{
	// TODO: implement this
}

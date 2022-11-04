#include "sprite-renderer.h"

#include <GL/glew.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

SpriteRenderer::SpriteRenderer()
{
	// Compile Shader
	this->shader = this->compileShader();
	this->modelMatrixLocation = glGetUniformLocation(this->shader, "modelMatrix");
	this->viewMatrixLocation = glGetUniformLocation(this->shader, "viewMatrix");
	this->projectionMatrixLocation = glGetUniformLocation(this->shader, "projectionMatrix");
	this->texture = 0;

	// Generate VAO
	glGenVertexArrays(1, &(this->vao));
	glBindVertexArray(this->vao);

	// Generate VBO (data)
	float vertices[] = {
		-0.5f, -0.5f,
		-0.5f,  0.5f,
		 0.5f, -0.5f,
		 0.5f,  0.5f,
	};

	// Generate VBO (state)
	GLuint vbo;
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

	// Generate EBO (data)
	unsigned int indices[] = {
		0, 1, 2, 3,
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
		uniform mat4 modelMatrix;
		uniform mat4 viewMatrix;
		uniform mat4 projectionMatrix;
		void main()
		{
			gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 0.0, 1.0);
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
	glm::mat4 model = glm::translate(glm::mat4(1.0f), glm::vec3(pos_x, pos_y, 0.0f));
	glUniformMatrix4fv(this->modelMatrixLocation, 1, GL_FALSE, glm::value_ptr(model));
	glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0);
}

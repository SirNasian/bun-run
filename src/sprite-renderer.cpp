#include "sprite-renderer.h"

#include <GL/glew.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

SpriteRenderer::SpriteRenderer()
{
	// Compile Shader
	this->shader = this->compileShader();
	this->modelMatrixLocation = glGetUniformLocation(this->shader, "v_model_matrix");
	this->viewMatrixLocation = glGetUniformLocation(this->shader, "v_view_matrix");
	this->projectionMatrixLocation = glGetUniformLocation(this->shader, "v_projection_matrix");
	this->texture = 0;

	// Set Default Uniforms
	glUseProgram(this->shader);
	glUniform4f(glGetUniformLocation(this->shader, "f_colour"), 1.0f, 1.0f, 1.0f, 1.0f);
	glUseProgram(0);

	// Generate VAO
	glGenVertexArrays(1, &(this->vao));
	glBindVertexArray(this->vao);

	// Generate VBO (data)
	float vertices[] = {
		-0.5f, -0.5f,  0.0f, 0.0f,
		-0.5f,  0.5f,  0.0f, 1.0f,
		 0.5f, -0.5f,  1.0f, 0.0f,
		 0.5f,  0.5f,  1.0f, 1.0f,
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
	int position = glGetAttribLocation(this->shader, "v_position");
	glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (void*)(0*sizeof(float)));
	glEnableVertexAttribArray(position);

	// Set Array Attribute `texture_coordinate`
	int texture_coordinate = glGetAttribLocation(this->shader, "v_texture_coordinate");
	glVertexAttribPointer(texture_coordinate, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (void*)(2*sizeof(float)));
	glEnableVertexAttribArray(texture_coordinate);

	// Unbind State
	glBindVertexArray(0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

const char* SpriteRenderer::getVertexShaderSource()
{
	return R"glsl(
		#version 330 core
		in vec2 v_position;
		in vec2 v_texture_coordinate;
		out vec2 f_texture_coordinate;
		uniform mat4 v_model_matrix;
		uniform mat4 v_view_matrix;
		uniform mat4 v_projection_matrix;
		void main()
		{
			f_texture_coordinate = v_texture_coordinate;
			gl_Position = v_projection_matrix * v_view_matrix * v_model_matrix * vec4(v_position, 0.0, 1.0);
		}
	)glsl";
}

const char* SpriteRenderer::getFragmentShaderSource()
{
	return R"glsl(
		#version 330 core
		in vec2 f_texture_coordinate;
		out vec4 colour;
		uniform sampler2D f_texture;
		uniform vec4 f_colour;
		void main()
		{
			colour = texture(f_texture, f_texture_coordinate) * f_colour;
		}
	)glsl";
}

void SpriteRenderer::render(float pos_x, float pos_y)
{
	glm::mat4 model = glm::translate(glm::mat4(1.0f), glm::vec3(pos_x, pos_y, 0.0f));
	glUniformMatrix4fv(this->modelMatrixLocation, 1, GL_FALSE, glm::value_ptr(model));
	glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0);
}

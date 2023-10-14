#include "SpriteRenderer.hpp"

const char* vertex_shader_source = R"glsl(
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

const char* fragment_shader_source = R"glsl(
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

namespace bunrun
{
	SpriteRenderer::SpriteRenderer()
	{
		// Compile Shader
		this->shader = ShaderProgram::compile(vertex_shader_source, fragment_shader_source);
		this->modelMatrixLocation = glGetUniformLocation(this->shader, "v_model_matrix");
		this->viewMatrixLocation = glGetUniformLocation(this->shader, "v_view_matrix");
		this->projectionMatrixLocation = glGetUniformLocation(this->shader, "v_projection_matrix");

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
		unsigned int indices[] = { 0, 1, 2, 3 };

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

	void SpriteRenderer::render(Sprite& sprite)
	{
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, sprite.getTexture());
		glUniform1i(glGetUniformLocation(this->shader, "f_texture"), 0);
		glUniformMatrix4fv(this->modelMatrixLocation, 1, GL_FALSE, glm::value_ptr(sprite.transform.getMatrix()));
		glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, 0);
	}


	void SpriteRenderer::setProjectionMatrix(glm::mat4& matrix)
	{
		glBindVertexArray(this->vao);
		glUseProgram(this->shader);
		glUniformMatrix4fv(this->projectionMatrixLocation, 1, GL_FALSE, glm::value_ptr(matrix));
	}

	void SpriteRenderer::setViewMatrix(glm::mat4& matrix)
	{
		glBindVertexArray(this->vao);
		glUseProgram(this->shader);
		glUniformMatrix4fv(this->viewMatrixLocation, 1, GL_FALSE, glm::value_ptr(matrix));
	}
}

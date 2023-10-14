#pragma once

#include <GL/glew.h>

namespace bunrun
{
	class ShaderProgram
	{
		public:
			static GLuint compile(const char* vertex_shader_source, const char* fragment_shader_source)
			{
				// TODO: error handling
				GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER);
				glShaderSource(vertex_shader, 1, &vertex_shader_source, NULL);
				glCompileShader(vertex_shader);

				// TODO: error handling
				GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER);
				glShaderSource(fragment_shader, 1, &fragment_shader_source, NULL);
				glCompileShader(fragment_shader);

				// TODO: error handling
				GLuint shader = glCreateProgram();
				glAttachShader(shader, vertex_shader);
				glAttachShader(shader, fragment_shader);
				glLinkProgram(shader);

				return shader;
			};
		private:
			ShaderProgram() = delete;
			ShaderProgram(ShaderProgram&) = delete;
			ShaderProgram& operator=(ShaderProgram&) = delete;
	};
}

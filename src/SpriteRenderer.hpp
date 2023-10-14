#pragma once

#include <GL/glew.h>
#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <list>

#include "Sprite.hpp"
#include "ShaderProgram.hpp"

namespace bunrun
{
	class SpriteRenderer
	{
		public:
			SpriteRenderer();
			void render(Sprite&);
			void setProjectionMatrix(glm::mat4&);
			void setViewMatrix(glm::mat4&);
		private:
			GLuint vao, shader;
			GLint modelMatrixLocation;
			GLint viewMatrixLocation;
			GLint projectionMatrixLocation;
	};
}

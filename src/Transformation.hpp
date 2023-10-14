#pragma once

#include <glm/gtc/matrix_transform.hpp>
#include <glm/mat4x4.hpp>
#include <glm/vec2.hpp>

namespace bunrun
{
	class Transformation
	{
		public:
			glm::vec2 position, scale;
			float rotation;

			Transformation() : position(glm::vec2(0.0f, 0.0f)), rotation(0.0f) {};
			Transformation(float x, float y, float sx = 1.0f, float sy = 1.0f, float rotation = 0.0f)
				: position(glm::vec2(x, y)), scale(glm::vec2(sx, sy)), rotation(rotation) {};

			glm::mat4 getMatrix()
			{
				glm::mat4 matrix(1.0f);
				matrix = glm::translate(matrix, glm::vec3(this->position, 1.0f));
				matrix = glm::rotate(matrix, glm::radians(this->rotation), glm::vec3(0.0f, 0.0f, 1.0f));
				matrix = glm::scale(matrix, glm::vec3(this->scale, 1.0f));
				return matrix;
			}
	};
}

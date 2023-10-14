#pragma once

#include <glm/gtc/matrix_transform.hpp>
#include <glm/mat4x4.hpp>
#include <glm/vec2.hpp>

namespace bunrun
{
	class Transformation
	{
		public:
			glm::vec2 position;
			float rotation;

			Transformation() : position(glm::vec2(0.0f, 0.0f)), rotation(0.0f) {};
			Transformation(float x, float y, float rotation = 0.0f) : position(glm::vec2(x, y)), rotation(rotation) {};

			glm::mat4 getMatrix()
			{
				glm::mat4 matrix(1.0f);
				matrix = glm::translate(matrix, glm::vec3(position, 1.0f));
				matrix = glm::rotate(matrix, glm::radians(rotation), glm::vec3(0.0f, 0.0f, 1.0f));
				return matrix;
			}
	};
}

#include <exception>
#include <iostream>
#include <stdexcept>
#include <string>

#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include "Sprite.hpp"
#include "SpriteRenderer.hpp"
#include "Transformation.hpp"

#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>

GLFWwindow* setupContext()
{
	if (!glfwInit()) throw std::runtime_error("GLFW failed to initialise");

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
	glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

	GLFWwindow* window = glfwCreateWindow(640, 480, "Bun Run!", NULL, NULL);
	if (!window) throw std::runtime_error("Failed to create window");
	glfwMakeContextCurrent(window);

	GLenum glew_error = glewInit();
	if (glew_error != GLEW_OK)
	{
		char message[1024];
		std::sprintf(message, "GLEW failed to initialise: %s", glewGetErrorString(glew_error));
		throw std::runtime_error("GLEW failed to initialise (\"%s\")");
	}

	return window;
}

int main()
{
	try
	{
		GLFWwindow* window = setupContext();

		std::list<bunrun::Sprite> sprites;
		sprites.push_back(bunrun::Sprite("image2.png", bunrun::Transformation(1.0f, 1.0f)));
		sprites.push_back(bunrun::Sprite("image3.png", bunrun::Transformation(3.0f, 2.0f)));
		bunrun::Sprite cursor_sprite("image.png", bunrun::Transformation(0.0f, 0.0f, 45.0f));

		glm::mat4 projection = glm::ortho(0.0f, 20.0f, 0.0f, 15.0f, 0.0f, 10.0f);
		glm::mat4 view = glm::lookAt(
			glm::vec3(0.0f, 0.0f, 1.0f),
			glm::vec3(0.0f, 0.0f, 0.0f),
			glm::vec3(0.0f, 1.0f, 0.0f)
		);

		bunrun::SpriteRenderer renderer;
		renderer.setProjectionMatrix(projection);
		renderer.setViewMatrix(view);

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
		double lastRun = glfwGetTime();
		double currRun = lastRun;
		while (!glfwWindowShouldClose(window))
		{
			glClear(GL_COLOR_BUFFER_BIT);

			double pos_x, pos_y;
			glfwGetCursorPos(window, &pos_x, &pos_y);
			cursor_sprite.transform.position.x = ((pos_x / 640.0f) * 20.0f);
			cursor_sprite.transform.position.y = ((pos_y / 480.0f) * 15.0f * -1) + 15.0f;

			renderer.render(cursor_sprite);
			for (bunrun::Sprite& sprite : sprites)
				renderer.render(sprite);

			glfwSwapBuffers(window);
			glfwPollEvents();

			currRun = glfwGetTime();
			std::cout << 1.0f/(currRun-lastRun) << std::endl;
			lastRun = glfwGetTime();
		}
	}
	catch (std::exception& e)
	{
		std::cerr << "ERROR: " << e.what() << std::endl;
		glfwTerminate();
		return -1;
	}
}

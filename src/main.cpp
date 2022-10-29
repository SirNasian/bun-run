#include <iostream>

#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include "renderable.h"
#include "sprite-renderer.h"

int main()
{
	GLFWwindow *window;

	if (!glfwInit())
		return -1;

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
	glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

	window = glfwCreateWindow(640, 640, "Bun Run!", NULL, NULL);
	if (!window)
	{
		glfwTerminate();
		return -1;
	}

	glfwMakeContextCurrent(window);

	GLenum glew_error = glewInit();
	if (glew_error != GLEW_OK)
	{
		fprintf(stderr, "GLEW Init Error: %s\n", glewGetErrorString(glew_error));
		glfwTerminate();
		return -1;
	}

	SpriteRenderer renderer;
	renderer.addRenderable(new Renderable());

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
	while (!glfwWindowShouldClose(window))
	{
		glClear(GL_COLOR_BUFFER_BIT);

		renderer.render();

		glfwSwapBuffers(window);
		glfwPollEvents();
	}

	glfwTerminate();
	return 0;
}

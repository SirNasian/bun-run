project(bun-run)

add_executable(bun-run
	src/main.cpp
	src/SpriteRenderer.cpp
	src/TextureLoader.cpp
)

target_link_libraries(bun-run
	GL
	GLEW
	glfw
)

project(bun-run)
add_executable(bun-run src/main.cpp src/renderable.cpp src/renderer.cpp)
target_link_libraries(bun-run GL GLEW glfw)

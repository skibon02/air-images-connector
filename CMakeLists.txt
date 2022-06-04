cmake_minimum_required(VERSION 3.0.0)
project(images-connector VERSION 0.1.0)

string(APPEND CMAKE_CUDA_FLAGS "-cudart=shared -lcudadevrt -gencode arch=compute_86,code=sm_86 -std=c++17")


set(CMAKE_CUDA_COMPILER "/usr/local/cuda-11.6/bin/nvcc")

find_package(OpenCV 4.5.5 EXACT)
find_package(CUDA 11.6 EXACT)

enable_language(CUDA)




cuda_add_executable(images-connector main.cu)
target_include_directories(
        images-connector
        PUBLIC

        ${OpenCV_INCLUDE_DIRS}
        ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
        # ${PostgreSQL_INCLUDE_DIRS}
)
target_link_libraries(
        images-connector

        opencv_core
        opencv_imgproc
        opencv_video
        opencv_videoio
        opencv_highgui
        # nvinfer
        # nvinfer_plugin
        # nlohmann_json::nlohmann_json
        # ${PostgreSQL_LIBRARIES}
)
set_target_properties(images-connector PROPERTIES CUDA_ARCHITECTURES "compute_86,code=sm_86")

file(COPY images DESTINATION ${CMAKE_CURRENT_BINARY_DIR})


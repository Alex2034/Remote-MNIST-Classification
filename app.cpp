#include <iostream>

#include <iostream>
#include <memory>

#include <torch/script.h>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;

// Function to display an image using OpenCV
void displayImage(Mat img)
{
    namedWindow("Display window", CV_WINDOW_AUTOSIZE); // Create a window for display.
    imshow("Display window", img);
    waitKey(0);
}


int main(int argc, const char* argv[]) {
    //std::cout << "OpenCV version : " << CV_VERSION << std::endl;
    Mat inputImage;
    inputImage = imread("../MNISTsamples/img_63.jpg", CV_LOAD_IMAGE_GRAYSCALE); // Load the image in grayscale.
    displayImage(inputImage);

    // Deserialize the ScriptModule from a file using torch::jit::load().
    std::shared_ptr<torch::jit::script::Module> torchModule = torch::jit::load("../model_trace.pt");

    std::vector<int64_t> sizes = {1, 1, inputImage.rows, inputImage.cols};
    at::TensorOptions options(at::ScalarType::Byte);
    at::Tensor tensorImage = torch::from_blob(inputImage.data, at::IntList(sizes), options);
    tensorImage = tensorImage.toType(at::kFloat);
    at::Tensor result = torchModule->forward({tensorImage}).toTensor();

    auto maxResult = result.max(1, true);
    auto maxIndex = std::get<1>(maxResult).item<float>();
    std::cout << maxIndex << std::endl;
}

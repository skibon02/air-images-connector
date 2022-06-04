#include <opencv4/opencv2/opencv.hpp>
#include <chrono>
#include <iostream>

#include <vector>
#define GLM_FORCE_RADIANS
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>

using namespace cv;
using namespace std;
using namespace chrono;

const float RATIO = 6.0/4.0;

struct Point{
    float x;
    float y;
};

struct PhotoCamera {
    Mat img;
    Mat img_warped;
    float RASKOLBAS = 14.4298679;

    glm::vec3 pos;
    std::vector<float> angles;
    std::vector<float> angles_offs;

    std::vector<glm::vec3> axis;
    glm::vec3 dirLine;
    std::vector<glm::vec3> dirRays;
    float perc;
    std::vector<glm::vec3> dots;

    string filename;

    PhotoCamera(glm::vec3 pos, std::vector<float> angles, string filename) : angles_offs(std::vector<float>(3)) {
        img = imread(filename);
        angles_offs = {-1.2, -2.4, 0};
        // angles_offs = {-2, -6, 1}; 
        this->perc = 1;
        this->angles = angles;
        this->pos = pos;    
        this->filename = filename;

        axis.resize(3);
        dirRays.resize(4);
        dots.resize(4);
        
        Update();
    }

    void Update() {
        angles[0] = 0;
        angles[1] = 0; 

        axis[0] = glm::vec3(1.0f, 0.0f, 0.0f);
        axis[1] = glm::vec3(0.0f, 1.0f, 0.0f);
        axis[2] = glm::vec3(0.0f, 0.0f, 1.0f);

        //axis
        //0 - по направлению
        //1 - вверх
        //2 - вправо
        auto mat_rot = glm::rotate(glm::mat4(1.0f), glm::radians(-angles[2] - angles_offs[2]), axis[1]);
        auto mat_rot3 = glm::mat3(mat_rot);
        axis[0] = mat_rot3 * axis[0];
        axis[2] = mat_rot3 * axis[2];

        mat_rot = glm::rotate(glm::mat4(1.0f), glm::radians(angles[1] + angles_offs[1]), axis[2]);
        mat_rot3 = glm::mat3(mat_rot);
        axis[0] = mat_rot3 * axis[0];
        axis[1] = mat_rot3 * axis[1];

        mat_rot = glm::rotate(glm::mat4(1.0f), glm::radians(-angles[0] - angles_offs[0]), axis[0]);
        mat_rot3 = glm::mat3(mat_rot);
        axis[2] = mat_rot3 * axis[2];
        axis[1] = mat_rot3 * axis[1];


        dirLine = axis[1] * -3.0f;

        dirRays[0] = glm::mat3(glm::rotate(glm::rotate(glm::mat4(1.0f), glm::radians(RASKOLBAS), axis[2]), glm::radians(RASKOLBAS*RATIO), axis[0]))*dirLine * 500.0f;
        dirRays[1] = glm::mat3(glm::rotate(glm::rotate(glm::mat4(1.0f), glm::radians(RASKOLBAS), axis[2]), glm::radians(-RASKOLBAS*RATIO), axis[0]))*dirLine * 500.0f;
        dirRays[2] = glm::mat3(glm::rotate(glm::rotate(glm::mat4(1.0f), glm::radians(-RASKOLBAS), axis[2]), glm::radians(-RASKOLBAS*RATIO), axis[0]))*dirLine * 500.0f;
        dirRays[3] = glm::mat3(glm::rotate(glm::rotate(glm::mat4(1.0f), glm::radians(-RASKOLBAS), axis[2]), glm::radians(RASKOLBAS*RATIO), axis[0]))*dirLine * 500.0f;

        for(int i = 0; i < 4; i++) {
            dots[i]  = glm::normalize(dirRays[i]);
            dots[i] = (-pos.y/dots[i].y)*dots[i]*perc + pos;
        }


        Point2f src_vertices[4];

        Point2f dst_vertices[4];
        for(int i = 0; i < 4; i++) {
            dst_vertices[i].y = dots[i].x + 800;
            dst_vertices[i].x = dots[i].z + 300;

        }
        src_vertices[0] = {0, 0};
        src_vertices[1] = {6000, 0};
        src_vertices[2] = {6000, 4000};
        src_vertices[3] = {0, 4000};
        auto dotsTransf = getPerspectiveTransform(src_vertices, dst_vertices, cv::INTER_LINEAR);

        warpPerspective(img, img_warped, dotsTransf, {900, 900});

        // imshow("img", img);
        // imshow("warped", img_warped);
        // waitKey(); 
    }


};

// __global__ void dothing(char* mem1, char* mem2) {
//     int i = threadIdx.x + blockIdx.x * 1024;
//     for(int j = 0; j < 1000; j++) {
//         mem1[i] = 0;
//         mem2[i] = 255;
//     }
// }
// #define THREADS_PER_BLOCK 1024
int main() {

    vector<PhotoCamera> photoCameras;

    const float COEF_X = 110480;
    const float COEF_Y = 55654;
    std::vector<std::vector<float>> angles = {
        {-05.45, -10.45, -179.58}, {-03.43, -09.27, -177.48}, {-05.87, -12.14, 178.23}, 

        {-10.10, -11.78, 177.98},
        {-06.85, -13.04, 179.90},
        {-09.62, -11.91, -179.39},
        {-10.52, -13.17, -178.86},
        {-06.78, -14.10, -176.86},
    {-06.77, -12.18, -177.51},
    {-06.05, -12.59, -177.49},
    {-07.16, -12.77, -177.74},
    {-07.15, -13.74, -179.07},
    {-06.11, -17.00, -175.62},
    {-08.74, -10.15, -179.42},
    {-07.65, -12.08, -178.54},
    {-05.98, -11.52, 178.64},
    {-06.56, -11.31, 178.03},
    {-05.70, -07.43, 175.38},
    {-04.92, -09.45, -179.05},
    {-07.67, -12.80, -178.61},
    {02.87, -00.38, -02.62}, {04.68, -02.56, -00.02}, {04.10, -01.98, -03.26}, {04.98, -02.82, -03.45}, {06.11, -04.27, -03.68}, 
    {07.08, -04.76, -04.11}, {06.15, -05.47, -02.01}, {06.10, -06.80, -04.98}, {05.06, -06.50, -05.33}, {06.19, -07.60, -08.18}, 
    {05.97, -05.20, -02.11}, {04.75, -04.47, 00.08}, {06.51, -09.35, -05.98}, {06.62, -08.23, 01.21}, {06.81, -07.84, 01.67},
    {04.79, -08.53, -00.83},
    };
    std::vector<::Point> gps_coords = {
        {59.84265850, 31.47160150}, {59.84228240, 31.47159460 }, {59.84190420, 31.47159500},
        
        {59.84153520, 31.47161250},
        {59.84115850, 31.47162660},
        {59.84078280, 31.47163910},	
        {59.84040940, 31.47162940},
        {59.84003730, 31.47161260},
        {59.83965250, 31.47160240},
        {59.83927620, 31.47159090},
        {59.83889160, 31.47158680},
        {59.83851880, 31.47160170},
        {59.83814570, 31.47159980},
        {59.83777020, 31.47160300},
        {59.83739830, 31.47161090},
        {59.83702240, 31.47162450},
        {59.83664390, 31.47161670},
        {59.83626190, 31.47162380},
        {59.83588520, 31.47160890},
        {59.83551610, 31.47160450},
        //25..40
        {59.83535810, 31.47351560}, {59.83572970, 31.47349250}, {59.83611240, 31.47347330}, {59.83649310, 31.47347010},
        {59.83687230, 31.47347420}, {59.83724990, 31.47347520}, {59.83763040, 31.47347290}, {59.83801190, 31.47347450}, 
        {59.83838830, 31.47347030}, {59.83876860, 31.47347330}, {59.83914780, 31.47347090}, {59.83952690, 31.47346510},
        {59.83990310, 31.47347460}, {59.84027640, 31.47347250}, {59.84065270, 31.47347150}, {59.84103100, 31.47347000},
    };
    std::vector<float> altitudes = {
        273.273, 272.246, 275.501, 
        273.532, 272.589, 271.905, 273.361, 270.790,
        276.101, 275.673, 274.732, 272.845, 273.273, 273.701, 273.532, 273.873, 273.189, 272.161, 272.845,274.473 ,272.333, 273.617,
        //25..40
        275.673, 276.101, 275.416, 277.044, 276.872, 276.272, 277.044, 276.272, 276.016,
        276.959, 273.445, 275.416, 274.045, 276.360, 276.016, 277.216,
    };
    ::Point fir_gps = gps_coords[0];
    int i = 0;
    int img_id = 5;

    Mat merged;
    for(auto& coord : gps_coords) {
        coord.x -= fir_gps.x;
        coord.y -= fir_gps.y;
        coord.x *= COEF_X;
        coord.y *= COEF_Y;


        auto cam_pos = glm::vec3(coord.x, altitudes[i], coord.y);

        PhotoCamera cam(cam_pos, angles[i], "images/" + to_string(img_id) + ".JPG");
        cout << cam.dots[0].x << " ";
        cout << cam.dots[1].x << " ";
        cout << cam.dots[2].x << " ";
        cout << cam.dots[3].x << " ";
        cout << endl;
        photoCameras.push_back(cam);

        if(merged.empty()) {
            merged = photoCameras[i].img_warped;
        }
        else {
            unsigned char* p_start = (unsigned char*)photoCameras[i].img_warped.datastart;
            unsigned char* mrg_start = (unsigned char*)merged.datastart;
            for(int j = 0; j < photoCameras[i].img_warped.cols * photoCameras[i].img_warped.rows; j++) {
                if(p_start[0] > 0 && p_start[1] > 0 && p_start[2] > 0) {
                    mrg_start[0] = p_start[0];
                    mrg_start[1] = p_start[1];
                    mrg_start[2] = p_start[2];
                }
                p_start += photoCameras[i].img_warped.elemSize();
                mrg_start += photoCameras[i].img_warped.elemSize();
            }
        }

        i++;
        img_id++;
    }
    imshow("merged", merged);
    waitKey();
    while(true) {
        bool isFirst = true;
        i = 0;
        for(auto &photoCam : photoCameras) {
            photoCam.Update();

            //merge
            if(isFirst) {
                merged = photoCameras[i].img_warped;
                isFirst = false;
            }
            else {
                unsigned char* p_start = (unsigned char*)photoCameras[i].img_warped.datastart;
                unsigned char* mrg_start = (unsigned char*)merged.datastart;
                for(int j = 0; j < photoCameras[i].img_warped.cols * photoCameras[i].img_warped.rows; j++) {
                    if(p_start[0] > 0 && p_start[1] > 0 && p_start[2] > 0) {
                        mrg_start[0] = p_start[0];
                        mrg_start[1] = p_start[1];
                        mrg_start[2] = p_start[2];
                    }
                    p_start += photoCameras[i].img_warped.elemSize();
                    mrg_start += photoCameras[i].img_warped.elemSize();
                }
            }
            i++;
        }

        imshow("merged", merged);
        auto c = waitKey();
        switch (c) {
            case 'o':
    
                for(auto &photoCam : photoCameras) {
                    photoCam.angles_offs[1]+=0.3;
                    cout << "pitch offs: " << photoCam.angles_offs[1] << endl;
                }
                break;
            case 'p':
    
                for(auto &photoCam : photoCameras) {
                    photoCam.angles_offs[1]-=0.3;
                    cout << "pitch offs: " << photoCam.angles_offs[1] << endl;
                }
    
                break;


        case 'u':

            for(auto &photoCam : photoCameras) {
                photoCam.angles_offs[0]+=0.3;
                cout << "roll offs: " << photoCam.angles_offs[0] << endl;
            }
            break;
        case 'i':

            for(auto &photoCam : photoCameras) {
                photoCam.angles_offs[0]-=0.3;
                cout << "roll offs: " << photoCam.angles_offs[0] << endl;
            }

            break;

        case 'k':

            for(auto &photoCam : photoCameras) {
                photoCam.angles_offs[2]+=0.3;
                cout << "yaw offs: " << photoCam.angles_offs[2] << endl;
            }
            break;
        case 'l':

            for(auto &photoCam : photoCameras) {
                photoCam.angles_offs[2]-=0.3;
                cout << "yaw offs: " << photoCam.angles_offs[2] << endl;
            }

        break;
        }
    }


    // Mat img1, img2;
    // img1 = imread("images/img1.jpg");
    // img2 = imread("images/img2.jpg");

    // void *cudaImg1, *cudaImg2;
    // int sz1 = img1.cols*img1.rows*img1.elemSize();
    // int sz2 = img2.cols*img2.rows*img2.elemSize();
    // cout << "size: " << sz1 << endl;
    // cudaMalloc((void**)&cudaImg1, sz1);
    // cudaMalloc((void**)&cudaImg2, sz2);

    // auto p1 = system_clock::now();
    // cudaMemcpy(cudaImg1, img1.datastart, sz1, cudaMemcpyHostToDevice);
    // cudaMemcpy(cudaImg2, img2.datastart, sz2, cudaMemcpyHostToDevice);

    // dothing<<<sz1/THREADS_PER_BLOCK,1024>>>((char*)cudaImg1, (char*)cudaImg2);

    // cudaMemcpy((void*)img1.datastart, cudaImg1, sz1, cudaMemcpyDeviceToHost);
    // cudaMemcpy((void*)img2.datastart, cudaImg2, sz2, cudaMemcpyDeviceToHost);
    // // char* img1data = (char*)img1.datastart;
    // // char* img2data = (char*)img2.datastart;
    // // for(int i = 0; i < sz1; i++) {
    // //     img1data[i] = 0;
    // //     img2data[i] = 255;
    // // }
    // auto p2 = system_clock::now();
    // cout << duration_cast<milliseconds>(p2-p1).count() << "ms" << endl;

    // // imshow("i1", img1);
    // // imshow("i2", img2);
    // // waitKey();


    // cudaFree(cudaImg1);
    // cudaFree(cudaImg2);


    return 0;
}
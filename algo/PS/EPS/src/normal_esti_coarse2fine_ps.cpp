//
//  normal_esti_coarse2fine_ps.cpp
//  pm_stereo
//
//  Created by KaiWu on Sep/9/16.
//  Copyright © 2016 KaiWu. All rights reserved.
//

#include "normal_esti_coarse2fine_ps.hpp"

// OV_tar_ind is not used
void esti_norm(MatrixXd &OV_tar, vector<MatrixXd> &OV_ref, VectorXi &OV_tar_ind, vector<VectorXi> &OV_ref_ind, Vector2i &size_tar, vector<Vector2i> &size_ref, vector<Vector2d, Eigen::aligned_allocator<Vector2d> > &center, vector<double> &radius, double* norm_map)
{
    const int N = 5; // level of sampling
    const int M = 6; // choose the best M centers
    const int num_img = static_cast<int>(OV_tar.cols()) / 3;
    const int num_ref = static_cast<int>(OV_ref.size());
    int num_samp[N] = {150, 500, 3000, 20000, 40000}; //80000 , static_cast<int>(OV_ref_spec.rows())
    double btwn_ang_last_iter[N] = {180, 10, 5, 3, 1}; // 0.5
    Vector3d view_dir(0.0, 0.0, 1.0), norm_opt(0.0, 0.0, 1.0);
    
    vector<MatrixXd> normal_samp(N);
    
    //string dir = "C:/Users/Admin/Documents/3D Recon/Data/WACV/obj1_9_25/";
    for (int i = 0; i < N; ++i)
    {
        normal_samp[i] = gen_normals(num_samp[i], view_dir, 180);
    }
    
    for (int i = 0; i < static_cast<int>(OV_tar.rows()); ++i)
    {
        // start of processing
        VectorXd ov_tar = OV_tar.row(i);
        
        vector<Vector3d> c(1);
        c[0] = norm_opt; // use the last estimated normal as the initial guess
        // c[0] << 0.0, 0.0, 1.0;
        vector<double> err_min(M);
        
        for (int j = 0; j < N; ++j)
        {
            int num_cen = static_cast<int>(c.size());
            vector<MatrixXd> normals(num_cen);
            
            for (int cc = 0; cc < num_cen; ++cc)
            {
                VectorXd cos_ang = normal_samp[j].transpose() * c[cc];
                cos_ang = cos_ang.array() - cos(btwn_ang_last_iter[j] * M_PI / 180.0);
                
                int num_norm = 0;
                size_t rows = normal_samp[j].rows(), cols = normal_samp[j].cols();
                normals[cc].resize(rows, cols);
                for (int k = 0; k < cols; ++k)
                    if(cos_ang(k) >= 0)
                        normals[cc].col(num_norm++) = normal_samp[j].col(k);
                normals[cc] = normals[cc].block(0, 0, rows, num_norm).eval();
//                cout << "sampled normals: " << endl << normals[cc] << endl;
                
                vector<double> err_per_norm(num_norm);
                
                for (int k = 0; k < num_norm; ++k)
                {
                    Vector2d normal = normals[cc].block(0, k, 2, 1);
                    // reason to flip n_x
                    // (y)                (x) <----------|
                    // ^                                 |
                    // |                =>               |
                    // |                                 |
                    // |--------> (x)                    v (y)
                    normal(0) = -normal(0);

                    //Vector2d u;
                    vector<double> u(2);
                    MatrixXd ov_ref(ov_tar.rows(), num_ref);
                    int ind, x, y;

                    for (int nf = 0; nf < num_ref; ++nf)
                    {
                        //u = center[nf] + normal * radius[nf];
                        u[0] = center[nf](0) + normal(0) * radius[nf];
                        u[1] = center[nf](1) + normal(1) * radius[nf];
                        x = floor(u[0] + 0.5);
                        y = floor(u[1] + 0.5);
                        // check if in the mask
                        double d2c = sqrt(pow((double)x - center[nf](0), 2.0) + pow((double)y - center[nf](1), 2.0));
                        // cout << "Inside of mask: " << d2c << endl;
                        if (d2c > radius[nf])
                        {
                            // cout << "Outside of mask: " << d2c << endl;
                            continue;
                        }
                        sub2ind(size_ref[nf], y, x, ind);
                        int ii = find_index(OV_ref_ind[nf], 0, OV_ref_ind[nf].rows() - 1, ind);
                        
                        if (ii == -1)
                            cout << "Error: Index " << ind << " not found" << endl;
                        if (OV_ref_ind[nf](ii) != ind)
                            cout << "Error: Index " << ind << " not consistent" << endl;

                        ov_ref.col(nf) = OV_ref[nf].row(ii).transpose();
                    }

                    vector<double> err(3);
                    VectorXd m;
                    for (int l = 0; l < 3; ++l)
                    {
                        // compute m
                        MatrixXd ov_ref_chan = ov_ref.block(0 + l * num_img, 0, num_img, 2);
                        VectorXd ov_tar_chan = ov_tar.block(0 + l * num_img, 0, num_img, 1);
                        
                        Eigen::NNLS<MatrixXd>::solve(ov_ref_chan, ov_tar_chan, m);
                        
                        err[l] = static_cast<double>((ov_tar_chan - ov_ref_chan * m).squaredNorm());
                    }
                    
                    err_per_norm[k] = err[0] + err[1] + err[2];
                }
                
                vector<size_t> err_ind = sort_indexes<double>(err_per_norm); // err_per_norm is not sorted
                if(j == 0) // first level of sampling, only 1 center
                {
                    c.resize(M);
                    for (int mm = 0; mm < M; ++mm)
                    {
                        c[mm] = normals[0].col(err_ind[mm]);
                        err_min[mm] = err_per_norm[err_ind[mm]];
                    }
                }
                else
                {
                    if(err_per_norm[err_ind[0]] < err_min[cc])
                    {
                        err_min[cc] = err_per_norm[err_ind[0]];
                        c[cc] = normals[cc].col(err_ind[0]);
                    }
                }
            }
        }
        vector<size_t> err_ind = sort_indexes(err_min);
        norm_opt = c[err_ind[0]];
        //cout << "estimated normal: " << norm_opt << endl;
        norm_opt(0) = -norm_opt(0);
        norm_map[3 * i + 0] = norm_opt(0);
        norm_map[3 * i + 1] = norm_opt(1);
        norm_map[3 * i + 2] = norm_opt(2);
        
        // drawing code
        //Mat img_tar, img_ref;
        //img_tar = imread(dir + "tar_11.png", CV_LOAD_IMAGE_COLOR);
        //img_ref = imread(dir + "ref_spec_37.png", CV_LOAD_IMAGE_COLOR);
        //// point in target image
        //int ind, x, y;
        //ind = OV_tar_ind(i);
        //ind2sub(size_tar, ind, y, x);
        //Point cen_tar = Point(x, y);
        //circle(img_tar, cen_tar, 5, Scalar(0, 0, 255));
        //// point in reference image
        //Vector2d u = center[1] + norm_opt.block(0, 0, 2, 1) * radius[1];
        //x = u(0) + 0.5;
        //y = u(1) + 0.5;
        //Point cen_ref = Point(x, y);
        //circle(img_ref, cen_ref, 5, Scalar(0, 0, 255));
        //// resize the image
        //resize(img_tar, img_tar, Size(), 0.8, 0.8);
        //resize(img_ref, img_ref, Size(), 0.8, 0.8);
        //// show image
        //namedWindow("Target object", WINDOW_AUTOSIZE );
        //imshow("Target object", img_tar);
        //namedWindow("Ref object", WINDOW_AUTOSIZE);
        //imshow("Ref object", img_ref);
        //cout.precision(std::numeric_limits< double >::max_digits10);
        //cout << "Time elapsed: " << (double)(clock() - start_t) / CLOCKS_PER_SEC << endl;
        //waitKey(100);
        //cout << "Time elapsed: " << (double)(clock() - start_t) / CLOCKS_PER_SEC << endl;
        loadbar(i, static_cast<unsigned int>(OV_tar.rows()));
    }
}

MatrixXd gen_normals(int num_samp, Vector3d &view_dir, double ang_span)
{
    int idx = 0;
    double fac = ang_span * M_PI / 180.0;
    MatrixXd normals(3, num_samp);
    
    for (int i = num_samp; i >= 0; --i)
    {
        double phi = acos(-1 + 2.0 * i / num_samp);
        double theta = sqrt(num_samp * M_PI) * phi;
        
        if (phi <= fac)
        {
            Vector3d normal;
            normal << sin(phi) * cos(theta),
                      sin(phi) * sin(theta),
                      cos(phi);
            
            if (normal.dot(view_dir) >= 0)
            {
                normals.col(idx) = normal;
                idx++;
            }
        }
        else
            break;
    }
    
    normals = normals.block(0, 0, 3, idx).eval();
    return normals;
}

// Use Matlab index
void ind2sub(Vector2i &imsize, int &ind, int &i, int &j)
{
    j = (ind - 1) / imsize(0) + 1;
    i = ind - (j - 1) * imsize(0);
}

void sub2ind(Vector2i &imsize, int &i, int &j, int &ind)
{
    ind = (j - 1) * imsize(0) + i;
}

int find_index(VectorXi &array, int start, int end, int key)
{
    if (start > end)
        return -1;

    int mid = start + (end - start) / 2;
    if (array(mid) > key)
        return find_index(array, start, mid - 1, key);

    if (array(mid) < key)
        return find_index(array, mid + 1, end, key);

    return mid;
}

int find_index(VectorXi &array, int key)
{
    int ind_ub = static_cast<int>(array.rows()) - 1;
    int ind_lb = 0;
    int ind = 0;
    while (1)
    {
        ind = ind_lb + (ind_ub - ind_lb) / 2;
        if(key == array(ind) || ind_lb  == ind_ub)
            break;
        
        if(array(ind) > key)
            ind_ub = ind - 1;
        else
            ind_lb = ind + 1;
    }
    return ind;
}

template <typename T>
T read_text(const char *fname)
{
    int m, n, end_of_line;
    std::fstream myfile(fname, std::ios_base::in);
    myfile >> m >> n;

    T M(m, n);
    int row = 0, col = 0;
    
    // solution 1
    while (row < m)
    {
        myfile >> M(row, col);
        col++;
        if(col == n)
        {
            row++;
            col = 0;
        }
    }
    
    // solution 2 (no improvement)
//    string line;
//    getline(myfile, line); // weird ""?
//    while(std::getline(myfile, line))
//    {
//        std::istringstream iss(line);
//        for (int i = 0; i < n; ++i)
//            iss >> M(row, col++);
//        iss >> end_of_line;
//        row++;
//        col = 0;
//    }
    
    return M;
}

void read_text(const char *fname, vector<Vector2i> &size_ref, vector<Vector2d, Eigen::aligned_allocator<Vector2d> > &center, vector<double> &radius, Vector2i &size_tar)
{
    std::fstream myfile(fname, std::ios_base::in);
    string label;

    while (!myfile.eof())
    {
        myfile >> label;
        if (label.compare("diff") == 0)
        {
            myfile >> size_ref[0](0) >> size_ref[0](1);
            myfile >> center[0](0) >> center[0](1);
            myfile >> radius[0];
        }
        else if (label.compare("spec") == 0)
        {
            myfile >> size_ref[1](0) >> size_ref[1](1);
            myfile >> center[1](0) >> center[1](1);
            myfile >> radius[1];
        }
        else if(label.compare("tar") == 0)
            myfile >> size_tar(0) >> size_tar(1);
    }
}

void write_text(const char *fname, double *fdata, const int num)
{
    std::fstream myfile(fname, std::ios_base::out);

    myfile << num << endl;

    int col = 0;
    while (col < num)
    {
        myfile << fdata[3 * col + 0] << " " << fdata[3 * col + 1] << " " << fdata[3 * col + 2] << endl;
        col++;
    }
}

// unused code
MatrixXd samp_norm(Vector3d &c, int num_samp, Vector3d &view_dir, double ang_span)
{
    int idx = 0;
    double fac = ang_span * M_PI / 180.0;
    MatrixXd normals(3, num_samp);
    Matrix3d R = rot_norm(view_dir, c);
    
    for (int i = num_samp; i >= 0; --i)
    {
        double phi = acos(-1 + 2.0 * i / num_samp);
        double theta = sqrt(num_samp * M_PI) * phi;
        
        if (phi <= fac)
        {
            Vector3d normal;
            normal << sin(phi) * cos(theta),
            sin(phi) * sin(theta),
            cos(phi);
            normal = R * normal;
            
            if (normal.dot(view_dir) >= 0)
            {
                normals.col(idx) = normal;
                idx++;
            }
        }
        else
            break;
    }
    
    normals = normals.block(0, 0, 3, idx).eval();
    return normals;
}

Matrix3d rot_norm(Vector3d &z, Vector3d &c)
{
    Vector3d rot_axis = z.cross(c);
    double rot_ang = acos(z.dot(c));
    
    return axisangle2rotmat(rot_axis, rot_ang);
}

Matrix3d axisangle2rotmat(Vector3d &axis, double &ang)
{
    double c = cos(ang);
    double s = sin(ang);
    double t = 1 - c;
    double x = axis(0);
    double y = axis(1);
    double z = axis(2);
    
    Matrix3d R;
    R << t * x * x + c,     t * x * y - z * s, t * x * z + y * s,
    t * x * y + z * s, t * y * y + c,     t * y * z - x * s,
    t * x * z - y * s, t * y * z + x * s, t * z * z + c;
    
    return R;
}

template MatrixXd read_text<MatrixXd>(const char *);
template VectorXi read_text<VectorXi>(const char *);
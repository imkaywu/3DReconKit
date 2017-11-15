## src

est_camera_params.py: estimate the camera intrinsic and extrinsic parameters (projection matrices)

est_camera_params.mat: MATLAB implementation, need to manualy input camera rotation and translation vectors, somehow didn't work

est_cam_proj_params.mat: estimate the camera and projector intrinsic parameters, camera's extrinsic parameter and camera to projector transformations

## Output files
/calib_results: camera-projector pair calibration results for SL

/txt: multi-view camera calibration results for MVS and VH

## Groundtruth
cube_mvs.ply: groundtruth for MVS

cube_sl.ply. groundtruth for SL
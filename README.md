# 3DRecon Toolkit
3D reconstruction toolkit, include a complete pipeline to run various 3D vision algorithms, and generate graphs for evaluation purposes.

## Algorithms
* PMVS: patch-based Multi-view Stereo
* EPS: example-based Photometric Stereo (check out [PSKit](https://github.com/imkaywu/PSKit))
* LLS-PS: linear least squares Photometric Stereo (check out [PSKit](https://github.com/imkaywu/PSKit))
* GSL: gray-encoded Structured Light (check out [SLKit](https://github.com/imkaywu/SLKit))
* VH: volumetric based Visual Hull
* SC: space carving

## Study problem condition
We are interested to find out the problem conditions under which an algorithm performs well. The process is divided into three step:
1. eval_prop: study the main effect of each property or interaction effect of each pair of properties 
2. eval_algo: evaluate the performance of each algorithm under a variety of problem conditions;
3. eval_interp: evaluate the proof of concept interpreter in terms of its ability to translate a user-specified description to a successful solution.

## Evaluation

There are three separate directories: `pairwise`, `train`, and `test`. Each directory, there are two files:
* `run` (`train`, `test`); run the algorithms to compute the accuracy and completeness
* `analysis`: plot the graphs
* `eval_acc_cmplt`: evaluate the accuracy and completeness of MVS, SL and VH
* `eval_angle`: evaluate the angle difference of PS

## Results

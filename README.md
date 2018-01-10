# 3DRecon Toolkit
3D reconstruction toolkit, including a complete pipeline to run various 3D vision algorithms, and generate graphs for evaluation purposes. For more details, please visit the [official website](https://imkaywu.github.io/3drecon_dataset/software). 

## For WACV reviewers
All information linked to my identity have been removed from the [official website](https://imkaywu.github.io/3drecon_dataset/software). I also removed personal information on my Github account. Please stay within the [official website](https://imkaywu.github.io/3drecon_dataset/software), otherwise you could come across other Github sites that could reveal my indentity.

## Dependencies
* MATLAB
* [eigen3-nnls](https://github.com/hmatuschek/eigen3-nnls)

## Download
Clone this repository and download data.
```
git clone https://github.com/imkaywu/3DReconKit
cd 3DReconKit
```

## Dataset
The real-world dataset can be downloaded in the [Dataset](https://imkaywu.github.io/3drecon_dataset/dataset) page of the [official website](https://imkaywu.github.io/3drecon_dataset).

The synthetic dataset can be generated using the [blender projects and scripts](https://github.com/imkaywu/3d-data-generator).

## Algorithms
| Algo Class |  Algo  | Summary  | Source code |
| :--------- | :----- | :------- | :---------- |
| MVS        | PMVS   | Patch based Multi-View Stereo | [PMVS](https://www.di.ens.fr/pmvs/) |
| PS         | EPS    | Example-base Photometric Stereo | [PSKit](https://github.com/imkaywu/PSKit) |
| PS         | LLS-PS | Least squares Photometric Stereo | [PSKit](https://github.com/imkaywu/PSKit) |
| SL         | GSL    | Gray-coded Structured Light | [SLKit](https://github.com/imkaywu/SLKit) |
| VH         | VH     | Volumetric Visual Hull |

## Demos
1. Run 3D reconstruction algorithms on synthtic dataset to discover the effective properties, run
```
eval/synth/eval_prop/run.m
eval/synth/eval_prop/evaluate.m
```
2. Run 3D reconstruction algorithms on synthtic dataset to discover the mapping between problem conditions and algorithms, run
```
eval/synth/eval_algo/run.m
eval/synth/eval_algo/evaluate.m
```
3. Run 3D reconstruction algorithms on synthtic dataset to evaluate the performance of interpreter, run
```
eval/synth/eval_interp/run.m
```
4. Run 3D reconstruction algorithms on real-world datasets to evaluate the performance of interpreter, run
```
eval/real_world/run.m
```

## Problem conditions
We are interested to find out the problem conditions under which an algorithm performs well. The process is divided into three step:
1. eval_prop: study the main effect of each property or interaction effect of each pair of properties;
2. eval_algo: evaluate the performance of each algorithm under a variety of problem conditions;
3. eval_interp: evaluate the proof of concept interpreter in terms of its ability to translate a user-specified description to a successful solution.

## License
MIT

close all
clear
clc

im_fname = 'TestImages/big_one_chris.png';
L = 19;
Cparams = load('classifier_parameters.mat');
% dets = ScanImageFixedSize(Cparams,im_fname);
Cparams.thresh = 3.0;

min_s = 0.6;
max_s = 1.3;
step_s = 0.06;
dets = ScanImageOverScale(Cparams,im_fname,min_s,max_s,step_s);

DisplayDetections(im_fname,dets)
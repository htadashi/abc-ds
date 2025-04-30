addpath(genpath('third-party/YALMIP'))
addpath(genpath('third-party/PENLABv104'))
addpath(genpath('third-party/crameri'))
addpath('datasets')

% Mosek installation: please change these lines according to your specific OS and installation:
setenv('PATH', [getenv('PATH') ';C:\Program Files\Mosek\11.0\tools\platform\win64x86\bin']);
addpath(genpath('C:\Program Files\Mosek\11.0\toolbox'))
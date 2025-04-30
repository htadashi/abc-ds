% Script to convert S²-NNDS data into RefData object
% and generate initial/unsafe sets in .json format

% 1:  Angle
% 3:  CShape
% 5:  GShape
% 14: NShape
% 15: PShape
% 19: Sine
% 22: SShape
% 24: Worm
lasa_idx = 24; 

x_s = sym('x', [2; 1]);
unsafe_p = {};

% Specific dataset configuration
switch lasa_idx
    case 1
        folder = 'Angle';
        initial_set_radius = 0.05; 
        % -0.6 < x < -0.4, 0.7 < y < 1.0
        unsafe_p{1} = -x_s(1) - 0.4;
        unsafe_p{2} =  x_s(1) + 0.6;
        unsafe_p{3} = -x_s(2) + 1.0;
        unsafe_p{4} =  x_s(2) - 0.7;
    case 3
        folder = 'CShape';
        initial_set_radius = 0.01;
        % over-approximation obtained using EncloSOS
        unsafe_p{1} = ...
            3273.977978*x_s(1)^4 + 0.0000004891500357*x_s(1)^3*x_s(2) + 3928.773574*x_s(1)^3 + 105636.2389*x_s(1)^2*x_s(2)^2 - 84508.99112*x_s(1)^2*x_s(2) + ... 
            18619.90492*x_s(1)^2 + 0.000001562166387*x_s(1)*x_s(2)^3 + 63381.74334*x_s(1)*x_s(2)^2 - 50705.39467*x_s(1)*x_s(2) + 10464.76371*x_s(1) + ...
            54745.68945*x_s(2)^4 - 87593.10312*x_s(2)^3 + 61853.9127*x_s(2)^2 - 21453.33716*x_s(2) + 2865.898104;
        unsafe_p{1} = -1*unsafe_p{1};
    case 5
        folder = 'GShape';
        initial_set_radius = 0.01;
        % x² + (y - 0.25)² < 0.01
        unsafe_p{1} = -(x_s(1))^2 - (x_s(2) - 0.25)^2 + 0.01;
    case 14
        folder = 'NShape';
        initial_set_radius = 0.005;
        % -y > 0, 4x + 0.8y + 1.6 > 0, -4x + 0.8y - 0.8 > 0
        unsafe_p{1} = -x_s(2);
        unsafe_p{2} =  4*x_s(1) + 0.8*x_s(2) + 1.6;
        unsafe_p{3} = -4*x_s(1) + 0.8*x_s(2) - 0.8;
    case 15
        folder = 'PShape';
        initial_set_radius = 0.001;
        % x² + (y - 0.4)² < 0.04
        unsafe_p{1} = -(x_s(1))^2 - (x_s(2) - 0.4)^2 + 0.04;
    case 19
        folder = 'Sine';
        initial_set_radius = 0.02;
        % (x + 0.4)² + (y - 0.35)² < 0.01
        unsafe_p{1} = -(x_s(1) + 0.4)^2 -(x_s(2) - 0.35)^2 + 0.01;
    case 22
        folder = 'Sshape';
        initial_set_radius = 0.03;
        % 0.3 < x < 1, 0.55 < y < 0.65
        unsafe_p{1} = 1 - x_s(1);
        unsafe_p{2} = x_s(1) - 0.3;
        unsafe_p{3} = 0.65 - x_s(2);
        unsafe_p{4} = x_s(2) - 0.55;        
    case 24
        folder = 'Worm';
        initial_set_radius = 0.005;
        % -0.4 < x < -0.3, -0.1 < y < 0.05
        unsafe_p{1} = -0.3 - x_s(1);
        unsafe_p{2} = x_s(1) + 0.4;
        unsafe_p{3} = 0.05 - x_s(2);
        unsafe_p{4} = x_s(2) + 0.1;          
end

% Load S²-NNDS *normalized* data
load(fullfile('datasets','S2NNDS',folder,'X_train.mat'), 'X_train');
load(fullfile('datasets','S2NNDS',folder,'y_train.mat'), 'y_train');

%% Convert to ABC-DS data format
X_train = double(X_train);
y_train = double(y_train);

X_train_t = X_train';
y_train_t = y_train';

Data_sh = [X_train_t; y_train_t];

data = {};
data{1} = [X_train_t(:,1:1000);    y_train_t(:,1:1000)];
data{2} = [X_train_t(:,1001:2000); y_train_t(:,1001:2000)];
data{3} = [X_train_t(:,2001:3000); y_train_t(:,2001:3000)];
data{4} = [X_train_t(:,3001:4000); y_train_t(:,3001:4000)];
data{5} = [X_train_t(:,4001:5000); y_train_t(:,4001:5000)];

mat_filename = fullfile('datasets','S2NNDS',folder,[folder '_training.mat']);
save(mat_filename, 'Data_sh', 'data');

%% Generate json file encoding unsafe set
unsafe_set_folder = fullfile('datasets','S2NNDS',folder,'unsafe_set');

for i=1:length(unsafe_p)
    poly2file(unsafe_p{i}, fullfile(unsafe_set_folder, ['poly' num2str(i) '.json']));
end

%% Generate json file encoding initial set

% Initial set rectangle:
% - we take the demonstrations and compute the minimum and maximum x and y values of their initial points. 
%   Then, we specify a tolerance 'radius' around these values, and construct an initial set as a hyperrectangle.

load(fullfile('datasets','S2NNDS',folder,'X_test.mat'), 'X_test');
X_test = double(X_test);
X_test_t = X_test';

initial_point_x = zeros(7,1);
initial_point_y = zeros(7,1);

for k=0:4
    initial_point_x(k+1) = X_train_t(1,1 + 1000*k);
    initial_point_y(k+1) = X_train_t(2,1 + 1000*k);
end
for k=0:1
    initial_point_x(k+6) = X_test_t(1,1 + 1000*k);
    initial_point_y(k+6) = X_test_t(2,1 + 1000*k);
end

x_min = min(initial_point_x);
x_max = max(initial_point_x);
y_min = min(initial_point_y);
y_max = max(initial_point_y);
r = initial_set_radius;

init_min_x = x_min - r;
init_max_x = x_max + r;
init_min_y = y_min - r;
init_max_y = y_max + r;

% Clamp values
init_min_x = max(init_min_x, -1);
init_max_x = min(init_max_x, 1);
init_min_y = max(init_min_y, -1);
init_max_y = min(init_max_y, 1);

p1 =  x_s(1) - init_min_x;  %  x + r - x_min > 0
p2 = -x_s(1) + init_max_x;  % -x + r + x_max > 0
p3 =  x_s(2) - init_min_y;  %  y + r - y_min > 0 
p4 = -x_s(2) + init_max_y;  % -y + r + y_max > 0

initial_set_folder = fullfile('datasets','S2NNDS',folder,'initial_set');

poly2file(p1, fullfile(initial_set_folder, 'poly1.json'));
poly2file(p2, fullfile(initial_set_folder, 'poly2.json'));
poly2file(p3, fullfile(initial_set_folder, 'poly3.json'));
poly2file(p4, fullfile(initial_set_folder, 'poly4.json'));

% Initial set circle:

% rd = RefData;
% rd.loadCustom(mat_filename);
% initial_set_center = rd.xi0_mean;
% 
% xc = initial_set_center(1);
% yc = initial_set_center(2);
% 
% r = initial_set_radius;
% p1 =  x_s(1) - xc + r;
% p2 = -x_s(1) + xc + r;
% p3 = -x_s(2) + yc + r;
% p4 =  x_s(2) - yc + r;

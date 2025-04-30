% Script to evaluate the MSE of test trajectories 
% in the S²-NNDS DS dataset

% 1:  Angle
% 3:  CShape
% 5:  GShape
% 14: NShape
% 15: PShape
% 19: Sine
% 22: SShape
% 24: Worm
lasa_idx = 24;
output_filename = '2025-04-29_210808_generated_DS_unscaled.txt';

switch lasa_idx
    case 1
        folder = 'Angle';
    case 3
        folder = 'CShape';
    case 5
        folder = 'GShape';
    case 14
        folder = 'NShape';
    case 15
        folder = 'PShape';
    case 19
        folder = 'Sine';
    case 22
        folder = 'Sshape';
    case 24
        folder = 'Worm';
end

% Read DS from file
fid = fopen(fullfile('output', output_filename), 'r');
expr_x_str = fgetl(fid); 
expr_y_str = fgetl(fid); 
fclose(fid);

syms x y
expr_x = str2sym(expr_x_str);
expr_y = str2sym(expr_y_str);

DS = symfun([expr_x; expr_y], [x, y]);

% Compute MSE using S²-NNDS *normalized* test data
load(fullfile('datasets','S2NNDS',folder,'X_test.mat'), 'X_test');
load(fullfile('datasets','S2NNDS',folder,'y_test.mat'), 'y_test');

X_test_t = X_test';
y_test_t = y_test';

f_DS = matlabFunction(DS);  % Converts DS to @(x,y) function handle

% - Apply DS column-wise to test data
predicted_velocities = f_DS(X_test_t(1,:), X_test_t(2,:));   % Returns 2×N numeric matrix


errors = y_test_t - predicted_velocities;
mse = sum(errors.^2, 'all') / (2*numel(errors));
disp(mse);
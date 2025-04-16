% Main script to configure and run experiments to compute polynomial dynamical systems f, polynomial
% Lyapunov functions V, and polynomial Barrier certificates B. Simply add elements to the
% `experiments` cell array, obtaining the initial options struct from `fvbsettings`.
%
% To get started, you can run this script without change (to run the `two_obstacle` robot scenario),
% or uncomment any of the other provided sample experiments.
%
%
% Copyright © 2023 Martin Schonger
% This software is licensed under the GPLv3.


% cleanup
close('all');
clear all;

global_options = struct;
global_options.seed = 13;
global_options.generator = 'twister';
global_options.output_root_path = 'output/';
global_options.generate_plots = true;

rng(global_options.seed, global_options.generator);


local_seed = 1;
experiments = {};


lasa_idx = 11; 
obstacle_type = "ellipse_axis"; % For ellipse-shaped obstacles
%obstacle_type = "circle";       % For circle-shaped obstacles
%obstacle_type = "poly";         % For custom semi-algebraic unsafe set 

experiments{end+1}.options = fvbsettings('enable_barrier', true, ...
     'epsilon', 1e-3, 'init_Bc_var', false, 'constraint_version', 3, ...
     'dataset', 'lasa', 'dataset_opts', struct('idx', 11, 'obstacle_repr', "ellipse_axis"), ...
     'enable_regularization', false, ...
     'deg_f', 5, 'deg_V', 4, 'deg_B', 4, 'deg_B_slack', 2, ...
     'enable_extra_constraint', true, 'regularization_factor', 0.01, 'seed', local_seed, ...
     'sdpoptions_penbmi', struct('PBM_MAX_ITER', 50, 'PEN_UP', 0.0, 'UM_MAX_ITER', 250));
experiments{end}.pre = {};



for curr_exp_idx = 1:length(experiments)
    rng_savepoint = rng;
    fprintf("Experiment %u of %u:\n", curr_exp_idx, length(experiments));
    try
        options = experiments{curr_exp_idx}.options;
        
        [result, options] = run_experiment(global_options, options, experiments{curr_exp_idx}.pre);

        % unscaled poly str to file
        M = length(result.f_fh_str_arr);
        poly_str_filename = strcat(global_options.output_root_path, result.timestamp, '_generated_DS_unscaled.txt');
        [poly_str_fid, msg] = fopen(poly_str_filename, 'at');
        assert(poly_str_fid >= 3, msg)
        for m = 1:M
            poly_str = xistr2xystr(result.f_fh_str_arr{m}, "xi1", "x");
            poly_str = xistr2xystr(poly_str, "xi2", "y");
            if m < M
                fprintf(poly_str_fid, '%s\n', poly_str);
            else
                fprintf(poly_str_fid, '%s', poly_str);
            end
        end
        fclose(poly_str_fid);
        
        % scaled poly str to file
        if strcmp(options.dataset, 'robot')
            M = length(result.f_fh_str_arr_scaled);
            poly_str_filename = strcat(global_options.output_root_path, result.timestamp, '_generated_DS.txt');
            [poly_str_fid, msg] = fopen(poly_str_filename, 'at');
            assert(poly_str_fid >= 3, msg)
            for m = 1:M
                poly_str = xistr2xystr(result.f_fh_str_arr_scaled{m}, "xi1", "x");
                poly_str = xistr2xystr(poly_str, "xi2", "y");
                if m < M
                    fprintf(poly_str_fid, '%s\n', poly_str);
                else
                    fprintf(poly_str_fid, '%s', poly_str);
                end
            end
            fclose(poly_str_fid);
        end

        % unscaled V str to file
        M = length(result.V_fh_str_arr);
        poly_str_filename = strcat(global_options.output_root_path, result.timestamp, '_V_unscaled.txt');
        [poly_str_fid, msg] = fopen(poly_str_filename, 'at');
        assert(poly_str_fid >= 3, msg)
        for m = 1:M
            poly_str = xistr2xystr(result.V_fh_str_arr{m}, "xi1", "x");
            poly_str = xistr2xystr(poly_str, "xi2", "y");
            if m < M
                fprintf(poly_str_fid, '%s\n', poly_str);
            else
                fprintf(poly_str_fid, '%s', poly_str);
            end
        end
        fclose(poly_str_fid);
        
        % scaled V str to file
        if strcmp(options.dataset, 'robot')
            M = length(result.V_fh_str_arr_scaled);
            poly_str_filename = strcat(global_options.output_root_path, result.timestamp, '_V.txt');
            [poly_str_fid, msg] = fopen(poly_str_filename, 'at');
            assert(poly_str_fid >= 3, msg)
            for m = 1:M
                poly_str = xistr2xystr(result.V_fh_str_arr_scaled{m}, "xi1", "x");
                poly_str = xistr2xystr(poly_str, "xi2", "y");
                if m < M
                    fprintf(poly_str_fid, '%s\n', poly_str);
                else
                    fprintf(poly_str_fid, '%s', poly_str);
                end
            end
            fclose(poly_str_fid);
        end

        % unscaled B str to file
        M = length(result.B_fh_str_arr);
        poly_str_filename = strcat(global_options.output_root_path, result.timestamp, '_B_unscaled.txt');
        [poly_str_fid, msg] = fopen(poly_str_filename, 'at');
        assert(poly_str_fid >= 3, msg)
        for m = 1:M
            poly_str = xistr2xystr(result.B_fh_str_arr{m}, "xi1", "x");
            poly_str = xistr2xystr(poly_str, "xi2", "y");
            if m < M
                fprintf(poly_str_fid, '%s\n', poly_str);
            else
                fprintf(poly_str_fid, '%s', poly_str);
            end
        end
        fclose(poly_str_fid);
        
        % scaled B str to file
        if strcmp(options.dataset, 'robot')
            M = length(result.B_fh_str_arr_scaled);
            poly_str_filename = strcat(global_options.output_root_path, result.timestamp, '_B.txt');
            [poly_str_fid, msg] = fopen(poly_str_filename, 'at');
            assert(poly_str_fid >= 3, msg)
            for m = 1:M
                poly_str = xistr2xystr(result.B_fh_str_arr_scaled{m}, "xi1", "x");
                poly_str = xistr2xystr(poly_str, "xi2", "y");
                if m < M
                    fprintf(poly_str_fid, '%s\n', poly_str);
                else
                    fprintf(poly_str_fid, '%s', poly_str);
                end
            end
            fclose(poly_str_fid);
        end
    catch ME
        fprintf(2, '[ERROR] %s (More info: %s)\n', ME.identifier, ME.message);
        fprintf(2, '%s\n', getReport(ME, 'extended'));
    
        diary off;
    
        pause(2);
    end
    rng(rng_savepoint);
end
% symfun bivariate polynomial to file
function poly2file(sympoly, json_filename)

    [sdpexpr_tmp, sdpvars_tmp] = sym_to_sdpvar(sympoly);
    [C, T] = coefficients(sdpexpr_tmp);
    
    M = length(symvar(sympoly));
    xi = sdpvar(M, 1);
    json = struct;
    json.coefs = full(C);
    T_replaced = replace(T, sdpvars_tmp.x, xi);
    json.monomials = sdisplay(T_replaced);
    
    json_encoded = jsonencode(json);
    json_fid = fopen(json_filename, 'w');
    fprintf(json_fid , '%s', json_encoded);
    fclose(json_fid);
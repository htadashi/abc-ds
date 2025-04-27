function [sdpvarexpr, sdpvars] = sym_to_sdpvar(symexpr)

symvars = symvar(symexpr);

sdpvars_candidates = {};
sdpvars_candidates_max = [];

for i = 1:length(symvars)
    cursymvar = char(symvars(i));
    vecname = extract(cursymvar, lettersPattern);
    vecname = vecname{1};
    idx = extract(cursymvar, digitsPattern);
    loc_arr = ismember(sdpvars_candidates, vecname);
    if ~sum(loc_arr)
        sdpvars_candidates{end+1} = vecname;
        if ~isempty(idx)
            idx = idx{1};
            idx = str2double(idx);
            sdpvars_candidates_max(end+1) = idx;
        else
            sdpvars_candidates_max(end+1) = 1;
        end
    else
        if ~isempty(idx)
            idx = idx{1};
            idx = str2double(idx);
            sdpvars_candidates_max(loc_arr) = max(sdpvars_candidates_max(loc_arr), idx);
        end
    end
end

sdpvars = struct;
tmp_symexpr = char(symexpr);

for i = 1:length(sdpvars_candidates)
    tmp_expr = strcat(sdpvars_candidates{i}, " = sdpvar(", int2str(sdpvars_candidates_max(i)), ",1);");
    eval(tmp_expr);
    tmp_expr2 = strcat("sdpvars.", sdpvars_candidates{i}, " = ", sdpvars_candidates{i}, ";");
    eval(tmp_expr2);

    for j = 1:sdpvars_candidates_max(i)
        tmp_symexpr = replace(tmp_symexpr, strcat(sdpvars_candidates{i}, int2str(j)), strcat(sdpvars_candidates{i}, "(", int2str(j), ")"));
    end
end

sdpvarexpr = eval(tmp_symexpr);

end
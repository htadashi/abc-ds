function [f,userdata] = ncm1y_objfun(x,Y,userdata)
  % f = sum_ij  (y_ij - h_ij)^2
  % matrix H is stored in userdata

  YH = Y{1}-userdata;
  f = YH(:)'*YH(:);


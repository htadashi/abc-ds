function [f,userdata] = sdp_objfun(x,Y,userdata)

% This file is a part of PENLAB package distributed under GPLv3 license
% Copyright (c) 2013 by  J. Fiala, M. Kocvara, M. Stingl
% Last Modified: 27 Nov 2013

  f = userdata.c'*x;


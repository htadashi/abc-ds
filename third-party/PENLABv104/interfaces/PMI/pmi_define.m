function [penm] = pmi_define(pmidata)
% PMI_DEFINE defines penm structure for Polynomial Matrix Inequality SPD 
% created from user's pmidata structure.
%
% Typical way of invoking the solver:
%    penm = pmi_define(userdata);
%    prob = penlab(penm);
%    prob.solve();
%    ...
%
% It is expected that 'pmidata' stores data for the following problem
%    min   c'x + 1/2 x'Hx
%    s.t.  lbg <= B*x <= ubg
%          lbx <=  x  <= ubx 
%          A_k(x)>=0     for k=1,..,Na
%    where
%          A_k(x) = sum_i  x(multi-index(i))*Q_i
%    for example
%          A_k(x) = Q_1 + x_1*x_3*Q_2 + x_2*x_3*x_4*Q_3
%          thus multi-indices are  
%             midx_1 = 0       (absolute term, Q_1)
%             midx_2 = [1,3]   (bilinear term, Q_2)
%             midx_3 = [2,3,4] (term for Q_3)
%
% List of elements of the user structure 'pmidata'
%   name ... [optional] name of the problem
%   Nx ..... number of primal variables
%   Na ..... [optional] number of matrix inequalities (or diagonal blocks
%            of the matrix constraint)
%   xinit .. [optional] dim (Nx,1), starting point
%
%   c ...... [optional] dim (Nx,1), coefficients of the linear obj. function,
%            considered a zero vector if not present
%   H ...... [optional] dim (Nx,Nx), Hessian for the obj. function,
%            considered a zero matrix if not present
%
%   lbx,ubx. [optional] dim (Nx,1) or scalars (1x1), lower and upper bound
%            defining the box constraints
%   B ...... [optional] dim(Ng,Nx), matrix defining the linear constraints
%   lbg,ubg. [optional] dim (Ng,1) or scalars, upper and lower bounds for B
%
%   A ...... if Na>0, cell array of A{k} for k=1,...,Na each defining 
%            one matrix constraint; let's assume that A{k} has maximal
%            order maxOrder and has nMat matrices defined, then A{k} should 
%            have the following elements:
%              A{k}.Q - cell array of nMat (sparse) matricies of the same
%                 dimension
%              A{k}.midx - matrix maxOrder x nMat defining the multi-indices
%                 for each matrix Q; use 0 within the multi-index to reduce
%                 the order
%            for example, A{k}.Q{i} defines i-th matrix to which belongs
%            multi-index  A{k}.midx(:,i). If midx(:,i) = [1;3;0], it means
%            that Q_i is multiplied by x_1*x_3 within the sum.

% This file is a part of PENLAB package distributed under GPLv3 license
% Copyright (c) 2013 by  J. Fiala, M. Kocvara, M. Stingl
% Last Modified: 27 Nov 2013

  penm = [];
  userdata = [];

  if (isfield(pmidata,'name'))
    penm.probname=pmidata.name;
  end
  penm.comment = 'Structure PENM generated by pmi_define()';

  Nx=pmidata.Nx;
  if (Nx>0)
    penm.Nx=Nx;
  else
    error('Input: Nx<=0');
  end
  
  % initial point
  if (isfield(pmidata,'xinit') && ~isempty(pmidata.xinit))  
    [n m] = size(pmidata.xinit);
    if (n==1 && m==Nx)
      penm.xinit = pmidata.xinit';
    elseif (n==Nx && m==1)
      penm.xinit = pmidata.xinit;
    else
      error('Input: xinit incompatible dimension.');
    end
  end

  % box constraints, dimensions will be checked inside Penlab
  if (isfield(pmidata,'lbx') && ~isempty(pmidata.lbx))
    penm.lbx=pmidata.lbx;
  end
  if (isfield(pmidata,'ubx') && ~isempty(pmidata.ubx))
    penm.ubx=pmidata.ubx;
  end

  % objective function
  if (isfield(pmidata,'c') && ~isempty(pmidata.c))
    [n m] = size(pmidata.c);
    if (n==1 && m==Nx)
      userdata.c=pmidata.c';
    elseif (n==Nx && m==1)
      userdata.c=pmidata.c;
    else
      error('Input: c incompatible dimension.');
    end
  else
    userdata.c=sparse(Nx,1);
  end
  if (isfield(pmidata,'H') && ~isempty(pmidata.H))
    [n m] = size(pmidata.H);
    if (n==Nx && m==Nx)
      userdata.H=pmidata.H;
    else
      error('Input: H incompatible dimensions.');
    end
  else
    userdata.H=sparse(Nx,Nx);
  end

  % linear constraints
  if (isfield(pmidata,'B') && ~isempty(pmidata.B))
    [m n] = size(pmidata.B);
    if (n~=Nx)
      error('Input: wrong dimension of B, should be Ng x Nx');
    end
    userdata.B=pmidata.B;
    Ng=m;
  else
    userdata.B=[];
    Ng=0;
  end
  penm.NgLIN=Ng;

  if (Ng>0)
    if (isfield(pmidata,'lbg') && ~isempty(pmidata.lbg))
      penm.lbg=pmidata.lbg;
    end
    if (isfield(pmidata,'ubg') && ~isempty(pmidata.ubg))
      penm.ubg=pmidata.ubg;
    end
  end

  % matrix constraints
  if (isfield(pmidata,'Na') && ~isempty(pmidata.Na) && pmidata.Na>0)
    % TODO do it better, detect linear/nonlinear; detect the right number
    % of constraints
    NA=pmidata.Na;
    penm.NANLN=NA;
    penm.NALIN=0;
    userdata.NA=NA;
    
    % let's make the constraints positive semidefinite
    penm.lbA=zeros(NA,1);

    for k=1:NA
      userdata.mcon{k}=check_mcon(Nx,pmidata.A{k}.midx,pmidata.A{k}.Q);
    end
  else
    penm.NANLN=0;
    penm.NALIN=0;
    userdata.NA=0;
  end

  % keep the proccessed structure
  penm.userdata=userdata;

  penm.objfun = @pmi_objfun;
  penm.objgrad = @pmi_objgrad;
  penm.objhess = @pmi_objhess;

  penm.confun = @pmi_confun;
  penm.congrad = @pmi_congrad;
  %penm.conhess = ...;  not needed because all linear

  penm.mconfun = @pmi_mconfun;
  penm.mcongrad = @pmi_mcongrad;
  penm.mconhess = @pmi_mconhess;

end

%%%%%%%%%%
% check one matrix constraint
% input:
%   Nx - number of variables (to check midx)
%   midx(maxOrder,nMat) - multiindices for each matrix
%   Q{nMat} - cell array of nMat sparse matrices forming the matrix constraint
function [mcon] = check_mcon(Nx,midx,Q)

  % check that every matrix has a multi-index
  [maxOrder, nMat] = size(midx);
  [m, n] = size(Q);
  if (max(m,n) ~= nMat || min(m,n)~=1)
    error('Input: not matching number of matrices and their multi-indices');
  end
  if (nMat<1 || maxOrder<1)
    error('Input: empty matrix constraint');
  end

  % check multiindex (only elements 0..Nx are allowed)
  if (any(any(midx<0)) || any(any(midx>Nx)))
    error('Input: multiindex for matrix constraint is out of range 0..Nx.');
  end

  % check dimensions
  [dimQ, n]=size(Q{1});
  if (dimQ~=n)
    error('Input: not square matrix');
  end
  for i=2:nMat
    [m,n] = size(Q{i});
    if (m~=dimQ || n~=dimQ)
      error('Input: not matching dimensions within one matrix constraint');
    end
  end
  mcon.dim=dimQ;
  mcon.midx=midx;
  mcon.Q=cell(nMat,1);
  % copy & force sparsity
  for i=1:nMat
    mcon.Q{i}=sparse(Q{i});
  end

end


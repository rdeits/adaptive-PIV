function[ uo, i_cond ] = vector_filter_vecstd( ui, vec_std )
%========================================================================
%
% version 0.60
%
%
% 	vector_filter_meidan.m
%
%
% Description:
%
%	Remove stray vectors using median filter.
%	This program is called by mpiv.m
%   A 3x3 to 5x5 area is used for the filtering.  The area is dynamically 
%   determined by the number of valid (but unfiltered) neighboring vectors.
%
%	  - error vector exceeds > vec_std is replaced by NaN
%
% Variables:
%
%	Input:
%	ui		velocity vector
%   	vec_std		threshold value (typically 2 to 3)
%			
%	Output:
%	uo		output velocity vector
%
%======================================================================
%
% Terms:
%
%       Distributed under the terms of the terms of the BSD License
%
% Copyright:
%
%       Nobuhito Mori
%           Disaster Prevention Research Institue
%           Kyoto University, JAPAN
%           mori@oceanwave.jp
%
%======================================================================
%
% Update:
%       0.61    2009/07/01 BSD License is applied
%       0.60    2003/06/26 Algorism has been rivised.
%       0.52    2003/06/20 Add if-else-end to avoid error for std
%       0.50    2003/06/11 Main routine has been modified by KAC
%	0.01	           First version
%
%========================================================================

% *********************** INPUT for professional users **********

% window 'diameter' for fitering.
% gives an area of (ndia*2+1) by (ndia*2+1)
ndia_start = 1;             
ndia_max = 4;     % ndia_max must < or = ndia_start

% set minimum number of valid (but unfiltered) neighboring vectors for filtering:
nf_min = 9;         % nf_min must > or = 5

% intrinsic piv error
err_std = 0.25;    

% *********************** END OF INPUT **************************

big = 10^5;
i_cond = 0;
u  = ui;
mx = size(u,1);
my = size(u,2);

if ndia_max < ndia_start
    error('ndia_start must < or = ndia_max')
end

if (mx < ndia_start*2+1) | (my < ndia_start*2+1)
    error('The total number of vectors is too small for filtering')
end

for iy=1:my
   for ix=1:mx
      
      iflag = 0;
      ndia = ndia_start;
      
      while iflag == 0
         lx1 = ix - ndia;
         lx2 = ix + ndia;
         ly1 = iy - ndia;
         ly2 = iy + ndia;
        
         if lx1 < 1
            lx1 = 1;
         end
        
         if ly1 < 1
            ly1 = 1;
         end
        
         if lx2 > mx
            lx2 = mx;
         end
        
         if ly2 > my
            ly2 = my;
         end
      
         fr = ui(lx1:lx2,ly1:ly2);                        
         fr = reshape(fr, 1, size(fr,1)*size(fr,2));
         tmp = find(~isnan(fr));
         f = fr(tmp);

         if length(f) >= nf_min
            [f_mean  f_std  f_med] = func_histfilter(f);
            iflag = 1;
         elseif ndia == ndia_max
            f_std = 0.0;
            f_mean = big;
            f_med = big;
            iflag = 1;
         else
            ndia = ndia + 1;
         end
      end
    
      std_limit = max(vec_std*f_std, err_std);

      if abs( ui(ix,iy) - f_mean ) > std_limit
         u(ix,iy) = NaN;
         i_cond = 1;
      end
   end
end

uo = u;


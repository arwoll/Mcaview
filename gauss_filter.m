function newy = gauss_filter(x, y, filt_fwhm)
% function newy = gauss_filter(x, y, filt_fwhm)
% Convolve a gaussian peak having FWHM given by filt_fwhm with data x, y
% and return the filter result, having the same length as x and y.

% For details, see depthprof.m (cxfit-1.1)
npts = length(x);
dx = (x(end)-x(1))/(npts-1);
resn = round(2*filt_fwhm/dx);

% The following guarantees an odd number of points, and that
% resx(resn+1) corresponds to the precise center of the function.
resx = linspace(-resn*dx, resn*dx, 2*resn+1);
res = gauss([0 filt_fwhm], resx);
newy = conv(y, res);

% y(resn+1) and y(sourcepts+resn) correspond to the center of the
% resolution function being coincident with the first and last
% data point, respectively.
newy = newy(resn+1:npts+resn);
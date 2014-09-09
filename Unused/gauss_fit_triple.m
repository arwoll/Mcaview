function peak_data = gauss_fit_triple(x,y, varargin)
% [area, varargout] = gauss_fit(x,y, varargin) accepts, as input, a set of
% x's and y's as input, and fits each tuple (x,y) to a gaussian profile,
% returning (at least) the area under each peak. (Each tuple is assumed to
% have only one such peak.) It is an analog of find_peak, which uses only
% simple summing and interpolation for the same purpose.
%
% There are different modes of operation, corresponding to different
% assumptions regarding the tuples (x,y). In 'linear' mode, the peak is
% assumed not to change position or width. In this case (appropriate for
% the vortex detector, or other detectors at low count rates...), the fits
% for individualt spectra simplies to the linear case, which is very fast.
% 
% 
% modes:  only 'lin' is supported
%
%       'peak': 'left', 'right'
%
% NOTES: x,y assumed to be column vectors...
%
mode = 'lin';
sampley = [];
peak_data = [];
delta = [];
peak = '1';

nvarargin = nargin -2;
if nvarargin > 1
    for k = 1:2:nvarargin
        switch varargin{k}
            case 'sampley'
                if isnumeric(varargin{k+1})
                    sampley = varargin{k+1};
                else
                    errordlg(['optional argument sampley must be followed by an array\n' ...
                        'containing sample y values for use with param estimate'], ...
                        'gaussfit error');
                    return
                end
            case 'delta'
                if isnumeric(varargin{k+1}) && all(size(varargin{k+1}) == size(y))
                    delta = varargin{k+1};
                else
                    errordlg('optional argument detla must be the same dimensions as y\n', ...
                        'gaussfit error');
                    return
                end
            case 'peak'
                if ischar(varargin{k+1})
                    peak = varargin{k+1};
                else
                    errordlg('optional argument peaks must be an integer y\n', ...
                        'gaussfit error');
                    return
                end
            otherwise
                warndlg(sprintf('Unrecognized input argument %s',varargin{k}));
        end
    end
end

if strcmp(mode, 'lin') && isempty(sampley)
    sampley = sum(y, 2);
elseif length(sampley) ~= size(y, 1)
    errorlg('Oops, sample must be the same size as the number of rows in y', ...
        'gaussfit errror');
end

peak_data = find_peak(x, sampley);
filt_fwhm = peak_data.fwhm/2;
cen = peak_data.ch_com;
% Step 1: Filter the input data w.r.t. this fw.
% For details, see depthprof.m (cxfit-1.1)
npts = length(x);
dx = (x(end)-x(1))/(npts-1);
resn = round(2*filt_fwhm/dx);
% The following guarantees an odd number of points, and that
% resx(resn+1) corresponds to the precise center of the function.
resx = linspace(-resn*dx, resn*dx, 2*resn+1);
res = gauss([0 filt_fwhm], resx);
newy = conv(sampley, res);
% y(resn+1) and y(sourcepts+resn) correspond to the center of the
% resolution function being coincident with the first and last
% data point, respectively.
newy = newy([resn+1:npts+resn]);
% Step 2: Search for other peaks -- find the 2nd highest one
peaks = [];
rising = 0;
curr = newy(1);
for k = 2:length(newy)
    if newy(k)>= curr
        rising = 1;
    elseif rising
            peaks(end+1).x = x(k-1);
            peaks(end).y = sampley(k-1);
            rising = 0;
    end
    curr = newy(k);
end
if length(peaks)<3
    % Try to find a shoulder...
    peaks = [];
    for k=1:length(newy)-1 dy(k) = newy(k+1)-newy(k); end
    dy = abs(dy);
    falling = 0;
    curr = dy(1);
    for k = 2:length(dy)
        if dy(k) <= curr
            falling = 1;
        elseif falling
            peaks(end+1).x = x(k);
            peaks(end).y = sampley(k);
            falling = 0;
        end
        curr = dy(k);
    end
    if length(peaks)<3
        warndlg('Sorry, couldn''t find three peaks...');
        % NEED A FLAG HERE...
        peak_data = [];
        return
    end
end
%Find two largest peaks and arrange acccording to left/right.
[p, ind] = sort([peaks.y], 'descend');
peaks = peaks(ind(1:3));

one_ratio = peaks(1).y/sum([peaks.y]);
two_ratio = peaks(2).y/sum([peaks.y]);
three_ratio = peaks(3).y/sum([peaks.y]);
% Step 3: Perform nonlinear fit w.r.t. two gaussians, determine pars
% Step 4: proceed with loop for linear fits.


delsq = sampley;
mx = max(delsq);
delsq(find(delsq<=0)) = mx;

wts = (1./delsq);

%dfe = length(x) - 6;
nonlin_model = fittype(['bk + a1*2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((xdata-cen1)*2.35482/fwhm).^2) + ' ...
    'a2*2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((xdata-cen2)*2.35482/fwhm).^2) +' ...
    'a3*2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((xdata-cen3)*2.35482/fwhm).^2)' ],...
    'ind', 'xdata', 'coeff', {'a1', 'bk', 'cen1', 'fwhm','a2','cen2','a3','cen3'});

nonlin_opts = fitoptions('Method', 'NonLinearLeastSquares', 'Display', 'off', ...
    'StartPoint', [peak_data.area*one_ratio peak_data.bkgd(1) peaks(1).x ...
    peak_data.fwhm peak_data.area*two_ratio peaks(2).x ...
    peak_data.area*three_ratio peaks(3).x], ...
    'Weights', wts);


%area = pars(1);bk = pars(2); cen=pars(3); fwhm=pars(4);  
%figure
%plot(x, sampley, 'bo', x, gaussbk( [peak_data.counts peak_data.bkgd peak_data.com  peak_data.fwhm], x), 'r-')
[gaussfit, goodness, output] = fit(x, sampley,nonlin_model, nonlin_opts);
%hold on;
%plot(x, sampley, 'bo',x, gaussfit(x), 'r-');
%hold off;
%fval = goodness.sse/goodness.dfe;
%fval = sum((output.residuals.*wts).^2)/goodness.dfe
%fval = sum((output.residuals).^2)/goodness.dfe

peak_data.fwhm = gaussfit.fwhm;
peak_data.bk = gaussfit.bk;
peak_data.compare = gaussfit(x);
peak_data.chi = goodness.sse/goodness.dfe;
peak_data.com = gaussfit.(['cen' peak]);
peak_data.area = gaussfit.(['a' peak]);


nspectra = size(y, 2);
if nspectra == 1
    return
end

cen1 = gaussfit.cen1;
cen2 = gaussfit.cen2;
cen3 = gaussfit.cen3;
fwhm = gaussfit.fwhm;
a1 = gaussfit.a1;
a2 = gaussfit.a2;
a3 = gaussfit.a3;
bk = gaussfit.bk;

lin_model = fittype({'1', '2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((x-cen1)*2.35482/fwhm).^2)', ...
    '2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((x-cen2)*2.35482/fwhm).^2)', ...
    '2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((x-cen3)*2.35482/fwhm).^2)'},...
    'problem', {'cen1', 'cen2','cen3','fwhm'},'coeff', {'bk','a1', 'a2', 'a3'});
%model = fittype({'gauss([cen fwhm], x)', '1'}, 'problem', {'cen', 'fwhm'},'coeff', {'area', 'bk'});
lin_opts = fitoptions(lin_model);
set(lin_opts, 'Lower', [0 0 0 0]);
% tic;
% iter = 0;

progress = waitbar(0, 'Background Subtraction...Please Wait');
%tic
if ~isempty(delta)
    delta = delta.*delta;
end

peak_data.area = zeros(1,nspectra);
peak_data.chi = zeros(1, nspectra);
peak_data.compare = zeros(size(y, 1), nspectra);

% For debugging...
%h = figure;

for k = 1:nspectra
    i_vs_e = y(:,k);
    if isempty(delta)
        delsq = i_vs_e;
    else
        delsq = delta(:,k);
    end
    mx = max(delsq);
    if mx == 0
        mx = 1;
    end
    delsq(find(delsq<=0)) = mx;
    wts = 1./delsq;
    set(lin_opts, 'Weights', wts);
    [foo, good,out] = fit(x, i_vs_e, lin_model, lin_opts, 'problem', ...
        {cen1 ,cen2, cen3,fwhm});
        
    peak_data.compare(:,k) = foo(x);
    peak_data.area(k) = foo.(['a' peak]);
    peak_data.chi(k) = good.sse/good.dfe;
%    plot(x, y(:,k), 'bo', x,foo(x), 'r-');
    waitbar(k/nspectra, progress);
end
%toc
close(progress);
%h = figure;
%plot(chi);
%close(h);



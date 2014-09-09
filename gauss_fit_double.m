function peak_data = gauss_fit_double(x,y, varargin)
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
                if any(varargin{k+1} == ['1' '2'])
                    peak = varargin{k+1};
                else
                    errordlg('optional argument peaks must be ''1'' or ''2''\n', ...
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

peak_data = find_peak(x, sampley,'mode', 'lin', 'back', [1 length(sampley)]);
cen = peak_data.ch_com;

newy = gauss_filter(x, sampley, peak_data.fwhm/2);

% Step 2: Search for other peaks -- find the 2nd highest one
peaks = find_peak_locations(x, newy);
if length(peaks)<2
    warndlg('Sorry, couldn''t find two peaks...');
    % NEED A FLAG HERE...
    peak_data = [];
    return
end
peaks = peaks(1:2);

% Replace the peaks.y values with those of y, and not
% newy.
for k = 1:length(peaks)
    peaks(k).y = sampley(peaks(k).index);
end

one_ratio = peaks(1).y/sum([peaks.y]);
two_ratio = peaks(2).y/sum([peaks.y]);
% Step 3: Perform nonlinear fit w.r.t. two gaussians, determine pars
% Step 4: proceed with loop for linear fits.

delsq = sampley;
mx = max(delsq);
delsq(find(delsq<=0)) = mx;

wts = (1./delsq);

%dfe = length(x) - 6;
nonlin_model = fittype(['bk + a1*2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((xdata-cen1)*2.35482/fwhm).^2) + ' ...
    'a2*2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((xdata-cen2)*2.35482/fwhm).^2)'],...
    'ind', 'xdata', 'coeff', {'a1', 'bk', 'cen1', 'fwhm','a2','cen2'});

nonlin_opts = fitoptions('Method', 'NonLinearLeastSquares', 'Display', 'off', ...
    'StartPoint', [peak_data.area*one_ratio peak_data.bkgd(1) peaks(1).x...
    peak_data.fwhm peak_data.area*two_ratio peaks(2).x], ...
    'Weights', wts);


%area = pars(1);bk = pars(2); cen=pars(3); fwhm=pars(4);  
%figure
%plot(x, sampley, 'bo', x, gaussbk( [peak_data.counts peak_data.bkgd peak_data.com  peak_data.fwhm], x), 'r-')
[gaussfit, goodness, output] = fit(x, double(sampley),nonlin_model, nonlin_opts);
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
fwhm = gaussfit.fwhm;
a1 = gaussfit.a1;
a2 = gaussfit.a2;
bk = gaussfit.bk;

lin_model = fittype({'1', '2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((x-cen1)*2.35482/fwhm).^2)', ...
    '2.35482/(fwhm*sqrt(2*pi))*exp(-0.5*((x-cen2)*2.35482/fwhm).^2)'},...
    'problem', {'cen1', 'cen2','fwhm'},'coeff', {'bk','a1', 'a2'});
%model = fittype({'gauss([cen fwhm], x)', '1'}, 'problem', {'cen', 'fwhm'},'coeff', {'area', 'bk'});
lin_opts = fitoptions(lin_model);
set(lin_opts, 'Lower', [0 0 0]);
% tic;
% iter = 0;

progress = waitbar(0, 'Background Subtraction...Please Wait');
%tic
if ~isempty(delta)
    delta = delta.*delta;
end

peak_data.area = zeros(1,nspectra);
peak_data.chi = zeros(1, nspectra);
peak_data.compare = zeros(size(y));

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
    [foo, good,out] = fit(x, i_vs_e, lin_model, lin_opts, 'problem', {cen1 ,cen2,fwhm});
        
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



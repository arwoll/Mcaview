function peak_data = find_peak(x,y, bk)
% peak_data = find_peak(x,y, bk)
% Returns limited information about the peak in y
% find_peak.fwhm = FWHM of peak
% find_peak.center returns COM of peak within FWHM
if length(x) == 1
    peak_data.wl = 1;
    peak_data.xli = 1;
    peak_data.wr = 1;
    peak_data.xri = 1;
    peak_data.fwhm = 1;
    peak_data.com = x;
    peak_data.ch_com = 1;

    peak_data.counts = y;
    peak_data.area = peak_data.counts;
    peak_data.delta = sqrt(y);
    peak_data.bkgd = 0;
    return
end

if nargin == 2
    bk = 2;
elseif bk == 'lin'
    ybk = [y(1:5) y(end-5:end)];
    xbk = [x(1:5) x(end-5:end)];
    if size(ybk,1) == 1
        ybk = ybk';
        xbk = xbk';
    end
    f=fit(xbk, ybk, 'm*x+b');
    y = y-f.m.*x-f.b;
    bk = 0;
end

[mx, mi] = max(y);
if bk > 0
    bkgd = mean([y(1:bk) y(end-bk+1:end)]);
else
    bkgd = 0;
end
hm = (mx-bkgd)/2.0;

walk = mi;

wl = find(y(mi:-1:1)<hm, 1);
if isempty(wl)
    wl = mi;  % Rather than 1 -- to make fwhm
    	% the half width of an error function shape
    xli = mi;
    xl=x(wl);
else
    wl = mi +1 - wl; % index of first element to left of peak < hm
    dx = x(wl+1)-x(wl);
    dy = y(wl+1)-y(wl);
    xl = dx/dy*(hm-y(wl)) + x(wl);
    xli = 1/dy*(hm-y(wl))+wl;  % xli, xri are the precise fractional index positions of the hm points. 
end
wr = find(y(mi:end)<hm, 1);
if isempty(wr) 
    %wr = length(y);
    wr = mi;
    xri = mi; 
    xr=x(wr);
else
    wr = mi - 1 + wr;  % index of first element to right of peak < hm
    dx = x(wr)-x(wr-1); 
    dy = y(wr)-y(wr-1);
    xr = dx/dy*(hm-y(wr-1)) + x(wr-1);
    xri = 1/dy*(hm-y(wr-1)) + wr-1; 
end

peak_data.wl = wl;
peak_data.xli = xli;
peak_data.wr = wr;
peak_data.xri = xri;
peak_data.fwhm = abs(xr-xl);
if sum(y(wl:wr))==0
    peak_data.com = mean(x(wl:wr));
    peak_data.ch_com = mean([wl:wr]);
else
    peak_data.com = sum(x(wl:wr).*y(wl:wr))/sum(y(wl:wr));
    peak_data.ch_com = sum([wl:wr] .*y(wl:wr))/sum(y(wl:wr));
end
peak_data.counts = sum(y-bkgd);
peak_data.area = abs(x(2)-x(1))*peak_data.counts;
peak_data.delta = sqrt(sum(y));
peak_data.bkgd = bkgd;

% An alternative way of getting the area is to use only the counts within
% the fwhm.  1.3141 is the ratio between the full area of a gaussian peak
% and the area within the fwhm.
% 
% peak_data.area = 1.3141*a;
% peak_data.area = 1.3141*abs((x(2)-x(1))*sum(y(wl:wr)-bkgd));

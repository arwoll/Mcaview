function y=gausstest(pars, xdata, wts)
area = pars(1); bk = pars(2); cen = pars(3); fwhm = pars(4);
sigma = fwhm/2.3548;

y = bk + area/(sigma*sqrt(2*pi))*exp(-0.5*((xdata-cen)/sigma).^2);

if nargin > 2
    y = y .* wts;
end
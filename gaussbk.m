function [y, J]=gaussbk(pars, xdata, wts)
% function y=gaussbk(pars, x)
% cen=pars(1); area = pars(2); fwhm=pars(3); bk = pars(4); 
% y=bk+area*gauss([cen fwhm], x);
FWHM_TO_SIGMA = 2.35482;
area = pars(1);bk = pars(2); cen=pars(3); fwhm=pars(4);  
sigma = fwhm/FWHM_TO_SIGMA;

%y = 1.0/(sigma*sqrt(2*pi))*exp(-0.5*((X-cen)/sigma).^2);

prefactor = area/(sigma*sqrt(2*pi));
exponential = exp(-0.5*((xdata-cen)/sigma).^2);
y=bk+prefactor*exponential;
if nargout > 1
    J = zeros(length(xdata),length(pars));
    J(:,3) = prefactor*(xdata-cen)./sigma^2.*exponential;
    J(:,1) = 1/(sigma*sqrt(2*pi))*exponential;
    J(:,4) = 1/FWHM_TO_SIGMA*prefactor*exponential.*( -1/sigma + (xdata-cen).^2/sigma^3);
    J(:,2) = ones(1, length(xdata));
end
if nargin > 2
    y = y.* wts;
    if nargout > 1
            J=J.*[wts wts wts wts];
    end
end
          
    
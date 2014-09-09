sig=f2.d;
cen=f2.c;
model = sprintf('a+b/(%g*sqrt(2*pi))*exp(-0.5*((x-%g)/%g)^2)', sig,cen, sig);
for k = 1:length(d_roi)
    y = image(e_roi, d_roi(k));
    f = fit(x,y,model, 'StartPoint', [1 1], 'Lower', [0 0]);
    a(k)=f.a;
    b(k)=f.b;
end
    
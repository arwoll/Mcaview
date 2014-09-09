dims = scandata.spec.size;
mc = reshape(single(scandata.mcadata), 1024, prod(dims));
tic
[u,s,v] = svd(mc);
toc
eigs = s*v';
eige = u*s;

en = scandata.energy;
de = scandata.depth;
v1 = de;
v2 = scandata.spec.var2(1,:);
mcafile = scandata.mcafile;

svdfile = strrep(mcafile, '.mca', '_svd.mat');
save_svd = questdlg(sprintf('save file %s?',svdfile),'Save');
if strcmp(save_svd, 'Yes')
    save(svdfile, 'mc','u','s' ,'v','en', 'de','v1', 'v2',...
        'eigs', 'eige', 'dims');
end
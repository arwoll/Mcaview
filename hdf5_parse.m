function [scandata, errors] = hdf5_parse(mcafile)
% function [scandata, errors] = hdf5_parse(mcafile)
% Very simple-minded parser for APS HDF5 format.
% Data groups appear to be either '/1D Scan' or  '/2D Scan'. XANES may have
% a different name. 
% 1st challenge: how to read the Group ID?
%

% Makes use of xmlread and java based xml methods -- see 'doc xmlread' in Matlab Help

h = msgbox('Loading MCA data from, please wait...(patiently)', 'Open', 'warn');

fileinfo = h5info(mcafile);
% Probably should grab some of the header info here...

filegroup = fileinfo.Groups.Name;

[mcapath, mcaname, extn] = fileparts(mcafile);

%% Initialization
errors.code = 0;
% Initialize scandata structure and spec substructures:
spec = struct('data', [],'scann',1,'scanline', '', 'npts', [],...
    'columns', 0,'headers',{{}},'motor_names',{{}},'motor_positions', [],...
    'cttime', [],'complete',1,'ctrs',{{}},'mot1','', 'var1',[],...
    'dims', 1,'size', []);

scandata = struct('spec', spec, 'mcadata',[], 'mcaformat', 'aps_hdf5', 'dead', struct('key',''), ...
    'depth', [], 'channels', [], 'mcafile', [mcaname extn], 'ecal', [], 'energy', [], ...
    'specfile',[mcaname extn], 'dtcorr', [], 'dtdel', [], 'image', {{}});

%%
mcadata = h5read(mcafile, [filegroup '/' 'MCA 1']);
scandata.ecal = [0 1 0];
header_cell = h5readatt(mcafile, filegroup, 'Header');
header = header_cell{1};            % Should be a big header string...
% preset = mcadata.item(0).getElementsByTagName('Preset');
% scandata.spec.cttime = sscanf(char(preset.item(0).getFirstChild.getData), '%f');


MCA_channels = size(mcadata, 1);
spectra = size(mcadata, 2);
channels = (0:(MCA_channels-1))';

scandata.spec.header = header;
scandata.spec.npts = spectra;
scandata.spec.size = spectra;
scandata.spec.data = h5read(mcafile, [filegroup '/' 'Detectors']);
scandata.spec.columns = size(scandata.spec.data, 2);
scandata.spec.headers = h5readatt(mcafile, [filegroup '/' 'Detectors'], 'Detector Names');
scandata.spec.ctrs = scandata.spec.headers;
scandata.spec.motor_names = {};
scandata.spec.motor_positions = [];
mot1_cell = h5readatt(mcafile, [filegroup '/' 'X Positions'], 'Motor Info');
scandata.spec.mot1 = mot1_cell{1};
scandata.spec.var1 = h5read(mcafile, [filegroup '/' 'X Positions']);

scandata.mcadata = single(mcadata);
scandata.depth = 1:size(mcadata, 2);
scandata.channels = channels; 
scandata.energy = channel2energy(scandata.channels, scandata.ecal);


% matfile format is now determined farther up...
% matfile = strrep(mcafile, '.mca', '.mat');
fullmatfile = fullfile(mcapath, [mcaname '.mat']);
if exist(fullmatfile, 'file')
    overwrite = questdlg(sprintf('Overwrite existing file %s?', ...
        fullmatfile), 'Overwrite?', 'Yes', 'No', 'Yes');
    if strcmp(overwrite, 'Yes')
        save(fullmatfile,'scandata');
    end
else
    save(fullmatfile,'scandata');
end

% full scandata:
%          spec: [1x1 struct]
%       mcadata: [1024x51x21 single]
%     mcaformat: 'chess1'
%          dead: [1x1 struct]
%         depth: [1x1071 double]
%      channels: [1024x1 double]
%       mcafile: 'teniers5_34.mca'
%          ecal: [-0.4681 0.0199 8.8771e-08]
%        energy: [1024x1 double]
%      specfile: 'teniers5'
%        dtcorr: [51x21 single]
%         dtdel: [51x21 single]
%         image: {1x21 cell}


% scandata.spec
% ans = 
%                data: [10x51x21 double]
%               scann: 34
%            scanline: 'smesh  scany 33.2 33.6 -0.05 0.25 50  scanz 294.3 274.3 20  2'
%                npts: 1071
%             columns: 10
%             headers: {1x10 cell}
%         motor_names: {1x58 cell}
%     motor_positions: [1x58 double]
%              cttime: 2
%            complete: 1
%                ctrs: {'sec'  'Itot'  'Iprot'  'mca'  'CESR'  'Imon'  'Idet'}
%                mot2: 'scanz'
%                mot1: 'scany'
%                var1: [51x21 double]
%                var2: [51x21 double]
%                dims: 2
%                size: [51 21]
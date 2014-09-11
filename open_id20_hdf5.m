function [scandata, errors] = open_id20_hdf5(mcafile)
% function [scandata, errors] = open_id20_hdf5(mcafile)
% Parser for APS HDF5 format. 
%
% NOTES: 
%   1. Data groups appear to be either '/1D Scan' or  '/2D Scan'. XANES may have
%      a different name. 
%   2. h5disp, etc. not available in Matlab 2010. Not sure when it
%      originated. 
%
% h5disp('mncal_ge2um_A_2D.0002.hdf5')
% HDF5 mncal_ge2um_A_2D.0002.hdf5 
% Group '/' 
%     Group '/2D Scan' 
%         Attributes:
%             'VERSION':  2.000000
%             'TAG':  'S20'
%             'Header':  '# 2-D Scan File created by LabVIEW... 
%                           ...'
%         Dataset 'Detectors' 
%             Size:  18x41x6
%             Attributes:
%                 'Detector Names':  'Preslit', 'caldiode_Iref', 'PreKB_I0', 'IT', 'MERCURY:DT Corr I0 ', 'MERCURY::Total', 'MERCURY::ClKa', 'MERCURY::CaKa', 'MERCURY::MnKa', 'MERCURY::MnKb', 'MERCURY::ZnKa', 'MERCURY::AsKa', 'MERCURY::AsKb', 'MERCURY::AuLg', 'MERCURY::ZrKb', 'MERCURY::ZrNbL', 'MERCURY::MoKa', 'MERCURY::MoKb'
%                 'DATASET_TYPE':  'DETECTORS'
%         Dataset 'MCA 1' 
%             Size:  2048x41x6
%             Attributes:
%                 'DATASET_TYPE':  'MCA'
%         Dataset 'X Positions' 
%             Size:  1x41x6
%             Attributes:
%                 'Motor Info':  'fine-focus', ''
%                 'DATASET_TYPE':  'X'
%         Dataset 'Y Positions'  
%             Size:  6x1
%             Attributes:
%                 'DATASET_TYPE':  'Y'
%                 'Motor Info':  'ADC KB Vert', ''
%
%
% TODO :
%   1. parse the header for ion chamber info, cttime, energy, etc.
%   2. Ask Dale & Robert to add include Energy Calibration in hdf5 file!
%
% Requires : column.m, add_error.m

h = msgbox('Loading MCA data from, please wait...(patiently)', 'Open', 'warn');
errors.code = 0;
scandata = [];

%% hdf5 validation
% At minimum, we need to:
%    1. Check, nominally at least, that this is APS data with the expected
%    format.
%    2. find group names before invoking them, such as MCA 1.
mca_dataset = 'MCA 1';
header_att = 'Header';
det_dataset = 'Detectors';
mot1_dataset = 'X Positions';
mot2_dataset = 'Y Positions';

fileinfo = h5info(mcafile);
if length(fileinfo.Groups) ~= 1
    errors = add_error(errors, 2, ...
        sprintf('Warning: HDF5 file %s has more than one group, which is unexpected\n',mcafile));
end
filegroup = fileinfo.Groups(1).Name;
if isempty(strfind(filegroup, 'Scan'))
    errors = add_error(errors, 1, ...
        sprintf('Error: 1st group of %s does not appear to have a scan, bad file or add functionality...\n',mcafile));
    return
end
if ~isempty(strfind(filegroup, '1D'))
    dims = 1;
elseif ~isempty(strfind(filegroup, '2D'))
    dims = 2;
else
    errors = add_error(errors, 1, ...
        sprintf('Error: 1st group name of HDF5 file %s is unrecognized...\n',mcafile));
    return
end

% NOTE: The following relies on hard-coded Dataset names. An alternative
% would be to loop through the datasets looking at the 'DATASET_TYPE'
% attribute of each, and finding the match to 'DETECTORS', 'MCA', 'X', and
% 'Y' (for 2D scans). But at the moment I don't see the need. 
datasets = {fileinfo.Groups.Datasets.Name};
if ~any(strcmp(det_dataset, datasets)) || ...
        ~any(strcmp(mca_dataset, datasets)) || ...
        ~any(strcmp(mot1_dataset, datasets)) || ...
        (dims == 2 && ~any(strcmp(mot2_dataset, datasets)))
    errors = add_error(errors, 1, ...
        sprintf('Error: One or more expected Datasets not found in HDF5 file %s is unrecognized...\n',mcafile));
    return
end

%% Initialization
[mcapath, mcaname, extn] = fileparts(mcafile);
errors.code = 0;
% Initialize scandata structure and spec substructures:
spec = struct('data', [],'scann',1,'scanline', '', 'npts', [],...
    'columns', 0,'headers',{{}},'motor_names',{{}},'motor_positions', [],...
    'cttime', [],'complete',1,'ctrs',{{}},'mot1','', 'var1',[],...
    'dims', dims,'size', []);

scandata = struct('spec', spec, 'mcadata',[], 'mcaformat', 'aps_hdf5', 'dead', struct('key',''), ...
    'depth', [], 'channels', [], 'mcafile', [mcaname extn], 'ecal', [], 'energy', [], ...
    'specfile',[mcaname extn], 'dtcorr', [], 'dtdel', [], 'image', {{}});

%%
% The rational way to do the following would be to look through
% DATASET_TYPE attributes of each dataset in order to find the Name of the
% MCA dataset, or warn / pick if there are more than one.
%
% 
mcadata = h5read(mcafile, [filegroup '/' mca_dataset]);
scandata.ecal = [0 1 0];
header_cell = h5readatt(mcafile, filegroup, header_att);
header = header_cell{1};            % Should be a big header string...

mcadata_dims = size(mcadata);   % Expect this to be MCA_channels x D1, or MCA_channels x D1 x D2
MCA_channels = mcadata_dims(1);
scandata.spec.size = mcadata_dims(2:end);
spectra = prod(scandata.spec.size);

channels = (0:(MCA_channels-1))';

scandata.spec.header = header;
scandata.spec.npts = spectra;


% The detectors array happens to be stored in column format, but mcaview
% expects row format. So transpose.
scandata.spec.data = double(h5read(mcafile, [filegroup '/' 'Detectors']));

scandata.spec.columns = size(scandata.spec.data, 2);
scandata.spec.headers = h5readatt(mcafile, [filegroup '/' 'Detectors'], 'Detector Names');
scandata.spec.ctrs = scandata.spec.headers;
scandata.spec.motor_names = {'mot1', 'mot2'};
scandata.spec.motor_positions = [0 1];
mot1_cell = h5readatt(mcafile, [filegroup '/X Positions'], 'Motor Info');
scandata.spec.mot1 = mot1_cell{1};

if scandata.spec.dims == 1 
    if size(scandata.spec.data, 1) == scandata.spec.npts && ...
        size(scandata.spec.data, 2) == scandata.spec.columns   
        scandata.spec.data = scandata.spec.data';
    else
        errors = add_error(errors, 2, ...
            sprintf(['Warning: In %s, I was expecting detectors data to be permuted, ' ...
            'but it does not seem to be. Check?\n'],mcafile));
    end
    scandata.spec.var1 = column(double(h5read(mcafile, [filegroup '/X Positions'])));
elseif scandata.spec.dims == 2
    mot2_cell = h5readatt(mcafile, [filegroup '/Y Positions'], 'Motor Info');
    scandata.spec.mot2 = mot2_cell{1};
    % For some reason, X Positions are dimensioned as [1 x N_X x N_Y], but
    % Y Positions are dimensioned as [N_Y x 1]. 
    % I want both to be [N_X x N_Y]
    scandata.spec.var1 = squeeze(double(h5read(mcafile, [filegroup '/X Positions'])));
    scandata.spec.var2 = double(h5read(mcafile, [filegroup '/Y Positions']));
    if all(size(scandata.spec.var2) == [scandata.spec.size(2) 1])
        scandata.spec.var2 = repmat(scandata.spec.var2', scandata.spec.size(1), 1);
    else
        errors = add_error(errors, 1, ...
            sprintf('Error reading hdf5: Dimenion of Y Positions in HDF5 file %s not as expected...\n',mcafile));
        return
    end
    if any(size(scandata.spec.var1) ~= size(scandata.spec.var2))
        errors = add_error(errors, 1, ...
            sprintf('Error reading hdf5: making dimensions of var2 / Y Positions agree with var1 / X Positions\n'));
        return
    end
else
    errors = add_error(errors, 2, ...
        sprintf('Error reading %s: Cannot handle > 2D scans', mcafile));
end



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

close(h);

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
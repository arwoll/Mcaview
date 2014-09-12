function out_struct = open_id20_hdf5_parse_head(header_str)
out_struct = [];

ion_chambers = struct('name', {}, 'sensitivity', {}, ...
    'V0', {}', 'V1', {}); % Sensitivity in A/V

line_starts = strfind(header_str, '#');
line_feeds = strfind(header_str, char(10));
k = line_starts(1);

% Clearly, the following is the proper motif for scanning the header.
% Get Integration time:
int_time_str = 'Integration time';
location = strfind(header_str, int_time_str);
if ~isempty(location)
    cttime = sscanf(header_str(location + length(int_time_str) : end), '%f', 1);    
end
% Next, get sensitivities, voltages, filters, and (perhaps) energy

%     elseif ~isempty(strfind(partline, 'Sensitivities'))
%         nextline = [fgets(header_str) char(13)];
%         fileheader = horzcat(fileheader, nextline);
%         [tok, partline] = strtok(nextline);
%         values = textscan(partline(1:end-1), '%s %f %s', 'whitespace', ' \b\t:');
%         for k = 1:length(values{1})
%            ion_chambers(k).name = values{1}{k};
%            ion_chambers(k).sensitivity = values{2}(k);
%            switch values{3}{k}
%                case 'nA/V'
%                    ion_chambers(k).sensitivity = ion_chambers(k).sensitivity * 1e-9;
%                case 'pA/V'
%                    ion_chambers(k).sensitivity = ion_chambers(k).sensitivity * 1e-12;
%            end
%         end
%     elseif ~isempty(strfind(partline, 'Analog Input Voltages'))
%         ic_names = {ion_chambers.name};
%         nextline = [fgets(header_str) char(13)];
%         fileheader = horzcat(fileheader, nextline);
%         [tok, partline] = strtok(nextline);
%         values = textscan(partline(1:end-1), '%s %f %f', 'whitespace', ' \b\t:/');
%         for k = 1:length(values{1})
%            this_ic = strcmp(values{1}{k}, ic_names);
%            if any(this_ic)
%                ion_chambers(this_ic).V0 = values{2}(k);
%                ion_chambers(this_ic).V1 = values{3}(k);
%            end
%         end
%     end
% end
% 
% out_struct.ion_chambers = ion_chambers;
% out_struct.header = fileheader;
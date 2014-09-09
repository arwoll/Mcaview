function results = mcaview_batch_process(rois)
% function results = mcaview_batch_process(rois)
%
% Given a set of ROIs, normally obtained in menu_file_batch_Callback,
% returns some consistent set of info about these ROIs.  
% For the moment, the ROIs must all be of the same type...
%
% As of APril 17th 2006 this function is more or less a bust...
% 
type = rois(1).type;

results = [];
switch type
    case 'energy'
        for m = 1:length(rois)
            results.e_com(m) = rois(m).e_com;
            results.area(m) = rois(m).area;
        end
    case 'depth'
%         for m = 1:length(rois)
%             x = rois(m).x;
%             y = rois(m).y;
%             dstep = x(2)-x(1);
% %             Instead of using find_peak,  we should be using the depth
% %             resolution -- which might be given as a function handle
% %             parameter or some such thing...
%             pd = find_peak(x, y);
%            newy = gauss_filt(x, y, pd.fwhm/2.0);
%            peaks = find_peak_locations(x, newy);
%             results.com(m) = pd.com
%             results.area(m) = pd.area;
         end
end
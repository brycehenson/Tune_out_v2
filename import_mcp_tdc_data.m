function [mcp_tdc_data,import_opts]=import_mcp_tdc_data(import_opts)
%import_data - imports data into a convineint strucure with mat file cache
%designed to decrease time-to-results this function deals with the tedious importing of data
%will load data from a cashed version if import_opts has not changed
%the output is a well aranged structure with everything you could want
%
% Syntax:  [data,import_opts]=import_data(import_opts)
%
% Inputs:
%    import_opts.dir            - string,directory of data files
%    import_opts.file_name      -string, file name before number eg d543.txt would be 'd'
%    import_opts.force_load_save-forces to load from cache, overides force_reimport & force_forc
%    import_opts.force_reimport -logical,override the cache
%    import_opts.force_forc;    -logical,remake the forc preconverted files
%    import_opts.dld_xy_rot     -float, rotation angle in radians
%    import_opts.txylim         -[3x2]float array,t,x,y limits in seconds,meters
%    import_opts.shot_num       -[1,shots] numbers of data files to import
%
% Outputs:
%    import_opts - struct, only changes made should be to add a \ to the end of import_opts.dir if required
%    mcp_tdc_data - struct
%    mcp_tdc_data.time_create_write-[shots,2]float array, posix time of when the data file was writen
%    mcp_tdc_data.num_counts -[1,shots]float array, number of counts in reconstucted data
%    mcp_tdc_data.counts_txy -{1,shots}cell array containing [counts,3] float array of time,x position, y position in seconds
%                               ,meters
%    mcp_tdc_data.shot_num   -[1,shots] numbers of data files that were imported, note not ness. the same as import_opts.shot_num 
%                               if for example there were missing files
%
% Example: 
%     import_opts.dir='C:\User\data\'
%     import_opts.file_name='d';
%     import_opts.force_reimport=0;
%     import_opts.force_forc=0;
%     import_opts.dld_xy_rot=0.61;
%     xlim=[-20e-3, 20e-3];     %tight XY lims to eliminate hot spot from destroying pulse widths
%     ylim=[-20e-3, 20e-3];
%     tlim=[.4,1.4];
%     import_opts.txylim=[tlim;xlim;ylim];
%     import_opts.shot_num=find_data_files(import_opts);
%     [data,import_opts]=import_data(import_opts);
%     vertcat(data.txy{data.total_num>1e3}) %combine all the data for shots with more than 1e3 counts

% Other m-files required: dld_raw_to_txy,masktxy,data_tcreate,dld_read_5channels_reconst_multi_imp,txy_importer
% Also See:find_data_files
% Subfunctions: none
% MAT-files required: none
%
% Known BUGS/ Possible Improvements
%    -more commenting
%    -dir \ adding is not linux friendly
%    -check for inputs
%    -multi layer cache & consider storing in import dir
%
% Author: Bryce Henson
% email: Bryce.Henson@live.com
% Last revision:2018-08-19

%------------- BEGIN CODE --------------

%do some basic checks on input
if ~isfield(import_opts, 'dir') ,error('bad input:dir'), end
if ~isfield(import_opts, 'file_name') ,error('bad input:file_name'), end
if ~isfield(import_opts, 'force_reimport') ,error('bad input:force_reimport'), end
if ~isfield(import_opts, 'dld_xy_rot') ,error('bad input:dld_xy_rot'), end
if ~isfield(import_opts, 'txylim') ,error('bad input:txylim'), end
if ~isfield(import_opts, 'dld_xy_rot') ,error('bad input:dld_xy_rot'), end
if ~isfield(import_opts, 'shot_num') ,error('bad input:dld_xy_rot'), end

if ~isa(import_opts.dir,'char') ,error('bad input:dir'), end
if ~isa(import_opts.file_name,'char') ,error('bad input:file_name'), end
if ~isa(import_opts.force_reimport,'logical') ,error('bad input:force_reimport'), end
if ~isa(import_opts.dld_xy_rot,'double') ,error('bad input:dld_xy_rot'), end
if ~isa(import_opts.txylim,'double') && size(import_opts.txylim)== [3,2]
    error('bad input:txylim'), end
if ~isa(import_opts.shot_num,'double') ,error('bad input:dld_xy_rot'), end



%fix if there is not a trailing \ on the directory
%NOT LINUX FRIENDLY!!!
if import_opts.dir(end)~='\'
    import_opts.dir=[import_opts.dir,'\'];
end
   
    
import_data=true;

%sanity checks
if numel(import_opts.shot_num)==0
    error('nothing passed to import_opts.shot_num')
end

if isfile('import_mcp_tdc_save.mat') && (import_opts.force_load_save || (~import_opts.force_forc && ~import_opts.force_reimport) )
    load('import_mcp_tdc_save.mat','import_opts_old')
    import_opts_old.force_reimport=import_opts.force_reimport; %prevents reimport after import_opts.force_reimport changed 1->0
    import_opts_old.force_forc=import_opts.force_forc;
    if isequal(import_opts_old,import_opts) || import_opts.force_load_save
        import_data=false; 
        fprintf('import_opts the same loading old data...')
        load('import_mcp_tdc_save.mat','mcp_tdc_data','import_opts_old')
        import_opts=import_opts_old;
        fprintf('Done\n')
    else
        clear('data')
    end
end


if import_data
    fprintf('importing files %04i:%04i',size(import_opts.shot_num,2),0)
    for ii=1:size(import_opts.shot_num,2)
        if ~(exist([import_opts.dir,import_opts.file_name,num2str(import_opts.shot_num(ii)),'.txt'],'file')==2)
                    data.txy{ii}=[];
                    fprintf('\n no_file %04i \n %04i\n',ii,ii)
        else
            %if the txy_forc does not exist or if import_opts.force_forc (re) make it
            if ~(exist([import_opts.dir,import_opts.file_name,'_txy_forc',num2str(import_opts.shot_num(ii)),'.txt'],'file')==2)...
                    || import_opts.force_forc
                dld_raw_to_txy([import_opts.dir,import_opts.file_name],import_opts.shot_num(ii),import_opts.shot_num(ii));
            end
            txydata=txy_importer([import_opts.dir,import_opts.file_name],num2str(import_opts.shot_num(ii)));
            txydata=masktxy(txydata,import_opts.txylim); %mask for counts in the window txylim     
            alpha=-import_opts.dld_xy_rot;
            mcp_tdc_data.counts_txy{ii}=txydata*[1 0 0;0 cos(alpha) -sin(alpha); 0 sin(alpha) cos(alpha)];
            mcp_tdc_data.num_counts(ii)=size(txydata,1);
            mcp_tdc_data.time_create_write(ii,:)=data_tcreate([import_opts.dir,import_opts.file_name],num2str(import_opts.shot_num(ii)));
            mcp_tdc_data.shot_num(ii)=import_opts.shot_num(ii);
        end %file exists condition
    fprintf('\b\b\b\b%04i',ii)
    end
    import_opts_old=import_opts;
    fprintf('\b\b\b\b...Done\nSaving mat file...')
    

    %saving the data takes a while, some comparisons:
        %compression on 66s , 1,741,941,211bytes
        %'-nocompression' 72s , 2,078,423,812bytes
    save('import_mcp_tdc_save.mat','mcp_tdc_data','import_opts_old','-v7.3');
    fprintf('Done\n')
end
end

%%import_opts.dld_xy_rot=0.61;s
%old rotation method
%             sin_theta = sin(import_opts.dld_xy_rot);
%             cos_theta = cos(import_opts.dld_xy_rot);
%             three_channel_output_rot(:,1) = txydata(:,1);
%             three_channel_output_rot(:,2) = txydata(:,2)*cos_theta...
%                 - txydata(:,3)*sin_theta;
%             three_channel_output_rot(:,3) = txydata(:,2)*sin_theta...
%                 + txydata(:,3)*cos_theta;


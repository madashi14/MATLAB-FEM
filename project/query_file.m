%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Libreria utilities 
% Giuseppe Catania, 2014-21
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [file,name]= query_file(dir,mask,permission,title)

    if nargin<4
        title= 'Get File';
    end
    if  nargin <3
        permission= 'r';
    end
    if nargin<2
        mask= '.*';
    end
    if  nargin<1
        dir= '.\';
    end

    switch permission
        case 'r'
            [fname,fpath]= uigetfile(sprintf('%s\\%s',dir,mask),title);
        case 'w'
            [fname,fpath]= uiputfile(sprintf('%s\\%s',dir,mask),title);
        otherwise
            errordlg('Error in query_file()');
    end
    if ischar(fpath) && ischar(fname)
        file=sprintf('%s%s',fpath, fname);
        indx= strfind(fname,mask);
        if ~isempty(indx)
            name= fname(1:indx-1);
        else
            name= fname;
        end
    else
        file= [];  name=[];
    end
end
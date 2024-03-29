function LMinstall(varargin)
%
% Downloads a set of folders from the LabelMe dataset.
%
% 1) Install all the images into the local paths: HOMEIMAGES, HOMEANNOTATIONS
%  LMinstall(HOMEIMAGES, HOMEANNOTATIONS);
%
% 2) install only images in the specified folders
%  LMinstall(folderlist, HOMEIMAGES, HOMEANNOTATIONS);
%
% 3) install only the images specified
%  LMinstall(folders, images, HOMEIMAGES, HOMEANNOTATIONS);
%
% HOMEIMAGES and HOMEANNOTATIONS point to your local destination folders.
%
% This function is useful if you do not want to download the entire
% dataset. You can first browse the dataset, and when you have decided for
% a set of folders that you want to use, you can use this function to
% download only those folders.
%
% Contribute to the dataset by labeling few images:
% http://labelme.csail.mit.edu/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LabelMe is a WEB-based image annotation tool and a Matlab toolbox that allows 
% researchers to label images and share the annotations with the rest of the community. 
%    Copyright (C) 2007  MIT, Computer Science and Artificial
%    Intelligence Laboratory. Antonio Torralba, Bryan Russell, William T. Freeman
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% If this function stops working, you might need to download the newest
% version of the toolbox in order to update the web addresses:

webpageanno = 'http://labelme.csail.mit.edu/Annotations';
webpageimg = 'http://labelme.csail.mit.edu/Images';

Narguments = length(varargin);

switch Narguments
    case {0,1}
        error('Not enough input arguments.')
    case 2
        disp('Install full database')
        HOMEIMAGES = varargin{1};
        HOMEANNOTATIONS = varargin{2};
        folderlist = urldir(webpageimg, 'DIR');
        folderlist = {folderlist(:).name};
        if strcmp(folderlist{1}(1),'/'); % remove root folder
            folderlist = folderlist(2:end);
        end
    case 3
        folderlist = varargin{1};
        HOMEIMAGES = varargin{2};
        HOMEANNOTATIONS = varargin{3};
    case 4
        folders = varargin{1};
        filelist = varargin{2};
        folderlist = unique(folders);
        HOMEIMAGES = varargin{3};
        HOMEANNOTATIONS = varargin{4};
    case 5
        folders = varargin{1};
        folderlist = unique(folders);
        HOMEIMAGES = varargin{2};
        HOMEANNOTATIONS = varargin{3};
        webpageimg = varargin{4};
        webpageanno = varargin{5};
    case 6
        folders = varargin{1};
        folderlist = unique(folders);        
        filelist = varargin{2};
        HOMEIMAGES = varargin{3};
        HOMEANNOTATIONS = varargin{4};
        webpageimg = varargin{5};
        webpageanno = varargin{6};
end

Nfolders = length(folderlist);

% create folders:
disp('create folders');
for i = 1:Nfolders
    mkdir(HOMEIMAGES, folderlist{i});
    mkdir(HOMEANNOTATIONS, folderlist{i});
end


disp('download images and annotations...')
for f = 1:Nfolders
    disp(sprintf('Downloading folder %s (%d/%d)...',  folderlist{f}, f, Nfolders))
    
    wpi = [webpageimg  '/' folderlist{f}];
    wpa = [webpageanno '/' folderlist{f}];
    
    if ismember(Narguments, [1 2 3 5]) 
        images = urldir(wpi, 'img');
        if ~isempty(images)
            images = {images(:).name};
        end
        
        annotations = urldir(wpa, 'txt');
        if ~isempty(annotations)
            annotations = {annotations(:).name};
        end
    else
        j = strmatch(folderlist{f}, folders, 'exact');
        images = filelist(j);
        annotations = strrep(filelist(j), '.jpg', '.xml');
    end
    
    
    Nimages = length(images);
    for i = 1:Nimages
        fp = fopen(fullfile(HOMEIMAGES,folderlist{f}, images{i}));
        if fp < 0
			disp(sprintf('    Downloading image %s (%d/%d)...',  images{i}, i, Nimages))
			[F,STATUS] = urlwrite([wpi '/' images{i}], fullfile(HOMEIMAGES, folderlist{f}, images{i}));
		else
            fclose(fp); 
            disp(sprintf('no need to download again: %s', images{i}))
		end
    end
    
    Nanno= length(annotations);
    for i = 1:Nanno
        disp(sprintf('    Downloading annotation %s (%d/%d)...',  annotations{i}, i, Nanno))
        [F,STATUS] = urlwrite([wpa '/' annotations{i}], fullfile(HOMEANNOTATIONS,folderlist{f},annotations{i}));
        if STATUS == 0
            disp(sprintf('annotation file %s does not exist', annotations{i}))
        end
    end
end

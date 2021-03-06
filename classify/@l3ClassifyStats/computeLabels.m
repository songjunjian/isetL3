function labels = computeLabels(obj, s, p_type, varargin)
% Compute labels based on statistics
%
%   labels = computeLabels(obj, s, varargin)
%
% Inputs:
%   obj    - l3ClassifyStats instance
%   s      - statistics matrix, each column represents stats from one patch
%   p_type - center pixel type of each type as a 1xN vector
%
% Outputs:
%   labels - labels of each patch
%
% Example:
%   s might be [ mean, contrast].  So, s(whichStat, whichPatch).
%   Each of the statistic types has a set of cutpoints (threshold levels
%   that separate the classes). 
%
%
% HJ, VISTA TEAM, 2015

% Programming note.
%   Maybe we should blur the classes by putting a probability that a sample
%   is placed in each bin, rather than having a hard threshold.  So, some
%   samples a little above the cutpoint might be placed in the one below,
%   and some a little below in the one above.  This would reduce the
%   'choppiness' of the hard threshold.

% Check inputs
if notDefined('s'), error('stats matrix required'); end
if notDefined('p_type'), error('pixel type is not defined'); end

% Compute levels of each statistics
lvl = cell(size(s, 1), 1);
for ii = 1 : size(s, 1)
    cp = [obj.cutPoints{ii}(:)' inf];
    
    % Check less than or equal on the statistics, and find the max of all
    % the returned indices, and store that max in lvl{ii}
    [~, lvl{ii}] = max(bsxfun(@le, s(ii, :)', cp), [], 2);
end

% Compute overall label index
nc = length(unique(p_type(:, 1)));  % number of channel types

% Number of channel types x Number of classes for each statistic
% obj.cutPoints is a cell array with dimension equal to the number of
% statistics.  We add one because if there are N cutpoints we have N+1
% classes.
aSize = [nc, cellfun(@(x) length(x), obj.cutPoints) + 1]; 

% Patch size should be odd to have a center.  There will be an error if the
% patch size is even.  That's OK.  We want the error.
r = (obj.patchSize(1)+1)/2; c = (obj.patchSize(2)+1)/2;
col = sub2ind(obj.patchSize, r, c);

% The class labels take the vector
%  [channel, statClasses1, statClasses2 ...]
%  centerPixelTypes, Number of Levels for each statistic.  Matlab expands
%  lvl{:} to a list of dimension values.
labels = sub2ind(aSize, p_type(col, :)', lvl{:});

end
function [statistics] = computePrecisionStatistics(precision_result)

% find the number of YUD images (maybe, 102)
numImage = length(precision_result);


% compute distribution of precision
numTemp1 = sum(precision_result >= 0.975);
precision_result(precision_result >= 0.975) = [];

numTemp2 = sum(precision_result >= 0.950);
precision_result(precision_result >= 0.950) = [];

numTemp3 = sum(precision_result >= 0.925);
precision_result(precision_result >= 0.925) = [];

numTemp4 = sum(precision_result >= 0.900);
precision_result(precision_result >= 0.900) = [];

numtemp5 = size(precision_result,2);


% check the total number of images and distribution
if (numImage ~= (numTemp1 + numTemp2 + numTemp3 + numTemp4 + numtemp5))
    error('Something is wrong in computePrecisionStatistics!!');
end


% return precision distribution
statistics = [numtemp5, numTemp4, numTemp3, numTemp2, numTemp1];


end


function [statistics] = computeRecallStatistics(recall_result)

% find the number of YUD images (maybe, 102)
numImage = length(recall_result);


% compute distribution of recall
numTemp1 = sum(recall_result >= 0.950);
recall_result(recall_result >= 0.950) = [];

numTemp2 = sum(recall_result >= 0.900);
recall_result(recall_result >= 0.900) = [];

numTemp3 = sum(recall_result >= 0.850);
recall_result(recall_result >= 0.850) = [];

numTemp4 = sum(recall_result >= 0.800);
recall_result(recall_result >= 0.800) = [];

numtemp5 = size(recall_result,2);


% check the total number of images and distribution
if (numImage ~= (numTemp1 + numTemp2 + numTemp3 + numTemp4 + numtemp5))
    error('Something is wrong in computeRecallStatistics!!');
end


% return recall distribution
statistics = [numtemp5, numTemp4, numTemp3, numTemp2, numTemp1];


end


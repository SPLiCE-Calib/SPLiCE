function x1 = find_x1(X, threshold)
% FIND_X1 Detect sudden jump in X data and return the value just before it.
% 
%   x1 = FIND_X1(X, threshold)
%
%   Inputs:
%       X          - column vector of X values
%       threshold  - minimum diff value to consider as "sudden jump"
%
%   Output:
%       x1         - X value just before first big jump

    if nargin < 2
        threshold = 200;  % 기본 임계값 (필요시 조정)
    end

    dX = diff(X);

    % 큰 변화가 나타나는 인덱스 찾기
    jumpIndices = find(dX > threshold);

    if isempty(jumpIndices)
        warning('No sudden jump found. Returning last X value.');
        x1 = X(end);
        return;
    end

    % 첫 번째 급격한 변화 직전의 값 선택
    idxBeforeJump = jumpIndices(1);
    x1 = X(idxBeforeJump);

end

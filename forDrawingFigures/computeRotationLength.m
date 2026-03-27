function [rotationLength] = computeRotationLength(R_gc_true)

% assign current parameters
M = length(R_gc_true);


% compute rotation movement per frame
rotationMovement = zeros(1,M);
for k = 2:M
    rotationMovement(k) = acos((trace(R_gc_true(:,:,k-1).' * R_gc_true(:,:,k))-1)/2) * (180/pi);
end


% return accumulated rotation length in degree
rotationLength = sum(rotationMovement);


end


function [ellip] = general_determineEllipse(planeNormal, d)

% 联立x^2+y^2+z^2=1 和 ax+by+cz+d=0 消掉z  note that we have d

% 一般方程 A x^2 + B xy + C y^2 + D x + E y = F  % 注意这个是和后面sampleEllipse的形式等价（F在右边）

    a = planeNormal(1);
    b = planeNormal(2);
    c = planeNormal(3);

    A = a^2/c^2+1;
    B = 2*a*b/c^2;
    C = b^2/c^2+1;
    D = 2*a*d/c^2;
    E = 2*b*d/c^2;
    F = 1-d^2/c^2;
    
    ellip = [A; B; C; D; E; F];
end
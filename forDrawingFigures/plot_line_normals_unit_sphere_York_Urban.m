function plot_line_normals_unit_sphere_York_Urban(imageCurForLine, lines, cam, R_cM, optsMWMS)

% refine lines and related line normals
[lines, ~, lineNormals] = extractGreatcircle(imageCurForLine, lines, cam);
lineNormals = lineNormals.';


% find useless (invalid) lines for Manhattan world
optsMWMS.verticalLineNormalAngleThreshold = 10;
optsMWMS.verticalPolarRegionAngleThreshold = 0;
invalidIndex = findInvalidManhattanLines(R_cM(:,3), lineNormals, optsMWMS);
lineNormals(:,invalidIndex) = [];


% plot normal vector of great circle from image lines
for k = 1:size(lineNormals,2)
    normal = lineNormals(:,k);
    plot3(normal(1),normal(2),normal(3),'o','MarkerSize',10,'LineWidth',1.5,'Color','k','MarkerFaceColor',[180/255,180/255,180/255]);
end


end


function [h1, h2] = plot_vertical_dominant_direction(verticalDominantDirection, arrowColor, arrowStemWidth)

% original vertical (gravity) direction
h1 = mArrow3([0;0;0],verticalDominantDirection,'color',arrowColor,'stemWidth',arrowStemWidth);

% inverse vertical (gravity) direction
h2 = mArrow3([0;0;0],-verticalDominantDirection,'color',arrowColor,'stemWidth',arrowStemWidth);


end


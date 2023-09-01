t_2 = 2;
Wd = W_d(:,:,t_2);
[X,Y] = meshgrid(1:1:l, 1:1:w);
Z = griddata(W_d(:,1,t_2), W_d(:,2,t_2), W_d(:,3,t_2),X,Y);

Wd1 = W_d1(:,:,t_2);
[X1,Y1] = meshgrid(1:1:l, 1:1:w);
Z1 = griddata(W_d1(:,1,t_2), W_d1(:,2,t_2), W_d1(:,3,t_2),X1,Y1);

Wd2 = W_d2(:,:,t_2);
[X2,Y2] = meshgrid(1:1:l, 1:1:w);
Z2 = griddata(W_d2(:,1,t_2), W_d2(:,2,t_2), W_d2(:,3,t_2),X2,Y2);

Wd3 = W_d3(:,:,t_2);
[X3,Y3] = meshgrid(1:1:l, 1:1:w);
Z3 = griddata(W_d3(:,1,t_2), W_d3(:,2,t_2), W_d3(:,3,t_2),X3,Y3);


hf = figure;
sgtitle(['progress of wildfire',' after ',num2str(t_2),' minutes'])
ha1 = subplot(2,2,1);
hp = pcolor(ha1,X,Y,Z);
shading(ha1,'interp')
colormap(ha1,jet)
clim([-1 1])
view(ha1,2)

ha2 = subplot(2,2,2);
hp1 = pcolor(ha2,X1,Y1,Z1);
shading(ha2,'interp')
colormap(ha2,jet)
clim([-1 1])
view(ha2,2)

ha3 = subplot(2,2,3);
hp2 = pcolor(ha3,X2,Y2,Z2);
shading(ha3,'interp')
colormap(ha3,jet)
clim([-1 1])
view(ha3,2)

ha4 = subplot(2,2,4);
hp3 = pcolor(ha4,X3,Y3,Z3);
shading(ha4,'interp')
colormap(ha4,jet)
clim([-1 1])
view(ha4,2)



for t_2 = 1:510
sgtitle(['progress of wildfire',' after ',num2str(t_2),' minutes'])

subplot(2,2,1)
title('In normal case')
Wd = W_d(:,:,t_2);
[X,Y] = meshgrid(1:1:l, 1:1:w);
Z = griddata(W_d(:,1,t_2), W_d(:,2,t_2), W_d(:,3,t_2),X,Y);
set(hp,'CData',Z)
pbaspect([8 5 1])

subplot(2,2,2)
title('Reduce the density by 1/3 after 60 minutes')
Wd1 = W_d1(:,:,t_2);
[X1,Y1] = meshgrid(1:1:l, 1:1:w);
Z1 = griddata(W_d1(:,1,t_2), W_d1(:,2,t_2), W_d1(:,3,t_2),X1,Y1);
set(hp1,'CData',Z1)
pbaspect([8 5 1])

subplot(2,2,3)
Wd2 = W_d2(:,:,t_2);
title('Premake the walking trail')
[X2,Y2] = meshgrid(1:1:l, 1:1:w);
Z2 = griddata(W_d2(:,1,t_2), W_d2(:,2,t_2), W_d2(:,3,t_2),X2,Y2);
set(hp2,'CData',Z2)
pbaspect([8 5 1])

subplot(2,2,4)
Wd3 = W_d3(:,:,t_2);
title('Premake the walking trail and sprinkle hydrex on it')
[X3,Y3] = meshgrid(1:1:l, 1:1:w);
Z3 = griddata(W_d3(:,1,t_2), W_d3(:,2,t_2), W_d3(:,3,t_2),X3,Y3);
set(hp3,'CData',Z3)
pbaspect([8 5 1])

pause(0.01)

if t_2 == t
    break
end

end
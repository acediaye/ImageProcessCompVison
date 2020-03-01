clear
clc

myimage=zeros(300,300);%demo image
xcenter=150;%set origin
ycenter=150;
radius=100;%set radius
theta=linspace(0,2*pi,round(4*pi*radius));%going around twice to make sure there are no gaps in circle due to discretized
x=radius*cos(theta)+xcenter;%equation for circle
y=radius*sin(theta)+ycenter;
for k=1:length(x)%for each x,y pair
    row=round(y(k));
    col=round(x(k));
    myimage(row,col)=255;%white circle
end
figure(1)
imshow(myimage)
title('original image')
axis on

[height,width]=size(myimage);
a_axis=0+1:1:size(myimage,2);%same size as width
b_axis=0+1:1:size(myimage,1);%same size as height
radius=50+1:1:350;%for radius range for unknown radius 3D
thetas=0+1:1:360;%for 0-360 degrees
numthetas=length(thetas);
accumulator=zeros(length(b_axis),length(a_axis));%same dimensions as image(row,col)%2D
%accumulator=zeros(length(b_axis),length(a_axis),length(radius));%same dimensions as image(row,col) 3D
for y=1:height
    for x=1:width
        if myimage(y,x)>0%for each edge pixel
            %for z=1:length(radius)%for unknown radius 3D
                %r=radius(z);%for unknown radius 3D
                r=100;%for static radius 2D
                for k=1:numthetas%for 0-360 degrees
                    a=x-r*cosd(thetas(k));%circle parametric equation
                    b=y-r*sind(thetas(k));%for certain x,y get a,b pair
                    if a>=1 && a<=size(myimage,2) && b>=1 && b<=size(myimage,1)%check within boundary
                        accumulator(round(b),round(a))=accumulator(round(b),round(a))+1;%2D
                        %accumulator(round(b),round(a),z)=accumulator(round(b),round(a),z)+1;%3D
                    end
                end
            %end%for 3D
        end
    end
end
figure(2)
imshow(imadjust(rescale(accumulator)),[],'XData',a_axis,'YData',b_axis,'InitialMagnification','fit')%2D only
xlabel('a_axis')
ylabel('b_axis')
title('accumulator')
axis on
axis normal
colormap(gray)

houghimage=zeros(height,width);%init output image
threshold = .9*max(max(accumulator));%threshold 2D
%threshold = .9*max(max(max(accumulator)));%threshold 3D
[height,width,depth]=size(accumulator);%my accumulator size
count=0;
r=100;%for static radius 2D
for i=1:height%for b_axis
    for j=1:width%for a_axis
        %for m=1:depth%for radius 3D
            if accumulator(i,j)>threshold%above threshold 2D
            %if accumulator(i,j,m)>threshold%above threshold 3D
                b=b_axis(i);%take out b
                a=a_axis(j);%take out a
                %r=radius(m);%take out r 3D
                sprintf("a %d, b %d, r %d",a,b,r)%print a,b from accumulator>threshold
                count=count+1;
                theta=linspace(0,2*pi,round(4*pi*r));%going around twice to make sure there are no gaps in circle due to discretized
                x=r*cos(theta)+a;%for certain a,b get x,y pair
                y=r*sin(theta)+b;
                for k=1:length(x)%for each x,y pair
                    row=round(y(k));
                    col=round(x(k));
                    if row>=1 && row<=size(myimage,1) && col>=1 && col<=size(myimage,2)%check boundary range
                        houghimage(row,col)=255;%white circle
                    end
                end
            end
        %end%for 3D
    end
end
count%display draw count from accumulator>threshold
figure(3)
imshow(houghimage)
title('hough image')
axis on

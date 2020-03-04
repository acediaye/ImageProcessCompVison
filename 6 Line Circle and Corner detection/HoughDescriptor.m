clear 
clc

height=300;
width=300;

xT=[50 100 150 200 250];%image 1, init set points
yT=[50 100 150 200 250];
thetaT=[45 45 45 45 45];
shift=[300;%translation
       0];
rotate=90;%rotation

demoimage1=zeros(height,width);
for i=1:length(xT)
    demoimage1(yT(i),xT(i))=255;%create image 1
end
T1=[1 0 shift(1);
    0 1 shift(2);
    0 0       1];
T2=[cosd(rotate) -sind(rotate) 0;
    sind(rotate)  cosd(rotate) 0;
          0         0          1];
demoimage2=zeros(height,width);
points=[];
for y=1:height
    for x=1:width
        if demoimage1(y,x)>0%transform image 1 template to query
            vector=[x;
                    y;
                    1];
            result=T1*T2*vector;
            if result(1)>=1 && result(1)<=300 && result(2)>=1 && result(2)<=300%check within bounds
                demoimage2(round(result(2)),round(result(1)))=255;%set pixel white
                points=horzcat(points, round(result));%append points
            end
        end
    end
end
length(points);
xQ=points(1,:);%create image 2
yQ=points(2,:);
thetaQ=thetaT+rotate;
%{
for i=1:length(xT)
    demoimage1(yT(i),xT(i))=255;
    demoimage2(yQ(i),xQ(i))=255;
end
%}
outimage1=zeros(height,width);
outimage2=zeros(height,width);
for y=1:height
    for x=1:width
        if demoimage1(y,x)>0
            outimage1(y-1:y+1,x-1:x+1)=255;%enlarge pixel neighborhood as white
        end
        if demoimage2(y,x)>0
            outimage2(y-1:y+1,x-1:x+1)=255;%enlarge pixel neighborhood as white
        end
    end
end
figure(1)
imshow(outimage1)
title('image 1')
figure(2)
imshow(outimage2)
title('image 2')

myimage=outimage1;
[height,width]=size(myimage);
maxdist=round(sqrt(height^2+width^2));
distX=-size(myimage,2)+1:1:size(myimage,2);%init -width to width, need neg numbers
distY=-size(myimage,1)+1:1:size(myimage,1);%init -height to height, need neg numbers
distT=-180+1:1:180;%init -179->180 degrees, need zero
accumulator=zeros(length(distY),length(distX),length(distT));%accumulator init
M=length(xT);%length of template
N=length(xQ);%lendth of query
for i=1:M%for each template
    for j=1:N%for each query
        %deltatheta = min(||thetaQ-thetaT||,360-||thetaQ-thetaT||)
        %|deltax| = |xT| - | cos(t) -sin(t)| |xQ| 
        %|deltay|   |yT|   |+sin(t)  cos(t)| |yQ| 
        deltat=min((thetaT(i)-thetaQ(j)),360-(thetaT(i)-thetaQ(j)));%min to cover 181->360 degrees
        %deltat=thetaT(i)-thetaQ(j);
        deltax=xT(i)-xQ(j)*cosd(deltat)+yQ(j)*sind(deltat);
        deltay=yT(i)-xQ(j)*sind(deltat)-yQ(j)*cosd(deltat);
        sprintf('dt %d, dx %d, dy %d',deltat,deltax,deltay)%raw answers for delta x,y,theta
        if deltax>=-size(myimage,2)+1 && deltax<=size(myimage,2) && deltay>=-size(myimage,1)+1 && deltay<=size(myimage,1) && deltat>=-179 && deltat<=180%check within boundary
            accumulator(round(deltay)+size(myimage,1),round(deltax)+size(myimage,2),round(deltat)+180)=accumulator(round(deltay)+size(myimage,1),round(deltax)+size(myimage,2),round(deltat)+180)+1;  
        end
    end
end
%{
figure(3)
imshow(imadjust(rescale(accumulator(:,:,1))),[],'XData',distX,'YData',distY,'InitialMagnification','fit')%2D only
xlabel('dist x')
ylabel('dist y')
title('accumulator')
axis on
axis normal
colormap(gray)
%}
max(max(max(accumulator)));

houghimage=zeros(height,width);%init output image
threshold = .9*max(max(max(accumulator)));%threshold 3D
[height,width,depth]=size(accumulator);%my accumulator size
count=0;
for i=1:height%for y
    for j=1:width%for x
        for k=1:depth%for theta
            if accumulator(i,j,k)>threshold%above threshold 3D
                dy=distY(i);%take out y 
                dx=distX(j);%take out x
                dt=distT(k);%take out theta
                sprintf("x %d, y %d, t %d",dx,dy,dt)%print x,y,theta from accumulator>threshold
                count=count+1;                
                %houghimage(y,x)=255;%too small 300x300 to cover accu 600x600
            end
        end
    end
end
count;%display draw count from accumulator>threshold
%figure(4)
%imshow(houghimage)
%title('hough image')
%axis on
%}

%x=0;%manual check x,y,theta
%y=300;
%t=-90;
T1=[1 0 dx;
    0 1 dy;
    0 0  1];
T2=[cosd(dt) -sind(dt) 0;
    sind(dt)  cosd(dt) 0;
         0        0    1];
height=300; width=300;
transimage=zeros(height,width);
for y=1:height
    for x=1:width
        if outimage2(y,x)>0%transform image2 query back to template
            vector=[x;
                    y;
                    1];
            result=T1*T2*vector;
            if result(1)>=1 && result(1)<=300 && result(2)>=1 && result(2)<=300%check within bounds
                transimage(round(result(2)),round(result(1)))=255;%set pixel white
            end
        end
    end
end
figure(3)
imshow(transimage)%should match template
title('untransformation')

%======================================================================%
%minutiae pairing
xT;
yT;
thetaT;
sprintf("x %d, y %d, t %d",dx,dy,dt)
pointsQ=[];
newpoints=[];
for i=1:length(xQ)
    pointsQ=[pointsQ [xQ(i);yQ(i)]];
end
T1=[1 0 dx;
    0 1 dy;
    0 0 1];
T2=[cosd(dt) -sind(dt) 0;
    sind(dt)  cosd(dt) 0;
         0        0  1];
for i=1:length(xQ)
    x=pointsQ(1,i);
    y=pointsQ(2,i);
    vector=[x;
            y;
            1];
    result=T1*T2*vector;
    if result(1)>=1 && result(1)<=300 && result(2)>=1 && result(2)<=300%check within bounds
        newpoints=[newpoints [round(result(1));round(result(2))]];%get untransforms points, should match template points
    end
end
xQ=newpoints(1,:);
yQ=newpoints(2,:);
thetaQ=thetaQ+dt;

M=length(xT);%for length of template
N=length(xQ);%for length of query
fT=zeros(1,M);%flag for each point in template
fQ=zeros(1,N);%flag for each point in query
count=0;
list=[];%list of pairs
threshDist=10;%distance threshold
threshRot=10;%rotation threshold
for i=1:M%for each point in template
    for j=1:N%for each point in query
        distance=sqrt((xT(i)-xQ(j))^2+(yT(i)-yQ(j))^2);
        diffrot=min(thetaT(i)-thetaQ(j),360-thetaT(i)-thetaQ(j));
        if fT(i)==0 && fQ(j)==0 && distance<threshDist && diffrot<threshRot%check conditions
            fT(i)=1;%flag point
            fQ(j)=1;
            count=count+1;
            list=[list [i;j]];%append to list
        end
    end
end
list%top row: points in template matched to bottom row: points in query

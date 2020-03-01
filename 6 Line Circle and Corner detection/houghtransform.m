clear
clc

myimage=zeros(150,150);%demo line image
[row,col]=size(myimage);
for i=1:150%origin top left
    myimage(i,i)=1;%diagonal down %theta=-45 rho=0
    myimage(i,151-i)=1;%diagonal up %theta=45 rho=107
    myimage(75,i)=1;%horizontal %theta=90 rho=75
    myimage(i,75)=1;%vertical %theta=0 rho=75
end
figure(1)
imshow(myimage)
title('original image')
%origin at top left, rho perpendicular distnace to line from origin
rho=75;%manual check line
theta=90;
x0=1;
xend=150;
if theta==0
    line([rho rho],[1 size(myimage,1)], 'Color', 'r');
else
    y0=(rho-x0*cosd(theta))/sind(theta);
    yend=(rho-xend*cosd(theta))/sind(theta);
    line([x0 xend], [y0 yend], 'Color','r');
end

[height,width] = size(myimage);%my image size
maxdist = round(sqrt(height^2+width^2));%diagonal image distance
thetas = -90+1:1:90;%all theta range
rhos = -maxdist+1:1:maxdist;%all rho range
numthetas = length(thetas);
numrhos = length(rhos);
accumulator = zeros(numrhos,numthetas);%initialize accumulator
for y=1:height
    for x=1:width
        if myimage(y,x)>0%if edge pixel
            for k=1:numthetas%for each theta
                rho=x*cosd(thetas(k))+y*sind(thetas(k));%calc corresponding rho
                accumulator(round(rho)+maxdist,k)=accumulator(round(rho)+maxdist,k)+1;%vote
            end
        end
    end
end
figure(2)
imshow(imadjust(rescale(accumulator)),[],'XData',thetas,'YData',rhos,'InitialMagnification','fit')
xlabel('\theta (degrees)')
ylabel('\rho')
title('accumulator')
axis on
axis normal
colormap(gray)

figure(3)
houghimage=zeros(height,width);%init output image
threshold = 0.9*max(max(accumulator));%threshold
[height,width]=size(accumulator);%my accumulator size
%imshow(myimage)
count=0;
for y=1:height
    for x=1:width
        if accumulator(y,x)>threshold
            rho=rhos(y);%take out rho
            theta=thetas(x);%take out theta
            sprintf("theta %d, rho %d",theta,rho);%display theta, rho from accumulator>threshold
            count=count+1;
            x0=1;%x start
            xend=size(myimage,2);%x end
            %{
            if theta == 0%vertical line
                line([rho rho],[1 size(myimage,1)], 'Color', 'r');
            else%non vertical line
                y0=(rho-x0*cosd(theta))/sind(theta);
                yend=(rho-xend*cosd(theta))/sind(theta);
                line([x0 xend], [y0 yend], 'Color','r');
            end
            %}
            %%{
            if theta==0%for vertical line
                for idy=1:size(myimage,1)%set each y value
                    houghimage(idy,rho)=255;%at certain x value white
                end
            else %theta!=0 %for non vertical line
                for idx=x0:xend%for each x
                    idy=round((rho-idx*cosd(theta))/sind(theta));%calc corresponding y value
                    if idy>=1 && idy<=size(myimage,1)%check within height bounds
                        houghimage(idy,idx)=255;%set pixel white
                    end
                end
            end
            %}
        end
    end
end
count%display count accumulator>threshold
imshow(houghimage)
title('hough image')

%{
%from matlab
[H,theta,rho]=hough(myimage);
figure(4)
imshow(imadjust(rescale(H)),[],...
       'XData',theta,...
       'YData',rho,...
       'InitialMagnification','fit');
xlabel('\theta (degrees)')
ylabel('\rho')
axis on
axis normal 
hold on
colormap(gca,hot)

P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
x = theta(P(:,2))
y = rho(P(:,1))
plot(x,y,'s','color','black');

lines = houghlines(myimage,theta,rho,P,'FillGap',5,'MinLength',7);
figure(5), imshow(myimage), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
%}

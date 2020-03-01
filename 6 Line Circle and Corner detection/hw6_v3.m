clear
clc

name='img3.pgm';%img1, img2, img3
mode='circle';%line, circle
rawimage=imread(name);
myimage=double(imread(name));

figure(1)
imshow(uint8(myimage))
title('original image')

figure(2)
edgeimage=imgaussfilt(myimage,1);%bluring filter
edgeimage=edge(edgeimage,'canny');%canny, sobel
%edgeimage=mylaplacian(myimage);
%edgeimage=mysobel(myimage);
imshow(edgeimage)
title('edge image')

switch mode
    case 'line'
        [height,width] = size(myimage);%my image size
        maxdist = round(sqrt(height^2+width^2));%diagonal image distance
        thetas = -90+1:1:90;%all theta range
        rhos = -maxdist+1:1:maxdist;%all rho range
        numthetas = length(thetas);
        numrhos = length(rhos);
        accumulator = zeros(numrhos,numthetas);%initialize accumulator(y,x)
        for y=1:height
            for x=1:width
                if edgeimage(y,x)>0%if edge pixel
                    for k=1:numthetas%for each theta
                        rho=x*cosd(thetas(k))+y*sind(thetas(k));%calc corresponding rho
                        accumulator(round(rho)+maxdist,k)=accumulator(round(rho)+maxdist,k)+1;%vote
                    end
                end
            end
        end
        figure(3)
        imshow(imadjust(rescale(accumulator)),[],'XData',thetas,'YData',rhos,'InitialMagnification','fit')
        xlabel('\theta (degrees)')
        ylabel('\rho')
        title('accumulator')
        axis on
        axis normal
        colormap(gray)
        
        figure(4)
        houghimage=zeros(height,width);%init hough image
        threshold = 0.6*max(max(accumulator));%threshold
        [height,width]=size(accumulator);%my accumulator size
        count=0;
        %imshow(myimage)
        %hold on
        for y=1:height
            for x=1:width
                if accumulator(y,x)>threshold
                    rho=rhos(y);%take out rho
                    theta=thetas(x);%take out theta
                    sprintf("theta %d, rho %d",theta,rho);
                    count=count+1;
                    x0=1;%width start
                    xend=size(myimage,2);%width end
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
                            if idy>=1 && idy<=size(myimage,1)%check condition for image width > height 
                                houghimage(idy,idx)=255;%set pixel white
                            end
                        end
                    end
                    %}
                end
            end
        end
        %hold off
        count;
        imshow(houghimage)
        title('hough transform image')

        [height,width]=size(myimage);
        finalimage=cat(3,rawimage,rawimage,rawimage);%final image init
        for y=1:height
            for x=1:width
                if houghimage(y,x) && edgeimage(y,x)%if both output and edge image overlap
                    finalimage(y-1:y+1,x-1:x+1,1)=255;%set pixel neighborhood red
                    finalimage(y-1:y+1,x-1:x+1,2)=0;
                    finalimage(y-1:y+1,x-1:x+1,3)=0;
                end
            end
        end
        figure(5)
        imshow(finalimage)
        title('final image')

    case 'circle'
        [height,width]=size(myimage);
        a_axis=0+1:1:size(myimage,2);%same size as width
        b_axis=0+1:1:size(myimage,1);%same size as height
        radius=50+1:5:150;%for radius range for unknown radius 3D
        thetas=0+1:1:360;%for 0-360 degrees
        numthetas=length(thetas);
        %accumulator=zeros(length(b_axis),length(a_axis));%same dimensions as image(row,col)%2D
        accumulator=zeros(length(b_axis),length(a_axis),length(radius));%same dimensions as image(row,col) 3D
        for y=1:height
            for x=1:width
                if edgeimage(y,x)>0%for each edge pixel
                    for z=1:length(radius)%for unknown radius 3D
                        r=radius(z);%for unknown radius 3D
                        %r=100;%for static radius 2D
                        for k=1:numthetas%for 0-360 degrees
                            a=x-r*cosd(thetas(k));%circle parametric equation
                            b=y-r*sind(thetas(k));%for certain x,y get a,b pair
                            if a>=1 && a<=size(myimage,2) && b>=1 && b<=size(myimage,1)%check within boundary
                                %accumulator(round(b),round(a))=accumulator(round(b),round(a))+1;%2D
                                accumulator(round(b),round(a),z)=accumulator(round(b),round(a),z)+1;%3D
                            end
                        end
                    end%for 3D
                end
            end
        end
        figure(3)
        imshow(imadjust(rescale(accumulator(:,:,1))),[],'XData',a_axis,'YData',b_axis,'InitialMagnification','fit')%2D only
        xlabel('a_axis')
        ylabel('b_axis')
        title('accumulator')
        axis on
        axis normal
        colormap(gray)

        houghimage=zeros(height,width);%init output image
        %threshold = .9*max(max(accumulator));%threshold 2D
        threshold = .8*max(max(max(accumulator)));%threshold 3D
        [height,width,depth]=size(accumulator);%my accumulator size
        count=0;
        %r=100;%for static radius 2D
        for i=1:height%for b_axis
            for j=1:width%for a_axis
                for m=1:depth%for radius 3D
                    %if accumulator(i,j)>threshold%above threshold 2D
                    if accumulator(i,j,m)>threshold%above threshold 3D
                        b=b_axis(i);%take out b
                        a=a_axis(j);%take out a
                        r=radius(m);%take out r 3D
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
                end%for 3D
            end
        end
        count%display draw count from accumulator>threshold
        figure(4)
        imshow(houghimage)
        title('hough image')
        axis on
        
        [height,width]=size(myimage);
        finalimage=cat(3,rawimage,rawimage,rawimage);%final image init
        for y=1:height
            for x=1:width
                if houghimage(y,x) && edgeimage(y,x)%if both output and edge image overlap
                    finalimage(y-1:y+1,x-1:x+1,1)=255;%set pixel neighborhood red
                    finalimage(y-1:y+1,x-1:x+1,2)=0;
                    finalimage(y-1:y+1,x-1:x+1,3)=0;
                end
            end
        end
        figure(5)
        imshow(finalimage)
        title('final image')
        
    otherwise
        error('mode error')
end

function y=mysobel(myimage)
    Gx = [-1 0 1;%gradient in x direction
          -2 0 2;
          -1 0 1];
    Gy = [-1 -2 -1;%gradient in y direction
           0  0  0;
           1  2  1];
    [row,col]=size(myimage);
    mag=zeros(row,col);%gradient magnitude image init
    for i=2:row-1%ignore border
        for j=2:col-1%ignore border
            Sx=sum(sum(Gx.*myimage(i-1:i+1,j-1:j+1)));%calc subimage
            Sy=sum(sum(Gy.*myimage(i-1:i+1,j-1:j+1)));%calc subimage
            mag(i,j)=sqrt(Sx.^2+Sy.^2);%gradiant magnitude image
        end
    end
    threshold=255*.9;%threshold
    outputimage=zeros(row,col);%output image init
    %%{
    for i=1:row
        for j= 1:col
            if mag(i,j)>threshold
                outputimage(i,j)=mag(i,j);%if over threshold keep
            else
                outputimage(i,j)=0;%else throw away
            end
        end
    end
    %}
    y=outputimage;%output image after threshold
end

function y=mylaplacian(myimage)
    kernal=[-1 -1 -1;%kernal
            -1  8 -1;
            -1 -1 -1];
    [row,col]=size(myimage);
    mag = zeros(row,col);%magnitude image init
    for i=2:row-1%ignore border
        for j=2:col-1%ignore border
            S=sum(sum(kernal.*myimage(i-1:i+1,j-1:j+1)));%calc subimage
            mag(i,j)=S;%magnitude image
        end
    end
    threshold=255*.9;%set threshold
    output=zeros(row,col);%output image init
    for i=1:row
        for j=1:col
            if mag(i,j)>threshold%check threshold
                output(i,j)=mag(i,j);%keep value
            else
                output(i,j)=0;%throw away value
            end
        end
    end
    y=output;
end

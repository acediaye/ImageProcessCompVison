function y = myhist(image)
    %having an array of 0-255 intensity and counting the number of pixels
    %that goes into each element
    graycount=zeros(1,256);%vector[256] to store pixel count
    [row,col]=size(image);
    for i=1:row%loops each pixel, sees intensity value, ++count at corresponding intensity
        for j=1:col
            intensity=image(i,j);
            graycount(intensity+1)=graycount(intensity+1)+1;%maps intensity 0 to index 1, shifts everying by 1
        end
    end
    for i=1:256%rescale pixel count to % pixels
       graycount(i)=graycount(i)/(row*col);
    end
    figure(1)
    bar(graycount)
    xlabel('Grayscale 0-255')
    ylabel('Pixel 0-1')
    title('Normalized histogram')
    y=graycount;%return vector for normalized histogram
end


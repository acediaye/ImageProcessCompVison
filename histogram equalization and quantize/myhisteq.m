function y = myhisteq(image)
    graycount=zeros(1,256);%vector[256] of 0-255 intensity to store pixel count
    [row,col]=size(image);
    for i=1:row%loops each pixel, sees intensity value, ++count at corresponding intensity index
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
    
    cumusum=0;
    Trans=zeros(1,256);%transform vector
    output=zeros(1,256);%s
    histeqimage=zeros(row,col);%display equalized image
    L=256-1;%number of gray levels
    for i=1:256%cumulative sum of all previous values * gray levels
        cumusum=cumusum+graycount(i);
        Trans(i)=cumusum;
        output(i)=round(Trans(i)*L);
    end
    for i=1:row%mapping to new gray level
        for j=1:col
            histeqimage(i,j)=output(image(i,j));%for each pixel find matching new intensity
        end
    end
    
    graycount2=zeros(1,256);%vector[256] of 0-255 intensity to store pixel count
    [row,col]=size(histeqimage);
    for i=1:row%loops each pixel, sees intensity value, ++count at corresponding intensity index
        for j=1:col
            intensity=histeqimage(i,j);
            graycount2(intensity+1)=graycount2(intensity+1)+1;%maps intensity 0 to index 1, shifts everying by 1
        end
    end
    for i=1:256%rescale pixel count to % pixels
       graycount2(i)=graycount2(i)/(row*col);
    end
   
    figure(2)
    bar(output) 
    xlabel('Grayscale 0-255')
    ylabel('Pixel count')
    title('cumulative distribution function')
    figure(3)
    bar(graycount2)
    xlabel('Grayscale 0-255')
    ylabel('Pixel 0-1')
    title('Equalized normalized histogram')
    
    %%{
    figure(4)
    imshow(histeqimage,[0 255])
    title('myhisteq')
    %{
    figure(5)
    imshow(image,[0 255])
    title('original')
    figure(5)
    J=histeq(image);
    imshow(J,[0 255])
    title('histeq')
    %}
    
    y=graycount2;%return vector for normalized equalized histogram
end
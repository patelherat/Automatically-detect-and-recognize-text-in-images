# Automatically-detect-and-recognize-text-in-images MATLAB demo
Firstly, Maximally Stable Extremal Regions(MSER) is used to find the text regions. By this the regions which does not contain text are also highlighted. It can be removed by geometric properties(eccentricity, euler number, extent, solidity) or stroke width variation. The values of geometric properties needs to be changed for different images. Then bounding box is drawn for every character. A chain of overlapping bounding boxes indicates a word. Afterwards, the whole text region will be represented by bounding box. The detected text will then be recognized by using OCR function.

Step 1:- Detect text regions using MSER 

![a](https://user-images.githubusercontent.com/20256767/95005166-96feb000-05c2-11eb-9bc1-16fc4fc66ea6.png)


Step 2:- Remove non-text regions using geometric properties

Step 3:- Remove non-text regions based on stroke width variation

Step 4:- Merge text regions

Step 5:- Recognize detected text using OCR


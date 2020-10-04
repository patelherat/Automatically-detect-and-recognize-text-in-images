# Automatically-detect-and-recognize-text-in-images MATLAB demo
Firstly, Maximally Stable Extremal Regions(MSER) is used to find the text regions. By this the regions which does not contain text are also highlighted. It can be removed by geometric properties(eccentricity, euler number, extent, solidity) or stroke width variation. The values of geometric properties needs to be changed for different images. Then bounding box is drawn for every character. A chain of overlapping bounding boxes indicates a word. Afterwards, the whole text region will be represented by bounding box. The detected text will then be recognized by using OCR function.

Step 1:- Detect text regions using MSER 

![a](https://user-images.githubusercontent.com/20256767/95005166-96feb000-05c2-11eb-9bc1-16fc4fc66ea6.png)


Step 2:- Remove non-text regions using geometric properties

![b](https://user-images.githubusercontent.com/20256767/95005167-9a923700-05c2-11eb-9d26-7313a2957b03.png)


Step 3:- Remove non-text regions based on stroke width variation

![c](https://user-images.githubusercontent.com/20256767/95005170-9d8d2780-05c2-11eb-9a3b-1eac21699e94.png)

![d](https://user-images.githubusercontent.com/20256767/95005174-a0881800-05c2-11eb-94d4-69bd82bdbc68.png)


Step 4:- Merge text regions

![e](https://user-images.githubusercontent.com/20256767/95005177-a3830880-05c2-11eb-8a28-6e59706e0da0.png)


Step 5:- Recognize detected text using OCR

![f](https://user-images.githubusercontent.com/20256767/95005181-b269bb00-05c2-11eb-9988-244ec40f76cc.png)


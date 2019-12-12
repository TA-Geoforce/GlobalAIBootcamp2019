# GlobalAIBootcamp2019
AI from Space using Azure presentation and source code


Introduction to technologies and frameworks for Deep Learning using satellite data and moving to production with Azure.



Create image tageoforce/robosat.pinkrsp


```bash
docker build -t tageoforce/robosat.pink .
```
and run docker compose

```bash
docker-compose up
```

or
```
docker run -it --rm  -v $PWD/src:/src --runtime=nvidia --ipc=host tageoforce/robosat.pink bash
```



For clean start use that
```
docker run -it --rm  python:3.6-buster bash
```


Classes
 - wooden pole
 - lighting pole
 - big double electrical wooden pole
 - big electrical wooden pole
 - basketball pole

 Train dataset:
 0228042975 

 Test dataset:
 0228042960

1. Step
Since we have already tiles in `srv/tiles/0228042975` we are going to use the cover to be created a csv output path

```
cd data
rsp cover --dir palairos/images palairos/images/cover
```

2. Step
Generate labels

```
rsp rasterize --geojson palairos/labels.geojson --type label --config model-unet.toml --cover palairos/images/cover palairos/labels
```

3. Step
Create a Training DataSet and spliting
```
# Create Training DataSet
awk '$2 > 0 { print $1 }' palairos/labels/instances_label.cover > palairos/instances.cover
awk '$2 == 0 { print $1 }' palairos/labels/instances_label.cover > palairos/no_instance.cover
sort -R palairos/no_instance.cover | head -n 4000 > palairos/no_instance_subset.cover
cat palairos/instances.cover palairos/no_instance_subset.cover > palairos/cover

rsp cover --cover palairos/cover --splits 90/10 palairos/training/cover palairos/validation/cover
rsp subset --dir palairos/images --cover palairos/training/cover palairos/training/images
rsp subset --dir palairos/labels --cover palairos/training/cover palairos/training/labels
rsp subset --dir palairos/images --cover palairos/validation/cover palairos/validation/images
rsp subset --dir palairos/labels --cover palairos/validation/cover palairos/validation/labels

```


4. Step
Training
```
rsp train --config model-unet.toml --epochs 1 --workers 8 --lr 0.000025 palairos palairos/pth

```


5. Retriveve and tile Predict Imagery

```
rsp cover --dir predict/images predict/images/cover
rsp rasterize --config model-unet.toml --geojson predict/test.geojson --cover predict/images/cover --type wp predict/osm
```

6. Predict

```
rsp predict --config model-unet.toml --checkpoint ds/pth/checkpoint-00003.pth predict predict/masks
```

7. Compare

```
rsp compare --images predict/images predict/osm predict/masks --mode stack predict/compare
rsp compare --mode list --geojson --labels predict/osm --masks predict/masks --maximum_qod 80 predict/compare/tiles.json


rsp compare --mode side --images predict/images predict/compare --labels predict/osm --masks predict/masks --maximum_qod 80 predict/compare_side

```

8. Vectorize prediction masks

```
rsp vectorize --config model-unet.toml --type wp predict/masks predict/wooden.poles.geojson
```





# Run mapbox-robosat

```
docker run --runtime=nvidia -it --rm -v $PWD/data:/data --ipc=host mapbox/robosat:v1.1.0-gpu 
./rs train --model /data/model.toml --dataset /data/dataset.toml --workers 8
```


# Docker pytorch using GPU

```
docker pull anibali/pytorch:cuda-9.0
docker run -it --rm --runtime=nvidia anibali/pytorch:cuda-9.0
```

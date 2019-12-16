FROM ta-geoforce/raster-vision:pytorch-0.10


COPY requirements.txt /
RUN pip install -r /requirements.txt

COPY  ./experiment/tiny_spacenet.py /

ENV PATH=$PATH:/src
ENV PYTHONPATH /src
ADD ./ /src
WORKDIR /src/

FROM jupyter/all-spark-notebook:bbfb8aad625b
LABEL authoer="Eyad Sibai <eyad.alsibai@gmail.com>"

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -qq update && apt-get -qq install -y libprotobuf-dev libleveldb-dev libgl1-mesa-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler libarmadillo-dev \
        binutils-dev libleptonica-dev && \
apt-get -qq install -y --no-install-recommends git libav-tools cmake build-essential \
# needed for tessarct
automake libtool autoconf-archive autoconf automake libtool pkg-config libpng12-dev libjpeg8-dev libtiff5-dev zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev \
libopenblas-dev libopencv-dev zlib1g-dev libboost-all-dev unzip libssl-dev libzmq3-dev portaudio19-dev \
libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler \
fonts-dejavu gfortran gcc \
&& apt-get -qq autoremove -y && apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

USER $NB_USER
RUN conda config --system --add channels conda-forge --add channels glemaitre --add channels distributions --add channels maciejkula --add channels datamicroscopes --add channels ioam --add channels r && conda config --set channel_priority false
COPY files/environment.yaml environment.yaml
RUN conda env update --file=environment.yaml --quiet \
    && conda remove qt pyqt --quiet --yes --force \
    && conda clean -l -tipsy && rm -rf "$HOME/.cache/pip/*" && rm environment.yaml

# USER root
# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
# ENV JULIA_PKGDIR=/opt/julia


# # Install julia 0.6
# RUN mkdir -p $JULIA_PKGDIR && \
#     curl -s -L https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.0-linux-x86_64.tar.gz | tar -C $JULIA_PKGDIR -x -z --strip-components=1 -f -
# RUN echo '("JULIA_LOAD_CACHE_PATH" in keys(ENV)) && unshift!(Base.LOAD_CACHE_PATH, ENV["JULIA_LOAD_CACHE_PATH"])' >> $JULIA_PKGDIR/etc/julia/juliarc.jl
# RUN echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> $JULIA_PKGDIR/etc/julia/juliarc.jl
# RUN chown -R $NB_USER:users $JULIA_PKGDIR

# ENV PATH=$PATH:$JULIA_PKGDIR/bin
# USER $NB_USER
# # Add Julia packages
# # Install IJulia as jovyan and then move the kernelspec out
# # to the system share location. Avoids problems with runtime UID change not
# # taking effect properly on the .local folder in the jovyan home dir.
# RUN julia -e 'Pkg.init()' && \
#     julia -e 'Pkg.update()' && \
#     julia -e 'Pkg.add("HDF5")' && \
#     julia -e 'Pkg.add("Gadfly")' && \
#     julia -e 'Pkg.add("RDatasets")' && \
#     julia -e 'Pkg.add("IJulia")' && \
#     # Precompile Julia packages \
#     julia -e 'using HDF5' && \
#     julia -e 'using Gadfly' && \
#     julia -e 'using RDatasets' && \
#     julia -e 'using IJulia'
# COPY files/julia_packages.jl julia_packages.jl

# RUN julia julia_packages.jl && \
#     # move kernelspec out of home \
# RUN mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
#     chmod -R go+rx $CONDA_DIR/share/jupyter && \
#     rm -rf $HOME/.local && \
#     fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter
## && rm julia_packages.jl

# install R packages
# RUN conda install --quiet --yes \
#     'r-essentials' \
#     'r-devtools'\
#     'r-base'\
#     'r-irkernel'\
#     'r-plyr'\
#     'r-shiny'\
#     'r-tidyverse'\
#     'r-markdown'\
#     'r-forecast'\
#     'r-reshape2'\
#     'r-randomforest'\
#     'r-caret'\
#     'r-ggplot2'\
#     'rpy2' \
#     'r-rsqlite' \
#     'r-caret' \
#     'r-rcurl' \
#     'r-tseries' \
#     'r-survival' \
#     'r-rstan' \
#     'r-rocr' \
#     'r-lme4' \
#     'r-kernsmooth' \
#     'r-glmnet' \
#     'r-ggplot2' \
#     'r-modelmetrics' \
#     'r-e1071' \
#     'r-anomalydetection' \
#     'r-rcpp ' \
#     'r-crayon' && conda clean -tipsy && fix-permissions $CONDA_DIR

# ENV RLIB=$CONDA_DIR/lib/R/library

# COPY files/r_packages.R r_packages.R
# RUN Rscript r_packages.R && rm r_packages.R && rm -rf '/tmp/*'

# ## Set Renviron to get libs from base R install
#RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> $CONDA_DIR/lib/R/etc/Renviron

# ## Set default CRAN repo
# RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /usr/local/lib/R/etc/Rprofile.site



USER $NB_USER

# Activate ipywidgets extension in the environment that runs the notebook server
# Required to display Altair charts in Jupyter notebook
RUN jupyter-nbextension enable nbextensions_configurator/config_menu/main
RUN jupyter-nbextension enable contrib_nbextensions_help_item/main
RUN jupyter-nbextension enable autosavetime/main
RUN jupyter-nbextension enable code_prettify/code_prettify
RUN jupyter-nbextension enable table_beautifier/main
RUN jupyter-nbextension enable toc2/main
RUN jupyter-nbextension enable spellchecker/main
RUN jupyter-nbextension enable toggle_all_line_numbers/main
RUN jupyter-nbextension enable execute_time/ExecuteTime
RUN jupyter-nbextension enable notify/notify
RUN jupyter-nbextension enable codefolding/main
RUN jupyter-nbextension enable varInspector/main
RUN jupyter-nbextension enable nbextensions_configurator/tree_tab/main
RUN jupyter-nbextension enable tree-filter/index
RUN jupyter-nbextension enable codefolding/edit
RUN jupyter-nbextension enable jupyter-js-widgets/extension

# && python -m jupyterdrive --mixed --user

# Configure ipython kernel to use matplotlib inline backend by default
RUN mkdir -p $HOME/.ipython/profile_default/startup
COPY files/mplimportnotebook.py $HOME/.ipython/profile_default/startup/

RUN mkdir -p $HOME/.config/matplotlib && echo 'backend: agg' > $HOME/.config/matplotlib/matplotlibrc
COPY files/ipython_config.py $HOME/.ipython/profile_default/ipython_config.py

# RUN python -m nltk.downloader all \
#     && find $HOME/nltk_data -type f -name "*.zip" -delete
#RUN python -m spacy download en
# RUN python -m textblob.download_corpora

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot"
RUN jt -t onedork -T -N -vim -lineh 140 -tfs 11
ENV PATH $HOME/bin:$PATH

# tensorflow board
EXPOSE 6006

# install fasttext
RUN mkdir $HOME/bin
RUN git clone --depth 1 https://github.com/facebookresearch/fastText.git && \
    cd fastText && make && mv fasttext $HOME/bin && cd .. \
    && rm -rf fastText

# Regularized Greedy Forests
RUN wget https://github.com/fukatani/rgf_python/releases/download/0.2.0/rgf1.2.zip && \
    unzip -q rgf1.2.zip && \
    cd rgf1.2 && \
    make && \
    mv bin/rgf $HOME/bin && \
    cd .. && \
    rm -rf rgf*

# Install Torch7
# RUN git clone --depth 1 --recursive https://github.com/torch/distro.git ~/torch
# USER root
# RUN cd /home/$NB_USER/torch && bash install-deps && apt-get autoremove -y && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# USER $NB_USER
# RUN cd /home/$NB_USER/torch && ./install.sh -b \
#     && export LUA_PATH='$HOME/.luarocks/share/lua/5.1/?.lua;$HOME/.luarocks/share/lua/5.1/?/init.lua;$HOME/torch/install/share/lua/5.1/?.lua;$HOME/torch/install/share/lua/5.1/?/init.lua;./?.lua;$HOME/torch/install/share/luajit-2.1.0-alpha/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua' \
#     && export LUA_CPATH='$HOME/.luarocks/lib/lua/5.1/?.so;$HOME/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so' \
#     && export PATH=$HOME/torch/install/bin:$PATH \
#     && export LD_LIBRARY_PATH=$HOME/torch/install/lib:$LD_LIBRARY_PATH \
#     && export DYLD_LIBRARY_PATH=$HOME/torch/install/lib:$DYLD_LIBRARY_PATH \
#     # install torch-nn
#     && luarocks install nn \
#     # install iTorch
#     && git clone --depth 1 https://github.com/facebook/iTorch.git && \
#     cd iTorch && \
#     luarocks make \
#     # clean up
#     && cd /home/$NB_USER/torch && ./clean.sh


# Vowpal wabbit
RUN git clone --depth 1 https://github.com/JohnLangford/vowpal_wabbit.git && \
    cd vowpal_wabbit && \
    make vw && \
    make spanning_tree && \
    cp vowpalwabbit/vw $HOME/bin/ && \
    cp vowpalwabbit/active_interactor $HOME/bin/ && \
    cp cluster/spanning_tree $HOME/bin/ && \
    cd .. && rm -rf vowpal_wabbit

# libfm
RUN git clone --depth 1 https://github.com/srendle/libfm.git && cd libfm && make all && \
    mv bin/* $HOME/bin/ && cd .. && rm -rf libfm

# fast_rgf
RUN git clone --depth 1 https://github.com/baidu/fast_rgf.git && cd fast_rgf && \
    sed -i '10 s/^##*//' CMakeLists.txt && \
    cd build && cmake .. && make && make install && cd .. && mv bin/* $HOME/bin && \
    cd .. && rm -rf fast_rgf

USER $NB_USER

RUN git clone --depth 1 https://github.com/PAIR-code/facets.git && cd facets && jupyter nbextension install facets-dist/ --user
ENV PYTHONPATH $HOME/facets/facets_overview/python/:$PYTHONPATH
RUN git clone --depth 1 https://github.com/guestwalk/libffm.git && cd libffm && make && cp ffm-predict $HOME/bin/ && cp ffm-train $HOME/bin/ && cd .. && rm -rf libffm

# RUN git clone https://github.com/alno/batch-learn.git && cd batch-learn && mkdir build && cd build && cmake .. && make  && cp batch-learn $HOME/bin/ && cd ../.. && rm -rf batch-learn

RUN git clone --depth 1 https://github.com/jeroenjanssens/data-science-at-the-command-line.git && mv data-science-at-the-command-line/tools/* $HOME/bin/ && \
rm -rf data-science-at-the-command-line

#RUN python -c "from keras.applications.resnet50 import ResNet50; ResNet50(weights='imagenet')"
#RUN python -c "from keras.applications.vgg16 import VGG16; VGG16(weights='imagenet')"
#RUN python -c "from keras.applications.vgg19 import VGG19; VGG19(weights='imagenet')"
#RUN python -c "from keras.applications.inception_v3 import InceptionV3; InceptionV3(weights='imagenet')"
#RUN python -c "from keras.applications.xception import Xception; Xception(weights='imagenet')"

#Install Caffe
#  RUN git clone --depth 1 https://github.com/BVLC/caffe.git ~/caffe && \
#      cd ~/caffe && \
#      cat python/requirements.txt | xargs -n1 pip install && \
#      mkdir build && cd build && \
#      cmake -DCPU_ONLY=1 -DOPENCV_VERSION=3 -DUSE_NCCL=1 -Dpython_version=3 .. && \
#      make -j"$(nproc)" all && \
#      make install

# # Set up Caffe environment variables
# ENV CAFFE_ROOT=~/caffe
# ENV PYCAFFE_ROOT=$CAFFE_ROOT/python
# ENV PYTHONPATH=$PYCAFFE_ROOT:$PYTHONPATH
# ENV PATH=$CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH

# RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig


# RUN git clone --recursive https://github.com/caffe2/caffe2.git
# RUN cd caffe2 && mkdir build && cd build \
#     && cmake .. \
#     -DUSE_CUDA=OFF \
#     -DUSE_NNPACK=OFF \
#     -DUSE_ROCKSDB=OFF \
#     && make -j"$(nproc)" install \
#     && ldconfig \
#     && make clean \
#     && cd .. \
#     && rm -rf build

# ENV PYTHONPATH /usr/local:$PYTHONPATH
RUN ipython -c 'import disp; disp.install()'

COPY files/xcessiv_config.py $HOME/.xcessiv/config.py


# RUN wget http://www.mlpack.org/files/mlpack-2.2.5.tar.gz && \
#     tar xzf mlpack-2.2.5.tar.gz && rm mlpack-2.2.5.tar.gz && \
#     cd mlpack-2.2.5 && mkdir build && cd build && \
#     cmake -D DEBUG=OFF -D PROFILE=OFF ../ && \
#     make && make install

# ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH


# RUN git clone https://github.com/tesseract-ocr/tesseract && cd tesseract && ./autogen.sh && \
#     ./configure --prefix=$HOME/local/ && make install

# ENV TESSDATA_PREFIX  $HOME/tessdata

# RUN mkdir tessdata && cd tessdata && \
#     wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata && \
#     wget https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata && \
#     wget https://github.com/tesseract-ocr/tessdata/raw/4.00/ara.traineddata && \
#     wget https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata

#installed by python
# RUN git clone https://github.com/davisking/dlib && cd dlib && mkdir build && cd build && cmake .. && cmake --build . && cd .. && python setup.py install


RUN mkdir kepler_mapper && cd kepler_mapper && wget https://raw.githubusercontent.com/MLWave/kepler-mapper/master/km.py
# RUN mkdir corex && cd corex && \
#     wget https://raw.githubusercontent.com/gregversteeg/bio_corex/master/corex.py && \
#     wget https://raw.githubusercontent.com/gregversteeg/bio_corex/master/vis_corex.py && \
#     wget https://raw.githubusercontent.com/gregversteeg/corex_topic/master/corex_topic.py && \
#     wget https://raw.githubusercontent.com/gregversteeg/corex_topic/master/vis_topic.py

# RUN mkdir empca && cd empca && wget https://raw.githubusercontent.com/sbailey/empca/master/empca.py

ENV PYTHONPATH $HOME/kepler_mapper:$HOME/corex:$HOME/empca:${PYTHONPATH}

ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info --packages com.spotify:featran-core_2.11:0.1.9,com.spotify:featran-numpy_2.11:0.1.9
#com.airbnb.aerosolve:core:0.1.103 add bintray repo
#com.github.haifengl:smile-scala:1.4.0

#npm install -g ijavascript
#ijsinstall
#npm install deeplearn
#curl -fsS https://dlang.org/install.sh | bash -s ldc
#source ~/dlang/ldc-{VERSION}/activate

# RUN wget https://github.com/google/or-tools/releases/download/v6.4/or-tools_python_examples_v6.4.4495.zip -O ortools.zip && \
# unzip ortools.zip && cd ortools_examples && make install && cd .. && rm -rf ortools


EXPOSE 1994
CMD ["xcessiv"]

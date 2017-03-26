FROM rocker/tidyverse:3.3.3
MAINTAINER "ymattu"

## Add LaTeX, rticles and bookdown support
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ghostscript \
    imagemagick \
    ## system dependency of hadley/pkgdown
    libmagick++-dev \
    ## system dependency of hunspell (devtools)
    libhunspell-dev \
    ## R CMD Check wants qpdf to check pdf sizes, or iy throws a Warning
    qpdf \
    ## for git via ssh key
    ssh \
    ## for building pdfs via pandoc/LaTeX
    lmodern \
    texlive-fonts-recommended \
    texlive-humanities \
    texlive-latex-extra \
    texinfo \
    ## just because
    less \
    vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  ## R manuals use inconsolata font, but texlive-fonts-extra is huge, so:
  && cd /usr/share/texlive/texmf-dist \
  && wget http://mirrors.ctan.org/install/fonts/inconsolata.tds.zip \
  && unzip inconsolata.tds.zip \
  && rm inconsolata.tds.zip \
  && echo "Map zi4.map" >> /usr/share/texlive/texmf-dist/web2c/updmap.cfg \
  && mktexlsr \
  && updmap-sys \
  ## And some nice R packages for publishing-related stuff
  && . /etc/environment \
  && install2.r --error --repos $MRAN --deps TRUE \
    bookdown rticles rmdshower

## For Japanse LaTeX environment
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    ibus-mozc \
    manpages-ja
RUN apt-get install -y --no-install-recommends imagemagick \
    texlive \
    texlive-lang-cjk \
    texlive-luatex \
    texlive-xetex \
    xdvik-ja \
    dvipsk-ja \
    gv \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    && apt-get clean \
    && cd /usr/share/texlive/texmf-dist \
    && wget http://download.forest.impress.co.jp/pub/library/i/ipafont/10483/IPAfont00303.zip \
    && unzip IPAfont00303.zip \
    && echo "Map zi4.map" >> /usr/share/texlive/texmf-dist/web2c/updmap.cfg \
    && mktexlsr \
    && updmap-sys

## Install some external dependencies. 
RUN apt-get update \
  && apt-get install -y --no-install-recommends -t unstable \
    default-jdk \
    default-jre \
    gdal-bin \
    icedtea-netx \
    libatlas-base-dev \
    libcairo2-dev \
    libgsl0-dev \
    libgdal-dev \
    libgeos-dev \
    libgeos-c1v5 \
    librdf0-dev \
    libssl-dev \
    libmysqlclient-dev \
    libpq-dev \
    libsqlite3-dev \
    libv8-dev \
    libxcb1-dev \
    libxdmcp-dev \
    libxml2-dev \
    libxslt1-dev \
    libxt-dev \
    netcdf-bin \
    r-cran-rgl \
  && R CMD javareconf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## Mecab
RUN wget -O mecab-0.996.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" ;\
    tar -xzf mecab-0.996.tar.gz ;\
    cd mecab-0.996; ./configure --enable-utf8-only; make; make install; ldconfig

## Ipadic
RUN wget -O mecab-ipadic-2.7.0-20070801.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM" ;\
    tar -xzf mecab-ipadic-2.7.0-20070801.tar.gz ;\
    cd mecab-ipadic-2.7.0-20070801; ./configure --with-charset=utf8; make; make install ;\
    echo "dicdir = /usr/local/lib/mecab/dic/ipadic" > /usr/local/etc/mecabrc

## Clean up
RUN apt remove -y build-essential ;\
    rm -rf rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* ;\
    rm -rf mecab-0.996.tar.gz* ;\
    rm -rf mecab-ipadic-2.7.0-20070801*

## Change environment to Japanese(Character and DateTime)
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
RUN sed -i '$d' /etc/locale.gen \
  && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen ja_JP.UTF-8 \
  && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
RUN /bin/bash -c "source /etc/default/locale"
RUN ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

## Install additional R packages
RUN Rscript -e "install.packages(c('githubinstall','rstan','ggmcmc','rstanarm','ellipse','hexbin','ggtern','mvtnorm','bda','Nippon','ggrepel','tm','slam'))"
RUN Rscript -e "install.packages('RMeCab',repos='http://rmecab.jp/R')"

CMD ["/init"]

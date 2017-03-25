FROM rocker/rstudio:latest
MAINTAINER "ymattu"

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    ibus-mozc \
    manpages-ja
RUN apt-get install -y --no-install-recommends imagemagick \
    lmodern \
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
    qpdf \
    r-cran-rgl \
    ssh \
  && R CMD javareconf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## Install the Hadleyverse packages (and some close friends).
RUN install2.r --error \
    broom \
    DiagrammeR \
    devtools \
    dplyr \
    ggplot2 \
    ggthemes \
    haven \
    httr \
    knitr \
    lubridate \
    packrat \
    pryr \
    purrr \
    reshape2 \
    rmarkdown \
    rmdformats \
    rticles \
    rvest \
    readr \
    readxl \
    testthat \
    tibble \
    tidyr \
    tufte \
    shiny \
    stringr \
    xml2

## Manually install (useful packages from) the SUGGESTS list of the above packages.
## (because --deps TRUE can fail when packages are added/removed from CRAN)
RUN install2.r --error \
    -r "https://cran.rstudio.com" \
    -r "http://www.bioconductor.org/packages/release/bioc" \
    base64enc \
    BiocInstaller \
    codetools \
    covr \
    data.table \
    downloader \
    gridExtra \
    gtable \
    hexbin \
    Hmisc \
    htmlwidgets \
    jpeg \
    Lahman \
    lattice \
    lintr \
    MASS \
    PKI \
    png \
    microbenchmark \
    mgcv \
    mapproj \
    maps \
    maptools \
    mgcv \
    nlme \
    nycflights13 \
    quantreg \
    Rcpp \
    rJava \
    roxygen2 \
    RMySQL \
    RPostgreSQL \
    RSQLite \
    testit \
    V8 \
    XML \
  && r -e 'source("https://raw.githubusercontent.com/MangoTheCat/remotes/master/install-github.R")$value("mangothecat/remotes")' \
  && r -e 'remotes::install_github("wesm/feather/R")' \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Mecab
RUN curl -O https://mecab.googlecode.com/files/mecab-0.996.tar.gz
RUN tar -xzf mecab-0.996.tar.gz
RUN cd mecab-0.996; ./configure --enable-utf8-only; make; make install; ldconfig

# Ipadic
RUN curl -O https://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz
RUN tar -xzf mecab-ipadic-2.7.0-20070801.tar.gz
RUN cd mecab-ipadic-2.7.0-20070801; ./configure --with-charset=utf8; make; make install
RUN echo "dicdir = /usr/local/lib/mecab/dic/ipadic" > /usr/local/etc/mecabrc

# Neologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
RUN cd mecab-ipadic-neologd
RUN ./bin/install-mecab-ipadic-neologd -n
RUN ./bin/install-mecab-ipadic-neologd --create_user_dic

# Clean up
RUN apt-get remove -y build-essential
RUN rm -rf mecab-0.996.tar.gz*
RUN rm -rf mecab-ipadic-2.7.0-20070801*

# Change environment to Japanese(Character and DateTime)
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
RUN sed -i '$d' /etc/locale.gen \
  && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen ja_JP.UTF-8 \
  && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
RUN /bin/bash -c "source /etc/default/locale"
RUN ln -sf  /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Install  additional R packages
RUN Rscript -e "install.packages(c('githubinstall','rstan','ggmcmc','rstanarm','ellipse','hexbin','ggtern','mvtnorm','bda','Nippon','ggrepel','tm','slam'))"
RUN Rscript -e "install.packages('RMeCab',repos='http://rmecab.jp/R')"

CMD ["/init"]

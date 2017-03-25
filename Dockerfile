FROM rocker/tidyverse:latest
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

# Mecab
RUN wget -O mecab-0.996.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE" ;\
    tar -xzf mecab-0.996.tar.gz ;\
    cd mecab-0.996; ./configure --enable-utf8-only; make; make install; ldconfig

# Ipadic
RUN wget -O mecab-ipadic-2.7.0-20070801.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM" ;\
    tar -xzf mecab-ipadic-2.7.0-20070801.tar.gz ;\
    cd mecab-ipadic-2.7.0-20070801; ./configure --with-charset=utf8; make; make install ;\
    echo "dicdir = /usr/local/lib/mecab/dic/ipadic" > /usr/local/etc/mecabrc

# Neologd
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
RUN mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y
RUN mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd --create_user_dic

# Clean up
RUN apt remove -y build-essential ;\
    rm -rf rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* ;\
    rm -rf mecab-0.996.tar.gz* ;\
    rm -rf mecab-ipadic-2.7.0-20070801*

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

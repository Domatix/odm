FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive.
ENV LANG C.UTF-8
ENV TZ=Europe/Madrid
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y \
    vim strace git curl nano tcl8.6-dev tk8.6-dev pkg-config fontconfig \
    python3-pip python3-all-dev python3-dev python3-setuptools python-tk python3-pypdf2 python3-dev virtualenv \
    libxslt-dev libzip-dev libldap2-dev libsasl2-dev libxslt1-dev libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev libtiff5-dev libjpeg8-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev liblcms2-utils libwebp-dev libyaml-dev \
    nodejs npm postgresql-client postgresql-contrib build-essential gdb
RUN curl -o wkhtmltox.tar.xz -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz \
	&& echo '3f923f425d345940089e44c1466f6408b9619562 wkhtmltox.tar.xz' | sha1sum -c - \
	&& tar xvf wkhtmltox.tar.xz \
	&& cp wkhtmltox/lib/* /usr/local/lib/ \
	&& cp wkhtmltox/bin/* /usr/local/bin/ \
	&& cp -r wkhtmltox/share/man/man1 /usr/local/share/man/
RUN npm install -g less less-plugin-clean-css
RUN pip3 install phonenumbers xmlsig workdays numpy unidecode passlib

FROM domatix/odoo:base

ENV DEBIAN_FRONTEND=noninteractive.
ENV LANG C.UTF-8 
ENV TZ=Europe/Madrid
ARG id 
ARG odoo_version
RUN useradd -m -d /opt/odoo -u $id -s /bin/bash odoo
RUN mkdir /opt/odoo/sources
RUN git clone --depth=1 --branch=$odoo_version https://github.com/odoo/odoo.git /opt/odoo/sources/odoo
RUN chown -R odoo:odoo /opt/odoo/sources/odoo
RUN pip3 install -r /opt/odoo/sources/odoo/doc/requirements.txt
RUN pip3 install -r /opt/odoo/sources/odoo/requirements.txt


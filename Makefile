ifeq ($(PREFIX),)
    PREFIX := /usr/bin
endif

current_dir = $(shell pwd)
install: 
	ln -s ${current_dir}/run.sh ${PREFIX}/cnt


update_conf: $(current_dir)/containers/*
	for file in $^; do \
		cp ${current_dir}/helper-scripts/* $${file}/custom ; \
	done


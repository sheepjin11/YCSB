CC=g++
CFLAGS=-std=c++17 -g -Wall -pthread -I./
LDFLAGS= -lpthread -ltbb -lhiredis -lsplinterdb -lrocksdb
SUBDIRS=core db
SUBCPPSRCS=$(wildcard core/*.cc) $(wildcard db/*.cc)
SUBCSRCS=$(wildcard core/*.c) $(wildcard db/*.c)
OBJECTS=$(SUBCPPSRCS:.cc=.o) $(SUBCSRCS:.c=.o)
EXEC=ycsbc

DATASET_EXCLUDES=db/rocks_db.cc db/redis_db.cc db/splinter_db.cc
DATASET_CPPSRCS=$(filter-out $(DATASET_EXCLUDES),$(SUBCPPSRCS))

all: $(SUBDIRS) $(EXEC)

$(SUBDIRS):
	$(MAKE) -C $@

$(EXEC): $(wildcard *.cc) $(OBJECTS)
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

datasets:
	$(CC) $(CFLAGS) -DYCSBC_MINIMAL $(wildcard *.cc) \
	    $(DATASET_CPPSRCS) $(SUBCSRCS) -lpthread -o $(EXEC)

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir $@; \
	done
	$(RM) $(EXEC)

.PHONY: $(SUBDIRS) $(EXEC) datasets clean


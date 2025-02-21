ifeq ($(origin CC),default)
  CC = g++
endif

PROJECT_NAME = simple-chess

CFLAGS ?= -O2 -g -std=c++20
OUT_O_DIR ?= build
COMMONINC = -I./include
SRC = ./src
ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

override CFLAGS += $(COMMONINC)

CSRC = main.cpp

# reproducing source tree in object tree
COBJ := $(addprefix $(OUT_O_DIR)/,$(CSRC:.cpp=.o))
DEPS = $(COBJ:.o=.d)

.PHONY: all
all: $(OUT_O_DIR)/$(PROJECT_NAME)

$(OUT_O_DIR)/$(PROJECT_NAME): $(COBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

# static pattern rule to not redefine generic one
$(COBJ) : $(OUT_O_DIR)/%.o : %.cpp
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(DEPS) : $(OUT_O_DIR)/%.d : %.cpp
	@mkdir -p $(@D)
	$(CC) -E $(CFLAGS) $< -MM -MT $(@:.d=.o) > $@

.PHONY: clean
clean:
	rm -rf $(COBJ) $(DEPS)

# targets which we have no need to recollect deps
NODEPS = clean

ifeq (0, $(words $(findstring $(MAKECMDGOALS), $(NODEPS))))
include $(DEPS)
endif

SRCS = libhwloc_helpers.c
OBJS = $(SRCS:.c=.o)
ifeq ($(shell uname), Darwin)
SUFFIX = dylib
else
SUFFIX = so
endif
EXE = libhwloc_helpers.$(SUFFIX)

INCDIRS = $(HWLOC_DIR:%=%/include)
LIBDIRS = $(HWLOC_DIR:%=%/lib)
LIBS = hwloc

CPPFLAGS = $(INCDIRS:%=-I%)
CFLAGS = -g -O
LDFLAGS = -g -O $(LIBDIRS:%=-L%)

ifeq ($(strip $(PREFIX)),)
$(error PREFIX is not defined)
endif

all: $(EXE)

%.o: %.c
ifeq ($(shell uname), Darwin)
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -c $*.c
else
	libtool --mode=compile --tag=CC $(CC) $(CPPFLAGS) $(CFLAGS) -c $*.c
endif

$(EXE): $(OBJS)
ifeq ($(shell uname), Darwin)
	libtool $(LIBDIRS:%=-L%) -dynamic -o $@ $^ $(LIBS:%=-l%)
else
	libtool --mode=link --tag=CC $(CC) $(LDFLAGS) -shared -rpath $(PREFIX)/lib $(LIBDIRS:%=-R%) -o $(@:%.$(SUFFIX)=%.la) $(^:%.o=%.lo) $(LIBS:%=-l%)
endif

install: $(EXE)
	install -d $(PREFIX)/lib
ifeq ($(shell uname), Darwin)
	install $^ $(PREFIX)/lib
else
	libtool --mode=install install $(^:%.$(SUFFIX)=%.la) $(PREFIX)/lib
endif

clean:
	rm -f $(OBJS) $(EXE)

.PHONY: all install clean

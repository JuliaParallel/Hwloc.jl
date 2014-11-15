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

all: $(EXE)

$(EXE): $(OBJS)
ifeq ($(shell uname), Darwin)
	libtool $(LIBDIRS:%=-L%) -dynamic -o $(@:%.$(SUFFIX)=%.la) $(^:%.o=%.lo) $(LIBS:%=-l%)
else
	libtool --mode=link --tag=CC $(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS:%=-l%)
endif

%.o: %.c
ifeq ($(shell uname), Darwin)
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -c $*.c
else
	libtool --mode=compile --tag=CC $(CC) $(CPPFLAGS) $(CFLAGS) -c $*.c
endif

ifneq ($(strip $(PREFIX)),)
install: $(EXE)
ifeq ($(shell uname), Darwin)
	install -d $(PREFIX)/lib
	install $^ $(PREFIX)/lib
else
	libtool --mode=install install -d $(PREFIX)/lib
	libtool --mode=install install $^ $(PREFIX)/lib
endif
endif

clean:
	rm -f $(OBJS) $(EXE)

.PHONY: all install clean

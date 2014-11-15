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
	libtool $(LIBDIRS:%=-L%) -dynamic -o $@ $^ $(LIBS:%=-l%)
else
	libtool --mode=link --tag=CC $(CC) $(LDFLAGS) -shared -o $@ $^ $(LIBS:%=-l%)
endif
%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -c $*.c

ifneq ($(strip $(PREFIX)),)
install: $(EXE)
	install -d $(PREFIX)/lib
	install $^ $(PREFIX)/lib
endif

clean:
	rm -f $(OBJS) $(EXE)

.PHONY: all install clean

SRCS = libhwloc_helpers.c
OBJS = $(SRCS:.c=.o)
ifeq ($(shell uname), Darwin)
SUFFIX = dylib
else
SUFFIX = so
endif
EXE = libhwloc_helpers.$(SUFFIX)

INCDIRS = $(HWLOC_DIRS:%=%/include)

all: $(EXE)
$(EXE): $(OBJS)
	libtool -dynamic -o $@ $^
%.o: %.c
	$(CC) $(INCDIRS:%=-I%) $(CPPFLAGS) -O $(CFLAGS) -fPIC -c $*.c

ifneq ($(strip $(PREFIX)),)
install: $(EXE)
	install -d $(PREFIX)/lib
	install $^ $(PREFIX)/lib
endif

clean:
	rm -f $(OBJS) $(EXE)

.PHONY: all install clean

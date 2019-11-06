CC = nasm 
LD = ld 
CCFLAGS = -f elf64

SRCDIR = src
OBJDIR = obj

SRC = ${wildcard ${SRCDIR}/*.asm}
OBJ = $(SRC:$(SRCDIR)/%.asm=$(OBJDIR)/%.o)

qsort: ${OBJ}
	${LD} ${LDFLAGS} ${OBJ} -o $@

${OBJDIR}/%.o: ${SRCDIR}/%.asm 
	${CC} ${CCFLAGS} $< -o $@

debug: CCFLAGS += -g -F dwarf
debug: LDFLAGS = -g
debug: qsort

.PHONY: clean

clean:
	rm -f ${OBJDIR}/*.o qsort

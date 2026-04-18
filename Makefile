AS = as
LD = ld

ASFLAGS = --64 -g
LDFLAGS = 

TARGET = mini-shell
SRC = ./src/main.s
OBJ = $(SRC:.s=.o)

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) $^ -o $@

%.o: %.s 
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -r $(OBJ) $(TARGET)

test: $(TARGET)
	./tests/test.sh

.PHONY: clean test

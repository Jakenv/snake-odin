#OBJS specifies which files to compile as part of the project
OBJS = snake.odin

OBJ_NAME = snake

#CC specifies which compiler we're using
CC = odin

#COMPILER_FLAGS specifies the additional compilation options we're using
# -w suppresses all warnings
COMPILER_FLAGS = -file

#This is the target that compiles our executable
all : $(OBJS)
	$(CC) build $(OBJS) $(COMPILER_FLAGS)

run :
	./$(OBJ_NAME)

clean :
	rm $(OBJ_NAME)

#include "fifo_model.h"

#include <stdlib.h>

static int *storage;
static int fifo_depth;
static int read_pointer;
static int write_pointer;
static int occupancy;

int fifo_model_init(int depth)
{
	int *new_storage;

	if (depth <= 0)
		return 0;

	new_storage = (int *)calloc((size_t)depth, sizeof(int));
	if (new_storage == NULL)
		return 0;

	free(storage);
	storage = new_storage;
	fifo_depth = depth;
	fifo_model_reset();
	return 1;
}

void fifo_model_reset(void)
{
	int index;

	read_pointer = 0;
	write_pointer = 0;
	occupancy = 0;
	for (index = 0; index < fifo_depth; ++index)
		storage[index] = 0;
}

int fifo_model_push(int data)
{
	if (storage == NULL || occupancy >= fifo_depth)
		return 0;

	storage[write_pointer] = data;
	write_pointer = (write_pointer + 1) % fifo_depth;
	++occupancy;
	return 1;
}

int fifo_model_pop(void)
{
	int data;

	if (storage == NULL || occupancy <= 0)
		return -1;

	data = storage[read_pointer];
	read_pointer = (read_pointer + 1) % fifo_depth;
	--occupancy;
	return data;
}

int fifo_model_is_empty(void)
{
	return occupancy == 0;
}

int fifo_model_is_full(void)
{
	return fifo_depth > 0 && occupancy == fifo_depth;
}

int fifo_model_count(void)
{
	return occupancy;
}

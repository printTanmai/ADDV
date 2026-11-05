#ifndef FIFO_MODEL_H
#define FIFO_MODEL_H

#ifdef __cplusplus
extern "C" {
#endif

int fifo_model_init(int depth);
void fifo_model_reset(void);
int fifo_model_push(int data);
int fifo_model_pop(void);
int fifo_model_is_empty(void);
int fifo_model_is_full(void);
int fifo_model_count(void);

#ifdef __cplusplus
}
#endif

#endif

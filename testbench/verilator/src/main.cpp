#include <iostream>
#include <verilated.h>
#include <Vtiny_rv.h>
#include "testbench.h"

#define DO_TRACE 1

void load_memory(FILE *fd, uint32_t* buffer) {
  size_t size = fread(buffer, 4, 65535, fd);
  printf("Loaded %d words\n", size);
}


int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  auto *tb = new TESTBENCH<Vtiny_rv>();

  FILE *f;
  if (argc > 1 && (f = fopen(argv[1], "rb"))!= nullptr) {
    load_memory(f, tb->m_core->tiny_rv__DOT__fetch__DOT__imem);
    fclose(f);
  } else {
    printf("WARN: No file loaded!\n");
  }

#if DO_TRACE
  tb->opentrace("trace.vcd");
#endif

  tb->reset();

  for (int i = 0; i < 100 * 1000; ++i) {
    tb->tick();
  }

#if DO_TRACE
  tb->close();
#endif

  return 0;
}
